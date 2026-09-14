# Claude Code CLI 安装过程（Windows / 大陆网络）

> 更新时间：2026-09-14。本文基于实际踩坑总结：**官方脚本地址会 302 跳转，国内容易被墙**。
>
> 本文命令**同时给出 PowerShell 和 CMD 两种版本**，请按你当前窗口类型选用。

## 〇、先分清你的窗口类型

| 窗口 | 提示符 | 打开方式 |
|---|---|---|
| **PowerShell** | `PS C:\...>`（开头有 `PS `） | 开始菜单搜 "PowerShell" |
| **CMD**（命令提示符） | `C:\...>`（没有 `PS`） | 开始菜单搜 "cmd" |

> 在 CMD 里输 PowerShell 命令（如 `Remove-Item`、`irm`）会报「不是内部或外部命令」；在 PowerShell 里输 CMD 命令一般也能跑，但变量写法不同（`$env:` vs `%...%`），所以照下面的来最稳。

---

## 一、两种安装方式

### 方式 1：npm 安装（推荐，最通用）—— 两种窗口通用

**第一步：先装 Node.js（npm 的前提，一般电脑选 x64）**

1. 检查有没有装：
   ```cmd
   node -v
   ```
   - 有版本号（如 `v22.x.x`）→ 已经装好，跳过本步，直接进第二步
   - 提示「不是内部或外部命令」→ 还没装，继续

2. 下载安装包（二选一）：
   - **官方**：https://nodejs.org/zh-cn → 下载 **LTS 版**（长期支持，如 v22 / v24）的 `.msi`
   - **国内镜像（更快，推荐大陆）**：https://npmmirror.com/mirrors/node/ → 选最新 LTS，下载 `node-vXX.X.X-x64.msi`

3. 双击 `.msi` 安装：一路「下一步」即可（默认会装好 npm 并自动加 PATH）

4. **重开终端**，验证（两种窗口通用）：
   ```cmd
   node -v
   npm -v
   ```
   两条都有版本号 → Node.js 装好了

**第二步：安装 Claude Code（两种窗口通用）**

```powershell
npm install -g @anthropic-ai/claude-code
```
```cmd
npm install -g @anthropic-ai/claude-code
```
- ⚠️ 实测：**需要翻墙**，否则安装不成功，推荐使用这种方法
- 可选：先换国内 npm 源，让 npm 下载更快（**但注意**：claude-code 本体下载仍需要翻墙，换源不能完全代替梯子）：
  ```cmd
  npm config set registry https://registry.npmmirror.com
  ```

### 方式 2：官方脚本安装（自带运行时，不用装 Node）

**PowerShell 窗口：**
```powershell
irm https://claude.ai/install.ps1 | iex
```

**CMD 窗口（没有 irm，用 curl 下载）：**
```cmd
curl -o install.ps1 https://claude.ai/install.ps1
```

> ⚠️ 坑：`claude.ai/install.ps1` 会 **302 跳转**到 `https://downloads.claude.ai/claude-code-releases/bootstrap.ps1`（Google 存储域名）。跟随跳转时容易失败，`irm` 会拿到 claude.ai 首页 HTML，然后报一堆网页 JS 的语法错误（`var` / `in` / `&&` 等）。

**✅ 更稳的写法：跳过跳转，直接访问最终地址**

PowerShell：
```powershell
irm https://downloads.claude.ai/claude-code-releases/bootstrap.ps1 -OutFile install.ps1
Get-Content install.ps1 -TotalCount 3
powershell -ExecutionPolicy Bypass -File install.ps1
```
CMD：
```cmd
curl -o install.ps1 https://downloads.claude.ai/claude-code-releases/bootstrap.ps1
type install.ps1 | more
powershell -ExecutionPolicy Bypass -File install.ps1
```
- 验证：文件开头是 `param(...)` 才是脚本；是 `<html>` 说明又下载成网页了

**连通性测试（下载前先看通不通）：**
```powershell
Test-NetConnection downloads.claude.ai -Port 443
```
```cmd
curl -sI --max-time 8 https://downloads.claude.ai/claude-code-releases/bootstrap.ps1
```
- PowerShell 显示 `TcpTestSucceeded : False` / CMD 连不上 → 梯子规则没覆盖 Google 域名，改用方式 1（npm）

---

## 二、验证安装 —— 两种窗口通用

```powershell
claude --version
```
```cmd
claude --version
```
- 能显示版本 → 装好了
- 提示「不是内部或外部命令」→ PATH 没生效：
  1. 重开窗口（PATH 是启动时读取的）
  2. 查安装位置（两种通用）：
     ```powershell
     where.exe claude
     ```
     ```cmd
     where claude
     ```
  3. 手动加 PATH：

     PowerShell（用户级）：
     ```powershell
     [Environment]::SetEnvironmentVariable("Path", [Environment]::GetEnvironmentVariable("Path","User") + ";$env:USERPROFILE\.local\bin", "User")
     ```
     CMD（用 setx，注意 setx 有 1024 字符上限，超长会截断）：
     ```cmd
     setx Path "%Path%;%USERPROFILE%\.local\bin"
     ```

---

## 三、卸载（干净重装用）

**卸载 npm 版 —— 两种通用：**
```powershell
npm uninstall -g @anthropic-ai/claude-code
```
```cmd
npm uninstall -g @anthropic-ai/claude-code
```

**删除官方脚本版安装的文件：**

PowerShell：
```powershell
Remove-Item -Recurse -Force "$env:USERPROFILE\.local\bin\claude*"
```
CMD：
```cmd
del /s /q "%USERPROFILE%\.local\bin\claude*"
```

**清配置（可选，会清掉登录状态）：**

PowerShell：
```powershell
Remove-Item -Recurse -Force "$env:USERPROFILE\.claude"
Remove-Item -Force "$env:USERPROFILE\.claude.json"
```
CMD：
```cmd
rd /s /q "%USERPROFILE%\.claude"
del /q "%USERPROFILE%\.claude.json"
```

**确认卸载干净（两种通用）：**
```powershell
where.exe claude
```
```cmd
where claude
```
（此时应提示找不到）

---

## 四、启动与登录（必须三选一）—— 启动命令两种通用

```powershell
claude
```
```cmd
claude
```

| 方式 | 做法 | 要配环境变量吗 |
|---|---|---|
| 订阅登录（Pro/Max） | 启动后输 `/login`，浏览器登录 | ❌ 不用 |
| API Key | 设 `ANTHROPIC_API_KEY` | ✅ 要 |
| 接火山方舟（国内省钱） | 设 `ANTHROPIC_BASE_URL` / `ANTHROPIC_AUTH_TOKEN` / `ANTHROPIC_MODEL` | ✅ 要 |

**设置环境变量：**

永久（用户级）——
PowerShell：
```powershell
[Environment]::SetEnvironmentVariable("ANTHROPIC_API_KEY", "你的key", "User")
```
CMD：
```cmd
setx ANTHROPIC_API_KEY "你的key"
```

只对当前窗口有效——
PowerShell：
```powershell
$env:ANTHROPIC_API_KEY = "你的key"
```
CMD：
```cmd
set ANTHROPIC_API_KEY=你的key
```

---

## 五、结论

- **大陆装 Claude Code，无论哪种方式基本都要翻墙**
- 官方脚本地址会跳转到 Google 存储域名（`downloads.claude.ai`），容易被墙 → 直接访问最终地址
- 打开 `claude` **不需要**配环境变量（安装脚本自动加 PATH）；但**登录/接模型**时需要

---

## 六、进阶：安装 cc-switch（图形化切换模型 / 一键接火山方舟）

cc-switch 是一个**桌面小工具**（Win/macOS/Linux），用来**可视化地切换** Claude Code / Codex / OpenCode / OpenClaw 等智能体的模型提供方。装好后不用手敲 `set` / `setx` 环境变量，填一次配置，以后一键切换。

> ⚠️ 注意：cc-switch **不能翻墙**。它只负责"让 claude 用哪个模型"，不负责"网络通不通"。连 Anthropic 官方依然需要梯子；接火山方舟（国内直连）才能真正绕开 403。

### 1. 下载（v3.20.3，2026-09-11）

GitHub Releases 主页：https://github.com/farion1231/cc-switch/releases

| 用途 | 文件 | 直接下载 |
|---|---|---|
| **x64 安装版（推荐，一般电脑）** | `CC-Switch-v3.20.3-Windows.msi` | https://github.com/farion1231/cc-switch/releases/download/v3.20.3/CC-Switch-v3.20.3-Windows.msi |
| x64 免安装版（解压即用） | `CC-Switch-v3.20.3-Windows-Portable.zip` | https://github.com/farion1231/cc-switch/releases/download/v3.20.3/CC-Switch-v3.20.3-Windows-Portable.zip |
| ARM 版（罕见） | `CC-Switch-v3.20.3-Windows-arm64.msi` | https://github.com/farion1231/cc-switch/releases/download/v3.20.3/CC-Switch-v3.20.3-Windows-arm64.msi |

> ⚠️ 从 GitHub 下载需要翻墙。查电脑是 x64 还是 ARM：CMD 里 `echo %PROCESSOR_ARCHITECTURE%`，显示 `AMD64` 就是普通 x64，用第一个。

### 2. 安装
- `.msi` 版：双击 → 下一步 → 完成
- `Portable.zip` 版：解压到任意文件夹，双击里面的 exe 即可，免安装

### 3. 配置接火山方舟（解决 403 的可视化做法）
1. 打开 cc-switch → 找到 **Claude Code** 一栏
2. **新建 provider**，取名如「火山方舟」，填：
   - Base URL：`https://ark.cn-beijing.volces.com/api/coding`
   - API Key：你的火山方舟 key
   - 模型 Model：`deepseek-v4-pro`
   - 小模型 Small/Fast Model：`deepseek-v4-flash-260731`
3. 点「**切换**」→ 它会自动写进 Claude Code 的配置
4. 运行 `claude` → 不再报 403

### 4. 它支持哪些智能体
Claude Code、Claude Desktop、Codex、Gemini CLI、Grok Build、OpenCode、OpenClaw、Hermes Agent 共 8 种（具体以版本界面为准）。
