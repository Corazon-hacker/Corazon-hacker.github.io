---
title: 【PortSwigger学院】路径遍历
comments: true
categories:
  - 靶场练习
  - PortSwigger靶场
tags:
  - PortSwigger靶场
  - 路径遍历
abbrlink: 15b3971d
date: 2025-04-30 12:59:05
description:
top:
---

## 什么是路径遍历

路径遍历也称为目录遍历。这些漏洞可使攻击者在运行应用程序的服务器上读取任意文件。这可能包括：

+ 应用程序代码和数据
+ 后端系统的凭证
+ 敏感的操作系统文件。

在某些情况下，攻击者可能能够写入服务器上的任意文件，从而修改应用程序数据或行为，并最终完全控制服务器。

<!-- more -->

## 通过路径遍历读取任意文件

### Lab: File path traversal, simple case

想象一下，一个购物应用程序会显示待售商品的图片。可以使用以下 HTML 加载图片：

```html
<img src="/loadImage?filename=218.png">
```

`loadImage `URL 接收一个`filename`参数，并返回指定文件的内容。图像文件存储在磁盘的 `/var/www/images/`  目录中。要返回图像，应用程序会将请求的文件名追加到该基本目录，并使用文件系统 API 读取文件内容。换句话说，应用程序会从以下文件路径读取内容：

```bash
/var/www/images/218.png
```

该应用程序没有针对路径遍历攻击实施任何防御措施。因此，攻击者可以请求以下 URL，从服务器文件系统中检索 /etc/passwd 文件：

```
https://insecure-website.com/loadImage?filename=../../../etc/passwd
```

这将导致应用程序从以下文件路径读取数据：

```
/var/www/images/../../../etc/passwd
```

`../`序列在文件路径中有效，表示在目录结构中上移一级。连续三个` ../ `顺序从 `/var/www/images/ `上移到文件系统根目录，因此实际读取的文件是：

```bash
/etc/passwd
```

在基于 Unix 的操作系统上，这是一个标准文件，包含服务器上注册用户的详细信息，但攻击者可以使用相同的技术检索其他任意文件。

在 Windows 系统中，../ 和 ..\都是有效的目录遍历序列。下面是一个针对基于 Windows 的服务器的等效攻击示例：

```
https://insecure-website.com/loadImage?filename=..\..\..\windows\win.ini
```

该实验室在显示产品图像时存在路径遍历漏洞。要解决该实验问题，请检索 `/etc/passwd `文件的内容。

![image-20250430160204983](【PortSwigger靶场】路径遍历/image-20250430160204983.png)

这一题很简单。把参数改一下就可以了。

## 利用路径遍历漏洞的常见障碍



### Lab: File path traversal, traversal sequences blocked with absolute path bypass

许多将用户输入置入文件路径的应用程序都有针对路径遍历攻击的防御措施。这些防御措施往往可以被绕过。

如果应用程序从用户提供的文件名中删除或阻止目录遍历序列，就有可能利用各种技术绕过防御。

您可以使用文件系统根目录下的绝对路径（如 `filename=/etc/passwd`）来直接引用文件，而无需使用任何遍历序列。

该实验室在显示产品图像时存在路径遍历漏洞。应用程序会阻止遍历序列，但会将所提供的文件名视为默认工作目录的相对文件名。要解决该实验问题，请检索 /etc/passwd 文件的内容。

+ 这道题阻止了相对目录遍历序列，但是可以用绝对路径

![image-20250430162204471](【PortSwigger靶场】路径遍历/image-20250430162204471.png)

### Lab: File path traversal, traversal sequences stripped non-recursively

您或许可以使用嵌套遍历序列，如 ....// 或 ....//。当内部序列被剥离时，这些序列会恢复为简单的遍历序列。

该实验室在显示产品图像时存在路径遍历漏洞。在使用用户提供的文件名之前，应用程序会从该文件名中删除路径遍历序列。要解决该实验问题，请检索 /etc/passwd 文件的内容。

+ 使用`....//....//....//etc//passwd`遍历是可以的，但是`//etc//passwd`不行。

![image-20250430163057050](【PortSwigger靶场】路径遍历/image-20250430163057050.png)

### Lab: File path traversal, traversal sequences stripped with superfluous URL-decode

在某些情况下，例如在 URL 路径或`multipart/form-data`  请求的`filename`参数中，网络服务器可能会在将您的输入传递给应用程序之前去掉任何目录遍历序列。有时，您可以通过 URL 编码，甚至是双重 URL  编码来绕过这种清理。这将分别导致 `%2e%2e%2f` 和 `%252e%252e%252f`。各种非标准编码，如 `..%c0%af` 或  `..%ef%bc%8f` 也可以使用。

该实验室在显示产品图像时存在路径遍历漏洞。应用程序会阻止包含路径遍历序列的输入。然后在使用输入之前对其进行 URL 解码。要解决本实验问题，请检索 /etc/passwd 文件的内容。

+ url单层编码访问失败，双重编码成功。服务器会对HTTP请求双重url解码。这里把`../`换成`%252e%252e%252f`或者`..%252f`就可以了。

![image-20250430165746276](【PortSwigger靶场】路径遍历/image-20250430165746276.png)

{% spoiler 为什么服务器会进行双重解码？%}
可能的情况是，服务器在处理请求的时候，可能在不同的层次上多次进行URL解码。比如，Web服务器（如Apache或Nginx）可能先进行一次解码，然后应用框架（如PHP、Python的Flask等）可能再进行一次解码。如果两次解码之间没有对路径进行正确的规范化或安全检查，就会导致攻击者通过双重编码绕过一些安全检测。
{% endspoiler %}

{% spoiler 有没有可能只解码一次或者更多次？%}

当然有可能。这取决于服务器的配置和代码实现。如果服务器只进行一次解码，那么攻击者需要直接使用单次编码的字符，例如`%2e%2f%2e%2e`等。而如果服务器解码次数超过两次，比如三次，那么攻击者可能需要使用三重编码，比如`%2525252e`（假设三重编码的话）。不过这种情况比较少见，因为通常服务器不会多次解码。

{% endspoiler %}

### Lab: File path traversal, validation of start of path

应用程序可能要求用户提供的文件名以预期的基本文件夹开始，如 `/var/www/images`。在这种情况下，可以在所需的基本文件夹后加上适当的遍历序列。例如：`filename=/var/www/images/.../.../.../etc/passwd`

+ 我用了url编码，不使用url编码也是可以的，这里单层解码，双层就不行了

![image-20250430171637924](【PortSwigger靶场】路径遍历/image-20250430171637924.png)

### Lab: File path traversal, validation of file extension with null byte bypass

应用程序可能要求用户提供的文件名以预期的文件扩展名结尾，如 .png。在这种情况下，可以使用空字节在所需扩展名之前有效地终止文件路径。例如：filename=.../.../.../etc/passwd%00.png。

本实验室在显示产品图像时存在路径遍历漏洞。应用程序会验证所提供的文件名是否以预期的文件扩展名结尾。要解决该实验问题，请检索 /etc/passwd 文件的内容。

这个感觉好牛啊，希望自己慢慢积累，积跬步至千里吧。

+ 相对路径后加`%00.png`绕过文件后缀验证

![image-20250430172259167](【PortSwigger靶场】路径遍历/image-20250430172259167.png)



## 如何防止路径遍历攻击

防止路径遍历漏洞的最有效方法是完全避免将用户提供的输入传递给文件系统 API。许多这样做的应用程序函数都可以重写，以更安全的方式提供相同的行为。

如果无法避免将用户提供的输入传递给文件系统 API，我们建议使用两层防御来防止攻击：

+ 在处理用户输入之前对其进行验证。理想情况下，将用户输入与允许值白名单进行比较。如果做不到这一点，则要验证输入是否只包含允许的内容，例如只包含字母数字字符。
+ 验证所提供的输入后，将输入追加到基本目录，并使用平台文件系统 API 对路径进行规范化。验证规范化路径是否以预期的基本目录开始。

下面是一个根据用户输入验证文件规范路径的简单 Java 代码示例：

```java
File file = new File(BASE_DIRECTORY, userInput);
if (file.getCanonicalPath().startsWith(BASE_DIRECTORY)) {
    // process file
}
```

 **代码逐行解析：**

1. 创建文件对象

```java
File file = new File(BASE_DIRECTORY, userInput);
```

- **`File`类**：Java中用于表示文件或目录路径的类。
- **构造函数参数**：
  - `BASE_DIRECTORY`：预定义的基础目录（如`/safe/path`），用于限制文件访问范围。
  - `userInput`：用户输入的路径（如`data.txt`或`../../secret.txt`）。
- **作用**：将两者拼接成完整路径。例如：
  - 若`BASE_DIRECTORY`是`/safe`，`userInput`是`file.txt`，则拼接为`/safe/file.txt`。
  - 若`userInput`是`../etc/passwd`，则拼接为`/safe/../etc/passwd`。

2. 路径规范化验证

```java
if (file.getCanonicalPath().startsWith(BASE_DIRECTORY)) {
    // 处理文件
}
```

- **`getCanonicalPath()`**：将路径转换为**绝对且唯一**的规范形式：

  - 解析`.`（当前目录）和`..`（上级目录）。
  - 去除多余的斜杠（如`/safe//file`变为`/safe/file`）。
  - 解析符号链接（如将快捷方式转为真实路径）。

  例如：`/safe/../etc/passwd` 会被规范化为 `/etc/passwd`。

- **`startsWith(BASE_DIRECTORY)`**：检查规范路径是否以`BASE_DIRECTORY`开头。

  - 若用户输入合法（如`data.txt`），规范路径为`/safe/data.txt`，验证通过。
  - 若用户输入非法（如`../../etc/passwd`），规范路径为`/etc/passwd`，验证失败。

但是这段代码应该有一定的问题，就是只要保证文件路径与`BASE_DIRECTORY`一致即可。比如说，如果`BASE_DIRECTORY`是`/base`便可以构造`/baseXXXX`越权访问与文件开头与`BASE_DIRECTORY`一致的同级目录。



本文参考：

[Path traversal](https://portswigger.net/web-security/file-path-traversal)
