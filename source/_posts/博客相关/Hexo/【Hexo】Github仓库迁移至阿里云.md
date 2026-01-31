---
title: 【Hexo】Github仓库迁移至阿里云
comments: true
abbrlink: 5be5b614
date: 2026-01-31 12:40:36
categories:
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

# ========== 样式定义 ==========
# 颜色定义
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
PURPLE='\033[1;35m'
CYAN='\033[1;36m'
WHITE='\033[1;37m'
NC='\033[0m'

# 字符样式
CHECK="[✓]"
CROSS="[✗]"
INFO="[i]"
WARN="[!]"
ARROW="->"
BRANCH="branch:"
CLOCK="time:"
FOLDER="dir:"
GLOBE="url:"
FILE="file:"
USER="user:"
GEAR="config:"
ROCKET="DEPLOY"
SUCCESS="[OK]"
ERROR="[ERR]"

# 进度条函数
progress_bar() {
    local width=50
    local percent=$1
    local filled=$((width * percent / 100))
    local empty=$((width - filled))
    
    printf "\["
    for ((i=0; i<filled; i++)); do printf "="; done
    for ((i=0; i<empty; i++)); do printf " "; done
    printf "] %3d%%" $percent
}

# ========== 配置区域 ==========
GIT_REPO="/home/git/repos/hexo.git"
MASTER_DEPLOY_DIR="/www/wwwroot/mcorazon.top"
HEXO_SOURCE_DIR="/var/www/hexo-source"
SITE_URL="http://47.121.28.192"
DOMAIN_NAME="mcorazon.top"
WEB_USER="www-data"
WEB_GROUP="www-data"
LOG_DIR="/var/log/hexo-deploy"
LOG_FILE="$LOG_DIR/deploy-$(date +%Y%m%d-%H%M%S).log"

# ========== 初始化 ==========
mkdir -p "$LOG_DIR"

# 清屏并显示横幅
clear
echo -e "${BLUE}"
echo "=========================================================================="
echo "  _   _  _____  _   _  ____   ____   _____  _      _____  _   _  _____"
echo " | | | ||  ___|| \\ | |/ ___| / ___| | ____|| |    | ____|| \\ | ||  ___|"
echo " | |_| || |__  |  \\| |\\___ \\| |     |  _|  | |    |  _|  |  \\| || |__"
echo " |  _  ||  __| | . \` | ___) | |___  | |___ | |___ | |___ | |\\  ||  __|"
echo " |_| |_||_|    |_|\\_||____/ \\____| |_____||_____||_____||_| \\_||_|"
echo "=========================================================================="
echo -e "${NC}"
echo -e "${CYAN}$CLOCK 部署开始时间: $(date '+%Y-%m-%d %H:%M:%S')${NC}"
echo -e "${CYAN}$GEAR 服务器地址: $SITE_URL${NC}"
echo -e "${PURPLE}==========================================================================${NC}"

# 日志函数
log_message() {
    local level=$1
    local message=$2
    local timestamp=$(date '+%H:%M:%S')
    
    case $level in
        "SUCCESS")
            echo -e "${GREEN}[$timestamp] $SUCCESS $message${NC}" ;;
        "ERROR")
            echo -e "${RED}[$timestamp] $ERROR $message${NC}" ;;
        "WARN")
            echo -e "${YELLOW}[$timestamp] $WARN $message${NC}" ;;
        "INFO")
            echo -e "${CYAN}[$timestamp] $INFO $message${NC}" ;;
        "DEBUG")
            echo -e "${PURPLE}[$timestamp] $GEAR $message${NC}" ;;
        "STEP")
            echo -e "${BLUE}[$timestamp] $ARROW $message${NC}" ;;
        *)
            echo -e "[$timestamp] $message" ;;
    esac
    
    # 记录到日志文件（无颜色）
    echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
}

handle_error() {
    log_message "ERROR" "部署失败: $1"
    echo -e "\n${RED}==========================================================================${NC}"
    echo -e "${RED}   $ERROR 部署过程中出现错误！${NC}"
    echo -e "${RED}==========================================================================${NC}"
    exit 1
}

# ========== 主程序开始 ==========
log_message "STEP" "开始处理 Git 推送事件"

# 解析推送信息
while read oldrev newrev refname
do
    branch=$(echo $refname | sed 's/^refs\/heads\///')
    
    echo -e "\n${BLUE}------------------------------------------------------------------${NC}"
    echo -e "${WHITE}[+] 接收到新的推送${NC}"
    echo -e "${BLUE}------------------------------------------------------------------${NC}"
    echo -e "  $BRANCH ${CYAN}$branch${NC}"
    echo -e "  [diff] 变更: ${oldrev:0:8} -> ${newrev:0:8}"
    
    case "$branch" in
        "master")
            echo -e "\n${GREEN}========== 开始部署静态网站 ==========${NC}"
            
            # 检查部署目录
            if [ ! -d "$MASTER_DEPLOY_DIR" ]; then
                log_message "WARN" "部署目录不存在，正在创建"
                echo -e "  $FOLDER $MASTER_DEPLOY_DIR"
                mkdir -p "$MASTER_DEPLOY_DIR" || handle_error "无法创建部署目录"
            fi
            
            # 显示进度
            log_message "STEP" "准备部署环境"
            echo -e "  ${CYAN}|--${NC} 目标目录: $MASTER_DEPLOY_DIR"
            
            # 备份现有网站
            if [ -d "$MASTER_DEPLOY_DIR" ] && [ "$(ls -A $MASTER_DEPLOY_DIR 2>/dev/null)" ]; then
                BACKUP_DIR="/tmp/hexo-backup-$(date +%Y%m%d-%H%M%S)"
                log_message "INFO" "正在备份现有网站"
                cp -r "$MASTER_DEPLOY_DIR" "$BACKUP_DIR" 2>/dev/null && {
                    BACKUP_SIZE=$(du -sh "$BACKUP_DIR" | cut -f1)
                    echo -e "  ${CYAN}|--${NC} 备份完成: $BACKUP_SIZE 大小"
                } || log_message "WARN" "备份失败，继续部署"
            fi
            
            # 清理目录
            log_message "STEP" "清理部署目录"
            cd "$MASTER_DEPLOY_DIR"
            if [ -d ".git" ]; then
                find . -maxdepth 1 ! -name '.' ! -name '.git' -exec rm -rf {} \; 2>/dev/null || true
            else
                rm -rf "$MASTER_DEPLOY_DIR"/*
            fi
            echo -e "  ${CYAN}|--${NC} 目录清理完成"
            
            # 检出代码
            log_message "STEP" "检出 master 分支"
            echo -n "  ${CYAN}|--${NC} 正在检出 "
            for i in {1..3}; do
                echo -n "."
                sleep 0.3
            done
            echo ""
            
            if git --work-tree="$MASTER_DEPLOY_DIR" --git-dir="$GIT_REPO" checkout -f master; then
                log_message "SUCCESS" "代码检出成功"
            else
                handle_error "检出 master 分支失败"
            fi
            
            # 设置权限
            log_message "STEP" "设置文件权限"
            chown -R $WEB_USER:$WEB_GROUP "$MASTER_DEPLOY_DIR" 2>/dev/null && \
            chmod -R 755 "$MASTER_DEPLOY_DIR" 2>/dev/null && {
                echo -e "  ${CYAN}|--${NC} 权限设置完成"
            } || log_message "WARN" "权限设置失败，继续..."
            
            # 验证部署
            log_message "STEP" "验证部署结果"
            if [ -f "$MASTER_DEPLOY_DIR/index.html" ]; then
                FILE_COUNT=$(find "$MASTER_DEPLOY_DIR" -type f | wc -l)
                DIR_SIZE=$(du -sh "$MASTER_DEPLOY_DIR" | cut -f1)
                echo -e "  ${GREEN}|--${NC} $FILE 发现 index.html"
                echo -e "  ${GREEN}|--${NC} $FILE 文件总数: $FILE_COUNT"
                echo -e "  ${GREEN}\`--${NC} $FOLDER 目录大小: $DIR_SIZE"
                
                echo -e "\n${GREEN}$ROCKET 静态网站部署完成！${NC}"
            else
                log_message "WARN" "未找到 index.html 文件"
            fi
            ;;
            
        "hexo")
            echo -e "\n${PURPLE}========== 开始处理源码更新 ==========${NC}"
            
            if [ -n "$HEXO_SOURCE_DIR" ] && [ "$HEXO_SOURCE_DIR" != "" ]; then
                log_message "STEP" "检出 hexo 分支源码"
                echo -e "  ${PURPLE}|--${NC} 目标目录: $HEXO_SOURCE_DIR"
                
                if [ ! -d "$HEXO_SOURCE_DIR" ]; then
                    mkdir -p "$HEXO_SOURCE_DIR"
                    echo -e "  ${PURPLE}|--${NC} 创建源码目录"
                fi
                
                if git --work-tree="$HEXO_SOURCE_DIR" --git-dir="$GIT_REPO" checkout -f hexo; then
                    log_message "SUCCESS" "源码检出成功"
                    
                    # 统计信息
                    POST_COUNT=$(find "$HEXO_SOURCE_DIR/source/_posts" -name "*.md" 2>/dev/null | wc -l || echo 0)
                    CONFIG_FILES=$(find "$HEXO_SOURCE_DIR" -name "*config*.yml" 2>/dev/null | wc -l)
                    
                    echo -e "  ${PURPLE}|--${NC} $FILE 文章数量: $POST_COUNT"
                    echo -e "  ${PURPLE}|--${NC} $GEAR 配置文件: $CONFIG_FILES"
                    
                    if [ $POST_COUNT -gt 0 ]; then
                        LATEST_POST=$(find "$HEXO_SOURCE_DIR/source/_posts" -name "*.md" -printf "%T+ %p\n" 2>/dev/null | sort -r | head -1 | cut -d' ' -f2-)
                        if [ -n "$LATEST_POST" ]; then
                            POST_NAME=$(basename "$LATEST_POST" .md)
                            echo -e "  ${PURPLE}\`--${NC} 最新文章: $POST_NAME"
                        fi
                    fi
                    
                    echo -e "\n${PURPLE}[*] 源码同步完成！${NC}"
                else
                    log_message "ERROR" "源码检出失败"
                fi
            else
                log_message "INFO" "hexo 分支已更新（未配置源码检出）"
            fi
            
            # 显示提交信息
            if [ "$oldrev" != "0000000000000000000000000000000000000000" ]; then
                COMMIT_COUNT=$(git --git-dir="$GIT_REPO" log --oneline "$oldrev..$newrev" | wc -l)
                if [ $COMMIT_COUNT -gt 0 ]; then
                    echo -e "\n${CYAN}[log] 本次更新包含 $COMMIT_COUNT 个提交${NC}"
                    echo -e "${CYAN}-----------------------------------${NC}"
                    git --git-dir="$GIT_REPO" log --oneline --abbrev-commit "$oldrev..$newrev" | head -5 | while read line; do
                        echo -e "  ${WHITE}*${NC} $line"
                    done
                    if [ $COMMIT_COUNT -gt 5 ]; then
                        echo -e "  ${WHITE}... 还有 $((COMMIT_COUNT-5)) 个提交${NC}"
                    fi
                fi
            fi
            ;;
            
        *)
            echo -e "\n${YELLOW}$WARN 未知分支: $branch${NC}"
            echo -e "  ${YELLOW}\`--${NC} 支持的部署分支：master（静态网站），hexo（源码）"
            ;;
    esac
done

# ========== 部署总结 ==========
echo -e "\n${GREEN}==========================================================================${NC}"
echo -e "${WHITE}[+] 部署执行完成 ${NC}"
echo -e "${GREEN}==========================================================================${NC}"

# 显示分支状态
echo -e "${CYAN}$BRANCH 仓库分支状态${NC}"
echo -e "${CYAN}-----------------------------------${NC}"
git --git-dir="$GIT_REPO" branch -avv | while read line; do
    if echo "$line" | grep -q "*"; then
        echo -e "  ${GREEN}$ARROW $line${NC}" | sed 's/\*/ /'
    elif echo "$line" | grep -q "master"; then
        echo -e "  ${BLUE}$FILE $line${NC}"
    elif echo "$line" | grep -q "hexo"; then
        echo -e "  ${PURPLE}$FOLDER $line${NC}"
    else
        echo -e "  ${WHITE}* $line${NC}"
    fi
done

# 显示访问信息
echo -e "\n${CYAN}$GLOBE 访问信息${NC}"
echo -e "${CYAN}-----------------------------------${NC}"
echo -e "  ${WHITE}|--${NC} 网站地址: ${BLUE}$SITE_URL${NC}"
echo -e "  ${WHITE}|--${NC} 域名绑定: ${BLUE}$DOMAIN_NAME${NC}"
if [ -d "$MASTER_DEPLOY_DIR" ]; then
    DEPLOY_TIME=$(date '+%H:%M:%S')
    echo -e "  ${WHITE}|--${NC} 部署时间: ${GREEN}$DEPLOY_TIME${NC}"
    
    # 检查网站访问
    if command -v curl &> /dev/null; then
        echo -n "  ${WHITE}\`--${NC} 状态检查: "
        HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" -m 5 "$SITE_URL" || echo "000")
        case $HTTP_CODE in
            200) echo -e "${GREEN}在线 (200 OK)${NC}" ;;
            404) echo -e "${YELLOW}页面未找到 (404)${NC}" ;;
            000) echo -e "${RED}无法访问${NC}" ;;
            *) echo -e "${YELLOW}状态码: $HTTP_CODE${NC}" ;;
        esac
    fi
fi

# 显示日志信息
echo -e "\n${CYAN}$FILE 日志信息${NC}"
echo -e "${CYAN}-----------------------------------${NC}"
echo -e "  ${WHITE}|--${NC} 本次日志: $LOG_FILE"
echo -e "  ${WHITE}\`--${NC} 日志目录: $LOG_DIR"

# 显示快速命令
echo -e "\n${CYAN}$GEAR 常用命令${NC}"
echo -e "${CYAN}-----------------------------------${NC}"
echo -e "  ${WHITE}*${NC} 查看最新日志: ${GREEN}tail -f $LOG_FILE${NC}"
echo -e "  ${WHITE}*${NC} 克隆源码分支: ${GREEN}git clone -b hexo $GIT_REPO${NC}"
echo -e "  ${WHITE}*${NC} 手动部署网站: ${GREEN}cd $MASTER_DEPLOY_DIR && git pull${NC}"

# 底部装饰
echo -e "\n${BLUE}==========================================================================${NC}"
echo -e "${WHITE}[*] 所有操作已完成于: $(date '+%Y-%m-%d %H:%M:%S')${NC}"
echo -e "${BLUE}==========================================================================${NC}"

# 清理旧日志
find "$LOG_DIR" -name "*.log" -mtime +7 -delete 2>/dev/null || true
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

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# 解析命令行参数
deploy_github="n"
for arg in "$@"; do
    case $arg in
        g|G)
            deploy_github="y"
            echo -e "${CYAN}✓ 检测到参数 g，将部署到 GitHub${NC}"
            ;;
        *)
            echo -e "${YELLOW}⚠ 未知参数: $arg${NC}"
            ;;
    esac
done

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}        Hexo 双平台部署脚本             ${NC}"
echo -e "${BLUE}========================================${NC}"

# 检查是否在 Hexo 目录
if [ ! -f "_config.yml" ]; then
    echo -e "${RED}错误：请在 Hexo 根目录运行此脚本${NC}"
    exit 1
fi

# 函数：简单快速的冲突检查
quick_conflict_check() {
    echo -e "${YELLOW}快速检查阿里云状态...${NC}"
    
    # 只检查是否能连接到远程，不拉取内容
    if timeout 5 git ls-remote aliyun hexo >/dev/null 2>&1; then
        echo -e "${GREEN}✓ 可以连接到阿里云${NC}"
        return 0
    else
        echo -e "${YELLOW}⚠ 无法连接到阿里云，继续执行...${NC}"
        return 0
    fi
}

# 函数：解决阿里云推送冲突（保留你原来的逻辑）
resolve_aliyun_conflict() {
    echo -e "${YELLOW}检测到阿里云推送冲突，正在解决...${NC}"
    
    # 保存当前工作
    git stash
    
    # 拉取阿里云最新代码到临时分支
    git fetch aliyun hexo:aliyun-remote
    
    # 切回hexo分支，使用ours策略合并（完全保留本地）
    git checkout hexo
    git merge -s ours aliyun-remote -m "合并阿里云远程分支，保留本地内容"
    
    # 强制推送
    git push aliyun hexo:hexo --force
    
    # 恢复之前的工作
    git stash pop
    
    echo -e "${GREEN}✓ 冲突已解决并推送成功${NC}"
}

# 第一步：快速冲突检查
quick_conflict_check

# 第二步：同步源码到阿里云服务器
echo -e "${YELLOW}[1/5] 同步源码到阿里云服务器...${NC}"

# 同步到阿里云 hexo 分支
echo -e "同步到阿里云服务器 (hexo分支)..."
if git push aliyun hexo:hexo 2>/dev/null; then
    echo -e "${GREEN}✓ 阿里云源码同步成功${NC}"
else
    # 推送失败，尝试解决冲突
    echo -e "${YELLOW}检测到阿里云推送冲突，自动解决中...${NC}"
    resolve_aliyun_conflict
fi

# 第三步：生成和部署静态文件到阿里云
echo -e "\n${YELLOW}[2/5] 清理旧文件...${NC}"
hexo clean

echo -e "${YELLOW}[3/5] 生成静态文件...${NC}"
hexo generate
if [ $? -ne 0 ]; then
    echo -e "${RED}错误：生成失败！请检查错误信息${NC}"
    exit 1
fi

# 第四步：部署到阿里云服务器（主要）
echo -e "${YELLOW}[4/5] 部署到阿里云服务器 (master分支)...${NC}"
cd public

# 初始化或更新阿里云仓库（用你原来的逻辑，不拉取内容）
if [ -d ".git" ]; then
    # 如果已有git仓库，直接使用
    echo -e "${CYAN}public目录已有git仓库${NC}"
else
    echo -e "${CYAN}初始化public为git仓库...${NC}"
    git init
    git remote add aliyun git@47.121.28.192:/home/git/repos/hexo.git
fi

# 添加所有文件
git add -A

if git diff --cached --quiet && [ -d ".git" ]; then
    echo -e "${YELLOW}提示：没有文件变更${NC}"
else
    git commit -m "更新: $(date '+%Y年%m月%d日 %H:%M')" >/dev/null 2>&1 || git commit -m "更新: $(date '+%Y年%m月%d日 %H:%M')"
    
    if git push aliyun master:master --force; then
        echo -e "${GREEN}✓ 阿里云部署成功${NC}"
    else
        echo -e "${RED}✗ 阿里云部署失败${NC}"
    fi
fi

cd ..

# 第五步：根据参数决定是否部署到 GitHub
if [ "$deploy_github" = "y" ] || [ "$deploy_github" = "Y" ]; then
    echo -e "\n${CYAN}=== 开始GitHub部署流程 ===${NC}"
    
    # 5.1 同步源码到 GitHub hexo 分支
    echo -e "${YELLOW}[5.1/5] 同步源码到 GitHub (hexo分支)...${NC}"
    if git push origin hexo; then
        echo -e "${GREEN}✓ GitHub 源码同步成功${NC}"
    else
        echo -e "${YELLOW}⚠ GitHub 源码同步失败，继续尝试静态部署...${NC}"
    fi
    
    # 5.2 部署静态文件到 GitHub master 分支
    echo -e "${YELLOW}[5.2/5] 部署静态文件到 GitHub (master分支)...${NC}"
    cd public
    
    # 检查是否已有 GitHub 远程仓库
    if [ ! "$(git remote get-url github 2>/dev/null)" ]; then
        git remote add github git@github.com:Corazon-hacker/Corazon-hacker.github.io.git
    fi
    
    if git push github master:master --force; then
        echo -e "${GREEN}✓ GitHub 静态文件部署成功${NC}"
    else
        echo -e "${YELLOW}⚠ GitHub 静态文件部署失败${NC}"
    fi
    
    cd ..
    echo -e "${CYAN}=== GitHub部署流程完成 ===${NC}"
else
    echo -e "\n${YELLOW}[5/5] 跳过 GitHub 部署${NC}"
fi

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}          部署流程完成！             ${NC}"
echo -e "${GREEN}========================================${NC}"
echo -e "${BLUE}主要部署：${NC}"
echo -e "阿里云服务器: ${BLUE}http://47.121.28.192${NC}"
echo -e "服务器路径: ${BLUE}/www/wwwroot/mcorazon.top${NC}"

if [ "$deploy_github" = "y" ] || [ "$deploy_github" = "Y" ]; then
    echo -e "${BLUE}\n备用部署：${NC}"
    echo -e "GitHub Pages: ${BLUE}https://Corazon-hacker.github.io${NC}"
fi

# 部署状态总结
echo -e "\n${PURPLE}部署状态总结：${NC}"
echo -e "源码分支(hexo):"
echo -e "  - 阿里云: ${GREEN}已同步${NC}"
if [ "$deploy_github" = "y" ] || [ "$deploy_github" = "Y" ]; then
    echo -e "  - GitHub: ${GREEN}已同步${NC}"
else
    echo -e "  - GitHub: ${YELLOW}未同步${NC}"
fi

echo -e "网站分支(master):"
echo -e "  - 阿里云: ${GREEN}已部署${NC}"
if [ "$deploy_github" = "y" ] || [ "$deploy_github" = "Y" ]; then
    echo -e "  - GitHub: ${GREEN}已部署${NC}"
else
    echo -e "  - GitHub: ${YELLOW}未部署${NC}"
fi

echo -e "\n${BLUE}使用说明：${NC}"
echo -e "只部署阿里云: ${GREEN}./deploy.sh${NC}"
echo -e "同时部署GitHub: ${GREEN}./deploy.sh g${NC}"
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
