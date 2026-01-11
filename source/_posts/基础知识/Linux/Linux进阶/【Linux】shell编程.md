---
title: 【Linux】shell编程
comments: true
categories:
  - 基础知识
  - Linux
  - Linux进阶
tags:
  - Linux
abbrlink: '63063238'
date: 2025-07-13 17:37:44
description:
top:
---

## shell编程

这里说的Shell 脚本（shell script），是在Linux 环境下运行的脚本程序

Shell 编程跟 JavaScript、php 编程一样，只要有一个能编写代码的文本编辑器和一个能解释执行的脚本解释器就可以了。

Linux 的 Shell 种类众多，常见的有：

- Bourne Shell（/usr/bin/sh或/bin/sh）
- Bourne Again Shell（/bin/bash）
- C Shell（/usr/bin/csh）
- K Shell（/usr/bin/ksh）
- Shell for Root（/sbin/sh）
- ……

Bash是大多数Linux 系统默认的 Shell，本文也仅关注Bash Shell。

在一般情况下，并不区分 Bourne Shell 和 Bourne Again Shell，所以，像 **#!/bin/sh**，它同样也可以改为 **#!/bin/bash**。

**#!** 告诉系统其后路径所指定的程序即是解释此脚本文件的 Shell 程序。

<!-- more -->

## 入门

### 运行Shell脚本

编写shell脚本：

```bash
vi test.sh

#!/bin/bash
echo "Hello World !"
```

**#!** 是一个约定的标记，它告诉系统这个脚本需要什么解释器来执行，即使用哪一种 Shell。

echo 命令用于向窗口输出文本。

运行 Shell 脚本有两种方法：

**1、作为可执行程序**

```bash
chmod +x ./test.sh  #使脚本具有执行权限
./test.sh  #执行脚本
```

默认情况下，一定要写成 **./test.sh**，而不是 **test.sh**，运行其它二进制的程序也一样。

除非将当前目录.加入到PATH环境变量中，配置方法：

```bash
sudo vi /etc/profile
加入一行
export PATH=$PATH:.
保存之后，执行
source /etc/profile
```

**2、作为解释器参数**

直接运行解释器，其参数就是 shell 脚本的文件名：

```bash
/bin/sh test.sh
```

这种方式运行的脚本，不需要在第一行指定解释器信息，写了也没用。

### 编写一个快捷创建shell脚本的命令

```bash
#!/bin/bash
if test -z $1;then
  newfile="./script_`date +%m%d_%s`"
else
  newfile=$1
fi
echo $newfile
if  ! grep "^#!" $newfile &>/dev/null; then
cat >> $newfile << EOF
#!/bin/bash
# Author:
# Date & Time: `date +"%F %T"`
#Description:
EOF
fi
vim +5 $newfile
chmod +x $newfile
```

将以上内容编写好之后保存为shell文件，然后执行

```bash
chmod u+x shell
sudo mv shell /usr/bin/
```

## Shell变量

### 变量类型

运行shell时，会同时存在三种变量：

- **1) 普通变量（局部变量）**： 系统中满足特定调用需求的配置信息，并且可能随时会发生调整变化的参数。局部变量在脚本或命令中定义，仅在当前shell实例中有效，其他shell启动的程序不能访问局部变量。
- **2) 环境变量（全局变量）** ：系统中默认已经存在，可以进行修改调整，所有的程序，包括shell启动的程序，都能访问环境变量，有些程序需要环境变量来保证其正常运行。必要的时候shell脚本也可以定义环境变量。可以在`/etc/profile`中修改环境变量。
- **3) shell变量**： shell变量是由shell程序设置的特殊变量。shell变量中有一部分是环境变量，有一部分是局部变量，这些变量保证了shell的正常运行

环境变量 vs 普通变量特点：

- 变量信息在系统中默认已经存在
- 变量信息名称设置为大写字母
- 变量功能配置对系统中全部用户生效
- 变量的设置会对系统功能有一定影响

### 定义变量

```bash
your_name="taobao.com"
```

可以用单引号（所见即所得） 双引号（可以识别变量） 反引号（可以执行命令）。不加引号进行变量值引用，推荐字符用双引号 数字不加引号。

变量名的命名须遵循如下规则：

- 命名只能使用英文字母，数字和下划线，首个字符不能以数字开头。
- 中间不能有空格，可以使用下划线（_）。
- 不能使用标点符号。
- 不能使用bash里的关键字（可用help命令查看保留关键字）。

### 使用变量

在变量名前面加美元符号即可，如：

```bash
your_name="qinjx"
echo $your_name
echo ${your_name}
```

加花括号可以帮助解释器识别变量的边界，比如：

```bash
for skill in Ada Coffe Action Java; do
    echo "I am good at ${skill}Script"
done
```

### 只读变量

使用 readonly 命令可以将变量定义为只读变量，只读变量的值不能被改变。

下面的例子尝试更改只读变量，结果报错：

```bash
python@ubuntu:~/shell$ myUrl="http://www.google.com"
python@ubuntu:~/shell$ readonly myUrl
python@ubuntu:~/shell$ myUrl="http://www.baidu.com"
-bash: myUrl: 只读变量
```

### 删除变量

使用 unset 命令可以删除变量，但不能删除只读变量：

```bash
#!/bin/sh
myUrl="http://www.baidu.com"
unset myUrl
echo $myUrl
```

## Shell算术运算符

下表列出了常用的算术运算符，假定变量 a 为 10，变量 b 为 20：

| 运算符 | 说明   | 举例                          |
| ------ | ------ | ----------------------------- |
| +      | 加法   | `expr $a + $b` 结果为 30。    |
| -      | 减法   | `expr $a - $b` 结果为 -10。   |
| *      | 乘法   | `expr $a \* $b` 结果为 200。\ |
| \*\*   | 幂运算 | `expr $a ** $b`               |
| /      | 除法   | `expr $b / $a` 结果为 2。     |
| %      | 取余   | `expr $b % $a` 结果为 0。     |
| =      | 赋值   | a=$b 将把变量 b 的值赋给 a。  |
| \|     | 或     | 按位或                        |
| &      | 与     | 按位与                        |
| ^      | 异或   | 按位异或                      |

shell脚本变量数值运算可以用以下四种方法

| 变量和变量运算                     | 变量和数值运算            | 数值和数值运算                          |
| ---------------------------------- | ------------------------- | --------------------------------------- |
| sum=\$[\$a+\$b]                    | a=\$[\$a+1]               | r=\$[ 2 * 3 ]                           |
| sum=\$((\$a+\$b))<br />((sum=a+b)) | a=$((\$a+1))              | r=\$(( 2 * 3 ))                         |
| sum=\`expr \$a + \$b\`             | a=\`expr \$a + 1\`        | r=\`expr 2\\ \* 3\`<br />r=\`expr 4/2\` |
| let sum=a+b                        | let a=a+1或<br />let a+=1 | let r=2*3                               |

expr 是一款表达式计算工具，使用它能完成表达式的求值操作。

```bash
val=`expr 2 + 2`
```

两点注意：

- 表达式和运算符之间要有空格，例如 2+2 是不对的，必须写成 2 + 2。
- 完整的表达式要被 \` \` 包含，这个字符是**反引号**在 Esc 键下边。

- 乘号(*)前边必须加反斜杠`\`才能实现乘法运算；

- 在 MAC 中 shell 的 expr 语法是：**$((表达式))**，此处表达式中的 “*” 不需要转义符号 `\` 。

```bash
let varName=算术表达式
varName=$[算术表达式]
varName=$((算术表达式))
```

## **Shell判断语句**

### **条件语句形式**

| **序号** | **表达式形式**       | **使用说明**                                                 |
| -------- | :------------------: | ------------------------------------------------------------ |
| 01       | [ <测试表达式> ] | 通过单中括号进行条件测试表达式书写；单中括号的边界和内容之间至少有一个空格 |
| 02       | [[ <测试表达式> ]]   | 通过双中括号进行条件测试表达式书写；双中括号的边界和内容之间至少有一个空格 |
| 03       | ((<测试表达式>))     | 通过双小括号进行条件测试表达式书写；双小括号的边界和内容之间无需有空格 |

<font class=notice>注：注意表达形式`[]`和`[[]]`之间的空格，如果没有空格则会报错，`[[s`会被当做命令执行</font>

在条件测试判断时，会根据布尔类型数值进行判断条件真与假的关系：

| **条件** | **数值表示** | **说明**                                 |
| -------- | ------------ | ---------------------------------------- |
| True     | 1            | 表示判断结果为真，判断的条件表达式成立   |
| False    | 0            | 表示判断结果为假，判断的条件表达式不成立 |

echo $? （特殊 0表示成功 其他表示失败）可以判断上一个命令是否执行成功，脚本、命令行都可以进行逻辑判断。

根据expr操作命令的返回值进行判断，$? 返回值为0表示命令执行成功，非0表示执行失败错误：

```bash
expr $num1 + $num2 + 1 &>/dev/null
if [ $? -ne 0 ]
then
    echo "你输入的数字有的不是整数，请重新输入"
    exit
fi
```

### **关系运算符**

关系运算符只支持数字，不支持字符串，除非字符串的值是数字。

双小括号 ”(())” 的作用是进行数值运算与数值比较，它的效率很高，用法灵活，是企业场景运维人员经常采用的运算操作符；

下表列出了常用的关系运算符，假定变量 a 为 10，变量 b 为 20：

| 运算符（`[]`中） | 运算符（`[[]]`、`(())`中） | 说明     | 举例                         |
| ---------------- | -------------------------- | -------- | ---------------------------- |
| -eq              | ==                         | 相等     | `[ $a -eq $b ]` 返回 false。 |
| -ne              | !=                         | 不相等   | `[ $a -ne $b ]` 返回 true。  |
| -gt              | >                          | 大于     | `[ $a -gt $b ]` 返回 false。 |
| -lt              | <                          | 小于     | `[ $a -lt $b ]` 返回 true。  |
| -ge              | \$a>\$b \|\| \$a=\$b       | 大于等于 | `[ $a -ge $b ]`返回 false。  |
| -le              | \$a<\$b \|\| \$a=\$b       | 小于等于 | `[ $a -le $b ]` 返回 true。  |

“=” 和 “!=” 也可在`[]`中做比较使用，但在`[]`中使用包含“>”和“<”的符号时，需要用反斜线转义

也可以在`[[]]`中使用包含 ”-gt” 和 ”-lt” 的符号 比较符号两端也要有空格

### **逻辑操作符**

以下介绍 Shell 的逻辑运算符，假定变量 a 为 10，变量 b 为 20:

| `[]`运算符 | `[[]]`运算符 | 说明       | 举例                                        |
| ---------- | ------------ | ---------- | ------------------------------------------- |
| -a         | &&           | 逻辑的 AND | `[[ $a -lt 100 && $b -gt 100 ]]` 返回 false |
| -o         | \|\|         | 逻辑的 OR  | `[[ $a -lt 100 || $b -gt 100 ]]` 返回 true  |
| !          | !            | 逻辑的NOT  | `[[ ! $a -lt 100 ]]` 返回false              |

示例：

```bash
[ 条件1 ] -a [ 条件2 ]
[[ 条件1 ]] && [[ 条件2 ]]
((条件1)) && ((条件2))
[ ! 条件 ] 
```

### 字符串运算符

下表列出了常用的字符串运算符，假定变量 a 为 “abc”，变量 b 为 “efg”：

| 运算符 | 说明                                      | 举例                             |
| ------ | ----------------------------------------- | -------------------------------- |
| =      | 检测两个字符串是否相等，相等返回 true。   | `[ $a = $b ]` 返回 false。       |
| !=     | 检测两个字符串是否相等，不相等返回 true。 | `[ $a != $b ]` 返回 true。       |
| -z     | 检测字符串长度是否为0，为0返回 true。     | `[ -z $a ]` 返回 false。         |
| -n     | 检测字符串长度是否为0，不为0返回 true。   | `[ -n "$a" ]` 返回 true。        |
| $      | 检测字符串是否为空，不为空返回 true。     | `[ $a ]` 返回 true。             |
| >      | 判断字符相同顺位的字符大小，常使用`[[]]`  | `[[ $a > $b ]]`返回false         |
| <      | 判断字符相同顺位的字符大小，常使用`[[]]`  | `[[ $a < $b ]]`返回true          |
| =\~    | 匹配正则表达式通，常使用`[[]]`            | `[[ $a =~ \b[a-z]*\b ]]`返回true |

### 文件检测运算符

文件测试运算符用于检测 Unix 文件的各种属性。

属性检测描述如下：

| 操作符  | 说明                                                 | 举例         |
| ------- | ---------------------------------------------------- | ------------ |
| -f file | 检测文件是否是普通文件（既不是目录，也不是设备文件） | [ -f $file ] |
| -d file | 检测文件是否是目录                                   | [ -d $file ] |
| -e file | 检测文件（包括目录）是否存在                         | [ -e $file ] |
| -b file | 检测文件是否是块设备文件                             | [ -b $file ] |
| -c file | 检测文件是否是字符设备文件                           | [ -c $file ] |
| -g file | 检测文件是否设置了 SGID 位                           | [ -g $file ] |
| -k file | 检测文件是否设置了粘着位(Sticky Bit)                 | [ -k $file ] |
| -u file | 检测文件是否设置了 SUID 位                           | [ -u $file ] |
| -r file | 检测文件是否可读                                     | [ -r $file ] |
| -w file | 检测文件是否可写                                     | [ -w $file ] |
| -x file | 检测文件是否可执行                                   | [ -x $file ] |
| -p file | 检测文件是否是有名管道                               | [ -p $file ] |
| -s file | 检测文件是否不为空（文件大小是否大于0）              | [ -s $file ] |
| -S file | 判断某文件是否 socket。                              | [ -S $file ] |
| -L file | 检测文件是否存在并且是一个符号链接。                 | [ -L $file ] |

## shell数据类型

### 字符串

字符串可以用单引号，也可以用双引号，也可以不用引号。

单引号：

```bash
str='this is a string'b
```

单引号字符串的限制：

- 单引号里的任何字符都会原样输出，单引号字符串中的变量是无效的；
- 单引号字串中不能出现单独一个的单引号（对单引号使用转义符后也不行），但可成对出现，作为字符串拼接使用。

双引号：

```bash
your_name='taobao'
str="Hello, I know you are \"$your_name\"! \n"
echo -e $str

# 输出结果为：
Hello, I know you are "taobao"! 
```

双引号的优点：

- 双引号里可以有变量
- 双引号里可以出现转义字符

拼接字符串：

```bash
your_name="taobao"
# 使用双引号拼接
greeting="hello, "$your_name" !"     #双引号外可以不加"{}"
greeting_1="hello, ${your_name} !"   #双引号内加"{}"
echo $greeting  $greeting_1
# 使用单引号拼接
greeting_2='hello, '$your_name' !'
greeting_3='hello, ${your_name} !'   #单引号内原来是啥就是啥
echo $greeting_2  $greeting_3

#输出结果为：
hello, taobao ! hello, taobao !
hello, taobao ! hello, ${your_name} !
```

**获取字符串长度`${#s}`**

```bash
string="abcd"
echo ${#string} #输出 4
```

**截取字符串${s:n1:n2}**

以下实例从字符串第 **2** 个字符开始截取 **4** 个字符：

```bash
string="taobao is a great site"
echo ${string:1:4} # 输出 unoo
```

**查找字符出现的位置`expr index`**

查找字符 **i** 或 **o** 的位置(哪个字母先出现就计算哪个)：

```bash
string="taobao is a great site"
echo `expr index "$string" io`  # 输出 3
```

**注意：** 以上脚本中 **`** 是反引号，而不是单引号 **'**。

### 数组

bash支持一维数组（不支持多维数组），并且没有限定数组的大小。

数组元素的下标由 0 开始编号。

#### 定义数组

在 Shell 中，用括号来表示数组，数组元素用"空格"符号分割开。可以不使用连续的下标，而且下标的范围没有限制。

数组的定义方法：

```bash
#定义数组的一般形式为：
array_name=(value0 value1 value2 value3)

#或者
array_name=(
value0
value1
value2
value3
)
#采用键值对的形式赋值（了解即可）
array=([1]=one [2]=two [3]=three)

#或单独定义数组的各个分量（麻烦，不推荐）
array_name[0]=value0
array_name[1]=value1
array_name[n]=valuen
```

#### 读取数组

读取数组元素值的一般格式是：

```bash
valuen=${array_name[n]}
```

例子：

```bash
#!/bin/bash
my_array=(A B "C" D)
echo "第一个元素为: ${my_array[0]}"
echo "第二个元素为: ${my_array[1]}"
echo "第三个元素为: ${my_array[2]}"
echo "第四个元素为: ${my_array[3]}"

#执行脚本，输出结果如下所示：
第一个元素为: A
第二个元素为: B
第三个元素为: C
第四个元素为: D
```

使用 `@`或`*` 符号可以获取数组中的所有元素，例如：

```bash
echo ${array_name[@]}
```

例子：

```bash
#!/bin/bash
my_array=(A B C D)
echo "数组的元素为: ${my_array[*]}"
my_array[4]=E
echo "数组的元素为: ${my_array[@]}"

#执行脚本，输出结果如下所示：
数组的元素为: A B C D
数组的元素为: A B C D E
```

#### 获取数组的长度

获取数组长度的方法与获取字符串长度的方法相同，例如：

```bash
# 取得数组元素的个数
length=${#array_name[@]}
# 或者
length=${#array_name[*]}
# 取得数组单个元素的长度
lengthn=${#array_name[n]}
```

例子：

```bash
#!/bin/bash
my_array=(A B C D)
echo "数组元素个数为: ${#my_array[*]}"
echo "数组元素个数为: ${#my_array[@]}"

#执行脚本，输出结果如下所示：
数组元素个数为: 4
数组元素个数为: 4
```

#### 数组元素信息删除

使用unset命令删除数组信息：

```
[17:38:49 root@centon7 ~]# my_array=(A B C D)
[17:53:00 root@centon7 ~]# echo ${my_array[*]}
A B C D
[17:54:25 root@centon7 ~]# unset my_array[3]
[17:55:01 root@centon7 ~]# echo ${my_array[*]}
A B C
[17:55:27 root@centon7 ~]# unset my_array 
[17:55:33 root@centon7 ~]# echo ${my_array[*]}  #输出为空
```

## Shell基础操作

### echo命令

Shell 的 echo 指令与 PHP 的 echo 指令类似，都是用于字符串的输出。命令格式：

```bash
echo string
```
示例：
```bash
#显示普通字符串:
echo "It is a test"       #这里的双引号完全可以省略，以下命令与上面实例效果一致：
echo It is a test

#显示转义字符:
echo "\"It is a test\""   #结果:"It is a test"
echo \"It is a test\"     #同样，双引号也可以省略

# -e 开启转义
echo "It is a test"
echo -e "It is \n a test\c"
# 执行结果
[15:38:16 root@rocky95 ~]# sh 1.sh 
It is a test
It is 
 a test[15:38:19 root@rocky95 ~]# 
```

### Shell传递参数

shell变量除了可以直接赋值外，还可以使用脚本传参和read命令从标准输入中获得，read为bash内置命令;

#### 调用脚本时传入参数

执行 Shell 脚本时，向脚本传递参数，脚本内获取参数的格式为：

```bash
sh filename.sh var1 var2 ...... varn
```

**n** 代表一个数字，\$1 为执行脚本的第一个参数，\$2 为执行脚本的第二个参数，以此类推……

**$0** 为执行的文件名

test.sh文件内容如下：

```bash
#!/bin/bash
echo "Shell 传递参数实例！";
echo "执行的文件名：$0";
echo "第一个参数为：$1";
echo "第二个参数为：$2";
echo "第三个参数为：$3";

#运行结果：
sh test.sh 1 2 3
Shell 传递参数实例！
执行的文件名：test.sh
第一个参数为：1
第二个参数为：2
第三个参数为：3
```

<font class=notice>注意：当”n“为多位时，脚本内变量需要用大括号“{}”包括，不然只能识别第一位</font>

参数获取：

| 参数处理 | 说明                                                         |
| -------- | ------------------------------------------------------------ |
| `$#`     | 传递到脚本的参数个数                                         |
| `$$`     | 脚本运行的当前进程ID号                                       |
| `$!`     | 后台运行的最后一个进程的ID号                                 |
| `$*`     | 所有参数作为一个字符串传出                                   |
| `$@`     | 所有的参数一个一个传出来                                     |
| `$?`     | 显示最后命令的退出状态。0表示没有错误，其他任何值表明有错误。 |

```bash
#!/bin/bash
echo '$1='$1
echo '$2='$2
echo '$10='$10
echo '$10='${10}
echo '$$='$$
echo '$#='$#
echo '$@='$@
echo '$*='$*
echo '$?='$?

# 执行脚本，输出结果如下所示：
sh 1.sh a b c d e f g h i j
$1=a
$2=b
$10=a0
$10=j
$$=3636848
$#=10
$@=a b c d e f g h i j
$*=a b c d e f g h i j
$?=0
```

`$*`与`$@`的区别：

- 只有在双引号中体现出来。假设在脚本运行时写了三个参数 1、2、3，，则`$*` 等价于 “1 2 3”（传递了一个参数），而`$@`等价于 “1” “2” “3”（传递了三个参数）。

```bash
#!/bin/bash
echo "-- \"\$*\" 演示 ---"
for i in "$*"; do
    echo $i
done
echo "-- \"\$@\" 演示 ---"
for i in "$@"; do
    echo $i
done
echo "-- \$* 演示 ---"
for i in $*; do
    echo $i
done
echo "-- \$@ 演示 ---"
for i in $@; do
    echo $i
done

#执行脚本，输出结果如下所示：
python@ubuntu:~/test$ sh test 1 2 3
-- "$*" 演示 ---
1 2 3
-- "$@" 演示 ---
1
2
3
-- $* 演示 ---
1
2
3
-- $@ 演示 ---
1
2
3
```

#### **read 命令**

从标准输入中读取一行,并把输入行的每个字段的值指定给 shell 变量。

```bash
# read
read var      #交互式传参给var
-p var	      #设置交互过程相关提示信息 prompt
-t var        #设置交互过程等待时间信息 timeout
```

示例：

```bash
#!/bin/sh
read name 
echo "You name is $name!"
read -p "请重新输入你的名字：" name
echo "You name is $name!"
read -p "这个输入只存在10s： " -t 10 name
echo 10s到了！！
#执行结果:
[15:34:25 root@rocky95 ~]# sh test.sh
Corazon                        #标准输入
You name is Corazon!           #输出
请重新输入你的名字：Corazon        #设置交互过程相关提示信息
You name is Corazon!           #输出
这个输入只存在10s： 10s到了！！     #设置交互过程等待时间信息#输出 
```

### printf 命令

printf 命令可以实现标准化输出，printf 命令的语法：

```bash
printf  format-string  [arguments...]
```

**参数说明：**

- **format-string:** 为格式控制字符串
- **arguments:** 为参数列表。

实例如下：

```bash
#!/bin/bash
printf "%-10s %-8s %-4s\n" 姓名 性别 体重kg  
printf "%-10s %-8s %-4.2f\n" 郭靖 男 66.1234 
printf "%-10s %-8s %-4.2f\n" 杨过 男 48.6543 
printf "%-10s %-8s %-4.2f\n" 郭芙 女 47.9876 

#执行脚本，输出结果如下所示：
姓名     性别   体重kg
郭靖     男      66.12
杨过     男      48.65
郭芙     女      47.99
```

- %s %c %d %f都是格式替代符
- %-10s 指一个宽度为10个字符（-表示左对齐，没有则表示右对齐），任何字符都会被显示在10个字符宽的字符内，如果不足则自动以空格填充，超过也会将内容全部显示出来。
- %-4.2f 指格式化为小数，其中.2指保留2位小数。

printf的转义序列：

| 序列  | 说明                                                         |
| ----- | ------------------------------------------------------------ |
| \a    | 警告字符，通常为ASCII的BEL字符                               |
| \b    | 后退                                                         |
| \c    | 抑制（不显示）输出结果中任何结尾的换行字符（只在%b格式指示符控制下的参数字符串中有效），而且，任何留在参数里的字符、任何接下来的参数以及任何留在格式字符串中的字符，都被忽略 |
| \f    | 换页（formfeed）                                             |
| \n    | 换行                                                         |
| \r    | 回车（Carriage return）                                      |
| \t    | 水平制表符                                                   |
| \v    | 垂直制表符                                                   |
| \     | 一个字面上的反斜杠字符                                       |
| \ddd  | 表示1到3位数八进制值的字符。仅在格式字符串中有效             |
| \0ddd | 表示1到3位的八进制值字符                                     |

例子：

```bash
printf "a string, no processing:<%s>\n" "A\nB"
a string, no processing:<A\nB>
printf "a string, no processing:<%b>\n" "A\nB"
a string, no processing:<A
B>
printf "www.runoob.com \a"
www.runoob.com [14:11:29 root@centon7 ~]# 
```

### test命令

Shell中的 test 命令用于检查某个条件是否成立，它可以进行数值、字符和文件三个方面的测试。

实例演示：

```bash
#01 数值测试
num1=10
num2=5
if test $[num1 / num2] -eq $[num2-num1]
then
    echo '两个数相等！'
else
    echo '两个数不相等！'
fi
#输出结果：
#两个数不相等！

#02 字符串测试
num1="ru1noob"
num2="runoob"
if test $num1 = $num2
then
    echo '两个字符串相等!'
else
    echo '两个字符串不相等!'
fi
#输出结果：
#两个字符串不相等!

# 文件测试
cd /bin
if test -e ./bash
then
    echo '文件已存在!'
else
    echo '文件不存在!'
fi
#输出结果：
#文件已存在!


#另外，Shell还提供了与( -a )、或( -o )、非( ! )三个逻辑操作符用于将测试条件连接起来，其优先级为："!“最高，”-a"次之，"-o"最低。例如：
cd /bin
if test -e ./notFile -o -e ./bash
then
    echo '至少有一个文件存在!'
else
    echo '两个文件都不存在'
fi
#输出结果：
#至少有一个文件存在!
```

### Shell 注释

以 **#** 开头的行就是注释，会被解释器忽略：

```bash
#--------------------------------------------
# 这是一个注释
# author：Corazon
# site：www.mcorazon.top
# slogan：强者，绝非偶然！
#--------------------------------------------
### 用户配置区 开始 ###
#
#
# 这里可以添加脚本描述信息
# 
#
### 用户配置区 结束  ###
```

多行注释还可以使用以下格式：

```bash
:<<EOF
注释内容...
注释内容...
注释内容...
EOF
```

EOF 也可以使用其他符号:

```bash
:<<'
注释内容...
'

:<<!
注释内容...
!
```

### 文件包含

Shell可以使用文件包含来调用变量和函数等。Shell 文件包含的语法格式如下：

```bash
. filename   # 注意点号(.)和文件名中间有一空格
或
source filename
```

**实例**

创建两个 shell 脚本文件。

```bash
#test1.sh 代码如下：
#!/bin/bash
url="http://www.baidu.com"


#test2.sh 代码如下：
#!/bin/bash
#使用 . 号来引用test1.sh 文件
. ./test1.sh
# 或者使用以下包含文件代码
# source ./test1.sh
echo "url地址：$url"
```

接下来，我们为 test2.sh 添加可执行权限并执行：

```bash
$ chmod +x test2.sh 
$ ./test2.sh 
url地址：http://www.baidu.com
```

> **注：**被包含的文件 test1.sh 不需要可执行权限。

### 其他命令与变量

**命令**

usleep --微秒

sleep --秒为单位

exit     退出整个脚本的运行（终止脚本继续运行）

unset  取消变量

**变量**

$random 随机数

## Shell 流程控制

通常，在bash的各种条件结构和流程控制结构中都要进行各种检验，然后根据检验结果执行不同的操作；

### if else判断语句

if 语句语法格式：

```bash
if [condition]:
then
    command1 
    ...
    commandN 
fi
```

在终端可以将命令写成一行：

```
if [ $(ps -ef | grep -c "ssh") -gt 1 ]; then echo "true"; fi
```

if else 语法格式：

```bash
if condition
then
    command
    ...
else
    command
    ...
fi
```

if else-if else 语法格式：

```bash
if condition1
then
    command1
    ......
elif condition2 
then 
    command2
    ......
else
    commandN
    ......
fi
```

if else语句经常与test命令结合使用，如下所示：

```bash
num1=$[2*3]
num2=$[1+5]
if test $[num1] -eq $[num2]
then
    echo '两个数字相等!'
else
    echo '两个数字不相等!'
fi

#输出结果：
两个数字相等!
```

### for循环

for循环一般格式：

```bash
for var in item1 item2 ... itemN
do
    command1
    ...
    commandN
done
```

C语言方式：

```bash
for ((exp1;exp2;exp3))
do
  command1
  ......
done
```

写成一行（方便在终端执行）：

```bash
for var in item1 item2 ... itemN; do command1; command2… done;
```

示例：

```bash
#顺序输出当前列表中的数字
for loop in 1 2 3 4 5
do
    echo "The value is: $loop"
done
#输出结果：
The value is: 1
The value is: 2
The value is: 3
The value is: 4
The value is: 5

#顺序输出字符串中的字符：
for str in 'This is a string'
do
    echo $str
done
#输出结果：
This is a string

#C语言方式
for ((i=1;i<=5;i++))
do
  echo -e "$i \c"
done
echo ""
#输出结果：
1 2 3 4 5 
```

### while循环

while循环格式为：

```bash
while condition
do
    command
done
```

while循环可用于读取键盘信息。下面的例子中，输入信息被设置为变量FILM，按`Ctrl-D`结束循环。

```bash
echo '按下 <CTRL-D> 退出'
echo -n '输入你最喜欢的网站名: '
while read FILM
do
    echo "是的！$FILM 是一个好网站"
done
```

运行脚本，输出类似下面：

```
按下 <CTRL-D> 退出
输入你最喜欢的网站名:淘宝
是的！淘宝 是一个好网站
```

### 无限循环

无限循环语法格式：

```bash
while :           #  三种方法均可
while true        #  三种方法均可 
for (( ; ; ))     #  三种方法均可
do
    command
done
```

### until 循环

until 循环执行一系列命令直至条件为 true 时停止，与 while 循环在处理方式上刚好相反。

一般 while 循环优于 until 循环，但在某些时候——也只是极少数情况下，until 循环更加有用。

until 语法格式：

```bash
until condition
do
    command
done
```

condition 为条件表达式，如果返回值为 false，则继续执行循环体内的语句，否则跳出循环。

以下实例我们使用 until 命令来输出 0 ~ 9 的数字：

```bash
#!/bin/bash
a=0
until [ ! $a -lt 10 ]
do
   echo $a
   a=`expr $a + 1`
done
```

### **循环控制语句**

在循环过程中，有时候需要在未达到循环结束条件时强制跳出循环，Shell使用两个命令来实现该功能：break和continue。

break命令允许跳出所有循环（终止执行后面的所有循环）。

下面的例子中，脚本进入死循环直至用户输入数字大于5。要跳出这个循环，返回到shell提示符下，需要使用break命令。

```bash
#!/bin/bash
while :
do
    echo -n "输入 1 到 5 之间的数字:"
    read aNum
    case $aNum in
        1|2|3|4|5) echo "你输入的数字为 $aNum!"
        ;;
        *) echo "你输入的数字不是 1 到 5 之间的! 游戏结束"
            break
        ;;
    esac
done
```

执行以上代码，输出结果为：

```bash
输入 1 到 5 之间的数字:3
你输入的数字为 3!
输入 1 到 5 之间的数字:7
你输入的数字不是 1 到 5 之间的! 游戏结束
```

continue命令与break命令类似，只有一点差别，它不会跳出所有循环，仅仅跳出当前循环。

### case

Shell case语句为多选择语句。可以用case语句匹配一个值与一个模式，如果匹配成功，执行相匹配的命令。case语句格式如下：

```bash
case 值 in
模式1)
    command1
    ...
    commandN
    ;;
模式2）
    command1
    ...
    commandN
    ;;
*)
	command1
	.....
	commandn
	;;
esac
```

下面的脚本提示输入1到4，与每一种模式进行匹配：

```bash
echo '输入 1 到 4 之间的数字:'
echo '你输入的数字为:'
read aNum
case $aNum in
    1)  echo '你选择了 1'
    ;;
    2)  echo '你选择了 2'
    ;;
    3)  echo '你选择了 3'
    ;;
    4)  echo '你选择了 4'
    ;;
    *)  echo '你没有输入 1 到 4 之间的数字'
    ;;
esac
#输入不同的内容，会有不同的结果，例如：
输入 1 到 4 之间的数字:
你输入的数字为:
3
你选择了 3
```

## Shell输入/输出重定向

重定向命令列表如下：

| 命令            | 说明                                               |
| --------------- | -------------------------------------------------- |
| command > file  | 将输出重定向到 file。                              |
| command < file  | 将输入重定向到 file。                              |
| command >> file | 将输出以追加的方式重定向到 file。                  |
| n > file        | 将文件描述符为 n 的文件重定向到 file。             |
| n >> file       | 将文件描述符为 n 的文件以追加的方式重定向到 file。 |
| n >& m          | 将输出文件 m 和 n 合并。                           |
| n <& m          | 将输入文件 m 和 n 合并。                           |
| << tag          | 将开始标记 tag 和结束标记 tag 之间的内容作为输入。 |

> 需要注意的是文件描述符 0 通常是标准输入（STDIN），1 是标准输出（STDOUT），2 是标准错误输出（STDERR）。

------

### 输出重定向

重定向一般通过在命令间插入特定的符号来实现。特别的，这些符号的语法如下所示:

```bash
command1 > file1
```

上面这个命令执行command1然后将输出的内容存入file1。

注意任何file1内的已经存在的内容将被新内容替代。如果要将新内容添加在文件末尾，请使用>>操作符。

输出重定向会覆盖文件内容：

```bash
$ echo "www.baidu.com" > users
$ cat users
www.baidu.com
$
```

如果不希望文件内容被覆盖，可以使用 >> 追加到文件末尾，例如：

```bash
$ echo "www.baidu.com" >> users
$ cat users
www.baidu.com
www.baidu.com
$
```

### 输入重定向

和输出重定向一样，Unix 命令也可以从文件获取输入，语法为：

```bash
command1 < file1
```

这样，本来需要从键盘获取输入的命令会转移到文件读取内容。

注意：输出重定向是大于号(>)，输入重定向是小于号(<)。

统计 users 文件的行数,执行以下命令：

```bash
python@ubuntu:~/test$ wc -l test 
4 test
```

也可以将输入重定向到 users 文件：

```bash
python@ubuntu:~/test$ wc -l <test
4
```

注意：上面两个例子的结果不同：第一个例子，会输出文件名；第二个不会，因为它仅仅知道从标准输入读取内容。

同时替换输入和输出，执行command1，从文件infile读取内容，然后将输出写入到outfile中:

```bash
command1 < infile > outfile
```

### 重定向深入讲解

一般情况下，每个 Unix/Linux 命令运行时都会打开三个文件：

- 标准输入文件(stdin)：stdin的文件描述符为0，Unix程序默认从stdin读取数据。
- 标准输出文件(stdout)：stdout 的文件描述符为1，Unix程序默认向stdout输出数据。
- 标准错误文件(stderr)：stderr的文件描述符为2，Unix程序会向stderr流中写入错误信息。

默认情况下，command > file 将 stdout 重定向到 file，command < file 将stdin 重定向到 file。

如果希望 stderr 重定向到 file，可以这样写：

```bash
$ command 2 > file
```

如果希望 stderr 追加到 file 文件末尾，可以这样写：

```bash
$ command 2 >> file
```

**2** 表示标准错误文件(stderr)。

如果希望将 stdout 和 stderr 合并后重定向到 file，可以这样写：

```bash
$ command > file 2>&1
或者
$ command >> file 2>&1
```

如果希望对 stdin 和 stdout 都重定向，可以这样写：

```bash
$ command < file1 >file2
```

command 命令将 stdin 重定向到 file1，将 stdout 重定向到 file2。

### Here Document

Here Document 是 Shell 中的一种特殊的重定向方式，用来将输入重定向到一个交互式 Shell 脚本或程序。

它的基本的形式如下：

```bash
command << delimiter
    document
delimiter
```

它的作用是将两个 delimiter 之间的内容(document) 作为输入传递给 command。

注意：结尾的delimiter 一定要顶格写，前面不能有任何字符，后面也不能有任何字符，包括空格和 tab 缩进。

在命令行中通过 wc -l 命令计算 Here Document 的行数：

```bash
$ wc -l << EOF
    欢迎来到
    菜鸟教程
    www.runoob.com
EOF
3          # 输出结果为 3 行
$
```

### /dev/null 文件

如果希望执行某个命令，但又不希望在屏幕上显示输出结果，那么可以将输出重定向到 /dev/null：

```bash
$ command > /dev/null
```

/dev/null 是一个特殊的文件，写入到它的内容都会被丢弃；如果尝试从该文件读取内容，那么什么也读不到。但是 /dev/null 文件非常有用，将命令的输出重定向到它，会起到"禁止输出"的效果。

如果希望屏蔽 stdout 和 stderr，可以这样写：

```bash
$ command > /dev/null 2>&1
```

0 是标准输入（STDIN），1 是标准输出（STDOUT），2 是标准错误输出（STDERR）。

## Shell 函数

与很多其他语言不同，所有函数在使用前必须定义。这意味着必须将函数放在脚本开始部分，直至shell解释器首次发现它时，才可以使用。调用函数仅使用其函数名即可。

**shell中函数的定义格式如下：**

```bash
[ function ] funname [()]
{
    action;
    [return n;]
}
```

说明：

- 1、可以带function fun() 定义，也可以直接fun() 定义（推荐），不带任何参数。
- 2、参数返回，可以显示加：return 返回，如果不加，将以最后一条命令运行结果，作为返回值。 return后跟数值n(0-255)

示例：

```bash
#!/bin/bash

funWithReturn(){
    echo "这个函数会对输入的两个数字进行相加运算..."
    echo "输入第一个数字: "
    read aNum
    echo "输入第二个数字: "
    read anotherNum
    echo "两个数字分别为 $aNum 和 $anotherNum !"
    return $(($aNum+$anotherNum))
}
funWithReturn
echo "输入的两个数字之和为 $? !"

# 执行结果
这个函数会对输入的两个数字进行相加运算...
输入第一个数字: 
1
输入第二个数字: 
2
两个数字分别为 1 和 2 !
输入的两个数字之和为 3 !
```

函数返回值在调用该函数后可通过 $? 来获得。

**Shell函数脚本文件实现传参功能**

**传参方式一：**

在Shell中，调用函数时可以向其传递参数。在函数体内部，通过 `$n` 的形式来获取参数的值，当n>=10时，需要使用`${n}`来获取参数。

带参数的函数示例：

```bash
#!/bin/bash

funWithParam(){
    echo "第一个参数为 $1 !"
    echo "第二个参数为 $2 !"
    echo "第十个参数为 $10 !"
    echo "第十个参数为 ${10} !"
    echo "第十一个参数为 ${11} !"
    echo "参数总数有 $# 个!"
    echo "作为一个字符串输出所有参数 $* !"
}
funWithParam 1 2 3 4 5 6 7 8 9 34 73

#运行输出结果：
第一个参数为 1 !
第二个参数为 2 !
第十个参数为 10 !
第十个参数为 34 !
第十一个参数为 73 !
参数总数有 11 个!
作为一个字符串输出所有参数 1 2 3 4 5 6 7 8 9 34 73 !
```

**传参方式二：**

可以在调用时传参，但是脚本格式不能省略，用变量代替。如果是多个变量可以用`$*`代替

脚本执行效果演示：

```bash
#!/bin/bash

funWithParam(){
    echo "第一个参数为 $1 !"
    echo "第二个参数为 $2 !"
    echo "第十个参数为 $10 !"
    echo "第十个参数为 ${10} !"
    echo "第十一个参数为 ${11} !"
    echo "参数总数有 $# 个!"
    echo "作为一个字符串输出所有参数 $* !"
}
funWithParam $*   # 或者：funWithParam $1......$11

[17:35:40 root@centon7 ~]# sh 1.sh 1 2 3 4 5 6 7 8 9 10 11
第一个参数为 1 !
第二个参数为 2 !
第十个参数为 10 !
第十个参数为 10 !
第十一个参数为 11 !
参数总数有 11 个!
作为一个字符串输出所有参数 1 2 3 4 5 6 7 8 9 10 11 !
```

<br/>


```
# 主函数，第一个执行的函数  --主函数 先执行 调用其他函数
main(){
  judge $*
  compare $*
}
# 调用主函数执行
main $*

```

另外，还有几个特殊字符用来处理参数：

| 参数处理                                                     | 说明                                                         |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| $#                                                           | 传递到脚本的参数个数                                         |
| $*                                                           | 以一个单字符串显示所有向脚本传递的参数                       |
| $$                                                           | 脚本运行的当前进程ID号                                       |
| $!                                                           | 后台运行的最后一个进程的ID号                                 |
| $@       | 与$*相同，但是使用时加引号，并在引号中返回每个参数。 |                                                              |
| $-                                                           | 显示Shell使用的当前选项，与set命令功能相同。                 |
| $?                                                           | 显示最后命令的退出状态。0表示没有错误，其他任何值表明有错误。 |

配置函数信息的文件：/etc/init.d/functions 。示例：

```bash
#!/bin/bash
.  /etc/init.d/functions

read -p "请输入一个数字：" num
if  [ $num -eq 10 ]
 then
 action "输入信息正确" /bin/true
else
 action "输入信息错误" /bin/false
fi
```

![image-20250717172053299](【Linux】shell编程/image-20250717172053299.png)

### 实例

### 杨辉三角：

```bash
#!/bin/bash

if (test -z $1) ;then 
 read -p "Input high Int Lines:" high 
else 
 high=$1 
fi 
if (test -z $2) ;then 
 space=4
else 
 space=$2
fi

printspace(){
  #空位填充
  for((z=1;z<=$1;z++));do
    echo -n " "
  done
}

a[0]=1     
for((i=0;i<=high;i++));do
  #产生当前列数据数组
  for ((j=$i;j>0;j--));do 
    ((a[$j]+=a[$j-1])) 
  done
  printspace $((($high-$i)*$space/2))
  for ((j=0;j<=$i;j++));do
    num=$(($space-${#a[$j]}))
    printspace $(($num/2))
    echo -n ${a[$j]}
    printspace $(($num-$num/2))
  done
  echo ""
done
```

### sum()&max():

```bash
#!/bin/bash

echo "shell的函数返回值只能为0~255的整数，高位自动丢弃"
sum(){
 sum=0
 for i in $@
 do
  if test $i -ne $1;then
   echo -n "+"
  fi
  echo -n "$i"
  sum=$(($sum+$i))
 done
 echo "=$sum"
 return $(($sum))
}
sum $@
echo "‘sum()’函数返回值："$?

max(){
 max=0
 for i in $@;do
  if test $i -ge $max;then
    max=$i
  fi
 done
 echo "参数最大值：$max"
 return $(($max))
}

max $@

echo "‘max()’函数返回值："$?
```

### 99乘法表：

```bash
#!/bin/bash

for i in {1..9};do
 for((j=1;j<=i;j++));do
  echo -en "$i*$j=$(($i*$j))\t"
 done
 echo ""
done

for a in {1..9};do
    for b in {0..9};do
        for c in {0..9};do
            number1=$((a*100+b*10+c))
            number2=$((a**3+b**3+c**3))
            if test $number1 -eq $number2; then
                echo "Found number $number1"
            fi
        done
    done
done
```





本文参考：
