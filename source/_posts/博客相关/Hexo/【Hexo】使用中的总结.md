---
title: 【Hexo】使用中的总结
comments: true
categories:
  - 博客相关
  - Hexo
tags:
  - Hexo
abbrlink: 8071f3a9
date: 2025-03-05 14:21:41
description:
top:
---

本文记录在使用hexo过程中遇到的一些问题，持续更新

<!-- more -->

## 带空格的标题

带空格的标题需要用双引号`“标  题”`引起来，不然文件和标题的命名会发生错误。

![image-20250305142442398](【Hexo】使用中的总结/image-20250305142442398.png)

## 标签未闭合

错误信息显示“unexpected end of file”，通常意味着模板中有未闭合的标签或语法错误，但也有其他可能。

![image-20250507115534543](【Hexo】使用中的总结/image-20250507115534543.png)

## 取消图片名字

![111](【Hexo】使用中的总结/111.png)

我使用Typora编写博客，复制粘贴图像的时候会自动生成名字，但是我觉得这样并不美观，因此我想让我的博客不再显示名称。由于我已经写了很多的博客，所以单纯的修改Typora会使我之前的图片依然显示名字，因此我考虑修改我的主题配置。

这个问题也花费了我不短的时间，主要明明可以简单的在主题的配置文件里添加`head: source/_data/head.css` 但是我这么做以后，始终不能成功。我的head.css文件并没有加载。网络适配器里搜索不到head.css，并且在我博客的右上角出现 `[object Promise]` 字符。

因此我直接修改了主题模板强制引入。

1. 打开主题的 `head.swig` 文件（路径：`themes/next/layout/_partials/head.swig`）。
2. 在文件末尾添加以下代码：

```css
{# 手动引入自定义 CSS #}
<link rel="stylesheet" href="/css/head.css">
```

3. 将 `head.css` 移动到 Hexo 的 `source/css/` 目录：

```
博客根目录/
├─ source/
│  └─ css/
│     └─ head.css   <-- 移动到此目录
```

4. 清理缓存并重新生成：`hexo clean && hexo g`

## 新生成的博客没有序列化

每次生成新博客之后要先执行一下`hexo cl && hexo g` 才会生成`abbrlink`。



本文参考：
