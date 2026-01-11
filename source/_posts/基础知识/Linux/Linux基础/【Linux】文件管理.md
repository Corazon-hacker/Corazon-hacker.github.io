---
title: 【Linux】文件管理
comments: true
categories:
  - 基础知识
  - Linux
  - Linux基础
tags:
  - Linux
abbrlink: 2d0621ba
date: 2025-02-20 15:04:16
description:
top:
---

## Linux目录

![Linux目录](【Linux】文件管理/image-20250219153540620.png)

- /：根目录，一般根目录下只存放目录，在Linux下有且只有一个根目录。所有的东西都是从这里开始。当你在终端里输入“/home”，你其实是在告诉电脑，先从/（根目录）开始，再进入到home目录。
- /bin: /usr/bin: 可执行二进制文件的目录，如常用的命令ls、tar、mv、cat等。
- /boot：放置linux系统启动时用到的一些文件，如Linux的内核文件：/boot/vmlinuz，系统引导管理器：/boot/grub。
- /dev：存放linux系统下的设备文件，访问该目录下某个文件，相当于访问某个设备，常用的是挂载光驱 mount /dev/cdrom /mnt。
- /etc：系统配置文件存放的目录，不建议在此目录下存放可执行文件，重要的配置文件有 /etc/inittab、/etc/fstab、/etc/init.d、/etc/X11、/etc/sysconfig、/etc/xinetd.d。
- /home：系统默认的用户家目录，新增用户账号时，用户的家目录都存放在此目录下，表示当前用户的家目录，edu 表示用户 edu 的家目录。
- /lib: /usr/lib: /usr/local/lib：系统使用的函数库的目录，程序在执行过程中，需要调用一些额外的参数时需要函数库的协助。
- /lost+fount：系统异常产生错误时，会将一些遗失的片段放置于此目录下。
- /mnt: /media：光盘默认挂载点，通常光盘挂载于 /mnt/cdrom 下，也不一定，可以选择任意位置进行挂载。
- /opt：给主机额外安装软件所摆放的目录。
- /proc：此目录的数据都在内存中，如系统核心，外部设备，网络状态，由于数据都存放于内存中，所以不占用磁盘空间，比较重要的目录有 /proc/cpuinfo、/proc/interrupts、/proc/dma、/proc/ioports、/proc/net/* 等。
- /root：系统管理员root的家目录。
- /sbin: /usr/sbin: /usr/local/sbin：放置系统管理员使用的可执行命令，如fdisk、shutdown、mount 等。与 /bin 不同的是，这几个目录是给系统管理员 root使用的命令，一般用户只能"查看"而不能设置和使用。
- /tmp：一般用户或正在执行的程序临时存放文件的目录，任何人都可以访问，重要数据不可放置在此目录下。
- /srv：服务启动之后需要访问的数据目录，如 www 服务需要访问的网页数据存放在 /srv/www 内。
- /usr：应用程序存放目录，/usr/bin 存放应用程序，/usr/share 存放共享数据，/usr/lib  存放不能直接运行的，却是许多程序运行所必需的一些函数库文件。/usr/local: 存放软件升级包。/usr/share/doc:  系统说明文件存放目录。/usr/share/man: 程序说明文件存放目录。
- /var：放置系统执行过程中经常变化的文件，如随时更改的日志文件 /var/log，/var/log/message：所有的登录文件存放目录，/var/spool/mail：邮件存放的目录，/var/run:程序或服务启动后，其PID存放在该目录下。

<!-- more -->

位于/home/user，称之为用户工作目录或家目录,表示方式：

```bash
/home/user
~
```

从/目录开始描述的路径为**绝对路径**，如：

```bash
cd /home
ls /usr
```

从当前位置开始描述的路径为**相对路径**，如：

```bash
cd ../../
ls abc/def
```

每个目录下都有**.和…**

. 表示当前目录

… 表示上一级目录，即父目录

根目录下的.和…都表示当前目录

## 基础操作

#### 输出重定向：>

可将本应显示在终端上的内容保存到指定文件中。

如：ls > test.txt ( test.txt 如果不存在，则创建，存在则覆盖其内容 )

注意： `>输出重定向会覆盖原来的内容，>>输出重定向则会追加到文件的尾部。`

#### 管道：|

管道：一个命令的输出可以通过管道做为另一个命令的输入。

“ | ”的左右分为两端，从左端写入到右端。

```bash
python@ubuntu:/bin$ ll -h |more   
总用量 13M
drwxr-xr-x  2 root root  4.0K 8月   4  2016 ./
drwxr-xr-x 26 root root  4.0K 7月  30  2016 ../
-rwxr-xr-x  1 root root 1014K 6月  24  2016 bash*
-rwxr-xr-x  1 root root   31K 5月  20  2015 bunzip2*
-rwxr-xr-x  1 root root  1.9M 8月  19  2015 busybox*
-rwxr-xr-x  1 root root   31K 5月  20  2015 bzcat*
lrwxrwxrwx  1 root root     6 5月  16  2016 bzcmp -> bzdiff*
-rwxr-xr-x  1 root root  2.1K 5月  20  2015 bzdiff*
lrwxrwxrwx  1 root root     6 5月  16  2016 bzegrep -> bzgrep*
--更多--
```

#### 清屏：clear

clear作用为清除终端上的显示(类似于DOS的cls清屏功能)，快捷键：Ctrl + l ( “l” 为字母 )。

#### 切换工作目录： cd

Linux所有的目录和文件名大小写敏感


cd后面可跟绝对路径，也可以跟相对路径。如果省略目录，则默认切换到当前用户的主目录。

| 命令 | 含义                                   |
| ---- | -------------------------------------- |
| cd   | 相当于cd ~                             |
| cd ~ | 切换到当前用户的主目录(/home/用户目录) |
| cd . | 切换到当前目录                         |
| cd … | 切换到上级目录                         |
| cd - | 进入上次所在的目录                     |

#### 查看命令位置：which

```bash
python@ubuntu:~$ which ls
/bin/ls
python@ubuntu:~$ which sudo
/usr/bin/sudo
```





## 查看文件内容

Linux系统中使用以下命令来查看文件的内容：

- cat 由第一行开始显示文件内容
- tac 从最后一行开始显示
- nl 显示的时候，顺道输出行号
- more 一页一页的显示文件内容
- less与more 类似，但可以往前翻页
- head 只看头几行
- tail 只看尾巴几行

#### 基本显示：cat、tac

语法：

```bash
cat [-AbEnTv]
```

选项与参数：

- -A ：相当于 -vET 的整合选项，可列出一些特殊字符而不是空白而已；
- -v ：列出一些看不出来的特殊字符
- -E ：将结尾的断行字节 $ 显示出来；
- -T ：将 [tab] 按键以 ^I 显示出来；
- -b ：列出行号，空白行不标行号
- -n ：列出行号，连同空白行也会有行号

```bash
[root@rocky8:/]# cat -b /etc/issue
     1	\S
     2	Kernel \r on an \m

[root@rocky8:/]# cat -n /etc/issue
     1	\S
     2	Kernel \r on an \m
     3
```

tac与cat命令刚好相反，文件内容从最后一行开始显示，可以看出 tac 是 cat 的倒着写！如：

```bash
[root@rocky8:/]# tac /etc/issue

Kernel \r on an \m
\S
```

#### 显示行号：nl

语法：

```bash
nl [-bnw] 文件
```

选项与参数：

- -b ：指定行号指定的方式，主要有两种：
  -b a ：表示不论是否为空行，也同样列出行号(类似 cat -n)；
  -b t ：如果有空行，空的那一行不要列出行号(默认值)；
- -n ：列出行号表示的方法，主要有三种：
  -n ln ：行号在荧幕的最左方显示；
  -n rn ：行号在自己栏位的最右方显示，且不加 0 ；
  -n rz ：行号在自己栏位的最右方显示，且加 0 ；
- -w ：行号栏位的占用的位数。

```bash
[root@rocky8:/]# nl /etc/issue
     1	\S
     2	Kernel \r on an \m
       
```

#### 分屏显示：more、less

```bash
[root@rocky8:/]# more /etc/man_db.config 
#
# Generated automatically from man.conf.in by the
# configure script.
#
# man.conf from man-1.6d
....(中间省略)....
--More--(28%)  <== 光标在这里等待命令
```

more运行时可以输入的命令有：

- 空白键 (space)：代表向下翻一页；
- Enter ：代表向下翻『一行』；
- /字串 ：代表在这个显示的内容当中，向下搜寻『字串』这个关键字；
- :f ：立刻显示出档名以及目前显示的行数；
- q ：代表立刻离开 more ，不再显示该文件内容。
- b 或 [ctrl]-b ：代表往回翻页，不过这动作只对文件有用，对管线无用。

```bash
[root@rocky8:/]# less /etc/man.config
#
# Generated automatically from man.conf.in by the
# configure script.
#
# man.conf from man-1.6d
....(中间省略)....
:   <== 这里可以等待你输入命令！
```

less运行时可以输入的命令有：

- 空白键 ：向下翻动一页；
- [pagedown]：向下翻动一页；
- [pageup] ：向上翻动一页；
- /字串 ：向下搜寻『字串』的功能；
- ?字串 ：向上搜寻『字串』的功能；
- n ：重复前一个搜寻 (与 / 或 ? 有关！)
- N ：反向的重复前一个搜寻 (与 / 或 ? 有关！)
- q ：离开 less 这个程序；

#### 取首尾n行：head、tail

head取出文件前面几行

语法：

```bash
head [-n number] 文件 
```

选项与参数：

- -n ：后面接数字，代表显示几行的意思

```bash
[root@rocky8:~]# head /etc/man.config
```

默认的情况中，显示前面 10 行！若要显示前 20 行，就得要这样：

```bash
[root@rocky8:~]# head -n 20 /etc/man.config
```

tail取出文件后面几行

语法：

```bash
tail [-n number] 文件 
```

选项与参数：

- -n ：后面接数字，代表显示几行的意思
- -f ：表示持续侦测后面所接的档名，要等到按下[ctrl]-c才会结束tail的侦测

```bash
[root@rocky8:~]# tail /etc/man.config
# 默认的情况中，显示最后的十行！若要显示最后的 20 行，就得要这样：
[root@rocky8:~]# tail -n 20 /etc/man.config
```

#### 显示当前路径：pwd

```bash
[root@rocky8:~]# pwd
/root
```

选项与参数：

- **-P** ：显示出确实的路径，而非使用连结 (link) 路径。

```bash
[root@rocky8:~]# cd /var/mail
[root@rocky8:mail]# pwd
/var/mail
[root@rocky8:mail]# pwd -P
/var/spool/mail
```

## 文件操作

#### 创建目录：mkdir

mkdir可以创建一个新的目录。

注意：新建目录的名称不能与当前目录中已有的目录或文件同名，并且目录创建者必须对当前目录具有写权限。

语法：

```bash
mkdir [-mp] 目录名称
```

选项与参数：

- -m ：指定被创建目录的权限，而不是根据默认权限 (umask) 设定
- -p ：递归创建所需要的目录

实例：-p递归创建目录：

```bash
[root@rocky8:~]# cd /tmp
[root@rocky8:tmp]# mkdir test	<==创建一名为 test 的新目录
[root@rocky8:tmp]# mkdir test1/test2/test3/test4
mkdir: cannot create directory ‘test1/test2/test3/test4’: No such file or directory		<== 没办法直接创建此目录啊！
[root@rocky8:tmp]# mkdir -p test1/test2/test3/test4
```

mkdir创建的目录权限默认根据umask得到，而-m参数可以指定被创建目录的权限：

```bash
[root@rocky8:~]# mkdir t1
[root@rocky8:~]# ll
total 0
drwxr-xr-x. 2 root root 6 Feb 20 15:06 t1
[root@rocky8:~]# mkdir t2 -m 711
[root@rocky8:~]# ll
total 0
drwxr-xr-x. 2 root root 6 Feb 20 15:06 t1
drwx--x--x. 2 root root 6 Feb 20 15:06 t2
```

#### 删除文件：rm

可通过rm删除文件或目录。使用rm命令要小心，因为文件删除后不能恢复。为了防止文件误删，可以在rm后使用-i参数以逐个确认要删除的文件。

常用参数及含义如下表所示：

| 参数 | 含义                                             |
| ---- | ------------------------------------------------ |
| -i   | 以进行交互式方式执行                             |
| -f   | 强制删除，忽略不存在的文件，无需提示             |
| -r   | 递归地删除目录下的内容，删除文件夹时必须加此参数 |

####ln： 建立链接文件

软链接：ln -s 源文件 链接文件

硬链接：ln 源文件 链接文件

软链接类似于Windows下的快捷方式，如果软链接文件和源文件不在同一个目录，源文件要使用绝对路径，不能使用相对路径。

硬链接只能链接普通文件不能链接目录。 两个文件占用相同大小的硬盘空间，即使删除了源文件，链接文件还是存在，所以-s选项是更常见的形式。

#### rename：修改文件名

rename命令是在Linux和Unix系统中使用的一个命令，用于批量重命名文件或目录。支持正则表达式。基本语法:

```bash
rename [选项] 表达式 替换的字符 文件...
```

命令选项：

```bash
[root@rocky8:~]#rename -h

Usage:
 rename [options] <expression> <replacement> <file>...

Rename files.

Options:
 -v, --verbose       explain what is being done
 -s, --symlink       act on the target of symlinks
 -n, --no-act        do not make any changes
 -o, --no-overwrite  don't overwrite existing files

 -h, --help          display this help
 -V, --version       display version

For more details see rename(1).

```

下面是rename命令的常用选项

```bash
-v, --verbose : 显示详细的操作信息 
-s, --symlink : 对符号链接目标进行操作
-h, --help : 显示帮助信息并退出 
-V, --version : 显示版本信息并退出
```

实例1：

```bash
[root@rocky8:~]#rename -v file afile file0?
`file01' -> `afile01'
`file02' -> `afile02'
`file03' -> `afile03'
`file04' -> `afile04'
`file05' -> `afile05'
`file06' -> `afile06'
`file07' -> `afile07'
`file08' -> `afile08'
`file09' -> `afile09'
```

实例2：

```bash
[root@rocky8:~]#rename file afile *
[root@rocky8:~]#ls
aafile01  aafile09  afile017  afile025  afile033  afile041  afile049  afile057  afile065  afile073  afile081  afile089  afile097......
```



#### grep：文本搜索

Linux系统中grep命令是一种强大的文本搜索工具，grep允许对文本文件进行模式查找。如果找到匹配模式， grep打印包含模式的所有行。

grep一般格式为：

```bash
grep [-选项] '搜索内容串' 文件名
```

在grep命令中输入字符串参数时，最好引号或双引号括起来。例如：`grep 'a' 1.txt`。

在当前目录中，查找前缀有test字样的文件中包含 test 字符串的文件，并打印出该字符串的行。此时，可以使用如下命令：

```bash
$ grep test test* #查找前缀有test的文件包含test字符串的文件  
testfile1:This a Linux testfile! #列出testfile1 文件中包含test字符的行  
testfile_2:This is a linux testfile! #列出testfile_2 文件中包含test字符的行  
testfile_2:Linux test #列出testfile_2 文件中包含test字符的行 
```

以递归的方式查找符合条件的文件。例如，查找指定目录/etc/acpi 及其子目录（如果存在子目录的话）下所有文件中包含字符串"update"的文件，并打印出该字符串所在行的内容，使用的命令为：

```bash
$ grep -r update /etc/acpi #以递归的方式查找“etc/acpi”  
#下包含“update”的文件  
/etc/acpi/ac.d/85-anacron.sh:# (Things like the slocate updatedb cause a lot of IO.)  
Rather than  
/etc/acpi/resume.d/85-anacron.sh:# (Things like the slocate updatedb cause a lot of  
IO.) Rather than  
/etc/acpi/events/thinkpad-cmos:action=/usr/sbin/thinkpad-keys--update 
```

反向查找。前面各个例子是查找并打印出符合条件的行，通过"-v"参数可以打印出不符合条件行的内容。

查找文件名中包含 test 的文件中不包含test 的行，此时，使用的命令为：

```bash
$ grep -v test* #查找文件名中包含test 的文件中不包含test 的行  
testfile1:helLinux!  
testfile1:Linis a free Unix-type operating system.  
testfile1:Lin  
testfile_1:HELLO LINUX!  
testfile_1:LINUX IS A FREE UNIX-TYPE OPTERATING SYSTEM.  
testfile_1:THIS IS A LINUX TESTFILE!  
testfile_2:HELLO LINUX!  
testfile_2:Linux is a free unix-type opterating system.  
```

#### 查找文件：find

常用用法：

| 命令                        | 含义                                   |
| --------------------------- | -------------------------------------- |
| find ./ -name test.sh       | 查找当前目录下所有名为test.sh的文件    |
| find ./ -name ‘*.sh’        | 查找当前目录下所有后缀为.sh的文件      |
| find ./ -name “[A-Z]*”      | 查找当前目录下所有以大写字母开头的文件 |
| find /tmp -size 2M          | 查找在/tmp 目录下等于2M的文件          |
| find /tmp -size +2M         | 查找在/tmp 目录下大于2M的文件          |
| find /tmp -size -2M         | 查找在/tmp 目录下小于2M的文件          |
| find ./ -size +4k -size -5M | 查找当前目录下大于4k，小于5M的文件     |
| find ./ -perm 0777          | 查找当前目录下权限为 777 的文件或目录  |

Linux find命令用来在指定目录下查找文件。任何位于参数之前的字符串都将被视为欲查找的目录名。如果使用该命令时，不设置任何参数，则find命令将在当前目录下查找子目录与文件。并且将查找到的子目录和文件全部进行显示。

语法：

```bash
find path -option [ -print ] [ -exec -ok command ] {} \;
```

**常用参数说明** :

- -perm xxxx：权限为 xxxx的文件或目录
- -user： 按照文件属主来查找文件。
- -size n : n单位,b:512位元组的区块,c:字元数,k:kilo bytes,w:二个位元组
- -mount, -xdev : 只检查和指定目录在同一个文件系统下的文件，避免列出其它文件系统中的文件
- -amin n : 在过去 n 分钟内被读取过
- -anewer file : 比文件 file 更晚被读取过的文件
- -atime n : 在过去n天内被读取过的文件
- -cmin n : 在过去 n 分钟内被修改过
- -cnewer file :比文件 file 更新的文件
- -ctime n : 在过去n天内被修改过的文件
- -empty : 空的文件
- -gid n or -group name : gid 是 n 或是 group 名称是 name
- -ipath p, -path p : 路径名称符合 p 的文件，ipath 会忽略大小写
- -name name, -iname name : 文件名称符合 name 的文件。iname 会忽略大小写
- -type 查找某一类型的文件：   
  - b - 块设备文件
  - d - 目录
  - c - 字符设备文件
  - p - 管道文件
  - l - 符号链接文件
  - f - 普通文件
- -exec 命令名{} \ (注意：“}”和“\”之间有空格)

find实例：

显示当前目录中大于20字节并以.c结尾的文件名

```bash
find . -name "*.c" -size +20c 
```

将目前目录其其下子目录中所有一般文件列出

```bash
find . -type f
```

将目前目录及其子目录下所有最近 20 天内更新过的文件列出

```bash
find . -ctime -20
```

查找/var/log目录中更改时间在7日以前的普通文件，并在删除之前询问它们：

```bash
find /var/log -type f -mtime +7 -ok rm {} \;
```

查找前目录中文件属主具有读、写权限，并且文件所属组的用户和其他用户具有读权限的文件：

```bash
find . -type f -perm 644 -exec ls -l {} \;
```

查找系统中所有文件长度为0的普通文件，并列出它们的完整路径：

```bash
find / -type f -size 0 -exec ls -l {} \;
```

从根目录查找类型为符号链接的文件，并将其删除：

```bash
find / -type l -exec rm -rf {} \
```

从当前目录查找用户tom的所有文件并显示在屏幕上

```bash
find . -user tom
```

在当前目录中查找所有文件以.doc结尾，且更改时间在3天以上的文件，找到后删除，并且给出删除提示

```bash
find . -name *.doc  -mtime +3 -ok rm {} \;
```

在当前目录下查找所有链接文件，并且以长格式显示文件的基本信息

```bash
find . -type l -exec ls -l {} \;
```

在当前目录下查找文件名有一个小写字母、一个大写字母、两个数字组成，且扩展名为.doc的文件

```bash
find . -name '[a-z][A-Z][0-9][0-9].doc'
```

#### 拷贝文件：cp

cp命令的功能是将给出的文件或目录复制到另一个文件或目录中，相当于DOS下的copy命令。

常用选项说明：

| 选项 | 含义                                                         |
| ---- | ------------------------------------------------------------ |
| -a   | 该选项通常在复制目录时使用，它保留链接、文件属性，并递归地复制目录，简单而言，保持文件原有属性。 |
| -f   | 已经存在的目标文件而不提示                                   |
| -i   | 交互式复制，在覆盖目标文件之前将给出提示要求用户确认         |
| -r   | 若给出的源文件是目录文件，则cp将递归复制该目录下的所有子目录和文件，目标文件必须为一个目录名。 |
| -v   | 显示拷贝进度                                                 |
| -l   | 创建硬链接(hard link)，而非复制文件本身                      |
| -s   | 复制成为符号链接 (symbolic link)，相当于批量创建快捷方式     |
| -u   | 若 destination 比 source 旧才升级 destination ！             |

cp vim_configure/ code/ -ivr 把文件夹 vim_configure 拷贝到 code 目录里。

#### 移动文件：mv

mv命令用来移动文件或目录，也可以给文件或目录重命名。

常用选项说明：

| 选项 | 含义                                                         |
| ---- | ------------------------------------------------------------ |
| -f   | 禁止交互式操作，如有覆盖也不会给出提示                       |
| -i   | 确认交互方式操作，如果mv操作将导致对已存在的目标文件的覆盖，系统会询问是否重写，要求用户回答以避免误覆盖文件 |
| -v   | 显示移动进度                                                 |

mv可以修改文件名：

```bash
[root@rocky8:~]#ll
total 4
-rw-------. 1 root root 1256 Feb 18 21:18 anaconda-ks.cfg
-rw-r--r--. 1 root root    0 Feb 19 11:43 test.txt
[root@rocky8:~]#mv test.txt test
[root@rocky8:~]#ll
total 4
-rw-------. 1 root root 1256 Feb 18 21:18 anaconda-ks.cfg
-rw-r--r--. 1 root root    0 Feb 19 11:43 test
```



#### 归档管理：tar

此命令可以把一系列文件归档到一个大文件中，也可以把档案文件解开以恢复数据。

tar使用格式 tar [参数] 打包文件名 文件

tar命令参数很特殊，其参数前面可以使用“-”，也可以不使用。

常用参数：

| 参数 | 含义                                                      |
| ---- | --------------------------------------------------------- |
| -c   | 生成档案文件，创建打包文件                                |
| -v   | 列出归档解档的详细过程，显示进度                          |
| -f   | 指定档案文件名称，f后面一定是.tar文件，所以必须放选项最后 |
| -t   | 列出档案中包含的文件                                      |
| -x   | 解开档案文件                                              |

注意：除了f需要放在参数的最后，其它参数的顺序任意。

```bash
[root@rocky8:~]# tar -cvf test.tar {1..3}.txt
1.txt
2.txt
3.txt
[root@rocky8:~]# ll
total 12
-rw-r--r--. 1 root root     0 Feb 20 15:14 1.txt
-rw-r--r--. 1 root root     0 Feb 20 15:14 2.txt
-rw-r--r--. 1 root root     0 Feb 20 15:14 3.txt
-rw-r--r--. 1 root root 10240 Feb 20 15:14 test.tar
[root@rocky8:~]# rm -rf *.txt
[root@rocky8:~]# ll
total 12
-rw-r--r--. 1 root root 10240 Feb 20 15:14 test.tar
[root@rocky8:~]# tar -xvf test.tar 
1.txt
2.txt
3.txt
[root@rocky8:~]# ll
total 12
-rw-r--r--. 1 root root     0 Feb 20 15:14 1.txt
-rw-r--r--. 1 root root     0 Feb 20 15:14 2.txt
-rw-r--r--. 1 root root     0 Feb 20 15:14 3.txt
-rw-r--r--. 1 root root 10240 Feb 20 15:14 test.tar
```

#### 文件压缩解压：gzip、bzip2

tar与gzip命令结合使用实现文件打包、压缩。 tar只负责打包文件，但不压缩，用gzip压缩tar打包后的文件，其扩展名一般用xxxx.tar.gz。

gzip使用格式如下：

```bash
gzip  [选项]  被压缩文件
```

常用选项：

| 选项 | 含义     |
| ---- | -------- |
| -d   | 解压文件 |
| -r   | 压缩文件 |



```bash
[root@rocky8:~]# ll *.tar*
-rw-r--r--. 1 root root 10240 Feb 20 15:14 test.tar
[root@rocky8:~]# gzip -r test.tar test.tar.gz  ==>或者:gzip test.tar
[root@rocky8:~]# ll *.tar*
-rw-r--r--. 1 root root 131 Feb 20 15:14 test.tar.gz
[root@rocky8:~]# gzip -d test.tar.gz 
[root@rocky8:~]# ll *.tar*
-rw-r--r--. 1 root root 10240 Feb 20 15:14 test.tar
```

tar命令中-z选项可以调用gzip实现了一个压缩的功能，实行一个先打包后压缩的过程。

压缩用法：tar zcvf 压缩包包名 文件1 文件2 …

例如： tar zcvf test.tar.gz 1.c 2.c 3.c 4.c把 1.c 2.c 3.c 4.c 压缩成 test.tar.gz

```bash
[root@rocky8:~]# ls
1.c  2.c  3.c  4.c
[root@rocky8:~]# tar -zcvf test.tar.gz {1..4}.c
1.c
2.c
3.c
4.c
[root@rocky8:~]# ls
1.c  2.c  3.c  4.c  test.tar.gz
[root@rocky8:~]# gzip -d test.tar.gz 
[root@rocky8:~]# ls
1.c  2.c  3.c  4.c  test.tar
```

解压用法： tar zxvf 压缩包包名

例如：

```bash
[root@rocky8:~]# ls
new.tar.gz  test.tar  test.tar.gz
[root@rocky8:~]# tar -zxvf new.tar.gz
1.c
2.c
3.c
4.c
[root@rocky8:~]# ls
1.c  2.c  3.c  4.c  new.tar.gz  test.tar  test.tar.gz
```

解压到指定目录：-C （解压时可以不指定-z选项）

```bash
[root@rocky8:~]# ls
1.c  2.c  3.c  4.c  new.tar.gz  test.tar  test.tar.gz
[root@rocky8:~]# tar -zxvf new.tar.gz -C number/
1.c
2.c
3.c
4.c
[root@rocky8:~]# ls number/
1.c  2.c  3.c  4.c
```

bzip2命令跟gzip用法类似

压缩用法：tar jcvf 压缩包包名 文件…(tar jcvf bk.tar.bz2 *.c)

解压用法：tar jxvf 压缩包包名 (tar jxvf bk.tar.bz2)

#### 文件压缩解压：zip、unzip

通过zip压缩文件的目标文件不需要指定扩展名，默认扩展名为zip。

压缩文件：zip [-r] 目标文件(没有扩展名) 源文件

解压文件：unzip -d 解压后目录文件 压缩文件

```bash
[root@rocky8:~]# ls
1.txt  2.txt  3.txt  4.txt  test.tar
[root@rocky8:~]# zip myzip *.txt
  adding: 1.txt (stored 0%)
  adding: 2.txt (stored 0%)
  adding: 3.txt (stored 0%)
  adding: 4.txt (stored 0%)
[root@rocky8:~]# ls
1.txt  2.txt  3.txt  4.txt  myzip.zip  test.tar
[root@rocky8:~]# rm -f *.txt *.tar
[root@rocky8:~]# ls
myzip.zip
[root@rocky8:~]# unzip myzip
Archive:  myzip.zip
 extracting: 1.txt                   
 extracting: 2.txt                   
 extracting: 3.txt                   
 extracting: 4.txt                   
[root@rocky8:~]# ls
1.txt  2.txt  3.txt  4.txt  myzip.zip
```









本文参考：
