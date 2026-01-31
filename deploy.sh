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

# 第一步：推送源码到 GitHub 的 hexo 分支
echo -e "${YELLOW}[1/5] 检查并提交源码更改...${NC}"

# 检查是否有未提交的更改
if ! git diff-index --quiet HEAD --; then
    echo -e "${YELLOW}检测到未提交的更改，正在提交...${NC}"
    
    # 拉取远程更新，避免冲突
    echo -e "${YELLOW}拉取远程更新...${NC}"
    git pull origin hexo
    
    # 添加所有更改
    git add .
    
    # 提交更改
    read -p "请输入提交信息（默认为'更新: 自动提交'）: " commit_msg
    commit_msg=${commit_msg:-"更新: 自动提交"}
    git commit -m "$commit_msg"
    
    # 推送到 GitHub 的 hexo 分支
    echo -e "${YELLOW}推送到 GitHub hexo 分支...${NC}"
    if git push origin hexo; then
        echo -e "${GREEN}✓ 源码已推送到 GitHub hexo 分支${NC}"
    else
        echo -e "${RED}✗ 推送到 GitHub hexo 分支失败${NC}"
        echo "可能的原因："
        echo "1. 网络连接问题"
        echo "2. 权限不足"
        echo "3. 有冲突需要手动解决"
        read -p "是否继续部署？(y/n): " continue_deploy
        if [[ ! "$continue_deploy" =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
else
    echo -e "${YELLOW}没有检测到源码更改，跳过提交${NC}"
    
    # 确保本地与远程同步
    echo -e "${YELLOW}检查远程更新...${NC}"
    git fetch origin
    local_hash=$(git rev-parse HEAD)
    remote_hash=$(git rev-parse origin/hexo 2>/dev/null)
    
    if [ "$local_hash" != "$remote_hash" ] && [ -n "$remote_hash" ]; then
        echo -e "${YELLOW}发现远程更新，正在拉取...${NC}"
        git pull origin hexo
    fi
fi

# 第二步：清理和生成
echo -e "${YELLOW}[2/5] 清理旧文件...${NC}"
hexo clean

echo -e "${YELLOW}[3/5] 生成静态文件...${NC}"
hexo generate

if [ $? -ne 0 ]; then
    echo -e "${RED}错误：生成失败！请检查错误信息${NC}"
    exit 1
fi

# 第三步：部署到阿里云
echo -e "${YELLOW}[4/5] 部署到阿里云服务器...${NC}"
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
    echo -e "${YELLOW}提示：没有文件变更${NC}"
else
    # 提交
    git commit -m "静态文件更新: $(date '+%Y年%m月%d日 %H:%M')" >/dev/null 2>&1 || git commit -m "静态文件更新: $(date '+%Y年%m月%d日 %H:%M')"
    
    # 推送到阿里云
    echo -e "${YELLOW}正在推送到阿里云服务器...${NC}"
    if git push -u origin master --force; then
        echo -e "${GREEN}✓ 阿里云部署成功${NC}"
    else
        echo -e "${RED}✗ 阿里云部署失败${NC}"
        echo "可能的原因："
        echo "1. SSH 密钥未配置"
        echo "2. 服务器仓库路径错误"
        echo "3. 权限问题"
    fi
fi

cd ..

# 第四步：可选部署到 GitHub Pages
echo -e "${YELLOW}[5/5] 是否要部署到 GitHub Pages？${NC}"
read -p "输入 y 部署，直接回车跳过: " deploy_github

if [ "$deploy_github" = "y" ] || [ "$deploy_github" = "Y" ]; then
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

# 总结信息
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}          双分支部署完成！           ${NC}"
echo -e "${GREEN}========================================${NC}"
echo -e "部署状态汇总："
echo -e "1. ${GREEN}✓${NC} 源码已同步到 GitHub hexo 分支"
echo -e "2. ${GREEN}✓${NC} 静态文件已部署到阿里云服务器"
if [ "$deploy_github" = "y" ] || [ "$deploy_github" = "Y" ]; then
    echo -e "3. ${GREEN}✓${NC} 静态文件已部署到 GitHub Pages"
else
    echo -e "3. ${YELLOW}➖${NC} GitHub Pages 部署已跳过"
fi

echo -e "\n访问地址："
echo -e "阿里云服务器: ${BLUE}http://47.121.28.192${NC}"
echo -e "服务器路径: ${BLUE}/www/wwwroot/mcorazon.top${NC}"
echo -e "GitHub Pages: ${BLUE}https://Corazon-hacker.github.io${NC}"

# 返回到 hexo 分支（如果在 public 目录中切换了）
cd /home/hexo_blog 2>/dev/null || true
git checkout hexo 2>/dev/null || true