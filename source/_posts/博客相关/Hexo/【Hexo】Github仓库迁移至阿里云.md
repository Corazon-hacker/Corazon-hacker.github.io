---
title: 【Hexo】Github仓库迁移至阿里云
comments: true
abbrlink: 5be5b614
categories:
  - 博客相关
  - Hexo
date: 2026-01-31 12:40:36
tags:
description:
top:
---



之前我实现的多台电脑共同管理github  hexo博客的文章。但是github总是速度很慢，甚至连接不上，为我带来了很大的不便。我现在打算把github当作备用，主要使用我的服务器。因此现在我又在我的阿里云服务器上实现了github、阿里云双部署，多台笔记本可以同时管理github和阿里云的仓库。而github因为已经完成了实现，就不进行删除了，只是默认不在github进行部署。

## 一、阿里云服务器仓库改造

### 1. 在阿里云服务器创建双分支结构

```bash
# 在阿里云服务器上执行
cd /home/git/repos

# 备份现有仓库（如果需要）
mv hexo.git hexo.git.backup

# 重新初始化裸仓库
git init --bare hexo.git

# 进入临时目录，设置双分支
cd /tmp
git clone /home/git/repos/hexo.git
cd hexo

# 创建两个分支并推送
git checkout -b hexo  # 源码分支
echo "# Hexo Blog Source" > README.md
git add README.md
git commit -m "初始化hexo分支"
git push origin hexo

git checkout -b master  # 静态文件分支
echo "# Public Website" > README.md
git add README.md
git commit -m "初始化master分支"
git push origin master

# 清理临时目录
cd ..
rm -rf hexo
```

### 2. 更新钩子脚本（post-receive）

记得添加执行权限

```bash
#!/bin/bash

# ========== 安全配置 ==========
# 目录配置（必须确保git用户有权限）
GIT_REPO="/home/git/repos/hexo.git"
MASTER_DEPLOY_DIR="/www/wwwroot/mcorazon.top"
BACKUP_ROOT="/home/git/backups/hexo"
LOG_DIR="/home/git/logs/hexo-deploy"
WEB_USER="www-data"
WEB_GROUP="www-data"

# 安全限制（防止脚本意外操作）
MAX_BACKUPS=5                    # 最多保留5个备份
MIN_DISK_SPACE_MB=100            # 至少需要100MB磁盘空间
DEPLOY_TIMEOUT=300               # 部署超时时间（秒）

# ========== 初始化安全环境 ==========
# 设置安全选项
set -e                           # 任何命令失败则退出
set -u                           # 使用未定义变量则退出
set -o pipefail                  # 管道中任何命令失败则退出

# 清空PATH，只使用绝对路径
export PATH="/usr/bin:/bin:/usr/sbin:/sbin"

# 创建必要的目录（确保git用户有权限）
mkdir -p "$BACKUP_ROOT" "$LOG_DIR" 2>/dev/null || {
    echo "错误：无法创建必要的目录"
    exit 1
}

# 设置目录权限
chmod 700 "$BACKUP_ROOT" "$LOG_DIR" 2>/dev/null || true

# 日志函数
log() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local log_file="$LOG_DIR/deploy.log"
    
    # 输出到控制台
    case "$level" in
        "ERROR") echo "[$timestamp] [ERROR] $message" >&2 ;;
        "WARN") echo "[$timestamp] [WARN] $message" >&2 ;;
        "INFO") echo "[$timestamp] [INFO] $message" ;;
        *) echo "[$timestamp] [$level] $message" ;;
    esac
    
    # 记录到日志文件
    echo "[$timestamp] [$level] $message" >> "$log_file"
    
    # 日志轮转（如果大于10MB）
    if [ -f "$log_file" ] && [ $(stat -c%s "$log_file" 2>/dev/null || echo 0) -gt 10485760 ]; then
        mv "$log_file" "$log_file.old" 2>/dev/null
    fi
}

# 错误处理函数
error_exit() {
    log "ERROR" "部署失败: $1"
    exit 1
}

# 安全检查函数
safety_check() {
    # 1. 检查部署目录是否合理
    if [ -z "$MASTER_DEPLOY_DIR" ] || [ "$MASTER_DEPLOY_DIR" = "/" ]; then
        error_exit "部署目录配置错误"
    fi
    
    # 2. 检查磁盘空间
    local available_space
    available_space=$(df -m "$BACKUP_ROOT" | awk 'NR==2 {print $4}' 2>/dev/null || echo 0)
    if [ "$available_space" -lt "$MIN_DISK_SPACE_MB" ]; then
        log "WARN" "磁盘空间不足: ${available_space}MB < ${MIN_DISK_SPACE_MB}MB"
    fi
    
    # 3. 检查目录权限
    if [ ! -w "$BACKUP_ROOT" ]; then
        log "WARN" "备份目录不可写: $BACKUP_ROOT"
    fi
    
    if [ ! -w "$LOG_DIR" ]; then
        log "WARN" "日志目录不可写: $LOG_DIR"
    fi
    
    # 4. 检查当前用户
    local current_user
    current_user=$(whoami)
    if [ "$current_user" != "git" ]; then
        log "WARN" "当前用户不是git: $current_user"
    fi
}

# 备份当前网站
backup_current_site() {
    if [ ! -d "$MASTER_DEPLOY_DIR" ] || [ ! "$(ls -A "$MASTER_DEPLOY_DIR" 2>/dev/null)" ]; then
        log "INFO" "部署目录为空，跳过备份"
        return 0
    fi
    
    local backup_file="$BACKUP_ROOT/backup-$(date +%Y%m%d-%H%M%S).tar.gz"
    
    # 检查磁盘空间
    local dir_size_mb
    dir_size_mb=$(du -sm "$MASTER_DEPLOY_DIR" 2>/dev/null | cut -f1 || echo 0)
    local available_space
    available_space=$(df -m "$BACKUP_ROOT" | awk 'NR==2 {print $4}' 2>/dev/null || echo 0)
    
    if [ "$available_space" -lt "$dir_size_mb" ]; then
        log "WARN" "磁盘空间不足，无法备份 (需要: ${dir_size_mb}MB, 可用: ${available_space}MB)"
        return 1
    fi
    
    log "INFO" "开始备份当前网站 (大小: ${dir_size_mb}MB)"
    
    # 使用tar压缩备份
    if tar -czf "$backup_file" -C "$MASTER_DEPLOY_DIR" . 2>/dev/null; then
        local backup_size
        backup_size=$(du -h "$backup_file" | cut -f1)
        log "INFO" "备份完成: $backup_file (${backup_size})"
        
        # 清理旧备份
        local backup_count
        backup_count=$(ls -1 "$BACKUP_ROOT"/backup-*.tar.gz 2>/dev/null | wc -l)
        if [ "$backup_count" -gt "$MAX_BACKUPS" ]; then
            ls -t "$BACKUP_ROOT"/backup-*.tar.gz 2>/dev/null | tail -n +$((MAX_BACKUPS + 1)) | while read old_backup; do
                rm -f "$old_backup"
                log "INFO" "删除旧备份: $(basename "$old_backup")"
            done
        fi
        return 0
    else
        log "WARN" "备份失败"
        return 1
    fi
}

# 安全清理部署目录
safe_clean_deploy_dir() {
    if [ ! -d "$MASTER_DEPLOY_DIR" ]; then
        mkdir -p "$MASTER_DEPLOY_DIR" || error_exit "无法创建部署目录"
        log "INFO" "创建部署目录: $MASTER_DEPLOY_DIR"
        return 0
    fi
    
    # 双重验证：确保目录看起来像网站目录
    local file_count
    file_count=$(find "$MASTER_DEPLOY_DIR" -maxdepth 1 -type f \( -name "*.html" -o -name "*.css" -o -name "*.js" \) | wc -l)
    if [ "$file_count" -eq 0 ] && [ -f "$MASTER_DEPLOY_DIR/index.html" ]; then
        file_count=1
    fi
    
    if [ "$file_count" -eq 0 ] && [ "$(ls -A "$MASTER_DEPLOY_DIR" 2>/dev/null)" ]; then
        log "WARN" "目录 $MASTER_DEPLOY_DIR 可能不是网站目录，但继续清理"
    fi
    
    # 安全清理：只删除常规文件，保留.gitkeep等隐藏文件
    log "INFO" "清理部署目录"
    
    cd "$MASTER_DEPLOY_DIR" || error_exit "无法进入部署目录"
    
    # 列出要删除的文件（用于日志）
    local delete_count
    delete_count=$(find . -maxdepth 1 ! -name '.' ! -name '.git*' ! -name '.*' 2>/dev/null | wc -l)
    
    if [ "$delete_count" -gt 0 ]; then
        log "INFO" "将删除 $delete_count 个文件/目录"
        
        # 逐个删除，避免通配符问题
        find . -maxdepth 1 ! -name '.' ! -name '.git*' ! -name '.*' -print0 2>/dev/null | while IFS= read -r -d '' item; do
            if [ -n "$item" ] && [ "$item" != "." ]; then
                rm -rf "$item"
            fi
        done
    fi
    
    log "INFO" "目录清理完成"
}

# 检出静态文件
checkout_static_files() {
    log "INFO" "检出静态文件"
    
    # 使用git archive导出文件，避免检出.git目录
    local temp_dir
    temp_dir=$(mktemp -d)
    
    if git archive master | tar -x -C "$temp_dir" 2>/dev/null; then
        # 复制文件到部署目录
        cp -r "$temp_dir"/* "$MASTER_DEPLOY_DIR"/ 2>/dev/null || true
        
        # 清理临时目录
        rm -rf "$temp_dir"
        
        # 验证部署结果
        if [ -f "$MASTER_DEPLOY_DIR/index.html" ]; then
            local file_count
            file_count=$(find "$MASTER_DEPLOY_DIR" -type f | wc -l)
            log "INFO" "检出成功，共 $file_count 个文件"
            return 0
        else
            error_exit "检出失败：未找到index.html"
        fi
    else
        rm -rf "$temp_dir"
        error_exit "git archive失败"
    fi
}

# 设置文件权限
set_permissions() {
    log "INFO" "设置文件权限"
    
    # 尝试使用sudo（需要在sudoers中配置）
    if command -v sudo >/dev/null 2>&1; then
        # 设置文件所有者
        if sudo chown -R "$WEB_USER:$WEB_GROUP" "$MASTER_DEPLOY_DIR" 2>/dev/null; then
            # 设置安全权限：文件640，目录750
            sudo find "$MASTER_DEPLOY_DIR" -type f -exec chmod 640 {} \; 2>/dev/null || true
            sudo find "$MASTER_DEPLOY_DIR" -type d -exec chmod 750 {} \; 2>/dev/null || true
            log "INFO" "权限设置完成（使用sudo）"
            return 0
        fi
    fi
    
    # 降级方案：尝试设置组权限
    if chgrp -R "$WEB_GROUP" "$MASTER_DEPLOY_DIR" 2>/dev/null; then
        # 设置组读写权限，其他用户只读
        find "$MASTER_DEPLOY_DIR" -type f -exec chmod 664 {} \; 2>/dev/null || true
        find "$MASTER_DEPLOY_DIR" -type d -exec chmod 775 {} \; 2>/dev/null || true
        log "INFO" "权限设置完成（使用降级方案）"
    else
        log "WARN" "无法设置文件权限，可能需要手动设置"
    fi
}

# 验证部署结果
verify_deployment() {
    log "INFO" "验证部署结果"
    
    if [ ! -f "$MASTER_DEPLOY_DIR/index.html" ]; then
        error_exit "部署失败：未找到index.html"
    fi
    
    local file_count
    file_count=$(find "$MASTER_DEPLOY_DIR" -type f | wc -l)
    local dir_size
    dir_size=$(du -sh "$MASTER_DEPLOY_DIR" | cut -f1)
    
    log "INFO" "验证通过：共 $file_count 个文件，大小 $dir_size"
    
    # 检查网站是否基本可访问
    if [ -f "$MASTER_DEPLOY_DIR/index.html" ]; then
        local first_line
        first_line=$(head -c 100 "$MASTER_DEPLOY_DIR/index.html" 2>/dev/null | tr -d '\n' || echo "")
        if echo "$first_line" | grep -q "<!DOCTYPE html\|<html"; then
            log "INFO" "HTML文件格式正确"
        fi
    fi
    
    return 0
}

# ========== 主程序 ==========
main() {
    log "INFO" "开始处理Git推送"
    
    # 执行安全检查
    safety_check
    
    # 读取推送信息
    while read oldrev newrev refname; do
        branch=${refname#refs/heads/}
        log "INFO" "推送分支: $branch (${oldrev:0:8} -> ${newrev:0:8})"
        
        case "$branch" in
            master)
                log "INFO" "开始部署静态网站"
                
                # 1. 备份当前网站
                backup_current_site
                
                # 2. 安全清理部署目录
                safe_clean_deploy_dir
                
                # 3. 检出静态文件
                checkout_static_files
                
                # 4. 设置文件权限
                set_permissions
                
                # 5. 验证部署结果
                verify_deployment
                
                log "INFO" "静态网站部署完成"
                ;;
                
            hexo)
                log "INFO" "hexo源码分支已更新"
                # 这里可以添加源码同步逻辑（如果需要）
                ;;
                
            *)
                log "WARN" "忽略未知分支: $branch"
                ;;
        esac
    done
    
    log "INFO" "所有操作完成"
}

# 设置超时，防止部署过程挂起
timeout "$DEPLOY_TIMEOUT" bash -c "main" 2>&1 | tee -a "$LOG_DIR/deploy.log"

exit_code=${PIPESTATUS[0]}
if [ "$exit_code" -eq 124 ]; then
    log "ERROR" "部署超时 (超过 ${DEPLOY_TIMEOUT}秒)"
    exit 1
elif [ "$exit_code" -ne 0 ]; then
    log "ERROR" "部署过程异常退出 (代码: $exit_code)"
    exit "$exit_code"
fi
```

## 二、本地电脑配置

### 1. 添加阿里云服务器为第二个远程仓库

在您的Hexo博客根目录：

```bash
# 添加阿里云服务器作为远程仓库（命名为 aliyun）
git remote add aliyun git@47.121.28.192:/home/git/repos/hexo.git

# 查看所有远程仓库
git remote -v
# 应该看到：
# origin    git@github.com:Corazon-hacker/Corazon-hacker.github.io.git (fetch)
# origin    git@github.com:Corazon-hacker/Corazon-hacker.github.io.git (push)
# aliyun    git@47.121.28.192:/home/git/repos/hexo.git (fetch)
# aliyun    git@47.121.28.192:/home/git/repos/hexo.git (push)
```

### 2. 配置SSH免密登录阿里云服务器

如果已经连上可忽略，已经有密钥则部分忽略

```bash
# 1. 生成专用于阿里云的SSH密钥（如果还没有）
ssh-keygen -t ed25519 -C "hexo@aliyun" -f ~/.ssh/id_ed25519_aliyun

# 2. 将公钥添加到阿里云服务器的 ~/.ssh/authorized_keys
# 先将公钥复制到剪贴板
cat ~/.ssh/id_ed25519_aliyun.pub | clip  # Windows
# 或
cat ~/.ssh/id_ed25519_aliyun.pub | pbcopy  # Mac

# 3. 登录阿里云服务器，将公钥添加到 authorized_keys
ssh root@47.121.28.192
echo "粘贴的公钥内容" >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
exit

# 4. 在本地配置SSH别名（可选但推荐）
# 编辑 ~/.ssh/config 文件，添加：
Host aliyun-hexo
    HostName 47.121.28.192
    Port 22
    User git
    IdentityFile ~/.ssh/id_ed25519_aliyun
    IdentitiesOnly yes

# 5. 测试连接
ssh -T aliyun-hexo
# 应该显示：Welcome to Git!
```

### 3. 更新Hexo配置文件

修改 `_config.yml` 中的部署配置，我最终修改完是喜爱面这样的：

```yaml
# Deployment
## Docs: https://hexo.io/docs/one-command-deployment
deploy:
  - type: git
    repo: git@github.com:Corazon-hacker/Corazon-hacker.github.io.git
    branch: master
    message: "Site updated: {{ now('YYYY-MM-DD HH:mm:ss') }}"
    # 同步删除文件（推荐开启）
    sync: true
  #已经连接好了coding，但是coding没有静态网页，就关了
  #- type: git
  #  repo: https://e.coding.net/g-pkbx0046/mcorazon/mcorazon.git
  #  branch: master
  #个人的阿里云服务器
  - type: git
    repo: git@47.121.28.192:/home/git/repos/hexo.git
    branch: master
    message: "Site updated: {{ now('YYYY-MM-DD HH:mm:ss') }}"
    # 同步删除文件（推荐开启）
    sync: true
  - type: baidu_url_submitter                         # 这是新加的主动推送
```

## 三、更新自动化部署脚本

在本地博客根目录下创建新的部署脚本 `deploy.sh`：

```bash
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
DEPLOY_TIMEOUT=600  # 10分钟

# ========== 辅助函数 ==========
print_error() { echo -e "${RED}[错误] $1${NC}" >&2; }
print_warn() { echo -e "${YELLOW}[警告] $1${NC}" >&2; }
print_info() { echo -e "${CYAN}[信息] $1${NC}"; }
print_success() { echo -e "${GREEN}[成功] $1${NC}"; }

# ========== 核心函数 ==========
# 检查命令是否存在
check_command() {
    if ! command -v "$1" >/dev/null 2>&1; then
        print_error "命令未找到: $1"
        return 1
    fi
    return 0
}

# 检查是否在Hexo目录
check_hexo_dir() {
    if [ ! -f "_config.yml" ]; then
        print_error "不是Hexo目录"
        print_error "请在Hexo根目录运行此脚本"
        return 1
    fi
    return 0
}

# 检查Git状态
check_git_status() {
    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        print_error "当前目录不是Git仓库"
        return 1
    fi
    
    local current_branch
    current_branch=$(git symbolic-ref --short HEAD 2>/dev/null || echo "未知")
    if [ "$current_branch" != "hexo" ]; then
        print_warn "当前分支不是hexo: $current_branch"
    fi
    
    if [ -n "$(git status --porcelain)" ]; then
        print_warn "发现未提交的更改:"
        git status --short
        
        local choice
        read -p "是否提交这些更改？(y/N): " choice
        if [[ "$choice" =~ ^[Yy]$ ]]; then
            git add .
            git commit -m "自动提交: $(date '+%Y-%m-%d %H:%M:%S')"
            print_success "更改已提交"
        fi
    fi
    
    return 0
}

# 检查远程连接
check_remote_connection() {
    local remote_name="$1"
    local remote_url="$2"
    
    print_info "检查远程仓库连接: $remote_name"
    
    if ! git remote get-url "$remote_name" >/dev/null 2>&1; then
        print_info "添加远程仓库: $remote_name"
        git remote add "$remote_name" "$remote_url" || {
            print_error "无法添加远程仓库: $remote_name"
            return 1
        }
    fi
    
    local retry_count=0
    while [ "$retry_count" -lt 3 ]; do
        if git ls-remote "$remote_name" >/dev/null 2>&1; then
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

# 安全推送
safe_git_push() {
    local remote="$1"
    local local_branch="$2"
    local remote_branch="$3"
    local retry_count=0
    
    print_info "推送分支: $local_branch -> $remote/$remote_branch"
    
    while [ "$retry_count" -lt 3 ]; do
        # 先拉取最新代码
        git fetch "$remote" "$remote_branch" 2>/dev/null || true
        
        # 尝试推送
        if git push "$remote" "$local_branch:$remote_branch" 2>/dev/null; then
            print_success "推送成功"
            return 0
        fi
        
        retry_count=$((retry_count + 1))
        
        if [ "$retry_count" -lt 3 ]; then
            print_warn "推送失败，第${retry_count}次重试..."
            sleep 2
        fi
    done
    
    # 尝试强制推送
    print_warn "普通推送失败，尝试强制推送"
    if git push "$remote" "$local_branch:$remote_branch" --force 2>/dev/null; then
        print_success "强制推送成功"
        return 0
    else
        print_error "所有推送尝试都失败"
        return 1
    fi
}

# 生成静态文件
generate_static_files() {
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
    print_info "准备部署到GitHub..."
    
    # 推送hexo分支
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
    local deploy_github="${1:-false}"
    
    print_info "=== 开始部署流程 ==="
    
    # 步骤1: 推送源码到阿里云
    print_info "步骤1: 同步源码到阿里云"
    if ! safe_git_push "aliyun" "hexo" "hexo"; then
        print_error "阿里云源码同步失败"
        return 1
    fi
    
    # 步骤2: 生成静态文件
    print_info "步骤2: 生成静态文件"
    if ! generate_static_files; then
        return 1
    fi
    
    # 步骤3: 部署到阿里云
    print_info "步骤3: 部署到阿里云"
    if ! deploy_to_aliyun; then
        print_error "阿里云部署失败"
        return 1
    fi
    
    # 步骤4: 部署到GitHub（可选）
    if [ "$deploy_github" = true ]; then
        print_info "步骤4: 部署到GitHub"
        if ! deploy_to_github; then
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
                print_info "检测到参数 -g，将部署到 GitHub"
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
    
    print_info "工作目录: $(pwd)"
    
    # 前置检查
    print_info "执行前置检查..."
    
    # 检查必要命令
    for cmd in git node npm hexo; do
        if ! check_command "$cmd"; then
            return 1
        fi
    done
    
    # 检查Hexo目录
    if ! check_hexo_dir; then
        return 1
    fi
    
    # 检查Git状态
    if ! check_git_status; then
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
    
    # 执行部署（使用timeout防止挂起）
    local deploy_result
    if timeout "$DEPLOY_TIMEOUT" bash -c "
        source \"$0\"
        if main_deploy \"$deploy_github\"; then
            exit 0
        else
            exit 1
        fi
    "; then
        deploy_result=0
        echo -e "\n${GREEN}========================================${NC}"
        echo -e "${GREEN}          部署成功完成！              ${NC}"
        echo -e "${GREEN}========================================${NC}"
    else
        deploy_result=$?
        if [ "$deploy_result" -eq 124 ]; then
            echo -e "\n${RED}========================================${NC}"
            echo -e "${RED}          部署超时！                   ${NC}"
            print_error "部署过程超过 ${DEPLOY_TIMEOUT} 秒"
            echo -e "${RED}========================================${NC}"
        else
            echo -e "\n${RED}========================================${NC}"
            echo -e "${RED}          部署失败！                   ${NC}"
            echo -e "${RED}========================================${NC}"
        fi
    fi
    
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

# 如果直接运行脚本，则执行main函数
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
    exit $?
fi
```

这是我修改了很多次的脚本，功能比较完善、也比较安全，能够处理一些多电脑协同式面对的一些冲突问题。



## 四、新电脑加入协作流程

### 1. 新电脑首次配置

```bash
# 1. 安装基础环境（Node.js, Git, Hexo CLI）
# 2. 克隆阿里云服务器上的源码
git clone -b hexo git@47.121.28.192:/home/git/repos/hexo.git my-blog
cd my-blog

# 3. 添加GitHub作为备用远程仓库
git remote add github git@github.com:Corazon-hacker/Corazon-hacker.github.io.git

# 4. 安装依赖
npm install

# 5. 测试运行
hexo clean && hexo g && hexo s
```

### 2. 新电脑日常同步工作流

创建同步脚本 `sync-workflow.sh`：

```bash
#!/bin/bash

# 工作流：开始工作前同步
echo "=== 开始工作前同步 ==="

# 1. 拉取阿里云最新源码（主仓库）
echo "从阿里云服务器拉取更新..."
git pull aliyun hexo

# 2. 尝试从GitHub拉取（可选）
read -p "是否从GitHub拉取更新？(y/N): " pull_github
if [[ "$pull_github" =~ ^[Yy]$ ]]; then
    echo "从GitHub拉取更新..."
    git pull github hexo
fi

# 3. 解决可能的冲突
if [ -n "$(git status --porcelain)" ]; then
    echo "发现未提交的更改，请处理："
    git status
    read -p "按回车继续..."
fi

echo "=== 同步完成，可以开始工作 ==="
```





本文参考：
