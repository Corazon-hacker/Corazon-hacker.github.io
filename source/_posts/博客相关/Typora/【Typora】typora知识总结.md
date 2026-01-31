---
title: 【Typora】typora知识总结
categories:
  - 博客相关
  - Typora
tags:
  - Typora
description: 使用typora编写hexo博客的方法及markdown语法的介绍。
abbrlink: 287bb156
toc: true
date: 2024-10-27 19:41:13
top:
---

## Markdown语法

### 快捷键汇总

|   功能   |  快捷键   |    功能     |    快捷键     |
| :------: | :-------: | :---------: | :-----------: |
|   加粗   |  Ctrl+B   |  插入图像   | Ctrl+Shift+I  |
|   斜体   |  Ctrl+I   |   删除线    |  Alt+Shift+5  |
|  下划线  |  Ctrl+U   |   公式块    | Ctrl+Shift+M  |
|  超链接  |  Ctrl+K   |   代码块    | Ctrl+Shift+K  |
|   表格   |  Ctrl+T   |   代码段    | Ctrl+Shift+`  |
|   引用   |  >+空格   |  退出引用   |   Shift+Tab   |
|   段落   |  Ctrl+0   |  有序列表   | Ctrl+Shift+[  |
|   标题   | Ctrl+数字 |  无序列表   | Ctrl+Shift+]  |
|   全选   |  Ctrl+A   |  选中行/句  |    Ctrl+L     |
| 选中段落 |  Ctrl+E   | 选中当前词  |    Ctrl+D     |
| 跳转所选 |  Ctrl+J   | 跳转文首/末 | Ctrl+Home/End |
|          |           | 源代码模式  |    Ctrl+/     |

<!--more-->



### 段落



#### 标题

使用 # 可以表示标题，一级标题对应一个 # ，二级标题对应两个 # 号，最多至六级标题。在Typora中，# 后要紧接着一个空格才能表示标题，否则就是普通字符。

```
# h1   //一级标题 对应 <h1> </h1>
## h2   //二级标题 对应 <h2> </h2>
### h3  //三级标题 对应 <h3> </h3>
#### h4  //四级标题 对应 <h4> </h4>
##### h5  //五级标题 对应 <h5> </h5>
###### h6  //六级标题 对应 <h6> </h6>
```



#### 字体

|                       格式                        |    功能    | 快捷键 |       展示       |
| :-----------------------------------------------: | :--------: | :----: | :--------------: |
|           \*这是斜体\*<br>\_这是斜体\_            |  斜体文本  | Ctrl+I |    *这是斜体*    |
|       \*\*这是粗体\*\*<br/>\_\_这是粗体\_\_       |  粗体文本  | Crtl+B |   **这是粗体**   |
| \*\*\*这是粗斜体\*\*\*<br/>\_\_\_这是粗斜体\_\_\_ | 粗斜体文本 |   无   | ***这是粗斜体*** |

在hexo中，为避免字体样式错误，最好不要让修改字体样式的标识符中紧挨别的字符，或者在两端外添加空格。以如下代码进行示范：

```
**你好**。我是全世界最帅的人
**你好。**我是全世界最帅的人
**你好。** 我是全世界最帅的人
```

<font class=notice>注：第二行其实没有空格，因为装了auto_spacing，强制加了空格</font>

**你好**。我是全世界最帅的人

**你好。**我是全世界最帅的人

**你好。** 我是全世界最帅的人

<font size=2>注：在typora中，并不会造成错误</font>



#### 代码

如果是一行代码，可以使用段内代码块来表示，用一对 **&apos;**（数字1旁边的符号）括住代码。比如`printf("Hello World!")`

如果是代码段，那么可以使用**三个 ` 加Enter/空格+编程语言**来表示。如：

```c
# include <stdio.h>
void main(){
	printf("Hello world!\n");
}
```

可以在代码块的右下角选择编程语言。



#### 链接<a id="t1p8"></a>

我们可以使用链接打开网页，也可以打开本地文件和实现页内跳转。链接的几种使用方式如下：

```
1.[链接文字](链接地址)
2.<链接地址>
3.[链接文字][链接ID]
  [链接ID]:http://XXXXXXXX.XXX
4.[链接文字][]
  [链接文字]:http://XXXXXXXX.XXX
```

以下列样例进行演示：

```
1.[百度](https://www.baidu.com/ "百度搜索")   绝对链接
2.<https://www.baidu.com/>
3.[About](/about/ "关于我")   相对链接
4.[打开hello-word文档](../4a17b156 "hello-world")  相对链接打开文章
5.[打开002.png照片](../../images/002.png "002.png")  相对链接打开图片
6.[My Home][ID]
[ID]:https://www.mcorazon.top "我的博客主页"
7.[My Home][]
[My Home]:https://www.mcorazon.top "我的博客主页"
8.[跳转到此小节首](#t1p8）
```

<font size=2>*注：1. 引号部分表示title，可以省略。样式2不可加title<br>2. 不能使用`<  >`跳转本地文件，如\<\.\./\.\./images/002\.png\> ，其并不会表示为可连接状态<br>3.同时，使用第八个样例时需要添加锚点，在1.8的标题后添加了`<a id="t1p8"></a>`*</font>

以上代码的结果如下：

1.[百度](https://www.baidu.com/ "百度搜索") &emsp; &emsp;&emsp;&emsp;绝对链接
2.<https://www.baidu.com/ >
3.[About](/about/ "关于我")   &emsp;&emsp;&emsp;&emsp;相对链接
4.[打开hello-word文档](../4a17b156 "hello-world")  &emsp;&emsp;&emsp;&emsp;相对链接打开文章
5.[打开002.png照片](../../images/002.png "002.png")  &emsp;&emsp;&emsp;&emsp;相对链接打开图片
6.[My Home][ID]&emsp;&emsp;&emsp;&emsp;&emsp;我的博客主页

[ID]:https://www.mcorazon.top "我的博客主页"

7.[My Home][]&emsp;&emsp;&emsp;&emsp;&emsp;我的博客主页

[My Home]:https://www.mcorazon.top "我的博客主页"

8.[跳转到此小节首](#t1p8)



#### 上标下标

上下标可以使用`^X^`，`~X~`来实现。如：

上标：a^X^，下标：a~X~

~~如果作为上标、下标的符号不止一个，则需要用花括号{}将其括起来。如：~~

~~上 标 为 12 ： a 12 , 下 标 为 34 ： a 34 上标为12：a^{12},下标为34：a~{34^2^}~ 上标为12：a^12^,下标为34：a34~~



#### 特殊符号

- （1）对于 Markdown 中的语法符号，前面加反斜线\即可显示符号本身。

- （2）其他特殊字符使用Unicode码表示，示例如下： 

  ![image-20241110173249216](【Hexo】typora知识总结/image-20241110173249216.png)



### 其他

#### 各种线

 你可以在一行中用三个以上的星号(*)、减号(-)、底线(_)来建立一个分隔线，行内不能有其他东西。你也可以在星号或是减号中间插入空格。 

```
---
***
___
```

---
***
___



#### 列表



1. **无序列表**

使用*，+或-标记符号加空格来表示无需列表项，示例如下

```
* 第一项
* 第二项
+ 第一项
+ 第二项
- 第一项
- 第二项
```

* 第一项
* 第二项

+ 第一项
+ 第二项

- 第一项
- 第二项

2. **有序列表**

使用数字加.再加空格来表示有序列表，其中，数字并不重要。示例如下：

```
1. 第一项
3. 第二项
10. 第三项
```

1. 第一项
2. 第二项
3. 第三项

3. **嵌套列表**

首先使用`*`、`+`或`-`进入列表，然后回车换行，会发现系统自动生成列表第二项，此时按下**Tab**键，列表第二项变为第一项的子列表。**按回车退出当前列表**。可以在无序列表中嵌套有序列表。

```
1. 1. 一
   1. 一.一
      1. 一.一.一
      2. 一.一.二
```

1. 一

   1. 一.一
      1. 一.一.一
      2. 一.一.二

   2. 一.二
      1. 一.二.一
      2. 一.二.二

#### 区块



可以使用`>`加空格来表示区块。

当我们想要引用别人的文章内容或者需要对文字进行强调时，可以将其放在区块内。

> 这是区块
>
> 区块也可以嵌套
>
> > ​	这是二级区块
> >
> > > 这是三级区块



#### 图片

**引用图片和链接的唯一区别就是在最前方添加一个感叹号。** 插入图片的语法如下：

```
![alt 属性文本](图片地址)
![alt 属性文本](图片地址 "可选标题")
```

示例如下：

```
1. ![绝对路径引用](/images/002.png "绝对路径引用" =200*200)
2. ![相对路径引用](【Hexo】typora知识总结/001.jpg "相对路径引用1")
3. ![相对路径引用](001.jpg "相对路径引用2")
4. ![网络图片]（https://www.baidu.com/img/PCtm_d9c8750bed0b3c7d089fa7d55720d6cf.png "Baidu")
```

由于使用插件markdown-it-imsize控制了图片大小，此图片在 typora 中无法显示↓

![本地png图片](【Hexo】typora知识总结/002.png "绝对路径引用" =200x200)

![相对路径引用](【Hexo】typora知识总结/001.jpg "相对路径引用1")

由于使用了post_asset_folder，此图片在 typora 中无法显示↓

![相对路径引用](001.jpg "相对路径引用2")

![网络图片](【Hexo】typora知识总结/PCtm_d9c8750bed0b3c7d089fa7d55720d6cf.png "Baidu")

<font class="notice">注：因为我的 typora 使用了图片自动下载功能，会强制改为本地图片，因此此处已经自动下载到了本地，并且依然使用的本地图片。</font>

在实际的使用过程中，虽然第三种方法最为方便，但是由于第三种方法图片不能在 typora 中显示，因此我采用了第二种方法来编写博客。其次由于我使用了 hexo 插件 abbrlink ，需要在主题配置文件中\node_modules\hexo-asset-image\index.js进行更改。



#### 表格

Markdown 制作表格使用 `|` 来分隔不同的单元格，使用 `-` 来分隔表头和其他行。`:-`表示左对齐`-:`表示右对齐`:-:`表示中间对齐。示例如下：

```
|左对齐|右对齐|中间对齐|
|:---|---:|:----:|
|单元格|单元格|单元格|
|单元格|单元格|单元格|
```

| 左对齐 | 右对齐 | 中间对齐 |
| :----- | -----: | :------: |
| 单元格 | 单元格 |  单元格  |
| 单元格 | 单元格 |  单元格  |

在Typora中，我们可以使用快捷键**Ctrl+T**来插入表格，并选择行列，当选中表格某一单元格时，可以在表格左上角手动设置对齐方式，右上角选择更多操作。

![image-20241028100647549](【Hexo】typora知识总结/image-20241028100647549.png)



#### 数学公式



在Typora中，有两种方法插入数学公式，示例如下：

```
第一种方法：$1+2=3$
第二种方法：
$$
1+2=3
$$
```

第一种方法：$1+2=3$

第二种方法：
$$
1+2=3
$$

## 三、Typora与HTML

### 3.1 改变字体颜色及大小

我们可以使用`<font> </font>`标签来改变字体的颜色及大小，如：

~~~
<font size=3 color="red">字体颜色为红色，大小为3</font>

<font size=4 color="blue">字体颜色为蓝色，大小为4</font>

<font size=6 color="#ffffff">字体颜色为紫罗兰，大小为6</font>

~~~

<font size=3 color="red">字体颜色为红色，大小为3</font>

<font size=4 color="blue">字体颜色为蓝色，大小为4</font>

<font size=6 color="#ffffff">字体颜色为紫罗兰，大小为6</font>

### 3.2 改变对齐方式

我们可以改变字体的对齐方式，用标签`<p> </p>`加上属性`align`，如：

~~~
<p align="left">左对齐</p>
<p align="center">中间对齐</p>
<p align="right">右对齐</p>
~~~

<p align="left">左对齐</p>
<p align="center">中间对齐</p>
<p align="right">右对齐</p>

### 3.3 插入头像

 我们可以通过标签`<img src=url />`来插入图片，如：

```
<img src="./【Hexo】typora知识总结/001.jpg" />
```

<img src="【Hexo】typora知识总结/001.jpg" />

我们可以改变`<img>`标签的属性，来改变图片的大小。

~~~
<img src="./【Hexo】typora知识总结/001.jpg" width=100 height=100/>
~~~

<img src="【Hexo】typora知识总结/001.jpg" width=100 height=100/>

也可以改变图片的位置，如：

~~~
<img src="【Hexo】typora知识总结/001.jpg" width=30 height=30 style="float:left"/>图片在左边
<img src="【Hexo】typora知识总结/001.jpg" width=30 height=30 style="float:right"/>图片在右边
~~~

<img src="【Hexo】typora知识总结/001.jpg" width=30 height=30 style="float:left"/>图片在左边
<img src="【Hexo】typora知识总结/001.jpg" width=30 height=30 style="float:right"/>图片在右边

## 四、其他用法

### 文章截断——阅读全文

若你是用的是NEXT主题，可以在文章中使用`< !--more-->` 手动进行截断
 这种方法可以根据文章的内容，自己在合适的位置添加 `< !--more-->` 标签，使用灵活，也是Hexo推荐的方法。

### 目录功能

使用hexo-toc可以在文章头部添加目录。 其配置在博客根目录的_config.yml文件中。类似于文章截断功能，在需要显示文章目录的地方添加`<!--toc-->`

额······因为使用这个以后侧边框的目录无法跳转，就又卸载了。



本文参考：

[Hexo中添加emoji表情](https://blog.csdn.net/weixin_30745641/article/details/95686757)

[ Hexo-Next 常用 MD 语法合集](https://www.imczw.com/post/tech/hexo-next-tags-markdown.html)

https://blog.csdn.net/qq_41261251/article/details/102817673

https://whatsid.me/2019/08/21/hexo-markdown-syntax/#

[Hexo系列(2) - NexT主题美化与博客功能增强](https://blog.csdn.net/lewky_liu/article/details/82432003)

[主题配置 - NexT 使用文档](https://theme-next.iissnan.com/theme-settings.html)

[Markdown连接的写法](https://blog.csdn.net/qq_32320399/article/details/99823695)
