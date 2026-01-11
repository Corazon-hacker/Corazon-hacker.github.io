---
title: 【Linux】mihomo代理
comments: true
abbrlink: f4ca21fa
categories:
  - 基础知识
  - Linux
  - Linux进阶
tags:
  - Linux
date: 2025-02-27 11:53:43
description:
top:
---

## mihomo

阿里云服务器每次访问外网都超时，之前安装工具都是先下载到本地再上传到服务器。前些天复现漏洞下个镜像拖来拖去的，实在是忍无可忍了。网上看了各种文章，尝试了各种方法，最后使用了mihomo代理成功访问外网。

<!-- more -->

### mihomo安装

1. mihomo下载，github地址：https://github.com/MetaCubeX/mihomo

```bash
1. 因为没法访问外网，要先下载到本地，再传到服务器。
2. gzip -d mihomo.gz          #解压缩
3. mv mihomo /usr/local/bin/mihomo   #将 mihomo 移动到 /usr/local/bin/ 目录：
4. sudo chmod +x /usr/local/bin/mihomo  #设置可执行权限
```

经过上述步骤以后，要在为mihomo添加配置文件config.yaml和Country.mmdb。Country.mmdb我是在在github上找的。

2.创建 systemd 配置文件 `/etc/systemd/system/mihomo.service`，并添加如下内容：

```bash
[Unit]
Description=mihomo Daemon, Another Clash Kernel.
After=network.target NetworkManager.service systemd-networkd.service iwd.service

[Service]
Type=simple
LimitNPROC=500
LimitNOFILE=1000000
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_RAW CAP_NET_BIND_SERVICE CAP_SYS_TIME CAP_SYS_PTRACE CAP_DAC_READ_SEARCH CAP_DAC_OVERRIDE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_RAW CAP_NET_BIND_SERVICE CAP_SYS_TIME CAP_SYS_PTRACE CAP_DAC_READ_SEARCH CAP_DAC_OVERRIDE
Restart=always
ExecStartPre=/usr/bin/sleep 1s
ExecStart=/usr/local/bin/mihomo -d /etc/mihomo
ExecReload=/bin/kill -HUP $MAINPID

[Install]
WantedBy=multi-user.target
```

3. 创建配置文件。mihomo和clash meta用的是相同的内核，因此这个配置文件和我本地Windows系统用的clash meta是一样的。我创建的配置文件在/etc/mihomo/config.yaml。但是这个配置文件需要按个性修改，我会在后文介绍他的更全面的功能，部分细节如下：

```bash
[11:42:20 root@rocky95 ~]# head -n 20 /etc/mihomo/config.yaml 
mixed-port: 7890
allow-lan: true
bind-address: '*'
mode: rule
log-level: info
external-controller: '127.0.0.1:9090'
unified-delay: true
tcp-concurrent: true
dns:
........
proxies:
.........
```

4. 重启systemd

```bash
systemctl daemon-reload
```

5. 启用 mihomo 服务：

```bash
systemctl enable mihomo
```

### mihomo使用

```bash
1. 启用 mihomo 服务：
systemctl enable mihomo
2. 立即启动 mihomo:
systemctl start mihomo
3. 重新加载mihomo
systemctl reload mihomo
4. 检查 mihomo 的运行状况
systemctl status mihomo
5. 检查 mihomo 的运行日志
journalctl -u mihomo -o cat -e
或
journalctl -u mihomo -o cat -f
6. 关闭 mihomo 服务：
systemctl disable mihomo
```

## 为Linux设置代理

### 临时启用和关闭代理

在使用Linux时，临时启用代理的命令：

```bash
export http_proxy=http://username:password@ip:port
export https_proxy=http://username:password@ip:port
```

ip和port为你的代理服务器的ip以及开放的端口。

取消代理：

```bash
unset http_proxy
unset https_proxy
```

### 永久全局代理

永久全局代理将临时启用代理的命令添加至系统配置文件中，source刷新shell环境即可。

1. 修改系统配置文件

`vim /etc/profile` 添加以下代码：

```bash
export http_proxy=http://username:password@ip:port
export https_proxy=https://username:password@ip:port
```

`source /etc/profile` 是配置文件生效



### 设置代理的基本语法

```bash
`环境变量
http_proxy:为http变量设置代理;默认不填开头以http协议传输
# 示例
`以下是常见的基本语法
http_proxy=ip:port
http_proxy=http://ip:port
http_proxy=socks4://ip:port
http_proxy=socks5://ip:port
​
`如果不想设置白名单,也可以使用用户名和密码进行验证
http_proxy=http://username:password@ip:port
http_proxy=http://username:password@ip:port
​
https_proxy:为https设置代理
ftp_proxy:为ftp设置代理
all_proxy:全部变量设置代理,设置了这个的时候上面不需要设置
no_proxy:无需代理的主机或域名;可以使用通配符,多个时使用","号分隔
# 示例：
*.aiezu.com,10.*.*.*,192.168.*.*
*.local,localhost,127.0.0.1
```

### 部署Web控制面板

部署好了mihomo代理以后，在虚拟机上切换节点、重载配置等较为不便，可以为mihomo部署控制面板，方便管理。但如果服务器暴露在公网中，使用Web面板会很不安全。因此把Web面板设置成只能本地发开就可以了，我们可以通过SSH协议链接服务器再打开Web面板。

1. 在config.yaml中添加或修改如下配置：

```bash
external-controller: '127.0.0.1:7891'#0.0.0.0所有ip都可访问
secret: "*******"  #设置密码更加保险
external-ui: /etc/mihomo/ui #web页面存放地址
```

2. 从github下载

```bash
sudo git clone https://github.com/metacubex/metacubexd.git -b gh-pages /etc/mihomo/ui
```

3. 重启mihomo服务

```bash
sudo systemctl restart mihomo
```

4. 远程连接访问

```
#首先通过SSH连接我们的服务器
ssh -L port:localhost:port user@ip
#然后在浏览器打开 http://localhost:7891/ui/ 就可以啦
```

如果`external-controller`设置成 `0.0.0.0` 就直接访问http://ip:port/ui（不建议）

## docker使用网络代理

Docker守护进程默认不会使用系统环境变量中的代理设置，需要单独配置。

gitbook上有一篇docker的详解：[Docker — 从入门到实践](https://yeasy.gitbook.io/docker_practice/)

- 为 docker 创建配置文件夹。


```bash
sudo mkdir -p /etc/systemd/system/docker.service.d
```

- 为 dockerd 创建 HTTP/HTTPS 网络代理的配置文件，文件路径是 /etc/systemd/system/docker.service.d/http-proxy.conf 。并在该文件中添加相关环境变量。


```bash
[Service]
Environment="HTTP_PROXY=http://user:password@ip:port/"
Environment="HTTPS_PROXY=http://user:password@ip:port/"
Environment="NO_PROXY=localhost,127.0.0.1,.example.com"
```

<font class=notice>注意：如果没有密码就不添加 `user:password@` （建议设置密码）</font>

- 刷新配置并重启 docker 服务。


```bash
sudo systemctl daemon-reload
sudo systemctl restart docker
```

<font class=notice>注意：使用 `docker info` 可以查看docker配置信息</font>

经过我不断的测试，我本地的电脑总是会出现无法使用服务器的代理访问外网的情况，通常需要我进入Web控制页面换几个代理才可以。这样一来非常的麻烦，因此我放弃了这么操作。为了方便，当我的本地机器（虚拟机）需要使用代理时，直接使用我主机的代理。而为了云服务器的安全，直接将云服务器的代理对外关闭了。

## 客户端使用代理

因为代理是部署在服务器的，因此自己的手机、电脑、平板等也可以使用服务器的代理。修改配置文件allow-lan改为true即可（危险）。

```bash
allow-lan: true
authentication:
  - "user:password"   # 格式：用户名:密码（可配置多组）
```

但是不得不说，如果你的服务器在公网，那么这是一件很危险的事情，因此至少需要给你的代理设置密码，也可以绑定IP白名单。

我试了一下，如果手机不用工具的话使用用户名密码访问不了公网，需要安装代理工具。

## 详细配置说明

```bash
# ==== 核心代理配置 ====
# 混合代理端口（同时支持 HTTP 和 SOCKS5 协议）
mixed-port: 7890  # 客户端（浏览器/Docker等）通过此端口连接代理
# 是否允许局域网内其他设备连接代理（如果本机在公网，那就都可以连接了）
allow-lan: true   # true:允许同一局域网设备使用代理 | false:仅本机可用
# 绑定地址（* 表示允许所有网络接口，包括公网和本地）
bind-address: '*'# 若需限制访问IP，可改为 127.0.0.1（仅本机）或特定IP
# 代理模式（rule:基于规则分流 | global:全局代理 | direct:直连）
mode: rule

# ==== 日志配置 ====
# 日志级别（debug/info/warning/error/silent）
log-level: info
# 日志文件路径（需确保目录存在且 mihomo 有写入权限）建议定期清理或配置 logrotate
log-file: /var/log/mihomo.log  #日志保存地址
#远程连接时使用的用户和密码（可以多个）密码务必高强度

# ==== 代理认证配置 ====
# HTTP/SOCKS5 代理的客户端认证（非控制面板密码）
authentication:
  - "user1:pass1"   # 格式：用户名:密码（可配置多组）
  # - "user2:pass2"          # 客户端连接需填写对应用户名密码

# ==== 控制面板配置 ====
# Web 控制面板监听地址（强烈建议绑定到 127.0.0.1 避免公网暴露）
#0.0.0.0表示所有ip均可访问
#127.0.0.1表示只有本机可以访问
external-controller: '127.0.0.1:7891'  
secret: "********"  #web页面密码，访问 http://IP:7891/ui 时需输入此密码，建议高强度
external-ui: /etc/mihomo/ui # Web 面板静态文件路径（需确保目录存在）

# ==== 高级网络配置 ====
# 统一延迟测试（true:所有节点同时测速 | false:按需测速）
unified-delay: true
# 启用 TCP 并发连接提升速度（可能增加服务器负载）
tcp-concurrent: true
dns:
.................
proxies:
.................
rule：
.................
```

## 遇到的问题：

1. 网上说mihomo的配置文件和clash是一样的，因此要把订阅链接转换成clash的订阅链接，可是我转换后并不能成功使用。经过进一步的了解得知mihomo是clash meta的更新，随后转成meta链接成功（在订阅链接后加`&flag=meta`）。

2. 为docker更换源、使用阿里加速器。然而尝试了各种源均没有什么卵用，只有个别镜像拉取成功，并且就算docker配置成功了，我还是没办法直接下载github的资源。

3. 使用clash代理，然而我花好久终于要整好的时候，clash并不支持我的配置文件中`type: hysteria2`，也就是不支持hysteria2协议。一时间手足无措，最后在一篇文章里看到mihomo支持，最后配置成功。

本文参考：

[Docker — 从入门到实践](https://yeasy.gitbook.io/docker_practice/)
