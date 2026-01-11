---
title: 【Linux】docker使用
comments: true
abbrlink: 4c00139f
categories:
  - 基础知识
  - Linux
  - Linux进阶
date: 2025-07-10 15:43:09
tags:
description:
top:
---

## 镜像操作

```bash
#能够连接镜像仓库情况下：
docker search centos  #找到相关镜像
#然后：
docker pull centos  #将镜像直接下载到docker里面
docker images  #查看镜像

#现在docker官方镜像仓库不可用，只能使用离线镜像：
#如何使用离线镜像：
#首先将镜像上传到服务器
rz -be上传镜像文件
#上传完毕后，上载到docker里
#容器镜像压缩包不要用tar命令进行解压，要用docker load加载及解压镜像压缩包
docker load -i centos.tar.gz

#查看镜像：
docker images
#删除镜像：
docker rmi [镜像名字]或[镜像ID] [镜像名字]或[镜像ID] ......
```

## 镜像加速

我用了国内镜像源也没用，最后用的本机代理。如果有代理的话直接用代理吧。

**更改国内源：**

```bash
sudo mkdir -p /etc/docker
vim /etc/docker/daemon.json
添加如下内容：
{
    "registry-mirrors":["https://a88u1jg4.mirror.aliyuncs.com","https://docker.lmirror.top","https://docker.m.daocloud.io","https://hub.uuuabc.top","https://docker.anyhub.us.kg","https://dockerhub.jobcher.com","https://dockerhub.icu","https://docker.ckyl.me","https://docker.awsl9527.cn","https://docker.laoex.link"]
}
保存退出
systemctl daemon-reload
systemctl restart docker
```

**使用代理：**

```bash
sudo mkdir -p /etc/systemd/system/docker.service.d
vim /etc/systemd/system/docker.service.d/http-proxy.conf

#添加内容：
[Service]
Environment="HTTP_PROXY=http://user:password@ip:port/"
Environment="HTTPS_PROXY=http://user:password@ip:port/"
Environment="NO_PROXY=localhost,127.0.0.1,.example.com"
#注意改成自己的代理ip和端口，如果没有密码去掉“user:password@”

#刷新配置并重启 docker 服务
sudo systemctl daemon-reload
sudo systemctl restart docker
```



## 容器操作：

基础操作：

```bash
#进入一个镜像容器
docker run --name 容器名称（自己取） -it centos(镜像的名称) /bin/bash(调用环境)
#退出容器
exit
此时退出后，容器就会停止运行

#查看所有的容器，包括停止的
docker ps -a 

#删除容器
docker rm [镜像名字]或[镜像ID]  #（名称不能重复）
#守护形式容器（-d 不会退出就关闭）
docker run --name=xiaoA -td centos /bin/bash

#查看正在运行的容器
docker ps

#进入正在运行的容器
docker exec -it xiaoA /bin/bash
#开启
docker start 容器名（容器ID） 容器名（容器ID） ......
#重启
docker restart 容器名（容器ID） 容器名（容器ID） ......
#停止容器
docker stop 容器名（容器ID） 容器名（容器ID） ......
#强制停止正在运行的容器：
docker kill 容器名（容器ID） 容器名（容器ID） ......
#关闭所有容器：
docker stop $(docker ps -a -q)
#删除所有容器：
docker rm $(docker ps -a -q)
#删除所有镜像
docker rmi $(docker images -q)
#查看容器日志
docker logs 容器名（容器ID）
```

拓展：

```bash
docker cp sourcePath ${containerId}:destinationPath #宿主机拷贝到容器
docker cp ${containerId}:sourcePath destinationPath #容器拷贝到宿主机
docker commit ${containerId} imageName:version      #保存一个容器为镜像
docker save -o destinationPath imageName            #保存image方便传输
docker load -i sourcePath                           #加载一个文件到image
```

## 文件持久化存储

```bash
#创建一个目录
mkdir ~/xiaoX_data
#新建一个容器
docker run --name xiaoC -v ~/xiaoX_data:/data -itd centos /bin/bash
#进入容器
docker exec -it xiaoC /bin/bash
cd /data
#创建一些文件
echo abc >> 1.txt
#通过另一个终端，可以看到文件会出现在/root/xiaoX_data/下面
#所以该文件不会丢失
```

## 如何创建自定义容器

```bash
#先创建一个放dockerfile的文件夹
mkdir -p /root/dockerfile/inter-image
#进入创建的文件夹
cd /root/dockerfile/inter-image 
#创建dockerfile（必须叫这个名字）
touch dockerfile
```

老师给的`dockerfile`内容如下：

```bash
FROM centos
RUN sed -i "s|mirrorlist=|#mirrorlist=|g" /etc/yum.repos.d/CentOS-*
RUN sed -i "s|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g" /etc/yum.repos.d/CentOS-*
RUN yum install wget -y
RUN yum install nginx -y
EXPOSE 80
CMD /bin/bash
```

但是我一直下载不了`centos:latest`，所以做了改动：

```bash
FROM centos:7
# 修复基础仓库地址
RUN sed -i \
    -e "s|mirrorlist=|#mirrorlist=|g" \
    -e "s|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g" \
    /etc/yum.repos.d/CentOS-*
# 安装 EPEL 仓库（nginx所在仓库）
RUN yum install -y epel-release
# 安装所需软件（合并命令减少层数）
RUN yum install -y wget nginx
EXPOSE 80
CMD /bin/bash  # 保持前台运行
```

保存上面内容后退出

```bash
docker build -t "inter-image" .  #构建镜像
```

构建完毕以后该镜像就会生成到docker里

```bash
docker images  #查看镜像
docker save -o 名字.tar.gz 镜像名字 
docker save -o inter-image.tar.gz inter-image 
docker run --name inter-image -v ~/dataxiaoE:/data -itd inter-image  /bin/bash #构建一个容器
docker exec -it inter-image /bin/bash #进入容器
/usr/sbin/nginx -t  #开启nginx服务
ip a
curl ip:80  #访问到nginx欢迎页面
exit  #退出
```

## 容器之间互联

### ip互联

基于上面创建的inter-image镜像分别启动容器test1和test2，并进入到容器中。

查询ip地址即可互联

![image-20250710214550350](【linux】docker使用/image-20250710214550350-17521567889481.png)

开启nginx服务后也可以通过 `curl` 命令连

![image-20250710220009917](【linux】docker使用/image-20250710220009917-17521567983984.png)

### 网络别名互联

定义网络别名（防止容器ip变化了，导致我们访问不到）

```bash
docker run --name test3 -td inter-image  #创建一个测试容器
docker run --name test4 -td --link=test3:webtest inter-image  #创建别名容器
docker exec -it test4 /bin/bash  #进入别名容器
ping webtest #就可以无视test3容器IP变化
```

![image-20250710205010145](【linux】docker使用/image-20250710205010145-175215682419010.png)

## docker的网络权限

host模式：

```
docker run --name host -it --net=host --privileged=true centos:7
ip a  #发现和本机的IP一样
exit  #退出
docker rm host  #删除容器
```

none模式：

```
docker run -td --name none --net=none --privileged=true centos:7
docker exec -it none /bin/bash
ip a  #发现只有lo网卡
exit  #退出
```

## 如何判断是否为docker环境

可以通过：`cat /proc/1/cgroup`命令查看内容

![image-20250710223300288](【linux】docker使用/image-20250710223300288.png)

也可以通过`ls -alh /.dockerenv`查看是否有容器环境文件

```bash
[root@92a79e791862 /]# ls -a /
.   .dockerenv         bin   dev  home  lib64  mnt  proc  run   srv  tmp  var
..  anaconda-post.log  boot  etc  lib   media  opt  root  sbin  sys  usr
[root@92a79e791862 /]# ls -a /.dockerenv  
/.dockerenv
```





本文参考：
