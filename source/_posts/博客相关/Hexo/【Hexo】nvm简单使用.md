---
title: 【Hexo】nvm简单使用
categories:
  - 博客相关
  - Hexo
tags:
  - private
description: >-
  声明：文章中涉及的程序(方法)可能带有攻击性，仅供安全研究与教学之用，读者将其信息做其他用途，由用户承担全部法律及连带责任，文章作者不承担任何法律及连带责任。
comments: true
abbrlink: 1e0c055a
date: 2026-01-11 15:07:55
top:
---



## 📦 NVM (Node版本管理器) 简明使用指南

管理Node.js版本是前端和Node.js开发中的常见需求，不同项目可能依赖不同的Node版本。NVM让你可以在同一台电脑上轻松安装、切换和使用多个Node.js版本。

### 一、安装NVM

**Windows用户**：
前往 [nvm-windows 项目发布页](https://github.com/coreybutler/nvm-windows/releases) 下载最新的 `nvm-setup.exe` 安装程序，按向导完成安装。

**macOS/Linux用户**：
使用安装脚本（通常已包含在系统包管理器中）：

bash

```
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
# 或
wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
```



安装后重启终端或执行 `source ~/.bashrc`（或 `~/.zshrc`）。

### 二、核心命令一览

| 命令                          | 功能                        | 示例/说明                                               |
| ----------------------------- | --------------------------- | ------------------------------------------------------- |
| **`nvm list available`**      | 查看所有可安装的Node.js版本 | 列出LTS和Current版本。                                  |
| **`nvm install <version>`**   | 安装指定版本的Node.js       | `nvm install 18.19.0` `nvm install latest` (安装最新版) |
| **`nvm list` 或 `nvm ls`**    | 查看所有已安装的版本        | 当前使用版本前有 `*` 标记。                             |
| **`nvm use <version>`**       | 切换使用的Node.js版本       | `nvm use 18.19.0`                                       |
| **`nvm current`**             | 显示当前使用的Node.js版本   | 快速查看当前激活版本。                                  |
| **`nvm uninstall <version>`** | 卸载指定版本的Node.js       | `nvm uninstall 14.17.0`                                 |

### 三、工作流示例

bash

```
# 1. 安装最新的LTS（长期支持）版本和另一个特定版本
nvm install 20.19.0
nvm install 18.19.0

# 2. 查看已安装的版本
nvm list
# 输出示例：
#   * 20.19.0 (Currently using 64-bit executable)
#     18.19.0

# 3. 切换到 18.19.0 版本
nvm use 18.19.0

# 4. 验证切换是否成功
node -v  # 应输出 v18.19.0

# 5. 为不同项目设置默认版本（可选）
nvm alias default 18.19.0
```



### 四、常见使用场景

- **解决项目兼容性问题**：当运行 `npm install` 或项目启动时报错，提示Node版本不符时，使用 `nvm install` 和 `nvm use` 切换到项目要求的版本。
- **尝鲜新特性**：安装 `latest` 版本测试新功能，同时保留稳定的LTS版本用于日常工作。
- **保持环境干净**：无需反复安装/卸载Node.js，所有版本隔离存放，通过 `nvm use` 一键切换。

### 五、注意事项

1. **全局安装的包**：每个Node版本有独立的全局 `node_modules`，切换版本后，可能需要重新安装某些全局命令行工具（如 `npm install -g hexo-cli`）。
2. **项目级版本控制**：建议在项目根目录创建 `.nvmrc` 文件（内容如 `18.19.0`），配合 `nvm use`（不带版本号）可自动切换。
3. **Windows选择**：`nvm-windows` 是独立项目，命令与macOS/Linux的nvm略有不同，但核心功能一致。

### 六、总结

NVM通过简单的命令解决了Node.js版本管理的核心痛点：

- **安装**：`nvm install <版本号>`
- **查看**：`nvm list`
- **切换**：`nvm use <版本号>`

掌握这三条命令，你就能轻松驾驭多个Node.js环境，让版本问题不再成为开发和部署的障碍。下次遇到“`Error [ERR_REQUIRE_ESM]`”或“`Unsupported engine`”这类版本错误时，不妨先试试NVM。



本文参考：
