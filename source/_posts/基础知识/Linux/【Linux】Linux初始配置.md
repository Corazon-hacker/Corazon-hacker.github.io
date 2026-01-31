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
cat > ~/install_color_ps1.sh << 'EOF'
#!/bin/bash
# PS1 Color Installer

# 备份原配置
BACKUP_FILE=~/.bashrc.backup.$(date +%Y%m%d_%H%M%S)
cp ~/.bashrc $BACKUP_FILE
echo "已备份原配置到: $BACKUP_FILE"

# 显示配色预览
echo ""
echo "请选择配色方案："
echo "1. 经典配色 [默认]"
echo "2. 高对比度"
echo "3. 简约风格"
echo "4. 多色渐变"
echo "5. 自定义输入"
echo ""
read -p "请输入选择 (1-5): " choice

case $choice in
    1)
        PS1_SETTING='PS1='"'"'\[\033[01;32m\][\t\[\033[00m\] \[\033[01;33m\]\u@\h\[\033[00m\] \[\033[01;36m\]\W\[\033[00m\]]\\$ '"'"''
        ;;
    2)
        PS1_SETTING='PS1='"'"'\[\033[01;31m\][\[\033[01;37m\]\t\[\033[01;31m\] \[\033[01;34m\]\u@\h\[\033[01;31m\] \[\033[01;33m\]\W\[\033[01;31m\]]\[\033[01;35m\]\\$\[\033[00m\] '"'"''
        ;;
    3)
        PS1_SETTING='PS1='"'"'\[\033[01;32m\]\t\[\033[00m\] \[\033[01;34m\]\u@\h\[\033[00m\] \[\033[01;33m\]\W\[\033[00m\]\\$ '"'"''
        ;;
    4)
        PS1_SETTING='PS1='"'"'\[\033[38;5;46m\][\[\033[38;5;51m\]\t\[\033[38;5;46m\] \[\033[38;5;226m\]\u@\h\[\033[38;5;46m\] \[\033[38;5;201m\]\W\[\033[38;5;46m\]]\[\033[38;5;196m\]\\$\[\033[00m\] '"'"''
        ;;
    5)
        read -p "请输入自定义PS1: " custom_ps1
        PS1_SETTING='PS1='"'"''"$custom_ps1"''"'"''
        ;;
    *)
        PS1_SETTING='PS1='"'"'\[\033[01;32m\][\t\[\033[00m\] \[\033[01;33m\]\u@\h\[\033[00m\] \[\033[01;36m\]\W\[\033[00m\]]\\$ '"'"''
        ;;
esac

# 清理原有PS1设置（如果有）
sed -i '/^PS1=/d' ~/.bashrc
sed -i '/^export PS1/d' ~/.bashrc

# 添加新的PS1设置
echo "" >> ~/.bashrc
echo "# Colorful PS1 (installed $(date))" >> ~/.bashrc
echo $PS1_SETTING >> ~/.bashrc
echo "export PS1" >> ~/.bashrc

# 应用配置
source ~/.bashrc

echo ""
echo "✅ PS1配置已完成！"
echo "当前提示符样式："
echo $PS1
EOF

# 赋予执行权限并运行
chmod +x ~/install_color_ps1.sh
./install_color_ps1.sh
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
