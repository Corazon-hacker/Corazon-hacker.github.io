---
title: 【Python】Python基础
comments: true
abbrlink: 731b144e
categories:
  - 基础知识
  - Python
date: 2025-07-15 10:07:42
tags:
description:
top:
---

## Python概述

## pycharm常用快捷键：

| 作用         | 快捷键           | 作用                 | 快捷键                  |
| ------------ | ---------------- | -------------------- | ----------------------- |
| 单行注释     | Ctrl + /         | 复制当前光标所在行   | Ctrl + D                |
| 格式化代码   | Ctrl + Alt + L   | 删除当前光标所在行   | Ctrl + X                |
| 全局查找     | Ctrl + Shift + R | 返回至上次浏览的位置 | Ctrl + Alt + left/right |
| 快速选中代码 | Ctrl + W         | 替换                 | Ctrl + R                |

## 标识符与关键字：

### 标识符

标识符就是一个名字，就好像每个人都有自己的名字；主要作用是作为程序中变量、函数、类、模块以及其他对象的调用名称。

Python中标识符的命名要遵守一定的命名规则：

- 标识符由字母、下划线和数字组成，但不能以数字开头。
- 标识符不能和 Python中关键字等相同。
- 标识符严格区分大小写，例：Corazon和corazon是不同标识符。
- 以下划线开头标识符往往有特殊含义。

### 关键字

关键字就是Pytnon内部已经定义好的具有特殊意义的标识符，开发人员不能重复定义。

Python3的关键字可以通过keyword模块的变量kwlist查看：

```python
# 打印关键字列表
import keyword
print(keyword.kwlist)
# 关键字输出结果
['False', 'None', 'True', '__peg_parser__','and', 'as', 'assert', 'async', 'await', 'break', 'class', 'continue', 'def', 'del', 'elif', 'else', 'except', 'finally', 'for', 'from', 'global', 'if', 'import', 'in', 'is', 'lambda', 'nonlocal', 'not', 'or', 'pass', 'raise', 'return', 'try', 'while', 'with', 'yield']

# 查看关键字帮助
print(help("if"))
```

### 定义变量

```python
变量名 = 数据
```

等号表示赋值运算符，两端有空格是开发规范，可以没有。

定义变量示例：

```python
name  =  "Corazon"
age = 35
is_man = True 

# 打印单个变量值，print()是一个输出函数，类似Linux里echo
print(name)
print(age)
# 打印多个变量值,多个变量用逗号隔开
print(name, age, is_man)
```

### 注释

注释是编写程序时，程序员对一个语句、程序段、函数等的解释或提示，可提高程序代码可读性；

合理的代码注释应该占源代码的1/4左右，注释内容不会被解释器执行。

```python
# 单行注释信息：以#号开头，后面留一个空格
# 这里就是单行注释，以#开头,后面整行都不会被解释器执行
print("I am Corazon teacher.")  # 表示打印输出
-- 在程序尾部注释，“#”前至少有两个空格
# 多行注释信息：包含在3个双引号或者3个单引号内的语句
"""
这里就是多行注释
三个引号里面的任何内容不会被解释器执行
"""
或者
'''
这里就是多行注释
三个引号里面的任何内容不会被解释器执行
'''
```

## python代码编写语法规范

### 代码语句分隔符号

Python使用分号，用于一条语句的结束标识，如果是一行结尾，可用换行来替代分号。

```python
Python使用分号，用于一条语句的结束标识，如果是一行结尾，可用换行来替代分号。

# 使用分号作为语句分隔符
print("I am");print("Corazon")

# 使用换行作为语句分隔符
print("I am")
print("Corazon")
```

### 代码语句缩进要求

Java、C 语言采用大括号“{}”分隔代码块，而Python 采用冒号“:”和“代码缩进”和来区分代码块之间的层次;对于类、函数、流程控制语句、异常处理语句等，行尾的冒号和下一行的缩进，表示下一个代码块的开始;而缩进的结束则表示此代码块的结束。

Python 中可使用空格或者Tab键实现，但无论是手动敲空格，还是使用 Tab 键，通常情况下都是采用 4 个空格长度作为一个缩进量;

默认情况下，一个 Tab 键就是4 个空格。

 

```python
i = int(input("请你输入一个数字: "))
if i > 5:
    print("你输入的数字是", i, "，大于5，",sep='')
else:
    print("你输入的数字是", i, "，小于5，",sep='')

```

### 代码语法规范补充

Python 采用 PEP 8 作为编码规范，其中 PEP 是 Python Enhancement Proposal（Python 增强建议书）的缩写;8 代表的是 Python 代码的样式指南。

- 下面仅给大家列出 PEP 8 中初学者应严格遵守的一些编写规则：
- 不要在行尾添加分号";"
- 不要用分号将两条命令放在同一行;
- 在运算符两侧、函数参数之间以及逗号两侧，都使用空格分隔;
- 使用必要的空行可以增加代码的可读性，通常在顶级定义（如函数或类的定义）之间空两行，而方法定义之间空一行;
- 另外在用于分隔某些功能的位置也可以空一行。
- python中有些特殊语句指令结尾，需要加入：

## python数据类型介绍

在python开发过程中，可以将数据类型分为两个大类：

python基本数据类型：字符串 数值型(整型 布尔型) 浮点型

python复合数据类型：元组、列表、字典、集合

### 数据类型之数字类型介绍

#### 整数类型

python中的整型，即int类型，Python中没有对整型数字大小限制；

```python
# 整数类型示例
x = 10
print(x) #   输出x的值    
print(type(x))  #打印类型，type()函数用于输出变量的类型
# 将不同进制数转成十进制
print(0x11, 0b101, 0O12, 20)
#为实现进制数互相转换，Python中内置了用于转换的函数：
y = 0b10001
print(bin(y),oct(y),int(y),hex(y))

#运行结果
10
<class 'int'>
17 5 10 20
0b10001 0o21 17 0x11
```

#### 浮点类型

在python中小数都属于浮点型(float）,有两种表现形式

```python
# 小数点形式（常用），较小的小数表示
f =  3.14
num1 = 3.1415926 + 3.1415926
x = 1
y = "Corazon"
f1 =  -3.14E2  # 指数形式： aEn 或 aen，较大的小数表示
f2 =  3.14e-2  # 指数形式： aEn 或 aen，较大的小数表示
print("f:",type(f))
print(num1)
print(3.1415926+3.1415926)
print("x:",type(x), "y:",type(y))
print("f1:",type(f1),"f2:",type(f2))

# 执行结果
f: <class 'float'>
6.2831852
6.2831852
x: <class 'int'> y: <class 'str'>
f1: <class 'float'> f2: <class 'float'>
```

#### 布尔类型

布尔型（Bool）是一种特殊数据类型，常用于判断，这种类型只有两种值，即"真"与"假"。

```python
print(4 == 2,5 > 1)
# 也可以做字符判断   --判断大小 依据ascii编码
name = "zhangsan"
print(name == "lisi")

# 打印结果
False True
False
```



```python
# 不光上面代码语句的结果是布尔值，单独一个数据没有进行计算也可以都有自己的布尔值，这就涉及到布尔的零值。
# 任意数据类型都有一个具体值的布尔值为False,我们称为零值。该类型的其他值的布尔值皆为True。
print(bool("Cozrzon"),bool(0)) # 字符串的零值True False
print(bool(24),bool(0))        # 整型的零值  True False
```

#### 数据类型间相互转换方法

python内置了进行转换数据类型的函数，常见有int()、float()，示例如下：

```python
# int() 转成整型
# float() 转成小数
x = 3
y = 3.14
#注意：浮点型转换为整数型时直接舍去小数部分（向下取整）
print(x, type(x), y, type(y))
print(float(x), type(float(x)), int(y), type(int(y)))

# 运行结果
3 <class 'int'> 3.14 <class 'float'>
3.0 <class 'float'> 3 <class 'int'>
```

### 数据类型值字符类型介绍

#### 字符串格式

单行字符串：

```python
# 用双引号，直接输出字符串
print("hi,Corazon")

# 以变量的形式输出字符串，采用单引号定义
s1 = 'hi,Corazon'
print(s1)
```
多行字符串也叫文本字符串，就是三个单引号或者三个双引号圈住的内容，实际上也是字符串；
```python
s = """
s1 = "hi,boy\nhi,girl"
s2 = 'I\'m Corazon'
s3 = "D:\\中科人才\\python.exe"
s4 = "我是中科人才，\
我喜欢python"
长字符串中放置单引号或者双引号不会导致解析错误
"""
print(s)

# 打印结果
s1 = "hi,boy
hi,girl"
s2 = 'I'm Corazon'
s3 = "D:\中科人才\python.exe"
s4 = "我是中科人才，我喜欢python"
长字符串中放置单引号或者双引号不会导致解析错误
```

#### 字符串信息转义设置

有些特殊字符信息前面加\ 转义字符会有特殊的含义作用：

| 转义字符  | 说明                                        | 转义字符 | 说明                                    |
| --------- | ------------------------------------------- | -------- | --------------------------------------- |
| \n        | 换行符，将光标位置移到下一行开头            | \r       | 回车符，将光标位置移到本行开头          |
| \t        | 水平制表符，也即 Tab 键，一般相当于四个空格 | \b       | 退格（Backspace），将光标位置移到前一列 |
| \任意字符 | 转义，例如`'`，`"`,` \`等                   | 行尾\    | 不换行，多行编辑一行输出                |
|           |                                             |          |                                         |

{% spoiler 代码操作示例 %}

```python
# 01 索引取值
s = "hello，Corazon"
print(s[1])  # 索引从前到后，从0开始，1对应的字符为e
print(s[-3])  # 索引从后到前，从-1开始，-3为倒数第三个字符，对应的字符为k
# 02 切片取值：序列类型对象[start : end : step]
print(s[2:5])  # llo     ：取索引1到索引3（左闭右开） == [1:3)
print(s[:5])  # hello   ：start缺省，默认从0取
print(s[6:])  # Corazon ：end缺省，默认取到最后
# 03 判断存在：使用in关键字检查某元素是否为序列的成员。
s = "hello,Corazon"
print("Corazon" in s)  # True
print("Leonidas" in s)  # False
# 04 +/*运算：支持使用“+”运算符做相加操作，它会将两个序列进行连接，但不会去除重复的元素。
#            使用数字 n 乘以一个序列会生成新的序列，其内容为原来序列被重复 n 次的结果。
s = "hello" + "Corazon"
print(s)  # 输出helloCorazon
s = "hello" + ",Corazon!!!"
print(s * 2)
print("*" * 30)  # 输出30个*

# 打印结果
e
z
llo
hello
Corazon
True
False
helloCorazon
hello,Corazon!!!hello,Corazon!!!
******************************
```

{% endspoiler %}



#### 字符串内置方法

在对字符串进行操作时，还会存在一些内置的方法函数，完成对字符串信息的特殊需求处理：

| **方法**        | **作用**                         | **示例**                                                     | **输出**              |
| --------------- | -------------------------------- | ------------------------------------------------------------ | --------------------- |
| `upper`         | 大写                             | `"hello".upper()`                                            | `"HELLO"`             |
| `lower`         | 小写                             | `"Hello".lower()`                                            | `"hello"`             |
| `startswith()`  | 是否以a开头                      | `"Corazon".startswith("a")`                                  | `True`                |
| `endswith()`    | 是否以a结尾                      | `"Corazon".endswith("a")`                                    | `False`               |
| **`isdigit()`** | 是否全数字                       | `'123'.isdigit()`                                            | `True`                |
| `isalpha()`     | 是否全字母                       | `'Corazon123'.isalpha()`                                     | `False`               |
| `isalnum()`     | 是否全为字母或数字               | `'Corazon123'.isalnum()`                                     | `True`                |
| `strip()`       | 去两边空格                       | `" hi Corazon \n".strip()`                                   | `"hi Corazon"`        |
| **`join()`**    | 多字符串连接                     | `"-".join(["Corazon","eric"])`                               | `"Corazon-eric"`      |
| **`split()`**   | 分割字符串，默认空格             | `"Corazon-eric".split("-")`                                  | `['Corazon', 'eric']` |
| **`find()`**    | 返回指定字符串索引，没有返回-1   | `"world".find("w")`                                          | 0                     |
| **`index()`**   | 返回指定字符串索引，找不到会报错 | `"world".index("w")`                                         | 0                     |
| **`count()`**   | 统计指定字符串出现次数           | `"world".count("l")`                                         | 1                     |
| **`len(s)`**    | 返回字符串长度                   | `len("Hello,Corazon!!!"))`                                   | 16                    |
| **`replace()`** | 替换old为new                     | `'oldold'.replace('old','new',1)`<br/>'oldold'.replace('old','new') | `newold`<br/>`newnew` |
| `format()`      | 格式化方法                       |                                                              |                       |

<font class=notice>注意：index()和find()方法只能匹配首个指定字符的索引</font>

### **复合数据类型**

#### **元组数据类型**

**元组数据类型定义：**

元组的元素只能读，不能进行修改（下标不能改 元素不能改 长度不能增加 但整体可以改），通常情况下，元组用于保存无需修改的内容；元组使用小括号表示声明（定义）一个元素数据类型：

```python
(element1, element2, element3, ..., elementn)
```

<font class=notice>注意：当创建的元组中只有一个字符串类型的元素时，该元素后面必须要加一个逗号，否则python解释器会将它视为字符串 </font>

{% spoiler 代码操作示例 %}

```python
l = (1,2,3)
print(l,type(l)) # (1, 2, 3) <class 'tuple'>

pen = ("pear1", "pear2", "pear3")  # 小括号
# 打印元组所有元素
print(pen)
```

{% endspoiler %}

**02** **元组数据序列操作：**

元组数据信息调取和列表操作基本一致，支持索引和切片操作。

{% spoiler 代码操作示例 %}

```python
l = ("element1", "element2", "element3", "element4", "element5", "element6")
print(l[2])  # 3

# 切片操作
print(l[2:4])  # (3, 4)  也是前闭后开 [2:4)
print(l[:4])  # (1, 2, 3, 4)
print("element2" in l)  # True

# 列表信息循环遍历：
pen = ("pear1", "pear2", "pear3")
for item in pen:
    print(item,end=" ")
print("\n--------分隔符-------")
#整体可以改
pen = ("pear1", "pear2", "pear3","pear4")
for item in pen:
    if item.find("4") >= 0:  # 字符串查找用法  find 返回字符串位置
        print(item + "这是第4个梨")  # 字符串相连用法
    else:
        print(item)
print("---------------")

# 运行结果
element3
('element3', 'element4')
('element1', 'element2', 'element3', 'element4')
True
pear1 pear2 pear3 
--------分隔符-------
pear1
pear2
pear3
pear4这是第4个梨
---------------
```

{% endspoiler %}

#### **列表数据类型**

列表会将所有元素都放在一对中括号[]里面，相邻元素之间用逗号分隔，具体表现形式：

```python
[element1, element2, element3, ..., elementn]
```

<font class=notice>注意：不同于C，java等语言中的数组，python的列表可以存放不同的任意数据类型对象。 </font>

```python
l = [123,"zkrc",True]
print(l,type(l),len(l))
for item in l:
    print(item,type(item))
# 执行结果
[123, 'zkrc', True] <class 'list'> 3
123 <class 'int'>
zkrc <class 'str'>
True <class 'bool'>
```

```python
# 列表方式赋值变量 --列表值与变量数量要一一对应
a,b = [1,2]
print(a,b)
a,b = [input("请输入第一个字符: "),input("请输入第二个字符: ")]
print(a,b)
```

**列表数据信息调取**

我们可以使用索引（index）访问列表中的某个元素，也可以使用切片操作访问列表中的一组元素值信息，从而得到的是一个新的子列表。

```python
索引求值
l = [10,11,12,13,14]
print(l[2])  # 12
print(l[-1]) # 14
 
切片操作
l = [10,11,12,13,14]
print(l[2:5])       #[12, 13, 14]
print(l[-3:-1])     #[12, 13]
```

**列表内置方法**

| **方法**      | **作用**               | **示例**            | **结果**                  |
| ------------- | ---------------------- | ------------------- | ------------------------- |
| `append()`    | 向列表追加元素         | `l.append(4)`       | `l``：[1, 2, 3, 4]`       |
| `insert()`    | 向列表任意位置添加元素 | `l.insert(0,100)`   | `l``：[100, 1, 2, 3]`     |
| `extend(``）` | 向列表合并一个列表     | `l.extend([4,5,6])` | `l``：[1, 2, 3, 4, 5, 6]` |
| `pop()`       | 根据索引删除列表元素   | `l.pop(1)`          | `l``：[1, 3]`             |
| `remove()`    | 根据元素值删除列表元素 | `l.remove(1)`       | `l``：[2, 3]`             |
| `clear()`     | 清空列表元素           | `l.clear()`         | `l``：[]`                 |
| `sort()`      | 排序（升序）           | `l.sort()`          | `l``：[1,2,3]`            |
| `reverse()`   | 翻转列表               | `l.reverse()`       | `l``：[3,2,1]`            |
| `count()`     | 元素重复的次数2是元素  | `l.count(2)`        | `返回值：1`               |
| `index()`     | 查找元素对应索引       | `l.index(2)`        | `返回值：1`               |

{% spoiler 代码操作示例 %}

```python
# 01 列表元素增加操作：append insert extend
l1 = [1, 2, 3]

# append()：追加一个元素
l1.append(4)
print(l1)           # [1, 2, 3, 4]

# insert(): 插入，即在任意位置添加元素
l1.insert(1, 100)   # 在索引1的位置添加元素100
print(l1)           # [1, 100, 2, 3, 4]

# extend()：扩展一个列表
l2 = [20, 21, 22, 23]
# l1.append(l2)
l1.extend(l2)
print(l1)           #[1, 100, 2, 3, 4, 20, 21, 22, 23]


# 02 列表元素删除操作：pop，remove，clear
l4 = [10, 20, 30, 40, 50]

# 按索引删除:pop,返回删除的元素
ret = l4.pop(3)
print(ret)
print(l4)            # [10, 20, 30, 50]

# 按着元素值删除
l4.remove(30)
print(l4)            # [10, 20, 50]

# 清空列表
l4.clear()
print(l4)            # []


# 03 列表元素修改操作：
l5 = [10, 20, 30, 40, 50]

#  将索引为1的值改为200
l5[1] = 200
print(l5)             # [10, 200, 30, 40, 50]

# 将l5中的40改为400 , step1：查询40的索引 step2：将索引为i的值改为400
i = l5.index(40) #  3
l5[i] = 400
print(l5)             # [10, 20, 30, 400, 50]

# 04 列表元素查询操作：index，sort
l5.reverse()          # 只是翻转 [50, 400, 30, 200, 10]
print(l5) # []

# 查询某个元素的索引，比如30的索引
print(l5.index(30))   # 2

# 排序
l5.sort(reverse=True)
print(l5)             # [400, 200, 50, 30, 10]
```

{% endspoiler %}

#### **字典数据类型**

字典是python提供的唯一内键的映射（mapping type）数据类型，python使用{ }创建字典。

由于字典中每个元素都包含键（key）和值（value）两部分，因此在创建字典时，键和值之间使用英文冒号`:`分隔。相邻元素之间使用英文逗号,分隔，所有元素放在大括号 `{ }` 中，字典的元素也叫成员，是一个键值对。

```python
dictname = {'key1':'value1', 'key2':'value2', ...}
```

同一字典中的各个键必须唯一，不能重复。

字典的键值对原本是无序的，但是在python3.6版本之后，字典默认做成有序的了。

{% spoiler 代码操作示例 %}

```python
d = {"01": "zhangsan", "02": "lisi", "03": "wangwu"}
print(d, type(d))

# 01 查键值
print(d["01"],d["02"])

# 02 添加或修改键值对
# 注意：如果键存在，则是修改，否则是添加
d["01"] = "xiaoX"  # 修改键的值
d["04"] = "zhaoliu"  # 添加键值对
print(d)

# 03 删除键值对
print(d)
del d["01"]  # 删除字典指定成员信息 delete
print(d)
del d  # 删除字典

# 字典成员过滤筛选：
d = {"01": "zhangsan", "02": "lisi", "03": "wangwu"}
print("01" in d)

# 字典数据信息遍历：
d = {"01": "zhangsan", "02": "lisi", "03": "wangwu"}
for key in d:
    print(key, d[key],"||",end=" ")
# 执行结果
{'01': 'zhangsan', '02': 'lisi', '03': 'wangwu'} <class 'dict'>
zhangsan lisi
{'01': 'xiaoX', '02': 'lisi', '03': 'wangwu', '04': 'zhaoliu'}
{'01': 'xiaoX', '02': 'lisi', '03': 'wangwu', '04': 'zhaoliu'}
{'02': 'lisi', '03': 'wangwu', '04': 'zhaoliu'}
True
01 zhangsan || 02 lisi || 03 wangwu || 
```

{% endspoiler %}

**字典内置的方法**

| **方法**       | **作用**                                                 | **示例**                 | **结果**                           |
| -------------- | -------------------------------------------------------- | ------------------------ | ---------------------------------- |
| `get()`        | 查询字典键值，取不到返回默认值                           | `d.get("name",None)`     | `"zkrc"`                           |
| `setdefault()` | 查询字典某键的值，取不到给字典设置键值，同时返回设置的值 | `d.setdefault("age",20)` | `18`                               |
| `keys()`       | 查询字典中所有的键                                       | `d.keys()`               | `['name','age']`                   |
| `values()`     | 查询字典中所有的值                                       | `d.values()`             | `['zkrc', 18]`                     |
| `items()`      | 查询字典中所有的键和值                                   | `d.items()`              | `[('name','zkrc'),`` ('age', 18)]` |
| `pop()`        | 删除字典**指定**的键值对                                 | `d.pop(`“age”`)`         | `{'name':'zkrc'}`                  |
| `popitem()`    | 删除字典**最后**的键值对                                 | `d.popitem()`            | `{'name':'zkrc'}`                  |
| `clear()`      | **清空**字典                                             | `d.clear()`              | `{}`                               |
| `update()`     | 更新字典                                                 |                          |                                    |

{% spoiler 代码操作示例 %}

```python
dic = {"name": "zkrc", "age": 22, "sex": "male"}

# 01. 查字典的键的值
name = dic.get("name")
sex = dic.get("sex", "female")
print(name)
print(sex)
print(dic.keys())     # 返回值：['name', 'age', 'sex']
print(dic.values())   # 返回值：['zkrc', 22, 'male']
print(dic.items())    # [('name', 'zkrc'), ('age', 22), ('sex', 'male')]

# setdefault取某键的值，如果能取到，则返回该键的值，如果没有该键，则会设置键值对
print(dic.setdefault("name"))
print(dic.setdefault("height", "180cm"))  # get()不会添加键值对 ，setdefault会添加
print(dic)            # {'name': 'zkrc', 'age': 22, 'sex': 'male', 'height': '180cm'}

# 02. 删除键值对 pop popitem
sex = dic.pop("sex")  # male
print(sex)            # male
print(dic)            # {'name': 'zkrc', 'age': 22}

dic.popitem()  # 删除最后一个键值对
print(dic)            # {'name': 'zkrc'}

dic.clear()           # 清空键值对

# 03. 添加或修改 update
add_dic = {"height": "180cm", "weight": "60kg"}
dic.update(add_dic)
print(dic)            # {'name': 'zkrc', 'age': 22, 'sex': 'male', 'height': '180cm', 'weight': '60kg'}

update_dic = {"age": 33, "height": "180cm", "weight": "60kg"}
dic.update(update_dic)
print(dic)            # {'name': 'zkrc', 'age': 33, 'sex': 'male', 'height': '180cm', 'weight': '60kg'}

# 04. 字典的循环
dic = {"name": "zkrc", "age": 22, "sex": "male"}
# 遍历键值对方式1
for key in dic:       # 将每个键分别赋值给key
     print(key, dic.get(key))

# 遍历键值对儿方式2
for i in dic.items(): # [('name', 'zkrc'), ('age', 22), ('sex', 'male')]
     print(i[0],i[1])
```

{% endspoiler %}

#### **集合数据类型**

Python 中的集合，和数学中的集合概念一样，由不同可hash的不重复的元素组成的集合。

Python 集合会将所有元素放在一对大括号 {} 中，相邻元素之间用“,”分隔。

同一集合中，只能存储不可变的数据类型，包括整形、浮点型、字符串、元组，无法存储列表、字典、集合这些可变的数据类型，否则 Python 解释器会抛出 TypeError错误。

```python
{element1,element2,...}
```

说明：由于集合中的元素是无序的，因此无法向列表那样使用下标访问元素，访问集合元素最常用的方法是使用循环结构；

**集合内置方法**

| **方法**                 | **作用**               | **示例**                                | **结果**            |
| ------------------------ | ---------------------- | --------------------------------------- | ------------------- |
| `add()`                  | 向集合添加元素         | `a.add(4)`                              | `{1, 2, 3, 4}`      |
| `update()`               | 向集合更新一个集合     | `a.update({3,4,5}) `                    | `{1, 3, 4, 5}`      |
| `remove()`               | 删除集合中的元素       | `a.remove(2)`                           | `{1, 3}`            |
| `discard()`              | 删除集合中的元素       | `a.discard(2)`                          | `{1, 3}`            |
| `pop()`                  | 删除集合第一个元素     | `a.pop()`                               | `{2,3}`             |
| `clear()`                | 清空集合               | `a.clear()`                             | `{}`                |
| `intersection()`         | 返回两个集合的交集     | `a.intersection(b)`                     | `{3}`               |
| `difference()`           | 返回两个集合的差集     | `a.difference(b)`<br/>`b.difference(a)` | `{1,2}`<br/>`{4,5}` |
| `symmetric_difference()` | 返回两个集合的对称差集 | `a.symmetric_difference(b)`             | `{1, 2, 4, 5}`      |
| `union()`                | 返回两个集合的并集     | `a.union(b)`                            | `{1, 2, 3, 4, 5}`   |

## 运算符号介绍

### 数运算符说明

| **运算符** | **说明**                     | **实例** | **结果** |
| ---------- | ---------------------------- | -------- | -------- |
| +          | 加                           | 1+1      | 2        |
| -          | 减                           | 1-1      | 0        |
| *          | 乘                           | 1*3      | 3        |
| /          | 除法                         | 4/2      | 2        |
| //         | 整除                         | 7 // 2   | 3        |
| %          | 取余，求模，即返回除法的余数 | 7 % 2    | 1        |
| **         | 幂运算/次方运算              | 2 ** 4   | 16       |
| \|         | 或                           | 5\|3     | 7        |
| &          | 与                           | 5&3      | 1        |
| ^          | 异或                         | 5^3      | 6        |

<font class=notice>Tips：事实上，a | b=(1 & b)+(a ^ b)</font>

### 位运算符说明

| **运算符** | **说 明**    | **用法举例** | **等价形式**              |
| ---------- | ------------ | ------------ | ------------------------- |
| =          | 赋值         | x = y        | x = y                     |
| +=         | 加赋值       | x += y       | x = x + y                 |
| -=         | 减赋值       | x -= y       | x = x - y                 |
| *=         | 乘赋值       | x *= y       | x = x * y                 |
| /=         | 除赋值       | x /= y       | x = x / y                 |
| %=         | 取余数赋值   | x %= y       | x = x % y                 |
| **=        | 幂赋值       | x **= y      | x = x ** y                |
| //=        | 取整数赋值   | x //= y      | x = x // y                |
| &=         | 按位与赋值   | x &= y       | x = x & y                 |
| \|=        | 按位或赋值   | x \|= y      | x = x \| y                |
| ^=         | 按位异或赋值 | x ^= y       | x = x ^ y                 |
| <<=        | 左移赋值     | x «= y       | x = x << y， y 指左移位数 |
| >>=        | 右移赋值     | x »= y       | x = x >> y， y 指右移位数 |

### 比较运算符说明

| **比较运算符** | **说明**                           |
| -------------- | ---------------------------------- |
| >              | 大于                               |
| <              | 小于                               |
| ==             | 等于                               |
| >=             | 大于等于（等价于数学中的 ≥）       |
| <=             | 小于等于（等价于数学中的 ≤）       |
| !=             | 不等于（等价于数学中的 ≠）         |
| is             | 判断两个变量所引用的对象是否相同   |
| is not         | 判断两个变量所引用的对象是否不相同 |

### 逻辑运算符说明

| **逻辑运算符** | **含义** | **基本格式** | **说明**                   |
| -------------- | -------- | ------------ | -------------------------- |
| and            | 与运算   | x and y      | 当x和y都为真时结果才为真。 |
| or             | 或运算   | x or y       | 当x和y都为假时结果才是假。 |
| not            | 非运算   | not y        | 对x的结果取相反的结果。    |

### 成员运算符说明

in和not in用于测试给定数据是否存在于序列（如列表、字符串）中：

in作用是，如果指定字符在字符串中，则返回True，否则返回False。not in的作用刚好相反。

编写运算符应用示例代码：

```python
x="zkrc"
y="b"
print(y in x)
print(y not in x)
# 运行结果
False
True
```

## 输入输出应用

### 输入输出函数说明

#### print()函数

print()函数用于打印内容或变量等输出，是python中最最用的函数。

函数语法格式：


```python
print(value1, ..., sep=' ', end='\n', file=sys.stdout,flush=False)
```

函数参数信息：

| **序号** | **函数参数** | **解释说明**                               |
| -------- | ------------ | ------------------------------------------ |
| 01       | value        | 打印的对象，之间用逗号分隔                 |
| 02       | sep          | 打印的两个值之间的分隔符，默认是空格       |
| 03       | end          | 打印输出以什么结尾，默认是换行符\n         |
| 04       | file         | 输出的文件对象，默认是sys.stdout，标准输出 |
| 05       | flush        | 表示要强制冲洗流（忽略）                   |

print() 函数使用以%开头的转换说明符对各种类型的数据进行格式化输出，具体请看下表：

| 符号       | 类型         | 示例                               |
| ---------- | ------------ | ---------------------------------- |
| `%s`       | 字符串       | `"Hello %s" % "World"`             |
| `%d`       | 整数         | `"Age: %d" % 25`                   |
| `%f`、`%F` | 浮点数       | `"Price: %.2f" % 99.876` → `99.88` |
| `%x`       | 十六进制整数 | `"Hex: %x" % 255` → `ff`           |
| `%%`       | 百分号本身   | `"Discount: 10%%"`                 |

代码操作示例：

```python
name = "Corazon"
sex = "Male"
age = 24
print(name, sex, sep=":", end=" ")
print(age)  # Corazon:Male 24  与上行合并为同一行
print("你的名字是:", name, "你的性别：", sex, "你的年龄", age)  # 你的名字是: Corazon 你的性别： Male 你的年龄 24
# 解决空格问题
print("你的名字是:", name, " 你的性别：", sex, " 你的年龄", age, sep='')  # 你的名字是:Corazon 你的性别：Male 你的年龄24
# 同时输出字符串和变量，用+拼接
info = "你的名字是:" + name
print(info)  # 你的名字是:Corazon

##Print格式化输出
# 方法1：{0}、{1}、{2}分别表示j,i,j+i，单引号里面是输出格式。
print("你的名字是{0},你的性别:{1},你的年龄:{2}".format(name, sex, age))  # 你的名字是Corazon,你的性别:Male,你的年龄:24
# 方法2：类似于C语言格式输出，使用%开头格式输出
print("你的名字是%s,你的性别:%s,你的年龄:%s" % (name, sex, age))  # 你的名字是Corazon,你的性别:Male,你的年龄:24
```

#### input()函数

input函数是用来接收用户输入的数据，会返回一个字符串类型的数据。如果想要得到其他类型的数据进行强制类型转化。代码操作示例：

```python
# 允许用户在终端下输入自己的账号和密码
name = input("请输入您的姓名：")
year = int(input("请输入您的出生年："))
month = int(input("请输入您的出生月："))
day = int(input("请输入您的出生日："))
# 前面双引号内容是格式化字符串，%s就是占位符，占据一个位置，类似教室占座。
# 占位符%s最终会被后面的变量的值所替代。
# 中间的`%`是一个分隔符。
# 多个变量表达式必须使用小括号扩起来。
# %02d 以整数输出，如果不足2位整数的，左边加0补充进去
print("您好%s，您的出生日期为：%d-%02d-%02d" % (name,year, month, day))
# 执行结果
请输入您的姓名：Corazon
请输入您的出生年：2000
请输入您的出生月：6
请输入您的出生日：8
您好Corazon，您的出生日期为：2000-06-08
```

### 格式化输出

话不多说

#### `%` 格式化（传统方法）

```python
name = "Alice"
age = 30
print("Name: %s, Age: %d" % (name, age))  # Name: Alice, Age: 30
```

**高级控制：**

```python
# 宽度与对齐
print("[%10s]" % "left")    # 右对齐：[      left]
print("[%-10s]" % "right")  # 左对齐：[right     ]

# 浮点数精度
print("π: %.03f" % 3.14159)  # π: 3.142
print("a: %010.03f" % 1.23456)  # a: 000001.235
print("a: %.010f" % 1.23456)  # a: 1.2345600000
```

------

#### **`str.format()` 方法**

Python 2.6+版本支持str.format()` 方法：

```python
print("Name: {0}, Age: {1}".format("Bob", 40))
print("Name: {name}, Age: {age}".format(name="Bob", age=40))
num=input("你还有{0}次机会，\n请输入一个1到20的整数：".format(5-count))
```

**核心功能：**

- **位置参数**
  `"{0} + {1} = {2}".format(1, 2, 3)` → `1 + 2 = 3`
- **关键字参数**
  `"User: {username}".format(username="admin")`
- **混合使用**
  `"{0} {last}".format("John", last="Doe")`

#### **格式化规范（`:` 后定义格式）：**

```python
# 数字格式化
print("π: {:.3f}".format(3.14159))      # π: 3.142
print("Hex: {:x}".format(255))          # ff

# 文本对齐
print("[{:>10}]".format("right"))       # [     right]
print("[{:^10}]".format("center"))      # [  center  ]

# 符号显示
print("Balance: {:+d}".format(100))     # +100

# 千位分隔符
print("{:,}".format(1000000))           # 1,000,000

# 百分比
print("Ratio: {:.2%}".format(0.25))     # 25.00%
```

------

#### **`f-strings`**

Python 3.6+，推荐。在渗透测试Python脚本中经常使用`f-strings`方式构建PayLoad

```python
name = "Corazon"
age = 35
print(f"Name: {name}, Age: {age}")  # Name: Corazon, Age: 35
```

 **高级特性：**

```python
# 表达式计算
print(f"Sum: {5 + 3}")                # Sum: 8

# 函数调用
print(f"Uppercase: {'hello'.upper()}")  # Uppercase: HELLO

# 格式控制
pi = 3.14159
print(f"π: {pi:.3f}")                 # π: 3.142 与%格式一样
print(f"Hex: {255:x}, int: {0b11111111:d}, Oct: {255:o}, Bin: {255:b}") # Hex: ff, int: 255, Oct: 377, Bin: 11111111

# 对齐与填充（字符串后接':'）
print(f"[{'left':<10}]")              # [left      ]
print(f"[{'right':>10}]")             # [     right]
print(f"[{'center':^10}]")            # [  center  ]
print(f"[{'pad':*>10}]")              # [*******pad]
# 构建cookie SQL注入字典，爆破某一用户密码（部分）：
cookies = {'TrackingId': f"{Tracking_id}' and ascii(substr((select password from {tablename} where username='{username}'),{password_index},1)) > {ascii_mid}--+;"}

# 日期格式化
from datetime import datetime
now = datetime.now()
print(now)                            # 2025-07-16 14:16:57.921635
print(f"Now: {now:%Y-%m-%d}")         # Now: 2025-07-16

# 原始字符串（避免转义）
name = "Corazon"
print(fr"Raw: \n {name}")             # Raw: \n Corazon
print(f"Raw: \\n {name}")             # Raw: \n Corazon
```

------

#### **模板字符串（`string.Template`）**

`string.Template` 是 Python 标准库中提供的一种安全、简单的字符串替换机制，特别适合处理用户提供的模板或需要防止注入攻击的场景。

**基本用法：**

```python
from string import Template

#01 创建模板对象
t = Template("Hello, $name! Today is $day.")

# 使用 substitute() 方法进行安全替换：
result = t.substitute(name="Alice", day="Monday")
print(result)                   # 输出: Hello, Alice! Today is Monday.

# 使用 safe_substitute() 方法，当缺少变量时不会报错：
result = t.safe_substitute(name="Bob")
print(result)                   # 输出: Hello, Bob! Today is $day.


#02 变量表示形式
from string import Template

# 简单变量 ($var)
t = Template("Welcome, $user!")
print(t.substitute(user="Admin"))  # Welcome, Admin!

# 包裹变量 (${var})
# 当变量名后需要紧跟字母、数字或下划线时使用,避免歧义：
t = Template("Total: ${amount}USD")
print(t.substitute(amount=100))    # Total: 100USD


#03 使用字典进行替换
data = {"name": "Corazon", "item": "book", "price": 29.99}
t = Template("$name bought a $item for $$$price")
print(t.substitute(data))  # Corazon bought a book for $29.99


#04 特殊字符处理
# 转义 `$` 符号，使用两个 `$` 表示字面值的美元符号：
t = Template("Cost: $$ $amount")
print(t.substitute(amount=50))  # Cost: $ 50

# 处理包含 `$` 的值
t = Template("Value: $val")
print(t.substitute(val="$100"))  # Value: $100
```

##### 高级用法

```python
# 2.自定义分隔符（继承 Template）
class MyTemplate(Template):
    delimiter = '#'  # 将分隔符改为 #
    idpattern = r'[a-z]+'  # 只允许小写字母变量名
t = MyTemplate("Hello, #name! Your code is #code")  
print(t.substitute(name="Corazon", code="XYZ123"))  # Hello, Corazon! Your code is XYZ123

# 3.处理无效标识符
class SafeTemplate(Template):
    idpattern = r'[_a-z][_a-z0-9]*'  # 标准标识符规则
t = SafeTemplate("$user_name: $score")
print(t.substitute(user_name="Eve", score=95))  # Eve: 95
```

##### 安全特性

`string.Template` 的主要安全优势：

1. **不执行表达式**：不会像 f-strings 那样执行任意代码
2. **无格式化功能**：不能访问对象属性或执行方法
3. **简单替换**：只进行直接的字符串替换

```python
# 安全示例 - 防止注入攻击
user_input = "${os.system('rm -rf /')}"  # 恶意输入
t = Template("User data: $data")
print(t.safe_substitute(data=user_input))  # 安全输出: User data: ${os.system('rm -rf /')}
```

##### 实际应用场景

1. 邮件模板

```python
email_template = Template("""
Dear $name,

Your order #$order_id has been shipped.
Tracking number: $tracking_num

Regards,
$company
""")

data = {
    "name": "Alice",
    "order_id": "12345",
    "tracking_num": "ZYX987",
    "company": "ACME Corp"
}

print(email_template.substitute(data))
```

**2. 配置文件模板**


```
config_template = Template("""
[DATABASE]
host = $db_host
port = $db_port
user = $db_user
password = $db_pass
""")

db_config = {
    "db_host": "localhost",
    "db_port": 5432,
    "db_user": "admin",
    "db_pass": "secure123"
}

print(config_template.substitute(db_config))
```

**3. 多语言支持**

```
templates = {
    "en": Template("Hello, $name!"),
    "es": Template("¡Hola, $name!"),
    "fr": Template("Bonjour, $name!")
}

def greet(name, lang="en"):
    return templates[lang].substitute(name=name)

print(greet("Pierre", "fr"))  # Bonjour, Pierre!
```



------

#### **其他方法**

 **(1) 字符串拼接**

```python
print("Name: " + name + ", Age: " + str(age))
```

 **(2) `str.join()` 处理列表**

```python
words = ["Python", "is", "powerful"]
print(" ".join(words))  # Python is powerful
```

------

#### **总结对比**

| **方法**          | **易读性** | **灵活性** | **安全性** | **版本要求**    |
| ----------------- | ---------- | ---------- | ---------- | --------------- |
| `%` 格式化        | 低         | 中         | 低         | 所有版本        |
| `str.format()`    | 高         | 高         | 中         | Python 2.6+     |
| **f-strings**     | **极高**   | **极高**   | 中         | **Python 3.6+** |
| `string.Template` | 中         | 低         | **高**     | 所有版本        |

## **流程控制语句**

**python流程控制语句介绍**

软件程序是由语句构成，而流程控制语句是用来控制程序中每条语句执行顺序的语句；可以通过控制语句实现更丰富的逻辑以及更强大的功能；几乎所有编程语言都有流程控制语句，功能也都基本相似，其流程控制方式有：

- 顺序结构

- 分支结构

- 循环结构


最简单最常用的就是顺序结构，即语句从上至下逐一执行：

```python
print("I am zkrc.")
print("I like python.") # 从上到下依次执行
```

### 流程控制分支语句

```python
# 单分支语句语法结构：
if 表达式:
    代码块 

# 双分支语句语法结构：
if 表达式:
    代码块1
else:
    代码块2

# if 表达式1:
    代码块1
elif 表达式2:
    代码块2
...更多elif语句
else：
    代码块 n
```

双分支语句中的pass用法：

- 空语句，不做任何事务处理，一般用作占位

- 保证格式完整

- 保证语义完整


**一些高阶用法：**

```python
#01 打印num1和num2中较大的数
num1, num2 = 1, 2
print(num1 if num1 > num2 else num2)  # 2
```

### **流程控制循环语句**

Python语言中的循环语句支持 while循环（条件循环）和for循环（遍历循环）

#### **流程控制循环语句-while**

循环语句语法格式：

```python
while 表达式:
    循环体
```

{% spoiler 循环语句应用示例 %}

```python
# 无限循环
while True:
    print("ok")

# 无限循环打印,间隔0.5秒。
import time
while True:
    print("boss")
    time.sleep(0.5)
    
# 有限循环：从数字1打印输出到10
count = 1          
while count <= 10: 
    print(count)
    count+=1
print("end")
```

{% endspoiler %}

#### **流程控制循环语句-for**

循环语句语法格式：

```python
for 迭代变量 in 字符串|列表|元组|字典|集合：
    代码块
```

{% spoiler 循环语句应用示例 %}

```python
for i in "zkrc":
    print(i)
    
for item in ["张三",'李四',"王五"]:
    print(item)
    
#  range函数： range(start,end,step)     
for i in range(5):  # range(5)结果为[0,1,2,3,4]
    print(i)

# 偶数
for i in range(2,11,2):
print(i)
结果:  前闭后开 不包含11
2
4
6
8
10
```

{% endspoiler %}

#### **流程控制循环嵌套**

```python
#01 独立嵌套
for i in range(5):  #5次
    for j in range(5):  #5次
        print("  *",end="")
    print("")
#02 关联嵌套
for i in range(1,5):  #控制行数
    for j in range(i):  #控制每行个数
        print(" *",end="")
    print("") 
```

#### **循环控制语句说明**

如果在某一时刻（在不满足结束条件的情况下）想提前结束循环，可以使用break或continue关键字；

**循环控制语句-break**

当break关键字用于for循环时，会终止循环而执行整个循环语句后面的代码信息；break 退出的是循环 exit() 或者quit() 退出的是脚本

```python
for i in range(1,6):
    if i == 3:
        break
    print(i)
print("end")
```

**循环控制语句-continue**

不同于break退出整个循环，continue指的退出当次循环，但会继续在循环结构中，完成后续的循环操作；

```python
for i in range(1,6):
    if i == 3:
        continue
    print(i)
print("end")
```

{% spoiler 流程循环语句练习 %}

循环控制语句练习-01：猜水果价格小游戏

一个水果摊，老板卖水果，你去猜水果价格，当你说出价格后，老板会告诉你大小；

如果猜高了，就会告诉你猜高了；

如果猜低了，就告诉你你猜低了；

直到猜对为止，并在猜对后，会输出一共猜了几次。

```python
import random
while True:
    rannum = random.randint(1,20)
    print("请出价猜水果价格：答案是1到20之间整数")
    count = 0
    while count <=5:
        num = input("你还有{0}次机会，\n请输入一个1到20的整数: ".format(5-count))
        if num.isdigit():
            num =int(num)
            if num == rannum:
                print("恭喜你，答对了!")
                break
            if num > rannum:
                print("猜的有点大")
            if num < rannum:
                print("猜的有点小")
            count = count +1
        else:
            print("请输入一个整数")
        if count == 5:
            print("给了你",count,"次机会都没答对，正确的答案是：",rannum,sep='')
            break
    print("怎么样，这游戏好玩吧？")
    print("按任意键结束游戏，按空格键继续游戏：")
    select = input("请输入你的选择：")
    if select != " ":
      break
```

{% endspoiler %}

## **编程函数**

函数定义语法格式：

```python
def 函数名(var1,var2...varn):
    操作指令信息
```



本文参考：
