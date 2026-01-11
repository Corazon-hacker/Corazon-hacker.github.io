---
title: 【Linux】磁盘管理
comments: true
categories:
  - 基础知识
  - Linux
  - Linux基础
tags:
  - Linux
abbrlink: bdf9e69e
date: 2025-02-20 16:51:58
description:
top:
---

### Linux 磁盘管理

Linux磁盘管理常用三个命令为df、du和fdisk。

- df：列出文件系统的整体磁盘使用量
- du：检查磁盘空间使用量
- fdisk：用于磁盘分区

<!-- more -->

------

#### df

获取硬盘被占用了多少空间，目前还剩下多少空间等信息。

语法：

```bash
df [-ahikHTm] [目录或文件名]
```

选项与参数：

- -a ：列出所有的文件系统，包括系统特有的 /proc 等文件系统；
- -k ：以 KBytes 的容量显示各文件系统；
- -m ：以 MBytes 的容量显示各文件系统；
- -h ：以人们较易阅读的 GBytes, MBytes, KBytes 等格式自行显示；
- -H ：以 M=1000K 取代 M=1024K 的进位方式；
- -T ：显示文件系统类型, 连同该 partition 的 filesystem 名称 (例如 ext3) 也列出；
- -i ：不用硬盘容量，而以 inode 的数量来显示

```bash
[root@rocky8:~]# df -Th
Filesystem          Type      Size  Used Avail Use% Mounted on
devtmpfs            devtmpfs  854M     0  854M   0% /dev
tmpfs               tmpfs     874M     0  874M   0% /dev/shm
tmpfs               tmpfs     874M  8.7M  865M   1% /run
tmpfs               tmpfs     874M     0  874M   0% /sys/fs/cgroup
/dev/mapper/rl-root xfs        70G  2.9G   68G   5% /
/dev/sda1           xfs      1014M  199M  816M  20% /boot
/dev/mapper/rl-home xfs       127G  939M  126G   1% /home
tmpfs               tmpfs     175M     0  175M   0% /run/user/0
```

将系统内的所有特殊文件格式及名称都列出来

```bash
[root@rocky8:~]# df -aT
Filesystem          Type       1K-blocks    Used Available Use% Mounted on
sysfs               sysfs              0       0         0    - /sys
proc                proc               0       0         0    - /proc
devtmpfs            devtmpfs      874420       0    874420   0% /dev
securityfs          securityfs         0       0         0    - /sys/kernel/security
tmpfs               tmpfs         894176       0    894176   0% /dev/shm
devpts              devpts             0       0         0    - /dev/pts
tmpfs               tmpfs         894176    8896    885280   1% /run
tmpfs               tmpfs         894176       0    894176   0% /sys/fs/cgroup
cgroup              cgroup             0       0         0    - /sys/fs/cgroup/systemd
pstore              pstore             0       0         0    - /sys/fs/pstore
bpf                 bpf                0       0         0    - /sys/fs/bpf
...................
```

#### du

du命令是对文件和目录磁盘使用的空间的查看。du命令用于统计目录或文件所占磁盘空间的大小，该命令的执行结果与df类似，du更侧重于磁盘的使用状况。

语法：

```bash
du [选项] 文件或目录名称
```

选项与参数：

- -a ：列出所有的文件与目录容量，因为默认仅统计目录底下的文件量而已。
- -h ：以人们较易读的容量格式 (G/M) 显示；
- -s ：列出总量而已，而不列出每个各别的目录占用容量；
- -S ：不包括子目录下的总计，与 -s 有点差别。
- -k ：以 KBytes 列出容量显示；
- -m ：以 MBytes 列出容量显示；

du直接加文件，可以打印文件的大小

```bash
[root@rocky8:~]# du 1.txt 
4	1.txt
[root@rocky8:~]# du -h 1.txt 
4.0K	1.txt
```

du没有加任何选项时，只列出当前目录下的所有文件夹容量（包括隐藏文件夹）:

```bash
[root@rocky8:~]# du
0	./test1     <==每个目录都会列出来
0	./test2
0	./test3
0	./.config/procps   <==包括隐藏文件的目录
0	./.config/htop
0	./.config
44	.           <==这个目录(.)所占用的总量
```

直接输入 du 没有加任何选项时，则 du 会分析当前所在目录的文件与目录所占用的硬盘空间。

加`-a`选项才显示文件的容量：

```bash
[root@rocky8:~]# du -a
4	./.bash_logout
4	./.bash_profile
4	./.bashrc
4	./.cshrc
....中间省略....
0	./.config/htop
0	./.config
44	.
```

检查根目录底下每个目录所占用的容量

```bash
[root@rocky8:~]# du -sh /*
0	/bin
159M	/boot
0	/dev
25M	/etc
.....中间省略....
0	/proc
.....中间省略....
8.0K	/tmp
2.1G	/usr
253M	/var
```

#### fdisk

**!!!   为保证我的Linux系统的正常使用，从磁盘分割和格式化及其以后的内容，暂未编写博客   !!!**

fdisk 是 Linux 的磁盘分区表操作工具。

语法：

```bash
fdisk [-l] 装置名称
```

选项与参数：

- -l ：输出后面接的装置所有的分区内容。若仅有 fdisk -l 时， 则系统将会把整个系统内能够搜寻到的装置的分区均列出来。

列出所有分区信息：

```bash
[root@rocky8:~]# fdisk -l
Disk /dev/sda: 200 GiB, 214748364800 bytes, 419430400 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0x9d182722

Device     Boot   Start       End   Sectors  Size Id Type
/dev/sda1  *       2048   2099199   2097152    1G 83 Linux
/dev/sda2       2099200 419430399 417331200  199G 8e Linux LVM


Disk /dev/mapper/rl-root: 70 GiB, 75161927680 bytes, 146800640 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes


Disk /dev/mapper/rl-swap: 2 GiB, 2168455168 bytes, 4235264 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes


Disk /dev/mapper/rl-home: 127 GiB, 136340045824 bytes, 266289152 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
```

查看根目录所在磁盘，并查阅该硬盘内的相关信息：

```bash
[root@rocky8:~]# df /            <==注意：重点在找出磁盘文件名而已
Filesystem          1K-blocks    Used Available Use% Mounted on
/dev/mapper/rl-root  73364480 2995664  70368816   5% /
[root@rocky8:~]# fdisk /dev/mapper/rl-root  <==不要加上数字！

Welcome to fdisk (util-linux 2.32.1).
Changes will remain in memory only, until you decide to write them.
Be careful before using the write command.

The old xfs signature will be removed by a write command.

Device does not contain a recognized partition table.
Created a new DOS disklabel with disk identifier 0xbb210c3d.

Command (m for help):      <==等待你的输入！
```

输入 m 后，就会看到底下这些命令介绍

```
Command (m for help): m

Help:

  DOS (MBR)
   a   toggle a bootable flag
   b   edit nested BSD disklabel
   c   toggle the dos compatibility flag

  Generic
   d   delete a partition            <==删除一个partition
   F   list free unpartitioned space
   l   list known partition types
   n   add a new partition           <==新增一个partition
   p   print the partition table     <==在屏幕上显示分割表
   t   change a partition type
   v   verify the partition table
   i   print information about a partition

  Misc
   m   print this menu
   u   change display/entry units
   x   extra functionality (experts only)

  Script
   I   load disk layout from sfdisk script file
   O   dump disk layout to sfdisk script file

  Save & Exit
   w   write table to disk and exit  <==将刚刚的动作写入分割表
   q   quit without saving changes   <==不储存离开fdisk程序

  Create a new label
   g   create a new empty GPT partition table
   G   create a new empty SGI (IRIX) partition table
   o   create a new empty DOS partition table
   s   create a new empty Sun partition table
```

离开 fdisk 时按下 `q`，那么所有的动作都不会生效！相反的， 按下`w`就是动作生效的意思。

这个是我的本地虚拟机：

```bash
Command (m for help): p  <== 这里可以输出目前磁盘的状态
Disk /dev/mapper/rl-root: 70 GiB, 75161927680 bytes, 146800640 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0xbb210c3d
Command (m for help): q
```

这个是我的云服务器：

```
Command (m for help): p

Disk /dev/vda: 40 GiB, 42949672960 bytes, 83886080 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: gpt
Disk identifier: 8E31C5C4-D56B-4F46-A42F-54B90BC33E0C

Device      Start      End  Sectors  Size Type
/dev/vda1    2048     4095     2048    1M BIOS boot
/dev/vda2    4096   208895   204800  100M EFI System
/dev/vda3  208896 83886046 83677151 39.9G Linux filesystem
Command (m for help): q
```

这个是本博客转载原文：

```
Command (m for help): p  <== 这里可以输出目前磁盘的状态

Disk /dev/hdc: 41.1 GB, 41174138880 bytes        <==这个磁盘的文件名与容量
255 heads, 63 sectors/track, 5005 cylinders      <==磁头、扇区与磁柱大小
Units = cylinders of 16065 * 512 = 8225280 bytes <==每个磁柱的大小

   Device Boot      Start         End      Blocks   Id  System
/dev/hdc1   *           1          13      104391   83  Linux
/dev/hdc2              14        1288    10241437+  83  Linux
/dev/hdc3            1289        1925     5116702+  83  Linux
/dev/hdc4            1926        5005    24740100    5  Extended
/dev/hdc5            1926        2052     1020096   82  Linux swap / Solaris
# 装置文件名 启动区否 开始磁柱    结束磁柱  1K大小容量 磁盘分区槽内的系统

Command (m for help): q
```

使用 `p` 可以列出目前这颗磁盘的分割表信息，这个信息的上半部在显示整体磁盘的状态。

#### 磁盘格式化

磁盘分割完毕后自然就是要进行文件系统的格式化，格式化的命令非常的简单，使用 `mkfs`（make filesystem） 命令。

语法：

```bash
mkfs [-t 文件系统格式] 装置文件名
```

选项与参数：

- -t ：可以接文件系统格式，例如 ext3, ext2, vfat 等(系统有支持才会生效)

查看 mkfs 支持的文件格式：

```bash
[root@VM_0_9_centos web]# mkfs[tab]
mkfs         mkfs.cramfs  mkfs.ext3    mkfs.minix   
mkfs.btrfs   mkfs.ext2    mkfs.ext4    mkfs.xfs
```

按下两个[tab]，会发现 mkfs 支持的文件格式如上所示。

将分区 /dev/hdc6（可指定其他分区） 格式化为ext3文件系统：

```
[root@www ~]# mkfs -t ext3 /dev/hdc6
mke2fs 1.39 (29-May-2006)
Filesystem label=                <==这里指的是分割槽的名称(label)
OS type: Linux
Block size=4096 (log=2)          <==block 的大小配置为 4K 
Fragment size=4096 (log=2)
251392 inodes, 502023 blocks     <==由此配置决定的inode/block数量
25101 blocks (5.00%) reserved for the super user
First data block=0
Maximum filesystem blocks=515899392
16 block groups
32768 blocks per group, 32768 fragments per group
15712 inodes per group
Superblock backups stored on blocks:
        32768, 98304, 163840, 229376, 294912

Writing inode tables: done
Creating journal (8192 blocks): done <==有日志记录
Writing superblocks and filesystem accounting information: done

This filesystem will be automatically checked every 34 mounts or
180 days, whichever comes first.  Use tune2fs -c or -i to override.
# 这样就创建起来我们所需要的 Ext3 文件系统了！简单明了！
1234567891011121314151617181920212223
```

#### 磁盘检验

fsck（file system check）用来检查和维护不一致的文件系统。

若系统掉电或磁盘发生问题，可利用fsck命令对文件系统进行检查。

语法：

```
fsck [-t 文件系统] [-ACay] 装置名称
```

选项与参数：

- -t : 给定档案系统的型式，若在 /etc/fstab 中已有定义或 kernel 本身已支援的则不需加上此参数
- -s : 依序一个一个地执行 fsck 的指令来检查
- -A : 对/etc/fstab 中所有列出来的 分区（partition）做检查
- -C : 显示完整的检查进度
- -d : 打印出 e2fsck 的 debug 结果
- -p : 同时有 -A 条件时，同时有多个 fsck 的检查一起执行
- -R : 同时有 -A 条件时，省略 / 不检查
- -V : 详细显示模式
- -a : 如果检查有错则自动修复
- -r : 如果检查有错则由使用者回答是否修复
- -y : 选项指定检测每个文件是自动输入yes，在不确定那些是不正常的时候，可以执行 # fsck -y 全部检查修复。

查看系统有多少文件系统支持的 fsck 命令：

```
[root@www ~]# fsck[tab][tab]
fsck         fsck.cramfs  fsck.ext2    fsck.ext3    fsck.msdos   fsck.vfat
12
```

强制检测 /dev/hdc6 分区:

```
[root@www ~]# fsck -C -f -t ext3 /dev/hdc6 
fsck 1.39 (29-May-2006)
e2fsck 1.39 (29-May-2006)
Pass 1: Checking inodes, blocks, and sizes
Pass 2: Checking directory structure
Pass 3: Checking directory connectivity
Pass 4: Checking reference counts
Pass 5: Checking group summary information
vbird_logical: 11/251968 files (9.1% non-contiguous), 36926/1004046 blocks
123456789
```

如果没有加上 -f 的选项，则由于这个文件系统不曾出现问题，检查的经过非常快速！若加上 -f 强制检查，才会一项一项的显示过程。

#### 磁盘挂载与卸除

Linux 的磁盘挂载使用 `mount` 命令，卸载使用 `umount` 命令。

磁盘挂载语法：

```
mount [-t 文件系统] [-L Label名] [-o 额外选项] [-n]  装置文件名  挂载点
1
```

用默认的方式，将刚刚创建的 /dev/hdc6 挂载到 /mnt/hdc6 上面！

```
[root@www ~]# mkdir /mnt/hdc6
[root@www ~]# mount /dev/hdc6 /mnt/hdc6
[root@www ~]# df
Filesystem           1K-blocks      Used Available Use% Mounted on
.....中间省略.....
/dev/hdc6              1976312     42072   1833836   3% /mnt/hdc6
123456
```

磁盘卸载命令 `umount` 语法：

```
umount [-fn] 装置文件名或挂载点
1
```

选项与参数：

- -f ：强制卸除！可用在类似网络文件系统 (NFS) 无法读取到的情况下；
- -n ：不升级 /etc/mtab 情况下卸除。

卸载/dev/hdc6

```
[root@www ~]# umount /dev/hdc6     
1
```



本文参考：
