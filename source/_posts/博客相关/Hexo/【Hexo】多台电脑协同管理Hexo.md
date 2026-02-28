---
title: 【Hexo】多台电脑协同管理Hexo
categories:
  - 博客相关
  - Hexo
comments: true
abbrlink: 543ce806
date: 2026-02-28 14:19:48
tags:
description:
top:
---

## 多台电脑协同管理Hexo博客完全指南

本文详细介绍了如何使用 **Git双分支策略**，在多个Windows电脑间无缝同步和管理一个Hexo博客。该方法能确保写作环境一致、源文件安全，并实现流畅的跨设备协作。

----

### 核心策略：Git双分支

我们采用双分支来分离关注点：

- **`hexo`分支 (或 `source` 分支)**：存放博客的**所有源文件**（文章、配置、主题、插件等）。此分支用于在多台电脑间同步和协作。
- **`main` 分支 (或 `master` 分支)**：存放Hexo生成的**静态网站文件**（`public/`文件夹内容）。此分支专门用于部署到GitHub Pages等托管服务。

----

### 第一部分：旧电脑（主机）初始化与迁移

假设你已在旧电脑上拥有一个本地Hexo博客。

1. **准备远程仓库**
   - 在GitHub上创建一个新仓库，仓库名必须为：`<你的用户名>.github.io`。

   - 创建后，在GitHub网页上手动新建一个名为 `hexo` 的分支。

2. **修改Hexo主配置文件 _config.yml**

**用编辑器打开，至少配置以下两部分**

+ 部署设置 (deploy)

```yaml
deploy:
  type: git
  repo: https://github.com/你的用户名/你的用户名.github.io.git # 或SSH地址
  branch: master # 确保部署到 master 分支
```

+ 主题设置 (theme)	

```yaml
theme: next # 假设你使用next主题
```

3. **安装必要插件（部署插件和渲染器，以Next主题为例）**


```
npm install
npm install hexo-deployer-git --save
npm install hexo-renderer-stylus --save # 如果使用Next主题
```

4. **本地仓库初始化**

```bash
# 进入博客根目录
cd your-blog-folder
# 初始化本地仓库
git init
# 创建并切换到 hexo 分支
git checkout -b hexo
# 添加远程仓库地址
git remote add origin https://github.com/你的用户名/你的用户名.github.io.git
```

5. **创建并配置 `.gitignore`**

- 在根目录创建 `.gitignore` 文件，内容必须包含：

```bash
node_modules/
public/
.deploy*/
db.json
*.log
```

我的`.gitignore` 文件如下：

```bash
# 依赖
node_modules/

# 生成文件
public/
.deploy*/

# 日志和数据库
*.log
db.json

# 环境文件
.env

# 系统文件
.DS_Store
Thumbs.db
```

6. **处理主题子模块问题**

在将博客项目推送到远程仓库时，如果您的主题（例如 Next 主题）是通过 `git clone` 命令安装的，其目录内会包含一个独立的 `.git` 文件夹。这会使 Git 将其识别为“子模块”，导致**主题的核心文件无法被正常提交和同步**，这是多机协作中最常见的故障点。

* 原因与必要性：直接 `git clone` 主题仓库会保留其完整的 Git 历史记录，Git会将其识别为“子模块”，忽略其内容，导致其他电脑拉取后主题目录为空。

+ 安全删除命令：在博客根目录下，执行以下命令来查找并删除主题文件夹中内嵌的 `.git` 文件夹：

```bash
# 以 Next 主题为例，此命令会安全地删除其内部的所有 .git 文件夹或文件
find themes/next -name ".git" -type f -o -name ".git" -type d | while read f; do rm -rf "$f"; echo "已清理: $f"; done
```

如果使用其他主题，请将 `themes/next` 替换为您的主题文件夹路径（例如 `themes/butterfly`）。

**⚠️ 警告**：

- **区分目标**：此操作仅针对 `themes/xxx/` 目录下的内嵌 `.git`。
- **绝对禁止**：**切勿删除**博客**项目根目录**下的 `.git` 文件夹，那是您整个项目版本控制的核心，删除会导致项目版本历史丢失。
- **执行时机**：通常在主题安装后、首次提交前，或在新电脑上发现主题文件缺失时执行。

7. **在旧电脑（正常工作的电脑）上更新依赖清单**

未解决多台电脑上依赖环境的不通导致的问题，需要同步多台电脑上的依赖环境，请严格按以下流程操作，**先旧电脑，后新电脑**。在旧电脑的博客根目录执行，将当前所有依赖的**精确版本**锁定并推送到仓库：

```bash
# 1. 进入博客目录
cd ~/Corazon/blog  # 请替换为你的实际路径

# 2. 生成/更新 package-lock.json，记录所有依赖的确切版本
npm install --package-lock-only

# 3. 提交这两个描述依赖的关键文件
git add package.json package-lock.json
git commit -m “更新：提交精确的依赖锁定文件”
git push origin hexo
```

8. **连接远程仓库并提交**

如果已经有秘钥，使用已存在的秘钥也可以。

```bash
# ========== 在每台新电脑上只需配置一次 ==========

# 1. 生成 SSH 密钥对（使用更现代的 ed25519 算法）
#    将引号内的邮箱替换为你的 GitHub 关联邮箱
ssh-keygen -t ed25519 -C "your_email@example.com"
# 生成过程中，连续按三次回车：
#   第一次：接受默认密钥文件保存位置
#   第二、三次：设置为空密码（直接回车），方便后续免密推送

# 2. 启动 SSH 代理，并在后台运行它（确保密钥被管理）
eval "$(ssh-agent -s)"

# 3. 将生成的私钥添加到 SSH 代理中
ssh-add ~/.ssh/id_ed25519

# 4. 查看并复制你的公钥（用于下一步添加到GitHub）
cat ~/.ssh/id_ed25519.pub
# 复制从 `ssh-ed25519 AAA...` 开始到邮箱结束的整段输出

# 5. 将公钥添加到 GitHub 账户（此步骤在浏览器中完成）：
#    a. 登录 GitHub，点击头像 -> Settings（设置）
#    b. 侧边栏选择 SSH and GPG keys（SSH和GPG密钥）
#    c. 点击 New SSH key（新建SSH密钥）
#    d. Title（标题）可自定义（如：“My Office PC”）
#    e. Key type（密钥类型）保持 Authentication Key（认证密钥）
#    f. 将第4步复制的公钥完整粘贴到 Key（密钥） 文本框中
#    g. 点击 Add SSH key（添加SSH密钥）完成

# 6. 测试 SSH 连接是否成功
ssh -T git@github.com
# 首次连接会询问是否信任主机，输入 `yes` 回车。
# 成功后会显示：“Hi 你的用户名! You've successfully authenticated...”

# ========== 针对你的 Hexo 博客仓库进行配置 ==========

# 7. 进入你的 Hexo 博客目录
cd ~/Corazon/blog  # 请将此路径替换为你的实际博客路径

# 8. 将远程仓库地址从 HTTPS 改为 SSH（关键步骤）
git remote set-url origin git@github.com:Corazon-hacker/Corazon-hacker.github.io.git
# 请将 `Corazon-hacker` 替换为你的 GitHub 用户名

# 9. 验证远程地址是否已修改成功
git remote -v
# 正确显示应为：
# origin  git@github.com:你的用户名/你的用户名.github.io.git (fetch)
# origin  git@github.com:你的用户名/你的用户名.github.io.git (push)
```

8. **提交源文件并首次部署**

```bash
git add .
git commit -m "初始化：提交Hexo博客所有源文件"
git push origin hexo

# 安装部署插件并生成网站
npm install hexo-deployer-git --save
hexo clean && hexo g -d
```

至此，`hexo` 分支已有源码，`master` 分支已有网站。

----



### ⚙️ 命令解析与注意事项

- **`npm install --package-lock-only`**：不实际安装，只根据当前 `node_modules` 更新 `package-lock.json` 文件，它是依赖的“精确清单”。
- **`npm ci`**：根据 `package-lock.json` 安装依赖，**能保证环境完全一致**，且安装速度更快。相比 `npm install`，它更严格，适用于自动化场景。
- **为何要删除 `node_modules`**：新电脑原有的 `node_modules` 可能缺少某些模块或版本不对，必须删除后从“精确清单”重建。

----

#### 第二部分：新电脑【首次加入协作】

在新电脑上，你需要克隆源码并恢复环境。

1. **安装基础环境**
   - **Node.js** (推荐LTS版，如v18.x/20.x，所有电脑版本尽量一致)
   - **Git**
   - **Hexo CLI** (`npm install -g hexo-cli`)
2. **新电脑**

克隆源码分支并恢复依赖环境。

```bash
# 1. 安装 Node.js、Git，然后安装 Hexo 命令行工具
npm install -g hexo-cli

# 2. 克隆博客源码仓库的 hexo 分支（注意 -b hexo 参数）
git clone -b hexo git@github.com:你的用户名/你的用户名.github.io.git
# 进入项目目录
cd 你的用户名.github.io

# 3. 安装项目依赖（切勿执行 hexo init  直接安装项目所需依赖）
npm install

# 4. 测试运行
hexo g && hexo s
```

3. **在新电脑上强制同步并重建依赖**

在旧电脑完成旧依赖推送后，立即在新电脑的博客目录执行：

```bash
# 1. 进入博客目录
cd C:\Users\zhang\Corazon-hacker.github.io  # 请替换为你的实际路径

# 2. 拉取旧电脑刚刚推送的更新
git pull origin hexo

# 3. 【关键】彻底删除现有的 node_modules 和缓存
rm -rf node_modules
hexo clean

# 4. 根据 package-lock.json 安装完全一致的依赖（使用 ci 命令）
npm ci
```


3. **测试运行**

```bash
hexo g
hexo s
```

访问 `http://localhost:4000` 正常，则新电脑环境配置成功。

## 三、🔄 日常双机同步工作流

这是保证协作不混乱的**黄金法则**，请严格遵守。

### 📜 核心原则与准备

**铁律**：将Git远程仓库的 `hexo` 分支视为 **“唯一真相源”** 。任何电脑在修改前，必须与其同步；修改后，必须立即将更新合并回去。

**前提检查**（每次开始前快速确认）：

1. **终端位置**：确保在博客根目录（包含 `_config.yml`, `source`, `themes` 的目录）。
2. **所在分支**：执行 `git branch` 确认当前分支为 `hexo`（前面有 `*` 号）。
3. **网络连接**：确保电脑可以正常访问 `github.com`。

### 🔄 标准化工作流程（以“电脑A”开始写作为例）

#### **场景一：任意电脑上【开始工作前】的同步**

在任意电脑修改博客之前，需要与github进行同步。避免覆盖掉之前的工作。在电脑A上打开终端，依次执行：

```bash
# 1. 进入你的博客目录（请替换为你的实际路径）
cd C:\你的\博客\路径

# 2. 临时保存所有未提交的更改（非必须，但安全）
git add .
git commit -m “临时存档：开始新工作前”

# 3. 【关键】拉取远程 hexo 分支的最新内容，并尝试自动合并
git pull origin hexo

# 4. 处理拉取结果
#    - 若显示 “Already up to date.”: 本地已最新，可直接开始工作。
#    - 若显示 “CONFLICT”: 发现冲突，请立即停止，跳转到下方的【冲突解决】部分。
```

拉取后，电脑A将获得github新增文章的所有源文件。此时，你可以在电脑A上直接进行 文章编写。

#### **场景二：任意电脑上【完成工作后】的提交与部署**

写作测试无误后，回到终端，按 **严格顺序** 执行：

```bash
# 1. （可选）本地生成并预览，确保无误
hexo clean && hexo g && hexo s
# 按 Ctrl+C 停止预览服务器

# 2. 将所有的改动添加到暂存区
git add .

# 3. 将暂存区的改动打包为一个正式的版本记录（提交）
git commit -m “描述你的更改，例如：发布文章《XXX》”

# 4. 将本地提交推送到远程仓库的 hexo 分支（同步源代码）
git push origin hexo
#成功标志：显示 `To github.com:...` 并提示类似 `* [new branch] hexo -> hexo`。

# 5. 生成静态网站并部署到 GitHub Pages（更新公开网站）
# 此命令会读取 _config.yml 中的部署设置，将 public/ 下文件推送到 master 分支
hexo clean && hexo g -d
#成功标志：提示 `INFO Deploy done: git`
```

推荐备注格式：

> feat: 添加新文章《XXX》
> fix: 修复YYY页面错别字
> update: 更新ZZZ主题配置

#### **场景三：紧急情况处理 - 【解决冲突】**

**何时发生**：当你 `git pull` 时，如果你本地修改了某行，而远程也修改了同一行。
**如何处理**：

1. **不要慌**，Git只是暂停下来等你解决。

2. 冲突文件内会有 `<<<<<<< HEAD`、`=======`、`>>>>>>>` 标记，分别包裹了你本地的改动和远程的改动。

3. **手动编辑**这个文件，保留你想要的内容，并删除所有标记符号。

4. 解决所有冲突文件后，再继续你的正常工作流

当 `git pull` 后出现 `CONFLICT` 提示时，请按顺序执行：

```bash
# 1. 查看哪些文件冲突了（状态为 “both modified”）
git status

# 2. 手动打开并编辑这些文件
#    文件中会有 <<<<<<< HEAD, =======, >>>>>>> 标记
#    保留你想要的内容，并删除所有标记行

# 3. 标记冲突已解决，并完成合并提交
git add 冲突的文件名  # 或使用 git add . 添加所有
git commit -m “解决合并冲突”

# 4. 继续正常流程：推送并部署
git push origin hexo
hexo clean && hexo g -d
```

----



### 四、⚠️ 其他高阶场景与故障处理

#### **场景一：当你需要修改博客，但不在常用电脑旁**

1. 在任何一台临时电脑上，通过 `git clone -b hexo <仓库地址>` 克隆源码。
2. 修改、测试后，完成 **阶段三** 的提交推送。
3. 回到常用电脑时，在开始任何工作前，务必执行 **阶段一** 的 `git pull` 来同步这次紧急修复。

#### **场景二：推送失败，提示“非快进式推送”**

**原因**：在你准备推送前，远程仓库已有你本地没有的新提交（可能来自另一台电脑）。
**解决**：

```bash
# 1. 先拉取合并
git pull origin hexo
# 2. 解决可能出现的冲突（同场景一）
# 3. 再次推送
git push origin hexo
```

### 💎 最佳实践清单

1. **勤提交，勤推送**：完成一个逻辑改动（如一篇文章）就立即走完 **阶段三**，避免本地积攒大量改动，增加冲突概率和丢失风险。
2. **写清晰的提交信息**：`git commit -m “更新主题”` 远不如 `git commit -m “feat: 更新Next主题至v8.15.1，启用暗黑模式”` 有用。
3. **部署前先预览**：`hexo g -d` 前，养成 `hexo g && hexo s` 预览的习惯，避免有误的代码直接上线。
4. **善用 `.gitignore`**：确保 `node_modules/`、`public/`、`db.json` 等文件不被跟踪，仓库只保留真正的“源文件”。

遵循这份详尽的流程，你可以像使用云文档一样，在任何电脑上无缝接力管理你的Hexo博客。

### ⚠️ 常见问题与排查（实战经验总结）

在同步过程中，你可能会遇到以下问题：

1. **新电脑克隆后运行 `hexo s` 失败**
   - **症状**：`package.json` 不存在或命令未找到。
   - **原因**：克隆错了分支（如克隆了 `master` 分支）。
   - **解决**：使用 `git clone -b hexo <仓库地址>` 确保克隆源码分支。

2. **页面无样式、错乱或加载极慢**
   - **症状**：浏览器开发者工具控制台显示CDN资源（如jQuery, Fancybox）加载失败或 `MIME type` 错误。
   - **原因**：主题配置使用外部CDN，网络不佳；或主题本地资源缺失。
   - **解决**：
     - **修改主题配置**：在 `themes/你的主题/_config.yml` 中，将资源引用改为 `local` 或 `lib`。
     - **检查依赖**：确认已安装主题所需渲染器，如Next主题需 `hexo-renderer-stylus`。
     - **清理缓存**：执行 `hexo clean` 并**强制刷新浏览器**（`Ctrl + F5`）或使用无痕窗口。

3. **同步后新电脑内容未更新**

   - **症状**：执行了 `git pull`，但页面还是旧的。

   - **原因**：Git拉取未真正生效，或Hexo/浏览器缓存顽固。

   - **解决**：

```bash
# 强制重置到远程最新状态
git fetch --all
git reset --hard origin/hexo
# 彻底清理并重装依赖
hexo clean
rm -rf node_modules
npm install
```

4. **主题自定义修改未同步**

   - **症状**：在A电脑修改了主题配置或文件，B电脑未生效。

   - **原因**：主题文件夹可能包含内嵌的 `.git` 子模块，导致文件未被跟踪。

   - **解决**：在**主题文件夹内**删除 `.git` 目录（`rm -rf themes/主题名/.git`），然后将整个主题文件夹重新提交到主仓库。

### 💎 最佳实践与建议

1. **提交规范化**：每次提交信息清晰，如 `feat: 添加文章《XXX》`、`fix: 修复YYY样式问题`。
2. **环境一致性**：尽量保持各电脑间 **Node.js** 和 **Hexo** 主版本号一致，避免因环境差异产生意外问题。
3. **定期备份**：除了推送到GitHub，可定期将整个博客目录压缩备份至网盘，双重保险。
4. **文件完整性**：在主题配置中使用本地资源（`_internal: local`）而非CDN，能大幅提升生成和访问稳定性，避免网络因素干扰。

### ✅ 总结

通过上述基于Git双分支的流程，你可以在任何一台配置好环境的电脑上，随时开始写作、同步进度，并保持发布渠道的统一。关键在于：**源文件同步走 `hexo` 分支，网站部署走 `master` 分支**，并在日常操作中养成“先拉后推”的习惯。

希望这篇指南能帮助你和其他博主实现高效的多设备博客管理！如果你在实践中有新的发现或问题，欢迎在评论区交流。



本文参考：
