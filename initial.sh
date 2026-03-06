#!/bin/bash

# =================================================================
# Hexo博客新电脑初始化脚本
# 功能：在新电脑上快速搭建Hexo博客开发环境
# 作者：基于您的配置自动生成
# =================================================================

# ========== 配置区域（请根据实际情况修改） ==========
# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 仓库配置
ALIYUN_REPO="git@47.121.28.192:/home/git/repos/hexo.git"
GITHUB_REPO="git@github.com:Corazon-hacker/Corazon-hacker.github.io.git"

# 用户信息
USER_NAME="Corazon-hacker"
USER_EMAIL="2208143652@qq.com"

# Hexo博客目录（可以修改）
HEXO_DIR="$HOME/hexo-blog"

# ========== 辅助函数 ==========
print_section() {
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}========================================${NC}"
}

print_step() {
    echo -e "${CYAN}[步骤 $1] $2${NC}"
}

print_info() {
    echo -e "${CYAN}[信息] $1${NC}"
}

print_success() {
    echo -e "${GREEN}[成功] $1${NC}"
}

print_warn() {
    echo -e "${YELLOW}[警告] $1${NC}"
}

print_error() {
    echo -e "${RED}[错误] $1${NC}" >&2
}

prompt_yes_no() {
    local prompt="$1"
    local default="${2:-n}"
    
    if [ "$default" = "y" ]; then
        prompt="$prompt [Y/n]: "
    else
        prompt="$prompt [y/N]: "
    fi
    
    while true; do
        read -p "$prompt" answer
        case "${answer:-$default}" in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            * ) echo "请输入 y 或 n";;
        esac
    done
}

wait_for_enter() {
    echo -e "${PURPLE}按回车键继续...${NC}"
    read -r
}

check_command() {
    if command -v "$1" >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

get_os_type() {
    local os_type="unknown"
    
    case "$(uname -s)" in
        Darwin*)    os_type="macos";;
        Linux*)     
            if [ -f /etc/os-release ]; then
                . /etc/os-release
                os_type="${ID}"
            else
                os_type="linux"
            fi
            ;;
        CYGWIN*|MINGW*|MSYS*) os_type="windows";;
        *)          os_type="unknown";;
    esac
    
    echo "$os_type"
}

# ========== 安装函数 ==========
install_git() {
    local os_type="$1"
    
    case "$os_type" in
        macos)
            if ! check_command git; then
                print_info "安装Git (macOS)..."
                brew install git || xcode-select --install
            fi
            ;;
        ubuntu|debian|linuxmint)
            if ! check_command git; then
                print_info "安装Git (Ubuntu/Debian)..."
                sudo apt update && sudo apt install -y git
            fi
            ;;
        centos|rhel|fedora|rocky|almalinux)
            if ! check_command git; then
                print_info "安装Git (CentOS/RHEL/Fedora)..."
                sudo yum install -y git || sudo dnf install -y git
            fi
            ;;
        arch|manjaro)
            if ! check_command git; then
                print_info "安装Git (Arch/Manjaro)..."
                sudo pacman -S --noconfirm git
            fi
            ;;
        windows)
            print_warn "请在Windows上手动安装Git: https://git-scm.com/"
            prompt_yes_no "是否已安装Git？" "n" || exit 1
            ;;
        *)
            print_error "不支持的操作系统: $os_type"
            print_warn "请手动安装Git: https://git-scm.com/"
            prompt_yes_no "是否已安装Git？" "n" || exit 1
            ;;
    esac
    
    if check_command git; then
        git_version=$(git --version | cut -d' ' -f3)
        print_success "Git 已安装 (版本: $git_version)"
    else
        print_error "Git 安装失败"
        exit 1
    fi
}

install_nodejs() {
    local os_type="$1"
    local node_version="18"  # 推荐使用Node.js 18 LTS
    
    case "$os_type" in
        macos)
            if ! check_command node; then
                print_info "安装Node.js (macOS)..."
                brew install node@$node_version || brew install node
            fi
            ;;
        ubuntu|debian|linuxmint)
            if ! check_command node; then
                print_info "安装Node.js (Ubuntu/Debian)..."
                
                # 安装curl如果不存在
                if ! check_command curl; then
                    sudo apt install -y curl
                fi
                
                # 使用NodeSource安装Node.js
                curl -fsSL https://deb.nodesource.com/setup_${node_version}.x | sudo -E bash -
                sudo apt install -y nodejs
            fi
            ;;
        centos|rhel|fedora|rocky|almalinux)
            if ! check_command node; then
                print_info "安装Node.js (CentOS/RHEL/Fedora)..."
                
                if ! check_command curl; then
                    sudo yum install -y curl || sudo dnf install -y curl
                fi
                
                curl -fsSL https://rpm.nodesource.com/setup_${node_version}.x | sudo bash -
                sudo yum install -y nodejs || sudo dnf install -y nodejs
            fi
            ;;
        arch|manjaro)
            if ! check_command nodejs; then
                print_info "安装Node.js (Arch/Manjaro)..."
                sudo pacman -S --noconfirm nodejs npm
            fi
            ;;
        windows)
            print_warn "请在Windows上手动安装Node.js: https://nodejs.org/"
            print_warn "推荐安装 Node.js ${node_version} LTS 版本"
            prompt_yes_no "是否已安装Node.js？" "n" || exit 1
            ;;
        *)
            print_error "不支持的操作系统: $os_type"
            print_warn "请手动安装Node.js: https://nodejs.org/"
            prompt_yes_no "是否已安装Node.js？" "n" || exit 1
            ;;
    esac
    
    if check_command node; then
        node_version=$(node --version | cut -d'v' -f2)
        npm_version=$(npm --version)
        print_success "Node.js 已安装 (版本: v$node_version)"
        print_success "npm 已安装 (版本: v$npm_version)"
    else
        print_error "Node.js 安装失败"
        exit 1
    fi
}

install_hexo_cli() {
    print_info "安装 Hexo CLI..."
    
    if npm install -g hexo-cli; then
        hexo_version=$(hexo version | grep "hexo:" | cut -d':' -f2 | tr -d ' ')
        print_success "Hexo CLI 已安装 (版本: $hexo_version)"
    else
        print_error "Hexo CLI 安装失败"
        exit 1
    fi
}

# ========== SSH密钥配置 ==========
configure_ssh() {
    print_section "配置SSH密钥"
    
    # 检查是否已有SSH密钥
    local ssh_key_type="ed25519"
    local ssh_key_path="$HOME/.ssh/id_$ssh_key_type"
    
    if [ -f "$ssh_key_path" ]; then
        print_info "检测到现有SSH密钥: $ssh_key_path"
        
        if prompt_yes_no "是否使用现有SSH密钥？" "y"; then
            # 显示公钥指纹
            local fingerprint=$(ssh-keygen -lf "$ssh_key_path.pub" | cut -d' ' -f2)
            print_info "SSH密钥指纹: $fingerprint"
            return 0
        fi
    fi
    
    # 生成新的SSH密钥
    print_info "生成新的SSH密钥..."
    
    if prompt_yes_no "是否为密钥设置密码？(推荐设置)" "n"; then
        ssh-keygen -t "$ssh_key_type" -C "$USER_EMAIL"
    else
        ssh-keygen -t "$ssh_key_type -C \"$USER_EMAIL\"" -N ""
    fi
    
    # 启动SSH代理
    print_info "启动SSH代理..."
    eval "$(ssh-agent -s)"
    ssh-add ~/.ssh/id_$ssh_key_type
    
    # 显示公钥
    print_section "SSH公钥"
    echo -e "${YELLOW}请将以下公钥添加到您的Git托管平台：${NC}"
    echo ""
    cat ~/.ssh/id_$ssh_key_type.pub
    echo ""
    print_info "公钥已复制到剪贴板（如果支持）"
    
    # 尝试复制到剪贴板
    case "$(get_os_type)" in
        macos)
            cat ~/.ssh/id_$ssh_key_type.pub | pbcopy
            print_success "公钥已复制到剪贴板"
            ;;
        linux)
            if check_command xclip; then
                cat ~/.ssh/id_$ssh_key_type.pub | xclip -selection clipboard
                print_success "公钥已复制到剪贴板"
            elif check_command xsel; then
                cat ~/.ssh/id_$ssh_key_type.pub | xsel --clipboard --input
                print_success "公钥已复制到剪贴板"
            else
                print_warn "请手动复制上面的公钥"
            fi
            ;;
        *)
            print_warn "请手动复制上面的公钥"
            ;;
    esac
    
    wait_for_enter
    return 0
}

add_ssh_key_to_platforms() {
    print_section "添加SSH密钥到托管平台"
    
    print_step "1" "添加SSH密钥到阿里云服务器"
    print_info "需要登录到阿里云服务器 (47.121.28.192)，然后将公钥添加到 ~/.ssh/authorized_keys"
    echo ""
    print_info "执行以下命令："
    echo "1. ssh root@47.121.28.192"
    echo "2. echo '$(cat ~/.ssh/id_ed25519.pub)' >> ~/.ssh/authorized_keys"
    echo "3. chmod 600 ~/.ssh/authorized_keys"
    echo ""
    
    if prompt_yes_no "是否已添加SSH密钥到阿里云服务器？" "n"; then
        print_success "阿里云SSH密钥已配置"
    else
        print_warn "请稍后手动添加SSH密钥到阿里云服务器"
    fi
    
    print_step "2" "添加SSH密钥到GitHub"
    print_info "访问: https://github.com/settings/keys"
    print_info "点击 'New SSH key'，粘贴公钥"
    echo ""
    
    if prompt_yes_no "是否已添加SSH密钥到GitHub？" "n"; then
        print_success "GitHub SSH密钥已配置"
    else
        print_warn "请稍后手动添加SSH密钥到GitHub"
    fi
    
    # 测试SSH连接
    test_ssh_connection
}

test_ssh_connection() {
    print_info "测试SSH连接..."
    
    # 测试阿里云连接
    print_info "测试阿里云连接..."
    if ssh -o ConnectTimeout=5 -o BatchMode=yes -o StrictHostKeyChecking=no git@47.121.28.192 "echo success" 2>/dev/null; then
        print_success "阿里云SSH连接成功"
    else
        print_warn "阿里云SSH连接失败，请检查配置"
    fi
    
    # 测试GitHub连接
    print_info "测试GitHub连接..."
    if ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
        print_success "GitHub SSH连接成功"
    else
        print_warn "GitHub SSH连接失败，请检查配置"
    fi
}

# ========== 克隆和设置Hexo博客 ==========
clone_hexo_blog() {
    print_section "克隆Hexo博客源码"
    
    # 选择克隆源
    print_info "请选择博客源码源："
    echo "1) 阿里云服务器 (主仓库，推荐)"
    echo "2) GitHub (备用仓库)"
    echo "3) 从本地备份恢复"
    echo ""
    
    local source_choice=""
    while [[ ! "$source_choice" =~ ^[123]$ ]]; do
        read -p "请选择 [1-3]: " source_choice
    done
    
    case "$source_choice" in
        1)
            # 从阿里云克隆
            print_info "从阿里云服务器克隆..."
            if git clone -b hexo "$ALIYUN_REPO" "$HEXO_DIR"; then
                print_success "从阿里云克隆成功"
                cd "$HEXO_DIR"
                # 添加GitHub作为远程仓库
                git remote add github "$GITHUB_REPO" 2>/dev/null || true
            else
                print_error "从阿里云克隆失败，尝试从GitHub克隆..."
                git clone -b hexo "$GITHUB_REPO" "$HEXO_DIR"
                cd "$HEXO_DIR"
                # 添加阿里云作为远程仓库
                git remote add aliyun "$ALIYUN_REPO" 2>/dev/null || true
            fi
            ;;
        2)
            # 从GitHub克隆
            print_info "从GitHub克隆..."
            git clone -b hexo "$GITHUB_REPO" "$HEXO_DIR"
            cd "$HEXO_DIR"
            # 添加阿里云作为远程仓库
            git remote add aliyun "$ALIYUN_REPO" 2>/dev/null || true
            ;;
        3)
            # 从本地备份恢复
            print_info "请提供本地备份路径："
            read -p "备份路径: " backup_path
            
            if [ -d "$backup_path" ]; then
                cp -r "$backup_path" "$HEXO_DIR"
                cd "$HEXO_DIR"
                
                # 初始化Git仓库
                if [ ! -d ".git" ]; then
                    git init
                    git checkout -b hexo
                    git add .
                    git commit -m "从本地备份恢复"
                fi
                
                # 添加远程仓库
                git remote add aliyun "$ALIYUN_REPO" 2>/dev/null || true
                git remote add github "$GITHUB_REPO" 2>/dev/null || true
            else
                print_error "备份路径不存在: $backup_path"
                exit 1
            fi
            ;;
    esac
    
    # 配置Git用户信息
    print_info "配置Git用户信息..."
    git config user.name "$USER_NAME"
    git config user.email "$USER_EMAIL"
    
    # 显示远程仓库
    print_info "远程仓库配置："
    git remote -v
}

install_blog_dependencies() {
    print_section "安装博客依赖"
    
    if [ ! -f "package.json" ]; then
        print_error "package.json 不存在，请检查克隆是否成功"
        exit 1
    fi
    
    print_info "安装项目依赖..."
    
    # 备份现有node_modules（如果有）
    if [ -d "node_modules" ]; then
        print_warn "检测到现有node_modules，正在备份..."
        mv node_modules "node_modules.backup.$(date +%Y%m%d%H%M%S)"
    fi
    
    # 使用npm ci安装依赖（更严格，适合CI/CD）
    if npm ci; then
        print_success "依赖安装成功"
    else
        print_warn "npm ci失败，尝试使用npm install..."
        if npm install; then
            print_success "依赖安装成功"
        else
            print_error "依赖安装失败"
            exit 1
        fi
    fi
    
    # 检查是否有缺失的插件
    print_info "检查Hexo插件..."
    if [ ! -f "package.json" ]; then
        print_warn "无法检查插件，请手动安装必要的Hexo插件"
        return
    fi
    
    # 检查常用插件
    local required_plugins=("hexo-deployer-git" "hexo-generator-feed" "hexo-renderer-stylus")
    
    for plugin in "${required_plugins[@]}"; do
        if ! grep -q "\"$plugin\"" package.json; then
            print_warn "建议安装插件: $plugin"
            if prompt_yes_no "是否安装 $plugin？" "n"; then
                npm install "$plugin" --save
            fi
        fi
    done
}

check_blog_configuration() {
    print_section "检查博客配置"
    
    # 检查关键文件
    local required_files=("_config.yml" "scaffolds/" "source/" "themes/")
    local missing_files=()
    
    for file in "${required_files[@]}"; do
        if [ ! -e "$file" ]; then
            missing_files+=("$file")
        fi
    done
    
    if [ ${#missing_files[@]} -gt 0 ]; then
        print_error "缺少必要的Hexo文件:"
        printf '%s\n' "${missing_files[@]}"
        
        if prompt_yes_no "是否尝试修复？" "n"; then
            print_info "尝试初始化Hexo..."
            hexo init .
        else
            print_error "请检查博客源码是否完整"
            return 1
        fi
    else
        print_success "所有必要文件都存在"
    fi
    
    # 检查主题配置
    if [ -d "themes" ]; then
        local theme_count=$(find themes -maxdepth 1 -type d | wc -l)
        if [ "$theme_count" -le 1 ]; then
            print_warn "未检测到主题文件"
            print_info "常见主题："
            echo "1. NexT (最受欢迎) - https://github.com/next-theme/hexo-theme-next"
            echo "2. Butterfly - https://github.com/jerryc127/hexo-theme-butterfly"
            echo "3. Fluid - https://github.com/fluid-dev/hexo-theme-fluid"
            echo ""
            
            if prompt_yes_no "是否要克隆一个主题？" "n"; then
                read -p "请输入主题GitHub仓库URL: " theme_repo
                read -p "请输入主题目录名: " theme_name
                
                if [ -n "$theme_repo" ] && [ -n "$theme_name" ]; then
                    git clone "$theme_repo" "themes/$theme_name"
                    
                    # 删除主题中的.git目录
                    if [ -d "themes/$theme_name/.git" ]; then
                        rm -rf "themes/$theme_name/.git"
                        print_info "已删除主题中的.git目录"
                    fi
                    
                    print_success "主题已安装到 themes/$theme_name"
                fi
            fi
        else
            print_success "检测到主题文件"
        fi
    fi
    
    return 0
}

configure_hexo_deployment() {
    print_section "配置Hexo部署"
    
    # 备份现有配置
    if [ -f "_config.yml" ]; then
        cp "_config.yml" "_config.yml.backup.$(date +%Y%m%d%H%M%S)"
    fi
    
    # 创建部署配置
    cat >> _config.yml << 'EOF'

# ========== 部署配置 ==========
deploy:
  type: git
  repo:
    # 阿里云服务器（主要）
    aliyun: git@47.121.28.192:/home/git/repos/hexo.git,master
    # GitHub（备用）
    github: git@github.com:Corazon-hacker/Corazon-hacker.github.io.git,master
  branch: master
  message: "更新: {{ now('YYYY年MM月DD日 HH:mm') }}"
EOF
    
    print_success "部署配置已添加到 _config.yml"
    
    # 提示用户检查配置
    print_info "请检查 _config.yml 中的配置："
    echo ""
    echo "1. 站点标题 (title)"
    echo "2. 站点描述 (description)"
    echo "3. 主题设置 (theme)"
    echo "4. 部署配置 (deploy)"
    echo ""
    
    if prompt_yes_no "是否要编辑 _config.yml？" "n"; then
        if check_command nano; then
            nano _config.yml
        elif check_command vim; then
            vim _config.yml
        elif check_command vi; then
            vi _config.yml
        else
            print_warn "没有找到文本编辑器，请手动编辑 _config.yml"
        fi
    fi
}

# ========== 测试运行 ==========
test_hexo_blog() {
    print_section "测试Hexo博客"
    
    # 清理并生成
    print_info "清理并生成静态文件..."
    if hexo clean && hexo generate; then
        print_success "静态文件生成成功"
        
        local file_count=$(find public -type f | wc -l)
        local dir_size=$(du -sh public | cut -f1)
        print_info "生成 $file_count 个文件，总大小 $dir_size"
    else
        print_error "静态文件生成失败"
        return 1
    fi
    
    # 本地预览
    print_info "启动本地预览服务器..."
    print_info "Hexo将在 http://localhost:4000 启动"
    print_info "按 Ctrl+C 停止服务器"
    echo ""
    
    if prompt_yes_no "是否启动本地服务器？" "y"; then
        hexo server &
        local server_pid=$!
        
        print_info "本地服务器已启动 (PID: $server_pid)"
        print_info "按回车键停止服务器并继续..."
        read -r
        
        kill $server_pid 2>/dev/null
        print_success "本地服务器已停止"
    fi
    
    return 0
}

# ========== 部署脚本安装 ==========
install_deploy_script() {
    print_section "安装部署脚本"
    
    # 创建部署脚本
    cat > deploy.sh << 'EOF'
#!/bin/bash

# ========== 安全配置 ==========
# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# 仓库配置
ALIYUN_REPO="git@47.121.28.192:/home/git/repos/hexo.git"
GITHUB_REPO="git@github.com:Corazon-hacker/Corazon-hacker.github.io.git"

# 超时配置
DEPLOY_TIMEOUT=600

# ========== 辅助函数 ==========
print_error() { echo -e "${RED}[错误] $1${NC}" >&2; }
print_warn() { echo -e "${YELLOW}[警告] $1${NC}" >&2; }
print_info() { echo -e "${CYAN}[信息] $1${NC}"; }
print_success() { echo -e "${GREEN}[成功] $1${NC}"; }

check_hexo_dir() {
    if [ ! -f "_config.yml" ]; then
        print_error "不是Hexo目录"
        print_error "请在Hexo根目录运行此脚本"
        return 1
    fi
    return 0
}

# ========== 主程序 ==========
main() {
    # 显示横幅
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}        Hexo 安全部署脚本              ${NC}"
    echo -e "${BLUE}========================================${NC}"
    
    # 检查是否在Hexo目录
    if ! check_hexo_dir; then
        return 1
    fi
    
    print_info "工作目录: $(pwd)"
    
    # 询问是否部署到GitHub
    deploy_github=false
    read -p "是否同时部署到GitHub？(y/N): " choice
    if [[ "$choice" =~ ^[Yy]$ ]]; then
        deploy_github=true
    fi
    
    # 1. 推送源码到阿里云
    print_info "步骤1: 同步源码到阿里云"
    if git push aliyun hexo; then
        print_success "阿里云源码同步成功"
    else
        print_warn "阿里云源码同步失败，尝试强制推送..."
        git push aliyun hexo --force || print_error "阿里云源码同步失败"
    fi
    
    # 2. 生成静态文件
    print_info "步骤2: 生成静态文件"
    if hexo clean && hexo generate; then
        print_success "静态文件生成成功"
    else
        print_error "静态文件生成失败"
        return 1
    fi
    
    # 3. 部署到阿里云
    print_info "步骤3: 部署到阿里云"
    cd public
    
    if [ -d ".git" ]; then
        git fetch aliyun
        git reset --hard aliyun/master 2>/dev/null || true
    else
        git init
        git remote add aliyun "$ALIYUN_REPO"
    fi
    
    git add -A
    if git diff --cached --quiet && [ -d ".git" ]; then
        print_warn "没有文件变更"
    else
        git commit -m "更新: $(date '+%Y年%m月%d日 %H:%M:%S')" >/dev/null 2>&1 || true
        if git push aliyun master --force; then
            print_success "阿里云部署成功"
        else
            print_error "阿里云部署失败"
        fi
    fi
    
    cd ..
    
    # 4. 部署到GitHub（可选）
    if [ "$deploy_github" = true ]; then
        print_info "步骤4: 部署到GitHub"
        
        # 推送源码
        if git push origin hexo; then
            print_success "GitHub源码同步成功"
        else
            print_warn "GitHub源码同步失败"
        fi
        
        # 部署静态文件
        if hexo deploy; then
            print_success "GitHub静态文件部署成功"
        else
            print_warn "GitHub静态文件部署失败"
        fi
    else
        print_info "步骤4: 跳过GitHub部署"
    fi
    
    echo -e "\n${GREEN}========================================${NC}"
    echo -e "${GREEN}          部署完成！                   ${NC}"
    echo -e "${GREEN}========================================${NC}"
    
    # 显示访问信息
    echo -e "\n${CYAN}访问信息:${NC}"
    echo -e "阿里云服务器: ${BLUE}http://47.121.28.192${NC}"
    
    if [ "$deploy_github" = true ]; then
        echo -e "GitHub Pages: ${BLUE}https://Corazon-hacker.github.io${NC}"
    fi
}

# 运行主程序
main "$@"
EOF
    
    # 给部署脚本执行权限
    chmod +x deploy.sh
    print_success "部署脚本已创建: deploy.sh"
    
    # 创建快捷启动脚本
    cat > start.sh << 'EOF'
#!/bin/bash
# Hexo博客快捷启动脚本

echo "Hexo博客快捷命令"
echo "================="
echo "1. 本地预览: hexo clean && hexo g && hexo s"
echo "2. 部署博客: ./deploy.sh"
echo "3. 新建文章: hexo new \"文章标题\""
echo "4. 清理缓存: hexo clean"
echo ""

echo "正在启动本地预览服务器..."
echo "按 Ctrl+C 停止服务器"
echo "访问地址: http://localhost:4000"
echo ""

hexo clean && hexo generate && hexo server
EOF
    
    chmod +x start.sh
    print_success "启动脚本已创建: start.sh"
}

# ========== 创建快捷命令 ==========
create_aliases() {
    print_section "创建快捷命令"
    
    local shell_rc=""
    
    # 检测当前shell
    case "$SHELL" in
        */zsh) shell_rc="$HOME/.zshrc";;
        */bash) shell_rc="$HOME/.bashrc";;
        *) shell_rc="$HOME/.bashrc";;
    esac
    
    # 添加Hexo快捷命令
    cat >> "$shell_rc" << EOF

# ========== Hexo博客快捷命令 ==========
alias hexo-start='cd $HEXO_DIR && ./start.sh'
alias hexo-deploy='cd $HEXO_DIR && ./deploy.sh'
alias hexo-blog='cd $HEXO_DIR'
alias hexo-new='cd $HEXO_DIR && hexo new'
alias hexo-update='cd $HEXO_DIR && git pull aliyun hexo && npm ci'
alias hexo-status='cd $HEXO_DIR && git status'
alias hexo-log='cd $HEXO_DIR && git log --oneline -10'
EOF
    
    print_success "快捷命令已添加到 $shell_rc"
    print_info "快捷命令列表："
    echo "  hexo-start    - 启动本地预览服务器"
    echo "  hexo-deploy   - 部署博客到阿里云/GitHub"
    echo "  hexo-blog     - 进入博客目录"
    echo "  hexo-new      - 创建新文章"
    echo "  hexo-update   - 更新博客源码和依赖"
    echo "  hexo-status   - 查看Git状态"
    echo "  hexo-log      - 查看最近提交记录"
    
    # 重新加载shell配置
    if [ -f "$shell_rc" ]; then
        source "$shell_rc" 2>/dev/null || true
    fi
}

# ========== 完成总结 ==========
show_summary() {
    print_section "初始化完成"
    
    echo -e "${GREEN}✓ Hexo博客环境初始化完成！${NC}"
    echo ""
    echo -e "${CYAN}重要信息：${NC}"
    echo "1. 博客目录: $HEXO_DIR"
    echo "2. 本地预览: cd $HEXO_DIR && hexo clean && hexo g && hexo s"
    echo "3. 部署博客: cd $HEXO_DIR && ./deploy.sh"
    echo "4. 创建文章: cd $HEXO_DIR && hexo new \"文章标题\""
    echo ""
    echo -e "${YELLOW}注意事项：${NC}"
    echo "1. 请确保SSH密钥已添加到阿里云和GitHub"
    echo "2. 检查 _config.yml 中的配置是否正确"
    echo "3. 如果主题缺失，请手动安装主题"
    echo "4. 定期使用 hexo-update 更新博客"
    echo ""
    
    # 显示下一步操作
    echo -e "${PURPLE}下一步操作：${NC}"
    echo "1. 进入博客目录: cd $HEXO_DIR"
    echo "2. 编辑 _config.yml 配置博客"
    echo "3. 检查主题配置"
    echo "4. 开始写作: hexo new \"我的第一篇文章\""
    echo "5. 本地预览: hexo-start 或 hexo clean && hexo g && hexo s"
    echo "6. 部署: hexo-deploy 或 ./deploy.sh"
    
    wait_for_enter
}

# ========== 主程序 ==========
main() {
    print_section "Hexo博客新电脑初始化脚本"
    echo ""
    echo "这个脚本将帮助您在新电脑上快速搭建Hexo博客环境。"
    echo "支持的操作系统: macOS, Ubuntu, Debian, CentOS, Fedora, Arch"
    echo ""
    echo "作者: 基于您的配置自动生成"
    echo "版本: 1.0.0"
    echo ""
    
    # 显示系统信息
    local os_type=$(get_os_type)
    print_info "操作系统: $os_type"
    print_info "用户名: $(whoami)"
    print_info "博客目录: $HEXO_DIR"
    echo ""
    
    if ! prompt_yes_no "是否开始初始化？" "y"; then
        print_info "初始化已取消"
        exit 0
    fi
    
    # 1. 安装基础软件
    print_step "1" "安装基础软件"
    install_git "$os_type"
    install_nodejs "$os_type"
    install_hexo_cli
    
    # 2. 配置SSH
    print_step "2" "配置SSH密钥"
    configure_ssh
    
    # 3. 克隆博客
    print_step "3" "克隆博客源码"
    clone_hexo_blog
    
    # 4. 安装依赖
    print_step "4" "安装博客依赖"
    install_blog_dependencies
    
    # 5. 检查配置
    print_step "5" "检查博客配置"
    check_blog_configuration
    
    # 6. 配置部署
    print_step "6" "配置Hexo部署"
    configure_hexo_deployment
    
    # 7. 测试运行
    print_step "7" "测试Hexo博客"
    test_hexo_blog
    
    # 8. 安装部署脚本
    print_step "8" "安装部署脚本"
    install_deploy_script
    
    # 9. 创建快捷命令
    print_step "9" "创建快捷命令"
    create_aliases
    
    # 10. SSH密钥添加到平台
    print_step "10" "添加SSH密钥到托管平台"
    add_ssh_key_to_platforms
    
    # 完成
    show_summary
    
    return 0
}

# 执行主程序
main "$@"