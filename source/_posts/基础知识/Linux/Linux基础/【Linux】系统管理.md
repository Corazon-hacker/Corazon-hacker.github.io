---
title: 【Linux】系统管理
comments: true
categories:
  - 基础知识
  - Linux
  - Linux基础
tags:
  - Linux
abbrlink: dd673edb
date: 2025-02-20 16:15:32
description:
top:
---

## 查看当前日历：cal

cal命令用于查看当前日历，-y显示整年日历：

```bash
python@ubuntu:~$ cal
      十一月 2019        
日 一 二 三 四 五 六  
                1  2  
 3  4  5  6  7  8  9  
10 11 12 13 14 15 16  
17 18 19 20 21 22 23  
24 25 26 27 28 29 30 
```

<!-- more -->

## 显示或设置时间：date

设置时间格式（需要管理员权限）：

```bash
date [MMDDhhmm[[CC]YY][.ss]] +format
```

MM为月，DD为天，hh为小时，mm为分钟；CC为年前两位，YY为年的后两位，ss为秒。

如： date 010203042016.55。

显示时间格式（date ‘+%y,%m,%d,%H,%M,%S’）：

| format格式 | 含义 |
| ---------- | ---- |
| %Y，%y     | 年   |
| %m         | 月   |
| %d         | 日   |
| %H         | 时   |
| %M         | 分   |
| %S         | 秒   |

## 查看网络状态：netstat

netstat命令用于显示网络状态。

利用netstat指令可让你得知整个Linux系统的网络情况。

语法：

```bash
netstat [-acCeFghilMnNoprstuvVwx][-A<网络类型>][--ip]
```

 **参数说明**：

- -a或–all 显示所有连线中的Socket。
- -A<网络类型>或–<网络类型> 列出该网络类型连线中的相关地址。
- -c或–continuous 持续列出网络状态。
- -C或–cache 显示路由器配置的快取信息。
- -e或–extend 显示网络其他相关信息。
- -F或–fib 显示FIB。
- -g或–groups 显示多重广播功能群组组员名单。
- -h或–help 在线帮助。
- -i或–interfaces 显示网络界面信息表单。
- -l或–listening 显示监控中的服务器的Socket。
- -M或–masquerade 显示伪装的网络连线。
- -n或–numeric 直接使用IP地址，而不通过域名服务器。
- -N或–netlink或–symbolic 显示网络硬件外围设备的符号连接名称。
- -o或–timers 显示计时器。
- -p或–programs 显示正在使用Socket的程序识别码和程序名称。
- -r或–route 显示Routing Table。
- -s或–statistice 显示网络工作信息统计表。
- -t或–tcp 显示TCP传输协议的连线状况。
- -u或–udp 显示UDP传输协议的连线状况。
- -v或–verbose 显示指令执行过程。
- -V或–version 显示版本信息。
- -w或–raw 显示RAW传输协议的连线状况。
- -x或–unix 此参数的效果和指定"-A unix"参数相同。
- –ip或–inet 此参数的效果和指定"-A inet"参数相同。

常用：

```bash
[root@rocky8:~]# netstat -nltp
Active Internet connections (only servers)
Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name    
tcp        0      0 0.0.0.0:22              0.0.0.0:*               LISTEN      829/sshd            
tcp6       0      0 :::22                   :::*                    LISTEN      829/sshd
```

## 查看进程信息：ps

进程是一个具有一定独立功能的程序，它是操作系统动态执行的基本单元。

**ps命令选项：**

- ps a 显示现行终端机下的所有程序，包括其他用户的程序。
- ps -A 显示所有程序。
- ps c 列出程序时，显示每个程序真正的指令名称，而不包含路 径，参数或常驻服务的标示。
- ps -e 此参数的效果和指定"A"参数相同。
- ps e 列出程序时，显示每个程序所使用的环境变量。
- ps f 用ASCII字符显示树状结构，表达程序间的相互关系。
- ps -H 显示树状结构，表示程序间的相互关系。
- ps -N 显示所有的程序，除了执行ps指令终端机下的程序之外。
- ps s 采用程序信号的格式显示程序状况。
- ps u 以用户为主的格式来显示程序状况。
- ps x 显示所有程序，不以终端机来区分。

| 选项 | 含义                                     |
| ---- | ---------------------------------------- |
| -a   | 显示终端上的所有进程，包括其他用户的进程 |
| -u   | 显示进程的详细状态                       |
| -x   | 显示没有控制终端的进程                   |
| -w   | 显示加宽，以便显示更多的信息             |
| -r   | 只显示正在运行的进程                     |

**常见用法：**

- ps -e 查看所有进程信息（瞬时的）
- ps -u root -N 查看所有不是root运行的进程
- ps ax 显示所有进程状态状态
- ps -ef |grep xxx 显示含有xxx的进程

实例：

```bash
[root@rocky8:~]# ps -A
    PID TTY          TIME CMD
      1 ?        00:00:01 systemd
      2 ?        00:00:00 kthreadd
……省略部分结果
   2207 ?        00:00:00 kworker/1:1-events
   2208 ?        00:00:00 kworker/0:0-ata_sff
   2215 ?        00:00:00 kworker/0:2-ata_sff
   2217 pts/1    00:00:00 ps
```

显示指定用户信息：

```bash
# ps -u root //显示root进程用户信息
 PID TTY     TIME CMD
  1 ?    00:00:02 init
  2 ?    00:00:00 kthreadd
  3 ?    00:00:00 migration/0
……省略部分结果
30487 ?    00:00:06 gnome-terminal
30488 ?    00:00:00 gnome-pty-helpe
30489 pts/0  00:00:00 bash
```

显示所有进程信息，连同命令行

```bash
# ps -ef //显示所有命令，连带命令行
UID    PID PPID C STIME TTY     TIME CMD
root     1   0 0 10:22 ?    00:00:02 /sbin/init
root     2   0 0 10:22 ?    00:00:00 [kthreadd]
root     3   2 0 10:22 ?    00:00:00 [migration/0]
root     4   2 0 10:22 ?    00:00:00 [ksoftirqd/0]
root     5   2 0 10:22 ?    00:00:00 [watchdog/0]
root     6   2 0 10:22 ?    /usr/lib/NetworkManager
……省略部分结果
root   31302 2095 0 17:42 ?    00:00:00 sshd: root@pts/2 
root   31374 31302 0 17:42 pts/2  00:00:00 -bash
root   31400   1 0 17:46 ?    00:00:00 /usr/bin/python /usr/sbin/aptd
root   31407 31374 0 17:48 pts/2  00:00:00 ps -ef
```

## 以树状图显示进程关系：pstree

显示进程的关系

```bash
[root@rocky8:~]# pstree
systemd─┬─NetworkManager───2*[{NetworkManager}]
        ├─atd
        ├─auditd───{auditd}
        ├─crond
        ├─dbus-daemon───{dbus-daemon}
        ├─firewalld───{firewalld}
        ├─irqbalance───{irqbalance}
        ├─login───bash───su───bash───su───bash
        ├─lsmd
        ├─mcelog
        ├─polkitd───5*[{polkitd}]
        ├─smartd
        ├─sshd─┬─sshd───sshd───bash
        │      └─sshd───sshd───bash───pstree
        ├─systemd───(sd-pam)
        ├─systemd-journal
        ├─systemd-logind
        ├─systemd-udevd
        └─tuned───3*[{tuned}]
        
[root@rocky8:~]# pstree -p
systemd(1)─┬─NetworkManager(816)─┬─{NetworkManager}(821)
           │                     └─{NetworkManager}(823)
           ├─atd(835)
           ├─auditd(768)───{auditd}(769)
           ├─crond(841)
           ├─dbus-daemon(796)───{dbus-daemon}(802)
           ├─firewalld(797)───{firewalld}(1030)
           ├─irqbalance(792)───{irqbalance}(801)
           ├─login(838)───bash(2012)───su(2043)───bash(2044)───su(2072)───bash(2076)
           ├─lsmd(793)
           ├─mcelog(798)
           ├─polkitd(1035)─┬─{polkitd}(1051)
           │               ├─{polkitd}(1052)
           │               ├─{polkitd}(1058)
           │               ├─{polkitd}(1059)
           │               └─{polkitd}(1072)
           ├─smartd(790)
           ├─sshd(829)─┬─sshd(1577)───sshd(1592)───bash(1593)
           │           └─sshd(1859)───sshd(1863)───bash(1864)───pstree(2220)
           ├─systemd(1582)───(sd-pam)(1586)
           ├─systemd-journal(633)
           ├─systemd-logind(794)
           ├─systemd-udevd(662)
           └─tuned(827)─┬─{tuned}(1168)
                        ├─{tuned}(1217)
                        └─{tuned}(1248)
[root@rocky8:~]# pstree -c
systemd─┬─NetworkManager─┬─{NetworkManager}
        │                └─{NetworkManager}
        ├─atd
        ├─auditd───{auditd}
        ├─crond
        ├─dbus-daemon───{dbus-daemon}
        ├─firewalld───{firewalld}
        ├─irqbalance───{irqbalance}
        ├─login───bash───su───bash───su───bash
        ├─lsmd
        ├─mcelog
        ├─polkitd─┬─{polkitd}
        │         ├─{polkitd}
        │         ├─{polkitd}
        │         ├─{polkitd}
        │         └─{polkitd}
        ├─smartd
        ├─sshd─┬─sshd───sshd───bash
        │      └─sshd───sshd───bash───pstree
        ├─systemd───(sd-pam)
        ├─systemd-journal
        ├─systemd-logind
        ├─systemd-udevd
        └─tuned─┬─{tuned}
                ├─{tuned}
                └─{tuned}
```

特别表明在运行的进程：

```bash
# pstree -apnh //显示进程间的关系
```

同时显示用户名称：

```bash
# pstree -u //显示用户名称
```

## 动态显示进程：top

top命令用来动态显示运行中的进程。top命令能够在运行后，在指定的时间间隔更新显示信息。-d参数可以指定显示信息更新的时间间隔。

在top命令执行后，可以按下按键得到对显示的结果进行排序：

| 按键 | 含义                               |
| ---- | ---------------------------------- |
| M    | 根据内存使用量来排序               |
| P    | 根据CPU占有率来排序                |
| T    | 根据进程运行时间的长短来排序       |
| U    | 可以根据后面输入的用户名来筛选进程 |
| K    | 可以根据后面输入的PID来杀死进程。  |
| q    | 退出                               |
| h    | 获得帮助                           |

```bash
[root@rocky8:~]# top
top - 15:40:09 up  4:53,  3 users,  load average: 1.06, 0.72, 0.37
Tasks: 161 total,   2 running, 159 sleeping,   0 stopped,   0 zombie
%Cpu(s):  0.2 us,  0.2 sy,  0.0 ni, 99.5 id,  0.0 wa,  0.2 hi,  0.0 si,  0.0 st
MiB Mem :   1746.4 total,   1230.0 free,    246.9 used,    269.5 buff/cache
MiB Swap:   2068.0 total,   2068.0 free,      0.0 used.   1340.5 avail Mem 

    PID USER      PR  NI    VIRT    RES    SHR S  %CPU  %MEM     TIME+ COMMAND                                                          
    827 root      20   0  618180  31188  15248 S   0.3   1.7   0:30.76 tuned                                                            
      1 root      20   0  175088  13464   9064 S   0.0   0.8   0:01.40 systemd                                                          
      2 root      20   0       0      0      0 S   0.0   0.0   0:00.01 kthreadd                                                         
      3 root       0 -20       0      0      0 I   0.0   0.0   0:00.00 rcu_gp                                                           
      4 root       0 -20       0      0      0 I   0.0   0.0   0:00.00 rcu_par_gp                                                       
      5 root       0 -20       0      0      0 I   0.0   0.0   0:00.00 slub_flushwq 
      ..................
```

更高级的命令是htop，但需要安装：

![htop动态进程](【Linux】系统管理/image-20250220163058799.png)

## 终止进程：kill

kill命令指定进程号的进程，需要配合 ps 使用。

使用格式：

```bash
kill [-signal] pid
```

信号值从0到15，其中9为绝对终止，可以处理一般信号无法终止的进程。

## 关机重启：reboot、shutdown、init

| 命令              | 含义                                       |
| ----------------- | ------------------------------------------ |
| reboot            | 重新启动操作系统                           |
| shutdown –r now   | 重新启动操作系统，shutdown会给别的用户提示 |
| shutdown -h now   | 立刻关机，其中now相当于时间为0的状态       |
| shutdown -h 20:25 | 系统在今天的20:25 会关机                   |
| shutdown -h +10   | 系统再过十分钟后自动关机                   |
| init 0            | 关机                                       |
| init 6            | 重启                                       |

## 查看或配置网卡信息：ifconfig

ifconfig显示所有网卡的信息：

```bash
[root@rocky8:~]# ifconfig
ens160: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 10.0.0.191  netmask 255.255.255.0  broadcast 10.0.0.255
        inet6 fe80::20c:29ff:fee9:9fb3  prefixlen 64  scopeid 0x20<link>
        ether 00:0c:29:e9:9f:b3  txqueuelen 1000  (Ethernet)
        RX packets 34362  bytes 34209026 (32.6 MiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 17179  bytes 1644986 (1.5 MiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

lo: flags=73<UP,LOOPBACK,RUNNING>  mtu 65536
        inet 127.0.0.1  netmask 255.0.0.0
        inet6 ::1  prefixlen 128  scopeid 0x10<host>
        loop  txqueuelen 1000  (Local Loopback)
        RX packets 48  bytes 4080 (3.9 KiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 48  bytes 4080 (3.9 KiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
```

修改ip:

```bash
[root@rocky8:~]# sudo ifconfig ens33 192.168.40.10
```

本文参考：
