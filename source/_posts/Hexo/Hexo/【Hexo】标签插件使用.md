---
title: 【Hexo】标签插件使用
comments: true
abbrlink: eefe99e9
categories:
  - Hexo
  - Hexo
tags:
  - Hexo
date: 2024-11-02 13:20:20
description:
top:
---

「tag 插件」(Tag Plugin) 是 Hexo 提供的一种快速生成特定内容的方式。 例如，在标准 Markdown 语法中，我们无法指定图片的大小。这种情景，我们即可使用标签来解决。 Hexo 内置来许多标签来帮助写作者可以更快的书写， 完整的标签列表 可以参考 [Hexo 官网](https://hexo.io/docs/tag-plugins.html)。 另外，Hexo 也开放来接口给主题，使主题有可能提供给写作者更简便的写作方法。

<!-- more -->

## 引用块

+ **blockquote**

在文章中插入引言，可包含作者、来源和标题，均可选。

标签方式：使用 `blockquote` 或者 简写 `quote`。

```
{% blockquote author, source link source_link_title %}
content
{% endblockquote %}
```

示例如下：

```
{% blockquote Corazon, https://www.mcorazon.top Corazon博客首页 %}
这个世界总有黑夜
但是我们总发着光
{% endblockquote %}
```

{% blockquote Corazon, https://www.mcorazon.top Corazon博客首页 %}
这个世界总有黑夜
但是我们总发着光
{% endblockquote %}	

- **pullquote**

pullquote 可以自定义引用块的样式

```
{% pullquote [class] %}
content
{% endpullquote %}
```

+ **居中引用**

```
{% centerquote %}blah blah blah{% endcenterquote %}
```

{% centerquote %}blah blah blah{% endcenterquote %}

同时HTML 居中引用的方式也比较简单：

```
<blockquote class="blockquote-center">blah blah blah</blockquote>
```

<blockquote class="blockquote-center">blah blah blah</blockquote>



## 代码块<a id="dmk"></a>

在文章中插入代码，包含指定语言、附加说明和网址，均可选。
 标签方式：使用 `codeblock` 或者 简写 `code`。

+ codeblock代码块

```
{% codeblock [title] [lang:language] [url] [link text] [additional options] %}
code snippet
{% endcodeblock %}
```

示例如下：

```
{% codeblock 示例代码 lang:objc https://www.mcorazon.top 博客首页 %}
[rectangle setX: 10 y: 10 width: 20 height: 20];
{% endcodeblock %}
```

{% codeblock 示例代码 lang:objc https://www.mcorazon.top/posts/eefe99e9/#dmk 代码块示例 %}
[rectangle setX: 10 y: 10 width: 20 height: 20];
{% endcodeblock %}

在 `additional options` 中，以 option:value 格式指定附加选项，例如 line_number:false（行数） first_line:5。

|  Extra Options   |                         Description                          | Default |
| :--------------: | :----------------------------------------------------------: | :-----: |
|  `line_number`   |                       Show line number                       | `true`  |
| `line_threshold` | Only show line numbers as long as the numbers of lines of the code block exceed such threshold. |   `0`   |
|   `highlight`    |                   Enable code highlighting                   | `true`  |
|   `first_line`   |                Specify the first line number                 |   `1`   |
|      `mark`      | Line highlight specific line(s), each value separated by a comma. Specify the number range using a dash Example: `mark:1,4-7,10` will mark lines 1, 4 to 7 and 10. |         |
|      `wrap`      | Wrap the code block in [``](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/table) | `true`  |

+ 反引号代码块<a id="fyhdmk"></a>

这与使用代码块相同，但使用了三个回车键来分隔代码块。

 \`\` [language] [title] [url] [link text] code snippet \`\` 

示例如下：

````
 ```python [反引号代码块示例] https://www.mcorazon.top/posts/eefe99e9/#fyhdmk 反引号代码块
 print("hello-word") 
 ```
````

 ```python [反引号代码块示例] https://www.mcorazon.top/posts/eefe99e9/#fyhdmk 反引号代码块
 print("hello-word") 
 ```



## iframe

在文章中嵌入 iframe，

```
{% iframe url [width] [height] %}
```

示例如下：

```
{% iframe //player.bilibili.com/player.html?isOutside=true&aid=113446695739195&bvid=BV17rDZYZEM1&cid=26669354075&p=1  500px 250px %}
```

{% iframe //player.bilibili.com/player.html?isOutside=true&aid=113446695739195&bvid=BV17rDZYZEM1&cid=26669354075&p=1  500px 250px %}

可能是因为主题的原因，目前video的iframe大小没有设置成功，但网页，图片可以设置。由于目前前端水平不足，暂时不处理。

以下HTML代码可实现同样的功能，不予演示。

```
<iframe src="//player.bilibili.com/player.html?isOutside=true&aid=113446695739195&bvid=BV17rDZYZEM1&cid=26669354075&p=1" scrolling="no" border="0" frameborder="no" framespacing="0"  allowfullscreen="true"></iframe>
```



## 图像

使用标签插入图像可以自定义图像的大小

```
{% img [class names] /path/to/image [width] [height] '"title text" "alt text"' %}
```
示例如下：
```
{% img imgcls /【Hexo】标签插件使用/004.png 20px 20px '"004.png" "这就是我的头像"' %}
```

{% img imgcls /【Hexo】标签插件使用/004.png 20px 20px '"004.png" "这就是我的头像"' %}

<font class="notice">*~~mlgbzd~~，一会儿行一会不行的*</font>



## Video 标签

```
{% video //player.bilibili.com/player.html?isOutside=true&aid=113446695739195&bvid=BV17rDZYZEM1&cid=26669354075&p=1 %}
```

{% video //player.bilibili.com/player.html?isOutside=true&aid=113446695739195&bvid=BV17rDZYZEM1&cid=26669354075&p=1 %}





## 链接

插入带有 target=“_blank” 属性的链接。

```
{% link text url [external] [title] %}
```

示例如下：

```
{% link text https:// [external] [title] %}
```



{% youtube lJIrF4YjHfQ %}



## 折叠展开文字hexo-sliding-spoiler

项目地址：https://gitcode.com/gh_mirrors/he/hexo-sliding-spoiler

## 安装

```sh
npm install hexo-sliding-spoiler --save
```

## 语法：

```
{% spoiler title %}
内容
{% endspoiler %}
```

## 演示：

```javascript
{% spoiler 标题 %}
内容
{% endspoiler %}
```

{% spoiler 标题 %}
内容
{% endspoiler %}

<font class=notice>注意：标题中包含空格时，用`"`包括</font>



参考文章：

[Hexo标签插件的使用](https://blog.csdn.net/qq_41518277/article/details/101765886)
