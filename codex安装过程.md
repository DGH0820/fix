# Codex 安装过程（Windows / 大陆网络）

> 更新时间：2026-09-14。Codex 是 OpenAI 的编程智能体，有 **CLI（终端）** 和 **App（桌面图形界面）** 两种形态，**二选一即可**，也可加装 IDE 扩展。
>
> ⚠️ 所有命令在 **PowerShell**（`PS C:\...>`）或 **CMD**（`C:\...>`）里运行都行（标注除外）；**Codex 需要 OpenAI 账号，大陆使用必须翻墙**。

## 〇、先分清两种形态，挑一个

| | **Codex CLI**（终端） | **Codex App**（桌面 App） | **IDE 扩展**（可选加装） |
|---|---|---|---|
| 形态 | 命令行，`codex` 命令 | 图形界面，点鼠标 | 装进 VS Code / Cursor / Windsurf |
| 适合 | 开发者、要脚本化/自动化 | 新手、喜欢可视化看 diff | 想一边写代码一边用 |
| 推荐度 | ⭐ 推荐先装 | 想用 GUI 就装 | 锦上添花 |
| 官方页 | — | openai.com/codex | developers.openai.com/codex/ide |

> 功能有重叠，**不用两个都装**。要教学演示、要复制命令给别人 → 装 CLI；要图形界面 → 装 App。

---

## 一、CLI 安装（推荐）

### 方式 A：官方脚本（自带运行时，不用装 Node）—— 最省事

Windows（PowerShell）：
```powershell
powershell -ExecutionPolicy ByPass -c "irm https://chatgpt.com/codex/install.ps1 | iex"
```
Windows（CMD）：
```cmd
powershell -ExecutionPolicy ByPass -c "irm https://chatgpt.com/codex/install.ps1 | iex"
```
Mac / Linux：
```bash
curl -fsSL https://chatgpt.com/codex/install.sh | sh
```
- 安装文件默认从 `https://releases.openai.com/codex` 下载，连不上会自动回退到 GitHub Releases
- ⚠️ 这两个地址（chatgpt.com / releases.openai.com）大陆都需要翻墙

### 方式 B：npm 安装（需要先装 Node.js）

```cmd
npm install -g @openai/codex
```
- 前提：已装 Node.js（没装的话，步骤和「claude-code-CIL安装过程.md」里 Node.js 安装一样：nodejs.org 或 npmmirror 下载 LTS 的 .msi）
- ✅ 实测（2026-09-14）：**先换 npmmirror 源，不需要翻墙即可安装成功**
- ⚠️ 但 codex **运行**时登录/调用 OpenAI 服务仍需要翻墙

**常见问题：npm 报 `ECONNRESET` / 连不上 registry.npmjs.org**

> 这个报错**非常常见**：大陆直连 npm 官方源不稳定/被墙，装**任何** npm 包都可能遇到，不是 codex 的问题。
> 解决：**换国内镜像**（最快最稳，跨平台通用）：
> ```cmd
> npm config set registry https://registry.npmmirror.com
> ```
> 然后重新安装：`npm install -g @openai/codex`
>
> 相关命令：
> - 查看当前源：`npm config get registry`（应显示 npmmirror.com）
> - 改回官方源：`npm config set registry https://registry.npmjs.org`
> - 用代理装（备选，Windows CMD）：
>   ```cmd
>   set HTTPS_PROXY=http://127.0.0.1:7897
>   set HTTP_PROXY=http://127.0.0.1:7897
>   npm install -g @openai/codex
>   ```
>
> ⚠️ 注意：换源只解决「下载包」，codex **运行**时连 OpenAI 服务仍需要翻墙。

### 方式 C：Mac 用户用 brew

```bash
brew install --cask codex
```

### 验证安装

```cmd
codex --version
```
- 有版本号 → 装好了
- 提示「不是内部或外部命令」→ PATH 没生效：重开终端 / `where codex` 查位置

---

## 二、App（桌面图形界面）安装

1. 打开官网：https://openai.com/codex
2. 找 **Download**，选你系统的安装包（Windows / macOS）
3. 双击安装
4. 打开后 **登录 ChatGPT 账号**即可使用

> ⚠️ 官网和登录都需要翻墙；App 是独立软件，装之前电脑也要能访问 OpenAI 服务。

---

## 三、IDE 扩展（可选）

在 VS Code / Cursor / Windsurf 里装 **Codex** 扩展（官方地址：developers.openai.com/codex/ide），装完在编辑器侧边栏直接用。

---

## 四、启动与登录（CLI，必须二选一）

```cmd
codex
```

| 方式 | 做法 | 说明 |
|---|---|---|
| **ChatGPT 登录** | 启动后 `/login`，浏览器登录账号 | 免费/付费账号都能用，按额度计费 |
| **OpenAI API Key** | 设 `OPENAI_API_KEY` 环境变量 | 按 API 用量计费 |

设置 API Key（CMD 永久）：
```cmd
setx OPENAI_API_KEY "你的key"
```
（当前窗口临时用 `set OPENAI_API_KEY=你的key`）

> ⚠️ 无论哪种登录，**都要能访问 OpenAI 服务（需翻墙）**。想在国内直连用便宜模型，可以研究第三方中转，但官方不保证支持。

---

## 五、卸载

**CLI：**
```cmd
npm uninstall -g @openai/codex
```
或删原生脚本装的位置（一般在 `%USERPROFILE%\.local\bin`）：
```cmd
del /s /q "%USERPROFILE%\.local\bin\codex*"
```
清配置（可选）：
```cmd
del /s /q "%USERPROFILE%\.codex"
```

**App：** 开始菜单 → 右键 Codex → 卸载（或「设置 → 应用 → Codex → 卸载」）

---

## 六、结论

- **CLI + App 二选一**，推荐先装 CLI（和 Claude Code 玩法一致，方便教学）
- 想用图形界面再装 App；两个都装没必要
- **大陆用 Codex 必须翻墙**（比 Claude 还严格：openai.com、chatgpt.com、api.openai.com 全被墙）——这里指**使用**（登录/调 API）；**安装**走 npm + npmmirror 源实测可免翻墙
- 配置上只需要 OpenAI 账号（`/login`）或 API Key，比 Claude 简单——它没有"接第三方模型"的官方路径
