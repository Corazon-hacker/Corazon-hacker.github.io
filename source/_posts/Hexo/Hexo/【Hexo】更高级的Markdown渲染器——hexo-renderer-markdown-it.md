---
title: 【Hexo】更高级的Markdown渲染器——hexo-renderer-markdown-it
comments: true
abbrlink: e3e8d0c4
categories:
  - Hexo
  - Hexo
tags:
  - Hexo
date: 2024-11-11 13:25:52
description:
top:
---

Hexo 默认搭配的 Markdown 渲染器是 hexo-renderer-marked，但其支持的渲染格式有限，不利于自由写作。因此，今天教大家如何更换为功能更加强大，渲染速度更快的 hexo-renderer-markdown-it 渲染器，并且还会详细介绍常用插件的配置，实现更优雅的 Markdown 写作。

container和footnote不知道为什么不能使用，估计也用不上，暂时不处理了。原文在参考文章里。

<!-- more -->

## 安装

卸载 `hexo-renderer-marked`

```
npm un hexo-renderer-marked --save
```

安装 `hexo-renderer-markdown-it`

```
npm i hexo-renderer-markdown-it --save
```

## 配置

将如下文本复制粘贴到 [Hexo](https://so.csdn.net/so/search?q=Hexo&spm=1001.2101.3001.7020) 的配置文件 `_config.yml` 的尾部

```
markdown:
  preset: "default"
  render:
    html: true
    xhtmlOut: false
    langPrefix: "language-"
    breaks: true
    linkify: true
    typographer: true
    quotes: "“”‘’"
  enable_rules:
  disable_rules:
  plugins:
    - markdown-it-abbr
    - markdown-it-cjk-breaks
    - markdown-it-deflist
    - markdown-it-emoji
    - markdown-it-footnote
    - markdown-it-ins
    - markdown-it-mark
    - markdown-it-sub
    - markdown-it-sup
    - markdown-it-checkbox
    - markdown-it-imsize
    - markdown-it-expandable
    - name: markdown-it-container
      options: success
    - name: markdown-it-container
      options: tips
    - name: markdown-it-container
      options: warning
    - name: markdown-it-container
      options: danger
  anchors:
    level: 2
    collisionSuffix: ""
    permalink: false
    permalinkClass: "header-anchor"
    permalinkSide: "left"
    permalinkSymbol: "¶"
    case: 0
    separator: "-"
```

## 插件

本章节讲述各种插件的用法、配置和注意事项。

### 安装

分别使用 `npm` 命令安装以下三个插件：

```
npm i markdown-it-checkbox
npm i markdown-it-imsize
npm i markdown-it-expandable
```

其它插件 `hexo-renderer-markdown-it` 渲染器自带的有，不要安装。

### 用法

#### 基础

| 名称                 | 描述     | 语法                              | 示例                          |
| -------------------- | -------- | --------------------------------- | ----------------------------- |
| markdown-it-abbr     | 注释     | `*[HTML]: 超文本标记语言`         | *[HTML]: 超文本标记语言       |
| markdown-it-emoji    | 表情     | `:)`  `:crab:`  `:horse:`   | :) :crab: :horse:             |
| markdown-it-footnote | 脚注     | `参考文献[^1]`                    | 参考文献[^1]                  |
| markdown-it-ins      | 下划线   | `++下划线++`                      | ++下划线++                    |
| markdown-it-mark     | 突出显示 | `==标记==`                        | ==标记==                      |
| markdown-it-sub      | 下标     | `H~2~O`                           | H~2~O                         |
| markdown-it-sup      | 上标     | `X^2^`                            | X^2^                          |
| markdown-it-checkbox | 复选框   | `- [ ] `未选 <br/> `- [x] `选中 | ![image-20241111151833850](【hexo】更高级的Markdown渲染器——hexo-renderer-markdown-it/image-20241111151833850.png) |

- [ ] 未选
- [x] 选中

#### 进阶

> [markdown-it-imsize](https://github.com/tatsy/markdown-it-imsize)：自定义图片宽高。

语法：（**注意**：`=100x200` 前面有一个空格）

```
![test](006.png =100x200)
```

![test](【Hexo】更高级的Markdown渲染器——hexo-renderer-markdown-it/006.png =100x200)



> [markdown-it-expandable](https://github.com/bioruebe/markdown-it-collapsible)：折叠/展开内容。

语法：

```
+++ **点击折叠**
这是被隐藏的内容
+++
```

效果：

+++ **点击折叠**
这是被隐藏的内容

+++

> [markdown-it-container](https://github.com/markdown-it/markdown-it-container)：自定义容器。

语法：

```
::: tips
**提示**
这是一个提示
:::

::: warning
**注意**
这是一个警告
:::

::: danger
**警告**
这是一个危险信号
:::

::: success
**成功**
这是一个成功信号
:::
```

效果：

::: tips
**提示**
这是一个提示
:::

::: warning
**注意**
这是一个警告
:::

::: danger
**警告**
这是一个危险信号
:::

::: success
**成功**
这是一个成功信号
:::















本文参考：

[【Hexo】选择更高级的Markdown渲染器](https://blog.csdn.net/qq_42951560/article/details/123596899)

