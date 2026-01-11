---
title: 【Linux】用户与权限管理
comments: true
abbrlink: 2b99b9f0
categories:
  - 基础知识
  - Linux
  - Linux基础
tags:
  - Linux
date: 2025-02-19 16:12:41
description:
top:
---

## 用户管理

用户管理包括用户与组账号的管理。

在Unix/Linux系统中，不论是由本机或是远程登录系统，每个系统都必须拥有一个账号，并且对于不同的系统资源拥有不同的使用权限。

Unix/Linux系统中的root账号通常用于系统的维护和管理，它对Unix/Linux操作系统的所有部分具有不受限制的访问权限。

在Unix/Linux安装的过程中，系统会自动创建许多用户账号，而这些默认的用户就称为“标准用户”。

在大多数版本的Unix/Linux中，都不推荐直接使用root账号登录系统。

<!-- more -->

### whoami：查看当前用户

查看当前系统当前账号的用户名。可通过cat /etc/passwd查看系统用户信息。

```bash
[Corazon@rocky8:~]$ whoami
Corazon
```

### who：查看登录用户

who命令用于查看当前所有登录系统的用户信息。

```bash
[Corazon@rocky8:~]$ who
root     tty1         2025-02-19 12:30
root     pts/0        2025-02-19 13:17 (10.0.0.1)
```

常用选项：

|    选项    | 含义                                               |
| :--------: | -------------------------------------------------- |
|  -m或am I  | 只显示运行who命令的用户名、登录终端和登录时间      |
| -q或–count | 只显示用户的登录账号和登录用户的数量               |
|     -u     | 在登录时间后显示该用户最后一次操作到当前的时间间隔 |
|  –heading  | 显示列标题                                         |
|     -u     | 显示PID                                            |

### exit：退出登录账户

如果是图形界面，退出当前终端；

如果是使用ssh远程登录，退出登陆账户；

如果是切换后的登陆用户，退出则返回上一个登陆账号。

### useradd：添加用户账号

在Unix/Linux中添加用户账号可以使用adduser或useradd命令，因为adduser命令是指向useradd命令的一个链接，因此，这两个命令的使用格式完全一样。

useradd命令的使用格式如下： useradd [参数] 新建用户账号

| 参数 | 含义                                                         |
| ---- | ------------------------------------------------------------ |
| -d   | 指定用户登录系统时的主目录                                   |
| -m   | 自动建立目录，未指定-d参数时会在/home/{当前用户}目录下建立主目录 |
| -g   | 指定组名称                                                   |

相关说明：

- Linux每个用户都要有一个主目录，主目录就是第一次登陆系统，用户的默认当前目录(/home/用户)；
- 每一个用户必须有一个主目录，所以用useradd创建用户的时候，一定给用户指定一个主目录；
- 如果创建用户的时候，不指定组名，那么系统会自动创建一个和用户名一样的组名。
- 使用user创建账户后需要使用命令`passwd 新建用户`为新账户设置密码后才能登陆

若创建用户时未指定家目录，后期可通过`usermod -d /home/abc abc`指定

| 命令                            | 含义                                                         |
| ------------------------------- | ------------------------------------------------------------ |
| useradd -d /home/abc abc -m     | 创建abc用户，如果/home/abc目录不存在，就自动创建这个目录，同时用户属于abc组 |
| useradd -d /home/a a -g test -m | 创建一个用户名字叫a，主目录在/home/a，如果主目录不存在，就自动创建主目录，同时用户属于test组 |
| cat /etc/passwd                 | 查看系统当前用户名                                           |



### 设置用户密码：passwd

超级用户可以为自己和其他用户指定口令，普通用户只能用它修改自己的口令。命令的格式为：

```bash
passwd 选项 用户名
```

可使用的选项：

- -l 锁定口令，即禁用账号。
- -u 口令解锁。
- -d 使账号无口令。
- -f 强迫用户下次登录时修改口令。

普通用户修改自己的口令时，passwd命令会先询问原口令，验证后再要求用户输入两遍新口令，如果两次输入的口令一致，则将这个口令指定给用户；而超级用户为用户指定口令时，就不需要知道原口令。

假设当前用户是sam，则下面的命令修改该用户自己的口令：

```bash
$ passwd 
Old password:****** 
New password:******* 
Re-enter new password:*******
```

如果是超级用户，可以用下列形式指定任何用户的口令：

```bash
# passwd sam 
New password:******* 
Re-enter new password:*******
```

使用root账户为用户指定空口令时，执行下列形式的命令：

```bash
passwd -d sam
```

此命令将用户 sam 的口令删除，这样用户 sam 下一次登录时，系统就不再允许该用户登录了。

passwd 命令还可以用 -l(lock) 选项锁定某一用户，使其不能登录，例如：

```bash
passwd -l sam
```





### usermod：修改用户

常用的选项包括`-c, -d, -m, -g, -G, -s, -u以及-o等`，这些选项的意义与`useradd`命令中的选项一样，可以为用户指定新的资源值 。

修改用户所在组：usermod -g 用户组 用户名

```bash
usermod -g test abc
```

改abc用户的家目录位置：usermod -d 家目录 用户名

```bash
usermod -d /home/abc abc
```

选项`-l 新用户名`指定一个新的账号，可修改用户名：

```bash
python@ubuntu:~/txt$ tail /etc/passwd -n 1 
aaa:x:1001:1001::/home/aaa:
python@ubuntu:~/txt$ sudo usermod -l bbb -d /home/bbb aaa   
python@ubuntu:~/txt$ tail /etc/passwd -n 1               
bbb:x:1001:1001::/home/bbb:
```



### 删除用户：userdel

| 命令                   | 含义                                    |
| ---------------------- | --------------------------------------- |
| userdel abc(用户名)    | 删除abc用户，但不会自动删除用户的主目录 |
| userdel -r abc(用户名) | 删除用户，同时删除用户的主目录          |

### 切换用户：su

su后面可以加“-”会将当前的工作目录自动转换到切换后的用户主目录.

| 命令          | 含义                                       |
| ------------- | ------------------------------------------ |
| su            | 切换到root用户                             |
| su root       | 切换到root用户                             |
| su -          | 切换到root用户，同时切换目录到/root        |
| su - root     | 切换到root用户，同时切换目录到/root        |
| su 普通用户   | 切换到普通用户                             |
| su - 普通用户 | 切换到普通用户，同时切换普通用户所在的目录 |

注意：对于ubuntu平台，只能通过sudo su进入root账号。

sudo允许系统管理员让普通用户执行一些或者全部的root命令的一个工具。

### sudo：以root身份执行指令

sudo命令可以临时获取root权限

使用权限：在 /etc/sudoers 中有出现的使用者。

```bash
显示出自己（执行 sudo 的使用者）的权限
sudo -l
以root权限执行上一条命令
sudo !!
```

sudoers文件配置语法

```bash
user  MACHINE=COMMANDS
用户 登录的主机=（可以变换的身份） 可以执行的命令  
```

例子：

```bash
允许root用户执行任意路径下的任意命令 
root    ALL=(ALL)       ALL
允许wheel用户组中的用户执行所有命令  
%wheel        ALL=(ALL)       ALL
允许wheel用户组中的用户在不输入该用户的密码的情况下使用所有命令
%wheel        ALL=(ALL)       NOPASSWD: ALL
允许support用户在EPG的机器上不输入密码的情况下使用SQUID中的命令
Cmnd_Alias   SQUID = /opt/vtbin/squid_refresh, /sbin/service, /bin/rm
Host_Alias   EPG = 192.168.1.1, 192.168.1.2
support EPG=(ALL) NOPASSWD: SQUID
```



### 添加、删除组账号：groupadd、groupdel

groupadd 新建组账号 groupdel 组账号 cat /etc/group 查看用户组

```bash
python@ubuntu:~/test$ sudo groupadd abc
python@ubuntu:~/test$ sudo groupdel abc
```





### 用户组管理：groupmod

修改用户组的属性使用groupmod命令。其语法如下：

```bash
groupmod 选项 用户组
```

常用的选项有：

- -g GID 为用户组指定新的组标识号。
- -o 与-g选项同时使用，用户组的新GID可以与系统已有用户组的GID相同。
- -n新用户组 将用户组的名字改为新名字

将组group2的组标识号修改为102：

```bash
groupmod -g 102 group2
```

将组group2的标识号改为10000，组名修改为group3：

```bash
groupmod –g 10000 -n group3 group2
```

如果一个用户同时属于多个用户组，那么用户可以在用户组之间切换，以便具有其他用户组的权限。

用户可以在登录后，使用命令newgrp切换到其他用户组，这个命令的参数就是目的用户组。例如：

```
$ newgrp root
```

这条命令将当前用户切换到root用户组，前提条件是root用户组确实是该用户的主组或附加组。类似于用户账号的管理，用户组的管理也可以通过集成的系统管理工具来完成。

## 权限管理

### 列出目录的内容：ls

Linux文件或者目录名称最长可以有265个字符，“.”代表当前目录，“…”代表上一级目录，以“.”开头的文件为隐藏文件，需要用 -a 参数才能显示。

ls常用参数：

| 参数 | 含义                                         |
| :--: | -------------------------------------------- |
|  -a  | 显示指定目录下所有子目录与文件，包括隐藏文件 |
|  -l  | 以列表方式显示文件的详细信息                 |
|  -h  | 配合 -l 以人性化的方式显示文件大小           |



![image-20250218170841665](【Linux】用户与权限管理/image-20250218170841665.png)

列出的信息的含义：

![img](【Linux】用户与权限管理/ccff78bd3a3c92ac11636923216ce3ed.png)

ls支持通配符：

|  通配符   | 含义                                                         |
| :-------: | :----------------------------------------------------------- |
|     *     | 文件代表文件名中所有字符                                     |
|  ls te*   | 查找以te开头的文件                                           |
| ls *html  | 查找结尾为html的文件                                         |
|    ？     | 代表文件名中任意一个字符                                     |
|  ls ?.c   | 只找第一个字符任意，后缀为.c的文件                           |
|  ls a.?   | 只找只有3个字符，前2字符为a.，最后一个字符任意的文件         |
|    []     | [”和“]”将字符组括起来，表示可以匹配字符组中的任意一个。“-”用于表示字符范围。 |
|   [abc]   | 匹配a、b、c中的任意一个                                      |
|   [a-f]   | 匹配从a到f范围内的的任意一个字符                             |
| ls [a-f]* | 找到从a到f范围内的的任意一个字符开头的文件                   |
|  ls a-f   | 查找文件名为a-f的文件,当“-”处于方括号之外失去通配符的作用    |
|     \     | 如果要使通配符作为普通字符使用，可以在其前面加上转义字符。“?”和“*”处于方括号内时不用使用转义字符就失去通配符的作用。 |
|  ls \\*a  | 查找文件名为*a的文件                                         |

### 显示inode的内容：stat

```bash
stat [文件或目录]
```

查看 testfile 文件的inode内容内容，可以用以下命令：

```bash
[root@rocky8 ~]# stat anaconda-ks.cfg 
  File: anaconda-ks.cfg
  Size: 1256      	Blocks: 8          IO Block: 4096   regular file
Device: fd00h/64768d	Inode: 201326724   Links: 1
Access: (0600/-rw-------)  Uid: (    0/    root)   Gid: (    0/    root)
Context: system_u:object_r:admin_home_t:s0
Access: 2025-02-18 21:18:29.137289911 +0800
Modify: 2025-02-18 21:18:29.216289006 +0800
Change: 2025-02-18 21:18:29.216289006 +0800
 Birth: 2025-02-18 21:18:29.137289911 +0800
```

### 文件访问权限

用户能够控制一个给定的文件或目录的访问程度，一个文件或目录可能有读、写及执行权限：

- 读权限（r） ：对于文件，具有读取文件内容的权限；对于目录，具有浏览目录的权限。
- 写权限（w） ：对于文件，具有修改文件内容的权限；对于目录，具有删除、移动目录内文件的权限。
- 可执行权限（x）： 对于文件，具有执行文件的权限；对于目录，该用户具有进入目录的权限。

通常，Unix/Linux系统只允许文件的属主(所有者)或超级用户改变文件的读写权限。

示例：

![img](【Linux】用户与权限管理/7da5a8288cfb2d26b70da16da71b36e8.png)

第1个字母代表文件的类型：

- “d” 代表文件夹
- “-” 代表普通文件
- “c” 代表硬件字符设备
- “b” 代表硬件块设备
- “s”表示管道文件
- “l” 代表软链接文件。

后9个字母分别代表三组权限：文件所有者、用户组、其他用户拥有的权限。

### chmod：修改文件权限

chmod 修改文件权限有两种使用格式：字母法与数字法。

字母法：chmod u/g/o/a +/-/= rwx 文件

| [ u/g/o/a ] | 含义                                                      |
| ----------- | --------------------------------------------------------- |
| u           | user 表示该文件的所有者                                   |
| g           | group 表示与该文件的所有者属于同一组( group )者，即用户组 |
| o           | other 表示其他以外的人                                    |
| a           | all 表示这三者皆是                                        |

| [ ±= ] | 含义     |
| ------ | -------- |
| +      | 增加权限 |
| -      | 撤销权限 |
| =      | 设定权限 |

| rwx  | 含义                                                         |
| ---- | ------------------------------------------------------------ |
| r    | read 表示可读取，对于一个目录，如果没有r权限，那么就意味着不能通过ls查看这个目录的内容。 |
| w    | write 表示可写入，对于一个目录，如果没有w权限，那么就意味着不能在目录下创建新的文件。 |
| x    | excute 表示可执行，对于一个目录，如果没有x权限，那么就意味着不能通过cd进入这个目录。 |

数字法：“rwx” 这些权限也可以用数字来代替

| 字母 | 说明                         |
| ---- | ---------------------------- |
| r    | 读取权限，数字代号为 “4”     |
| w    | 写入权限，数字代号为 “2”     |
| x    | 执行权限，数字代号为 “1”     |
| -    | 不具任何权限，数字代号为 “0” |

如执行：chmod u=rwx,g=rx,o=r filename 就等同于：chmod u=7,g=5,o=4 filename

chmod 751 file：

- 文件所有者：读、写、执行权限
- 同组用户：读、执行的权限
- 其它用户：执行的权限

chmod 777 file：所有用户拥有读、写、执行权限

注意：如果想递归所有目录加上相同权限，需要加上参数“ -R ”。 如：chmod 777 test/ -R 递归 test 目录下所有文件加 777 权限

### 修改文件所有者：chown

```bash
[Corazon@rocky8:~]$ ll a
-rw-rw-r--. 1 Corazon Corazon 0 Feb 19 13:31 a
[Corazon@rocky8:~]$ su
Password: 
[root@rocky8:Corazon]# chown Cora a
[root@rocky8:Corazon]# ll a
-rw-rw-r--. 1 Cora Corazon 0 Feb 19 13:31 a
```

### 修改文件所属组：chgrp

```bash
[root@rocky8:Corazon]# ll a
-rw-rw-r--. 1 Cora Corazon 0 Feb 19 13:31 a
[root@rocky8:Corazon]# ll a
-rw-rw-r--. 1 Cora Corazon 0 Feb 19 13:31 a
[root@rocky8:Corazon]# chgrp Cora a
[root@rocky8:Corazon]# ll a
-rw-rw-r--. 1 Cora Cora 0 Feb 19 13:31 a
```



## 特殊权限

linux共12位权限，除了9位基础权限还有3个特殊权限。

### 三种特殊的权限

#### SetUID(suid)

**命令功能：** **临时使用命令的属主权限执行该命令。**即如果文件有suid权限时，那么普通用户去执行该文件时，会以该文件的所属用户的身份去执行。

SetUID（简写suid）：会在属主权限位的执行权限上写个s。 如果该属主权限位上有执行权限，则会在属主权限位的执行权限上写个s（小写）； 如果该属主权限位上没有执行权限，则会在属主权限位的执行权限上写个S（大写）。

suid数字权限是4000,设置方法：

```
方式1：
[root@centos7 ~]# chmod u+s filename
方式2：
[root@centos7 ~]# chmod 4755 filename
1234
```

查看passwd命令的权限

```
`[root@localhost ftl]``# ll /usr/bin/passwd ` `问题： ``passwd``文件的属组是root,表示只有root用户可以访问的文件，为什么普通用户依然可以使用该命令更改自己的密码？``答案：当普通用户[omd]使用``passwd``命令的时候，系统看到``passwd``命令文件的属性有大写s后，表示这个命令的属主权限被omd用户获得,也就是omd用户获得文件``/etc/shadow``的root的rwx权限`
1
```

由于`passwd`具有s权限，普通用户使用该命令的时候，就会以该命令的属主身份root执行该命令，于是能够顺利修改普通用户不具备修改权限的`/etc/shadow`文件。

希望普通用户user1可以删除某个自己没有权限删除的文件的操作方法：

- sudo给user1授权rm权限
- rm设置suid
- 修改被删除文件上级目录的权限

**SetUID（简称suid）总结：**

1. 让普通用户对可执行的二进制文件，临时拥有二进制文件的属主权限；
2. 如果设置的二进制文件没有执行权限，那么suid的权限显示就是S（大写字母S）；
3. 特殊权限suid仅对二进制可执行程序有效，其他文件或目录则无效。
4. suid极其危险，如果给vim或者rm命令设置了setUID，那么任何文件都能编辑或者删除了，相当于有root权限了。

#### setGID（sgid）

**命令功能：**使用sgid可以使得多个用户之间共享一个目录的所有文件变得简单。当某个目录设置了sgid后，在该目录中新建的文件不在是创建该文件的默认所属组。

如果该属组权限位上有执行权限，则会在属组主权限位的执行权限上写个s（小写字母）； 如果该属组权限位上没有执行权限，则会在属组主权限位的执行权限上写个S（大写字母S）。

write命令的权限：

```
[root@VM_0_9_centos ~]# ll /bin/write 
-rwxr-sr-x 1 root tty 19544 Aug  9 11:10 /bin/write
12
```

sgid数字权限是2000，设置方法：

```
方式1：
[root@VM_0_9_centos ~]# chmod 2755 test/
方式2：
[root@VM_0_9_centos ~]# chmod g+s test/

[root@VM_0_9_centos ~]# ll -d test/
drwxr-sr-x 2 root root 4096 Nov 22 21:02 test/
1234567
```

在设置SetGID的文件夹创建文件的属组是父目录的属组：

```bash
[root@VM_0_9_centos ~]# cd test/
[root@VM_0_9_centos test]# su aaa
[aaa@VM_0_9_centos test]$ touch bbb
[aaa@VM_0_9_centos test]$ ll
-rw-rw-r-- 1 aaa  root 0 Nov 22 21:14 bbb
12345
```

#### sticky(sbit)粘滞位

**命令功能：**粘滞位，只对目录有效，对某目录设置粘滞位后，普通用户就算有w权限也只能删除该目录下自己建立的文件，而不能删除其他用户建立的文件。

如果该其他用户权限位上有执行权限，则会在其他用户权限位的执行权限上写个t（小写）； 如果该其它用户权限位上没有执行权限，则会在其他用户权限位的执行权限上写个T（大写）。

系统中存在的/tmp目录是经典的粘滞位目录，谁都有写权限，因此安全成问题，常常是木马第一手跳板。

```
[aaa@VM_0_9_centos ~]$ ll -d /tmp/ 
drwxrwxrwt. 9 root root 4096 Nov 22 21:15 /tmp/
12
```

sbit数字权限是1000，设置方法：

```bash
方法1：
[root@VM_0_9_centos ~]# chmod 1755 test/
方法2：
[root@VM_0_9_centos ~]# chmod o+t test/ 
查看权限：
[root@VM_0_9_centos ~]# ll -d test/    
drwxr-xr-t 2 root root 4096 Nov 22 21:15 test/
1234567
```

### chattr权限

chattr概述：凌驾于r、w、x、suid、sgid之上的权限。

#### lsattr：查看特殊权限

```
[root@VM_0_9_centos ~]# lsattr /etc/passwd
-------------e-- /etc/passwd
12
```

#### chattr：设置特殊权限

| 权限说明 |                                                            |
| -------- | ---------------------------------------------------------- |
| -i       | 锁定文件，不能编辑，不能修改，不能删除，不能移动，可以执行 |
| -a       | 仅可以追加文件，不能编辑，不能删除，不能移动，可以执行     |

防止系统中某个关键文件被修改：

```
[root@VM_0_9_centos ~]# chattr +i /etc/fstab
[root@VM_0_9_centos ~]# lsattr /etc/fstab   
----i--------e-- /etc/fstab
123
```

让某个文件只能往里面追加内容，不能删除，一些日志文件适用于这种操作：

```
[root@VM_0_9_centos ~]# chattr +a user_act.log
[root@VM_0_9_centos ~]# lsattr user_act.log 
-----a-------e-- user_act.log
123
```

### 掩码umask

#### umask的作用

umask值用于设置用户在创建文件时的默认权限，当我们在系统中创建目录或文件时，目录或文件所具有的默认权限就是由umask值决定的。

对于root用户，系统默认的umask值是0022；对于普通用户，系统默认的umask值是0002。执行umask命令可以查看当前用户的umask值。

```
[root@VM_0_9_centos ~]# umask
0022
12
```

#### umask是如何改变新文件的权限

umask值一共有4组数字，其中第1组数字用于定义特殊权限，一般不予考虑，与一般权限有关的是后3组数字。

默认情况下，对于目录，用户所能拥有的最大权限是777；对于文件，用户所能拥有的最大权限是目录的最大权限去掉执行权限，即666。因为x执行权限对于目录是必须的，没有执行权限就无法进入目录，而对于文件则不必默认赋予x执行权限。

对于root用户，他的umask值是022。当root用户创建目录时，默认的权限就是用最大权限777去掉相应位置的umask值权限，即对于所有者不必去掉任何权限，对于所属组要去掉w权限，对于其他用户也要去掉w权限，所以目录的默认权限就是755；当root用户创建文件时，默认的权限则是用最大权限666去掉相应位置的umask值，即文件的默认权限是644。

通过umask命令可以修改umask值，比如将umask值设为0077。

```
[root@VM_0_9_centos ~]# umask 0077
[root@VM_0_9_centos ~]# umask
0077
123
```

#### 永久修改umask

umask命令只能临时修改umask值，系统重启之后umask将还原成默认值。如果要永久修改umask值，可修改`/etc/bashrc`或`/etc/profile`文件。

例如要将默认umask值设置为027，那么可以在文件中增加一行`umask 027`。



本文参考：

