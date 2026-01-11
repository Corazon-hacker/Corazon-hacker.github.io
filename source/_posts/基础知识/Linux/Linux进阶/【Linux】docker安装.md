---
title: 【Linux】docker安装
comments: true
abbrlink: b1246162
categories:
  - 基础知识
  - Linux
  - Linux进阶
date: 2025-07-10 22:10:54
tags:
description:
top:
---

## docker安装

1. **关闭安全程序**

```bash
systemctl stop firewalld
systemctl stop iptables
systemctl disable firewalld
systemctl disable iptable
iptables -F

查看selinux是否关闭
getenforce 
如果看到是disabled就说明关闭了
如果看到enforcing就证明开着

修改
sed -i '7s#enforcing#disabled#g' /etc/selinux/config
生效
setenforce 0
```

2. **让时间同步**

```bash
yum install -y ntp ntpdate
ntpdate cn.pool.ntp.org

执行计划任务
crontab -e
* * * * * /usr/sbin/ntpdate  cn.pool.ntp.org &>/dev/null

重启计划任务
systemctl restart crond
```

3. **安装基础依赖程序**

```bash
yum clean all && yum makecache
yum install -y device-mapper-persistent-data lvm2 wget net-tools nfs-utils lrzsz gcc gcc-c++ make cmake libxml2-devel openssl-devel curl curl-devel unzip sudo ntp libaio-devel wget vim ncurses-devel autoconf automake zlib-devel  python-devel epel-release openssh-server socat  ipvsadm conntrack telnet ipvsadm  yum-utils
```

4. **安装阿里云docker源**

```bash
yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo

安装docker：
yum install docker-ce -y

安装完毕后可以执行
docker version
查看docker版本

启动并开机运行docker
systemctl start docker && systemctl enable docker

检查docker是否启动成功
systemctl status docker
看到running就是成功了
```

5. **修改内核参数**

```bash
modprobe br_netfilter
cat > /etc/sysctl.d/docker.conf <<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF

修改完查看确认无误
cat /etc/sysctl.d/docker.conf

生效：
sysctl -p /etc/sysctl.d/docker.conf

确认内核状态
lsmod | grep br_netfilter

重启后会失效，为了防止此情况
vim /etc/sysconfig/modules/br_netfilter.modules
编写内容：
modprobe br_netfilter
保存退出

给他执行权限
chmod +x /etc/sysconfig/modules/br_netfilter.modules

创建一个脚本文件：
vim /etc/rc.sysinit
内容：
#!/bin/bash
for file in /etc/sysconfig/modules/*.modules
do
  [ -x $file ] && $file
done
保存退出
可以通过reboot命令重启服务器查看是否生效
```





本文参考：
