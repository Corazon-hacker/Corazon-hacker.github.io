---
title: 【Linux】Linux初始配置
categories:
  - 基础知识
  - Linux
description: 本文介绍在阿里云服务器刚开始装好Linux系统之后的配置
comments: true
abbrlink: 3e2ea1d0
date: 2026-01-30 03:25:12
tags:
top:
---

## 命令行样式修改

```bash
#!/bin/bash
# PS1 Color Installer for Ubuntu 24 - Simplified Version

# 备份原配置
BACKUP_FILE=~/.bashrc.backup.$(date +%Y%m%d_%H%M%S)
cp ~/.bashrc $BACKUP_FILE 2>/dev/null

# Ubuntu系统全局配置
GLOBAL_BASHRC="/etc/bash.bashrc"
CURRENT_USER=$(whoami)

if [ "$CURRENT_USER" = "root" ]; then
    # 备份全局配置
    if [ -f "$GLOBAL_BASHRC" ]; then
        cp "$GLOBAL_BASHRC" "${GLOBAL_BASHRC}.backup.$(date +%Y%m%d_%H%M%S)" 2>/dev/null
    fi
fi

# 定义颜色
# 普通用户PS1：褐色中括号，绿色用户名，蓝色主机名，青色当前目录，白色时间
PS1_USER='PS1='"'"'\[\033[38;5;130m\][\[\033[01;37m\]\t\[\033[38;5;130m\] \[\033[01;32m\]\u\[\033[01;34m\]@\h\[\033[38;5;130m\] \[\033[01;36m\]\W\[\033[38;5;130m\]]\[\033[00m\]\\$ '"'"''

# Root用户PS1：褐色中括号，红色用户名，蓝色主机名，青色当前目录，白色时间
PS1_ROOT='PS1='"'"'\[\033[38;5;130m\][\[\033[01;37m\]\t\[\033[38;5;130m\] \[\033[01;31m\]\u\[\033[01;34m\]@\h\[\033[38;5;130m\] \[\033[01;36m\]\W\[\033[38;5;130m\]]\[\033[00m\]\\# '"'"''

# 清理当前用户的原有PS1设置
sed -i '/^PS1=/d' ~/.bashrc 2>/dev/null
sed -i '/^export PS1/d' ~/.bashrc 2>/dev/null

# 在当前用户的.bashrc中添加条件判断
echo "" >> ~/.bashrc
echo "# Colorful PS1 (installed $(date))" >> ~/.bashrc
echo 'if [ "$(id -u)" -eq 0 ]; then' >> ~/.bashrc
echo "    $PS1_ROOT" >> ~/.bashrc
echo "else" >> ~/.bashrc
echo "    $PS1_USER" >> ~/.bashrc
echo "fi" >> ~/.bashrc
echo "export PS1" >> ~/.bashrc

# 如果是root用户，修改全局配置
if [ "$CURRENT_USER" = "root" ]; then
    # 清理全局配置中的原有PS1设置
    sed -i '/^PS1=/d' "$GLOBAL_BASHRC" 2>/dev/null
    sed -i '/^export PS1/d' "$GLOBAL_BASHRC" 2>/dev/null
    
    # 在全局配置中添加相同的条件判断
    echo "" >> "$GLOBAL_BASHRC"
    echo "# Colorful PS1 (installed $(date))" >> "$GLOBAL_BASHRC"
    echo 'if [ "$(id -u)" -eq 0 ]; then' >> "$GLOBAL_BASHRC"
    echo "    $PS1_ROOT" >> "$GLOBAL_BASHRC"
    echo "else" >> "$GLOBAL_BASHRC"
    echo "    $PS1_USER" >> "$GLOBAL_BASHRC"
    echo "fi" >> "$GLOBAL_BASHRC"
    echo "export PS1" >> "$GLOBAL_BASHRC"
fi

# 应用配置并刷新bash
source ~/.bashrc 2>/dev/null
exec bash
```



## 设置主机名

```bash
sudo hostnamectl set-hostname newhostname
```

更改主机名脚本：

```bash
cat > ~/change_hostname.sh << 'EOF'
#!/bin/bash
# 主机名修改脚本

echo "当前主机名: $(hostname)"
echo ""

# 显示可用主机名建议
echo "可选主机名示例:"
echo "1. myserver"
echo "2. aliyun-server"
echo "3. web01"
echo "4. dev-$(date +%m%d)"
echo ""

read -p "请输入新主机名: " newname

if [ -z "$newname" ]; then
    echo "错误: 主机名不能为空!"
    exit 1
fi

# 备份原配置
sudo cp /etc/hostname /etc/hostname.backup.$(date +%Y%m%d)
sudo cp /etc/hosts /etc/hosts.backup.$(date +%Y%m%d)

# 修改主机名
echo "正在修改主机名为: $newname"
sudo hostnamectl set-hostname "$newname"

# 修改hosts文件
if grep -q "127.0.1.1" /etc/hosts; then
    sudo sed -i "s/127\.0\.1\.1.*/127.0.1.1\t$newname/" /etc/hosts
else
    echo "127.0.1.1\t$newname" | sudo tee -a /etc/hosts
fi

echo ""
echo "✅ 修改完成!"
echo "新主机名: $(hostname)"
echo ""
echo "请执行以下命令使修改生效:"
echo "1. 重新登录SSH: exit 然后重新连接"
echo "2. 或者执行: exec bash"
EOF

# 赋予执行权限
chmod +x ~/change_hostname.sh
```





## 

本文参考：
