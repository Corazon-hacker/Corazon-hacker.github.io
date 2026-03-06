#!/bin/bash

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}        Hexo 双分支部署脚本           ${NC}"
echo -e "${BLUE}========================================${NC}"

# ========== 安全推送函数 ==========
# 用法：safe_push <remote_name> <branch_name>
safe_push() {
    local remote=$1
    local branch=$2
    echo -e "${YELLOW}正在检查 $remote/$branch 状态...${NC}"
    
    # 获取远程最新信息
    git fetch "$remote" "$branch" 2>/dev/null
    
    # 获取本地和远程 commit 哈希
    local local_commit=$(git rev-parse "$branch" 2>/dev/null)
    local remote_commit=$(git rev-parse "$remote/$branch" 2>/dev/null)
    
    # 如果远程分支不存在
    if [ -z "$remote_commit" ]; then
        echo -e "${YELLOW}远程分支 $remote/$branch 不存在，将创建并推送...${NC}"
        if git push -u "$remote" "$branch"; then
            echo -e "${GREEN}✓ 成功创建并推送到 $remote/$branch${NC}"
            return 0
        else
            echo -e "${RED}✗ 推送失败${NC}"
            return 1
        fi
    fi
    
    # 比较本地和远程
    if [ "$local_commit" = "$remote_commit" ]; then
        echo -e "${GREEN}✓ 本地 $branch 已经与远程 $remote/$branch 一致，无需推送${NC}"
        return 0
    fi
    
    # 计算领先/落后提交数
    local ahead=$(git rev-list --count "$remote/$branch..$branch" 2>/dev/null)
    local behind=$(git rev-list --count "$branch..$remote/$branch" 2>/dev/null)
    
    if [ "$behind" -gt 0 ]; then
        echo -e "${YELLOW}检测到本地 $branch 落后于远程 $remote/$branch 共 $behind 个提交${NC}"
        echo "请选择操作："
        echo "  1) 拉取远程更改并合并（推荐）"
        echo "  2) 强制推送本地版本（将覆盖远程更改）"
        echo "  3) 跳过此分支的推送"
        read -p "请输入选项 [1/2/3]: " push_choice
        case $push_choice in
            1)
                echo -e "${YELLOW}正在拉取远程更改并合并...${NC}"
                git pull "$remote" "$branch"
                if [ $? -ne 0 ]; then
                    echo -e "${RED}拉取合并失败，请手动解决冲突后重新运行脚本${NC}"
                    exit 1
                fi
                echo -e "${YELLOW}拉取完成，现在推送...${NC}"
                git push "$remote" "$branch"
                ;;
            2)
                echo -e "${YELLOW}强制推送中...${NC}"
                git push -f "$remote" "$branch"
                ;;
            3)
                echo -e "${YELLOW}已跳过推送到 $remote/$branch${NC}"
                return 0
                ;;
            *)
                echo -e "${RED}无效选项，跳过推送${NC}"
                return 1
                ;;
        esac
    elif [ "$ahead" -gt 0 ]; then
        echo -e "${GREEN}本地领先远程 $ahead 个提交，直接推送...${NC}"
        git push "$remote" "$branch"
    else
        # 理论上不会到这里，但以防万一
        echo -e "${YELLOW}未知状态，尝试推送...${NC}"
        git push "$remote" "$branch"
    fi
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ 成功推送到 $remote/$branch${NC}"
    else
        echo -e "${RED}✗ 推送到 $remote/$branch 失败${NC}"
        return 1
    fi
}

# ========== 初始化检查 ==========
# 检查是否在 Hexo 目录
if [ ! -f "_config.yml" ]; then
    echo -e "${RED}错误：请在 Hexo 根目录运行此脚本${NC}"
    exit 1
fi

# 检查当前分支
current_branch=$(git symbolic-ref --short HEAD 2>/dev/null)
if [ "$current_branch" != "hexo" ]; then
    echo -e "${YELLOW}当前不在 hexo 分支，正在切换到 hexo 分支...${NC}"
    git checkout hexo 2>/dev/null || {
        echo -e "${RED}错误：无法切换到 hexo 分支，请确保已初始化 Git 仓库${NC}"
        exit 1
    }
fi

# ========== 第一步：处理本地更改 ==========
echo -e "${YELLOW}[1/5] 检查并提交本地源码更改...${NC}"

# 检查是否有未提交的更改
if ! git diff-index --quiet HEAD --; then
    echo -e "${YELLOW}检测到未提交的更改，正在提交...${NC}"
    
    # 拉取远程更新，避免冲突
    echo -e "${YELLOW}拉取 GitHub 远程更新（hexo 分支）...${NC}"
    git pull origin hexo 2>/dev/null || echo -e "${YELLOW}拉取失败，可能首次运行或无远程${NC}"
    
    # 添加所有更改
    git add .
    
    # 提交更改
    read -p "请输入提交信息（默认为'更新: 自动提交'）: " commit_msg
    commit_msg=${commit_msg:-"更新: 自动提交"}
    git commit -m "$commit_msg"
    echo -e "${GREEN}✓ 本地更改已提交${NC}"
else
    echo -e "${YELLOW}没有检测到本地更改，跳过提交${NC}"
    
    # 确保本地与 GitHub 远程同步
    echo -e "${YELLOW}检查 GitHub 远程更新...${NC}"
    git fetch origin
    local_hash=$(git rev-parse HEAD)
    remote_hash=$(git rev-parse origin/hexo 2>/dev/null)
    
    if [ "$local_hash" != "$remote_hash" ] && [ -n "$remote_hash" ]; then
        echo -e "${YELLOW}发现 GitHub 远程更新，正在拉取...${NC}"
        git pull origin hexo
    fi
fi

# ========== 第二步：推送源码到阿里云 hexo 分支 ==========
echo -e "${YELLOW}[2/5] 推送源码到阿里云 hexo 分支...${NC}"

# 检查并添加阿里云远程仓库（如果尚未添加）
ALIYUN_REMOTE="aliyun"
ALIYUN_URL="git@47.121.28.192:/home/git/repos/hexo.git"

if ! git remote | grep -q "^$ALIYUN_REMOTE$"; then
    echo -e "${YELLOW}添加阿里云远程仓库: $ALIYUN_URL${NC}"
    git remote add "$ALIYUN_REMOTE" "$ALIYUN_URL"
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ 阿里云远程仓库添加成功${NC}"
    else
        echo -e "${RED}✗ 阿里云远程仓库添加失败，请手动检查${NC}"
        exit 1
    fi
fi

# 使用安全推送函数推送到阿里云 hexo 分支
safe_push "$ALIYUN_REMOTE" "hexo"

# ========== 第三步：生成静态文件 ==========
echo -e "${YELLOW}[3/5] 清理并生成静态文件...${NC}"
hexo clean
hexo generate

if [ $? -ne 0 ]; then
    echo -e "${RED}错误：生成失败！请检查错误信息${NC}"
    exit 1
fi
echo -e "${GREEN}✓ 静态文件生成成功${NC}"

# ========== 第四步：部署静态文件到阿里云 master 分支 ==========
echo -e "${YELLOW}[4/5] 部署静态文件到阿里云服务器 master 分支...${NC}"
cd public

# 检查是否已有 git 仓库
if [ -d ".git" ]; then
    # 已有仓库，直接拉取避免冲突
    git pull origin master --rebase 2>/dev/null || true
else
    # 新仓库
    git init
    git remote add origin git@47.121.28.192:/home/git/repos/hexo.git
    git config --local user.email "2208143652@qq.com"
    git config --local user.name "Corazon-hacker"
fi

# 添加所有文件
git add -A

# 检查是否有变更
if git diff --cached --quiet && [ -d ".git" ]; then
    echo -e "${YELLOW}提示：没有文件变更，跳过提交${NC}"
else
    # 提交
    git commit -m "静态文件更新: $(date '+%Y年%m月%d日 %H:%M')" >/dev/null 2>&1 || git commit -m "静态文件更新: $(date '+%Y年%m月%d日 %H:%M')"
    
    # 推送到阿里云 master 分支（强制推送，可根据需要调整）
    echo -e "${YELLOW}正在推送到阿里云服务器 master 分支...${NC}"
    if git push -u origin master --force; then
        echo -e "${GREEN}✓ 阿里云 master 部署成功${NC}"
    else
        echo -e "${RED}✗ 阿里云 master 部署失败${NC}"
        echo "可能的原因："
        echo "1. SSH 密钥未配置"
        echo "2. 服务器仓库路径错误"
        echo "3. 权限问题"
    fi
fi

cd ..

# ========== 第五步：处理 GitHub 推送（询问后） ==========
echo -e "${YELLOW}[5/5] GitHub 相关操作${NC}"

# 询问是否推送源码到 GitHub hexo 分支
read -p "是否推送源码到 GitHub hexo 分支？(y/n, 默认 n): " push_github_src
if [[ "$push_github_src" =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}推送源码到 GitHub hexo 分支...${NC}"
    safe_push "origin" "hexo"
else
    echo -e "${YELLOW}跳过推送源码到 GitHub${NC}"
fi

# 询问是否部署静态文件到 GitHub Pages
read -p "是否部署静态文件到 GitHub Pages？(y/n, 默认 n): " deploy_github
if [[ "$deploy_github" =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}开始部署到 GitHub Pages...${NC}"
    
    # 检查部署配置
    if ! grep -q "deploy:" _config.yml 2>/dev/null; then
        echo -e "${YELLOW}警告：未找到部署配置，正在检查插件...${NC}"
        if [ ! -d "node_modules/hexo-deployer-git" ]; then
            echo -e "${YELLOW}安装 hexo-deployer-git 插件...${NC}"
            npm install hexo-deployer-git --save
        fi
    fi
    
    hexo deploy
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}警告：GitHub Pages 部署失败${NC}"
        echo "可能的原因："
        echo "1. 部署配置错误"
        echo "2. 缺少 hexo-deployer-git 插件"
        echo "3. 网络连接问题"
    else
        echo -e "${GREEN}✓ GitHub Pages 部署成功${NC}"
    fi
else
    echo -e "${YELLOW}跳过 GitHub Pages 部署${NC}"
fi

# ========== 总结信息 ==========
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}          双分支部署完成！           ${NC}"
echo -e "${GREEN}========================================${NC}"
echo -e "部署状态汇总："
echo -e "1. ${GREEN}✓${NC} 本地更改已提交"
echo -e "2. ${GREEN}✓${NC} 源码已同步到阿里云 hexo 分支"
echo -e "3. ${GREEN}✓${NC} 静态文件已部署到阿里云服务器 master 分支"
if [[ "$push_github_src" =~ ^[Yy]$ ]]; then
    echo -e "4. ${GREEN}✓${NC} 源码已同步到 GitHub hexo 分支"
else
    echo -e "4. ${YELLOW}➖${NC} GitHub 源码推送已跳过"
fi
if [[ "$deploy_github" =~ ^[Yy]$ ]]; then
    echo -e "5. ${GREEN}✓${NC} 静态文件已部署到 GitHub Pages"
else
    echo -e "5. ${YELLOW}➖${NC} GitHub Pages 部署已跳过"
fi

echo -e "\n访问地址："
echo -e "阿里云服务器: ${BLUE}http://47.121.28.192${NC}"
echo -e "服务器路径: ${BLUE}/www/wwwroot/mcorazon.top${NC}"
echo -e "GitHub Pages: ${BLUE}https://Corazon-hacker.github.io${NC}"

# 返回到 hexo 分支（如果在 public 目录中切换了）
cd /home/hexo_blog 2>/dev/null || true
git checkout hexo 2>/dev/null || true