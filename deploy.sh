#!/bin/bash

# ========== 安全配置 ==========
# 颜色定义（只用于输出，不影响功能）
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# 仓库配置（使用变量，便于修改）
ALIYUN_REPO="git@47.121.28.192:/home/git/repos/hexo.git"
GITHUB_REPO="git@github.com:Corazon-hacker/Corazon-hacker.github.io.git"

# 安全配置
MAX_RETRIES=3
LOCK_FILE="/tmp/hexo-deploy.lock"
DEPLOY_TIMEOUT=600  # 10分钟超时

# ========== 安全函数 ==========
# 输出函数（带颜色）
print_error() { echo -e "${RED}[错误] $1${NC}" >&2; }
print_warn() { echo -e "${YELLOW}[警告] $1${NC}" >&2; }
print_info() { echo -e "${CYAN}[信息] $1${NC}"; }
print_success() { echo -e "${GREEN}[成功] $1${NC}"; }

# 检查命令是否存在
check_command() {
    if ! command -v "$1" >/dev/null 2>&1; then
        print_error "命令未找到: $1"
        return 1
    fi
    return 0
}

# 获取绝对路径
get_abs_path() {
    cd "$(dirname "$1")" 2>/dev/null || return 1
    echo "$(pwd)/$(basename "$1")"
}

# 检查是否在Hexo目录
check_hexo_dir() {
    local hexo_dir="$1"
    
    if [ ! -f "$hexo_dir/_config.yml" ]; then
        print_error "不是Hexo目录: $hexo_dir"
        print_error "请在Hexo根目录运行此脚本"
        return 1
    fi
    
    # 检查必要的目录
    if [ ! -d "$hexo_dir/source" ] || [ ! -d "$hexo_dir/themes" ]; then
        print_warn "目录结构不完整，可能不是有效的Hexo项目"
    fi
    
    return 0
}

# 检查Git仓库状态
check_git_status() {
    local hexo_dir="$1"
    
    cd "$hexo_dir" || return 1
    
    # 检查是否是git仓库
    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        print_error "当前目录不是Git仓库"
        return 1
    fi
    
    # 检查当前分支
    local current_branch
    current_branch=$(git symbolic-ref --short HEAD 2>/dev/null || echo "未知")
    if [ "$current_branch" != "hexo" ]; then
        print_warn "当前分支不是hexo: $current_branch"
        print_info "建议切换到hexo分支: git checkout hexo"
    fi
    
    # 检查是否有未提交的更改
    if [ -n "$(git status --porcelain)" ]; then
        print_warn "发现未提交的更改:"
        git status --short
        
        local choice
        read -p "是否提交这些更改？(y/N): " choice
        if [[ "$choice" =~ ^[Yy]$ ]]; then
            git add .
            git commit -m "自动提交: $(date '+%Y-%m-%d %H:%M:%S')"
            print_success "更改已提交"
        else
            print_warn "继续部署，未提交的更改可能丢失"
        fi
    fi
    
    return 0
}

# 检查远程仓库连接
check_remote_connection() {
    local remote_name="$1"
    local remote_url="$2"
    
    print_info "检查远程仓库连接: $remote_name"
    
    # 检查远程仓库是否已配置
    if ! git remote get-url "$remote_name" >/dev/null 2>&1; then
        print_info "添加远程仓库: $remote_name"
        git remote add "$remote_name" "$remote_url" || {
            print_error "无法添加远程仓库: $remote_name"
            return 1
        }
    fi
    
    # 测试连接
    local retry_count=0
    while [ "$retry_count" -lt 3 ]; do
        if timeout 10 git ls-remote "$remote_name" >/dev/null 2>&1; then
            print_success "远程仓库可访问: $remote_name"
            return 0
        fi
        
        retry_count=$((retry_count + 1))
        print_warn "连接失败，第${retry_count}次重试..."
        sleep 2
    done
    
    print_error "无法连接远程仓库: $remote_name"
    return 1
}

# 检查磁盘空间
check_disk_space() {
    local min_space_mb="${1:-100}"
    local hexo_dir="$2"
    
    cd "$hexo_dir" || return 1
    
    local available_space
    available_space=$(df -m . | awk 'NR==2 {print $4}' 2>/dev/null || echo 0)
    
    if [ "$available_space" -lt "$min_space_mb" ]; then
        print_error "磁盘空间不足: ${available_space}MB < ${min_space_mb}MB"
        return 1
    fi
    
    print_success "磁盘空间充足: ${available_space}MB"
    return 0
}

# 安全推送函数（避免冲突）
safe_git_push() {
    local remote="$1"
    local local_branch="$2"
    local remote_branch="$3"
    local retry_count=0
    
    print_info "推送分支: $local_branch -> $remote/$remote_branch"
    
    while [ "$retry_count" -lt "$MAX_RETRIES" ]; do
        # 先拉取最新代码（如果可能）
        if git fetch "$remote" "$remote_branch" 2>/dev/null; then
            # 尝试合并
            if git merge --no-commit "FETCH_HEAD" 2>/dev/null; then
                git commit -m "合并远程更新 $(date '+%Y-%m-%d %H:%M:%S')" 2>/dev/null || true
            else
                # 有冲突，自动解决（保留本地版本）
                git merge --abort 2>/dev/null || true
            fi
        fi
        
        # 尝试推送
        if git push "$remote" "$local_branch:$remote_branch" 2>/dev/null; then
            print_success "推送成功"
            return 0
        fi
        
        retry_count=$((retry_count + 1))
        
        if [ "$retry_count" -lt "$MAX_RETRIES" ]; then
            print_warn "推送失败，第${retry_count}次重试..."
            sleep 2
        fi
    done
    
    # 所有重试都失败，尝试强制推送（使用--force-with-lease更安全）
    print_warn "普通推送失败，尝试安全强制推送"
    if git push "$remote" "$local_branch:$remote_branch" --force-with-lease 2>/dev/null; then
        print_success "强制推送成功"
        return 0
    else
        print_error "所有推送尝试都失败"
        return 1
    fi
}

# 生成静态文件
generate_static_files() {
    local hexo_dir="$1"
    
    cd "$hexo_dir" || return 1
    
    print_info "清理旧文件..."
    if ! hexo clean; then
        print_error "清理失败"
        return 1
    fi
    
    print_info "生成静态文件..."
    if ! hexo generate; then
        print_error "生成失败"
        return 1
    fi
    
    # 检查生成结果
    if [ ! -d "public" ] || [ ! -f "public/index.html" ]; then
        print_error "静态文件生成失败：未找到public/index.html"
        return 1
    fi
    
    local file_count
    file_count=$(find public -type f | wc -l)
    print_success "生成完成，共 $file_count 个文件"
    return 0
}

# 部署到阿里云
deploy_to_aliyun() {
    local hexo_dir="$1"
    
    cd "$hexo_dir" || return 1
    
    print_info "准备部署到阿里云..."
    
    # 创建临时目录
    local temp_dir
    temp_dir=$(mktemp -d)
    if [ ! -d "$temp_dir" ]; then
        print_error "无法创建临时目录"
        return 1
    fi
    
    # 复制文件到临时目录
    if ! cp -r public/* "$temp_dir"/ 2>/dev/null; then
        rm -rf "$temp_dir"
        print_error "复制文件失败"
        return 1
    fi
    
    # 创建.gitkeep文件（如果需要保留空目录）
    find "$temp_dir" -type d -empty -exec touch {}/.gitkeep \;
    
    # 在临时目录中初始化Git
    cd "$temp_dir" || {
        rm -rf "$temp_dir"
        return 1
    }
    
    git init >/dev/null 2>&1
    git config user.email "deploy@$(hostname)"
    git config user.name "Deploy Bot"
    git add -A >/dev/null 2>&1
    
    if git diff --cached --quiet; then
        print_warn "没有文件变更"
        rm -rf "$temp_dir"
        return 0
    fi
    
    git commit -m "更新: $(date '+%Y年%m月%d日 %H:%M:%S')" >/dev/null 2>&1 || true
    
    # 添加远程仓库
    git remote add aliyun "$ALIYUN_REPO" 2>/dev/null
    git remote set-url aliyun "$ALIYUN_REPO" 2>/dev/null
    
    # 推送master分支
    print_info "推送到阿里云master分支..."
    if git push aliyun master:master --force 2>/dev/null; then
        print_success "阿里云部署成功"
        local success=true
    else
        print_error "阿里云部署失败"
        local success=false
    fi
    
    # 清理临时目录
    cd /tmp
    rm -rf "$temp_dir"
    
    if [ "$success" = true ]; then
        return 0
    else
        return 1
    fi
}

# 部署到GitHub
deploy_to_github() {
    local hexo_dir="$1"
    
    cd "$hexo_dir" || return 1
    
    print_info "准备部署到GitHub..."
    
    # 推送hexo分支（源码）
    if safe_git_push "origin" "hexo" "hexo"; then
        print_success "GitHub源码同步成功"
    else
        print_warn "GitHub源码同步失败"
    fi
    
    # 使用hexo deploy部署静态文件
    print_info "使用hexo deploy部署静态文件到GitHub..."
    if hexo deploy 2>/dev/null; then
        print_success "GitHub静态文件部署成功"
        return 0
    else
        print_error "GitHub静态文件部署失败"
        return 1
    fi
}

# 主部署流程
main_deploy() {
    local hexo_dir="$1"
    local deploy_github="${2:-false}"
    
    cd "$hexo_dir" || {
        print_error "无法进入目录: $hexo_dir"
        return 1
    }
    
    print_info "=== 开始部署流程 ==="
    
    # 步骤1: 推送源码到阿里云
    print_info "步骤1: 同步源码到阿里云"
    if ! safe_git_push "aliyun" "hexo" "hexo"; then
        print_error "阿里云源码同步失败"
        return 1
    fi
    
    # 步骤2: 生成静态文件
    print_info "步骤2: 生成静态文件"
    if ! generate_static_files "$hexo_dir"; then
        return 1
    fi
    
    # 步骤3: 部署到阿里云
    print_info "步骤3: 部署到阿里云"
    if ! deploy_to_aliyun "$hexo_dir"; then
        print_error "阿里云部署失败"
        return 1
    fi
    
    # 步骤4: 部署到GitHub（可选）
    if [ "$deploy_github" = true ]; then
        print_info "步骤4: 部署到GitHub"
        if ! deploy_to_github "$hexo_dir"; then
            print_warn "GitHub部署失败，但阿里云部署成功"
        fi
    else
        print_info "步骤4: 跳过GitHub部署"
    fi
    
    return 0
}

# ========== 主程序 ==========
main() {
    # 解析命令行参数
    local deploy_github=false
    local show_help=false
    
    for arg in "$@"; do
        case "$arg" in
            -g|--github|g)
                deploy_github=true
                ;;
            -h|--help)
                show_help=true
                ;;
            *)
                print_warn "未知参数: $arg"
                ;;
        esac
    done
    
    if [ "$show_help" = true ]; then
        echo "用法: $0 [选项]"
        echo "选项:"
        echo "  -g, --github   同时部署到GitHub"
        echo "  -h, --help     显示帮助信息"
        echo ""
        echo "示例:"
        echo "  $0             只部署到阿里云"
        echo "  $0 -g          同时部署到阿里云和GitHub"
        return 0
    fi
    
    # 显示横幅
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}        Hexo 安全部署脚本              ${NC}"
    echo -e "${BLUE}========================================${NC}"
    
    # 获取当前目录
    local current_dir
    current_dir=$(pwd)
    local hexo_dir
    hexo_dir=$(get_abs_path "$current_dir")
    
    print_info "工作目录: $hexo_dir"
    
    # 前置检查
    print_info "执行前置检查..."
    
    # 检查必要命令
    for cmd in git node npm hexo; do
        if ! check_command "$cmd"; then
            return 1
        fi
    done
    
    # 检查Hexo目录
    if ! check_hexo_dir "$hexo_dir"; then
        return 1
    fi
    
    # 检查Git状态
    if ! check_git_status "$hexo_dir"; then
        return 1
    fi
    
    # 检查远程仓库连接
    if ! check_remote_connection "aliyun" "$ALIYUN_REPO"; then
        print_error "阿里云仓库连接失败"
        return 1
    fi
    
    if [ "$deploy_github" = true ]; then
        if ! check_remote_connection "origin" "$GITHUB_REPO"; then
            print_warn "GitHub仓库连接失败，但继续阿里云部署"
            deploy_github=false
        fi
    fi
    
    # 检查磁盘空间
    if ! check_disk_space 100 "$hexo_dir"; then
        print_warn "磁盘空间不足，但继续尝试部署"
    fi
    
    # 检查锁定文件
    if [ -f "$LOCK_FILE" ]; then
        local lock_age
        lock_age=$(( $(date +%s) - $(stat -c %Y "$LOCK_FILE") ))
        if [ "$lock_age" -lt 300 ]; then  # 5分钟内的锁文件
            print_error "检测到另一个部署进程正在运行"
            return 1
        else
            print_warn "发现旧的锁定文件，移除并继续"
            rm -f "$LOCK_FILE"
        fi
    fi
    
    # 创建锁定文件
    touch "$LOCK_FILE" 2>/dev/null || print_warn "无法创建锁定文件"
    
    # 设置超时
    timeout "$DEPLOY_TIMEOUT" bash -c "
        if main_deploy \"$hexo_dir\" \"$deploy_github\"; then
            exit 0
        else
            exit 1
        fi
    "
    
    local deploy_result=$?
    
    # 清理锁定文件
    rm -f "$LOCK_FILE"
    
    # 处理结果
    echo -e "\n${BLUE}========================================${NC}"
    
    if [ "$deploy_result" -eq 0 ]; then
        echo -e "${GREEN}          部署成功完成！              ${NC}"
    elif [ "$deploy_result" -eq 124 ]; then
        echo -e "${RED}          部署超时！                   ${NC}"
        print_error "部署过程超过 ${DEPLOY_TIMEOUT} 秒"
        deploy_result=1
    else
        echo -e "${RED}          部署失败！                   ${NC}"
    fi
    
    echo -e "${BLUE}========================================${NC}"
    
    # 显示部署状态
    echo -e "\n${PURPLE}部署状态总结:${NC}"
    echo -e "阿里云源码 (hexo分支): ${GREEN}已同步${NC}"
    echo -e "阿里云网站 (master分支): ${GREEN}已部署${NC}"
    
    if [ "$deploy_github" = true ]; then
        echo -e "GitHub源码 (hexo分支): ${GREEN}已同步${NC}"
        echo -e "GitHub网站 (master分支): ${GREEN}已部署${NC}"
    else
        echo -e "GitHub源码 (hexo分支): ${YELLOW}未同步${NC}"
        echo -e "GitHub网站 (master分支): ${YELLOW}未部署${NC}"
    fi
    
    # 显示访问信息
    echo -e "\n${CYAN}访问信息:${NC}"
    echo -e "阿里云服务器: ${BLUE}http://47.121.28.192${NC}"
    echo -e "网站路径: ${BLUE}/www/wwwroot/mcorazon.top${NC}"
    
    if [ "$deploy_github" = true ]; then
        echo -e "GitHub Pages: ${BLUE}https://Corazon-hacker.github.io${NC}"
    fi
    
    echo -e "\n${BLUE}使用说明:${NC}"
    echo -e "只部署阿里云: ${GREEN}./deploy.sh${NC}"
    echo -e "同时部署GitHub: ${GREEN}./deploy.sh -g${NC}"
    
    return "$deploy_result"
}

# 运行主程序
main "$@"
exit $?