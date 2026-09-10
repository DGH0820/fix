# 流行大模型 CLI 工具下载/安装指南（汇总版）

> 整理日期：2026-09-07
> 覆盖工具：
> - 国外系：**Claude Code（claude）**、**Anthropic API CLI（ant）**、**OpenAI Codex CLI（codex）**、**Gemini CLI（gemini）**、**GitHub Copilot CLI（copilot）**、**OpenCode**、**aider**、**Goose**
> - 国内系：**Qwen Code（qwen）**、**DeepSeek（API）**、**DeepSeek Harness（dsh）**、**智谱 ZCode**、**Ollama（本地模型）**
> - 附带：**模型 API 导入/管理工具**推荐（One API / new-api / LiteLLM / Cherry Studio / 硅基流动等）
> - 所有命令均来自各官方文档/仓库；安装方法请以官方最新文档为准。

---

## 0. 工具总览

| 工具 | 一行安装（最简版） | 认证/模型 | 中国大陆需翻墙？ |
|---|---|---|---|
| **Claude Code** | `curl -fsSL https://claude.ai/install.sh \| bash` | Claude 订阅 / API Key / 云厂商 | ✅ 需要 |
| **Codex CLI** | `curl -fsSL https://chatgpt.com/codex/install.sh \| sh` | ChatGPT 订阅 / API Key | ✅ 需要 |
| **Gemini CLI** | `npm install -g @google/gemini-cli` | Google 账号 / API Key | ✅ 需要 |
| **Copilot CLI** | `curl -fsSL https://gh.io/copilot-install \| bash` | GitHub + Copilot 订阅 | ⚠️ 部分需要 |
| **OpenCode** | `curl -fsSL https://opencode.ai/install \| bash` | 多 Provider（含 DeepSeek/Ollama） | ⚠️ 看模型 |
| **aider** | `pipx install aider-chat` | 多 Provider（含 DeepSeek/Ollama） | ⚠️ 看模型 |
| **Goose** | `curl -fsSL .../goose/.../download_cli.sh \| bash` | 15+ Provider | ⚠️ 看模型 |
| **Qwen Code** | `curl -fsSL https://qwen-code-assets.oss-cn-hangzhou.aliyuncs.com/...\| bash` | 阿里云百炼 / 多 Provider | ❌ 国内直连 |
| **DeepSeek（API）** | 无独立 CLI，OpenAI 兼容 API | platform.deepseek.com | ❌ 国内直连 |
| **DeepSeek Harness（dsh）** | `npx @deepseek-ai/dsh web` | Web UI 智能体平台 / 插件化 | ❌ 国内直连 |
| **智谱 ZCode** | 官网 zcode.z.ai 下载桌面版 | GLM-5.3 / GLM 订阅 | ❌ 国内直连 |
| **Ollama（本地）** | `curl -fsSL https://ollama.com/install.sh \| sh` | 本地模型，无需账号 | ❌ 完全本地 |

> **一句话选型**
> - 想免翻墙：Qwen Code、智谱 ZCode、DeepSeek API/Harness、Ollama 本地模型，或把这些国内 API 塞进 OpenCode/aider 里用。
> - 愿意翻墙+境外卡：Claude Code、Codex CLI 体验最好；Copilot CLI 门槛最低（有 GitHub 账号即可）。
> - 注意：**Claude Code 和 Claude CLI 常被混用，官方其实是两个产品**，见第 3 节。

---

## 0.1 核心概念：Agent 工具 ≠ 模型，先配好 API 才能调用

本指南里的工具（Claude Code / Codex / Qwen Code / aider 等）都是**客户端/智能体**，**本身不包含模型**，只是"会调用模型的壳"。想真正用起来，永远分两步：

1. **先搞到模型 API 凭据**（二选一）：
   - **订阅套餐（月费制）**：Claude Pro / ChatGPT Plus / GLM Coding Plan 等 → 在工具内浏览器登录即可，官方模型自动配好，**通常不用手动填 Key**
   - **API Key（按量计费）**：在模型平台开发者后台注册 → 充值 → 创建 Key（形如 `sk-xxx`）→ 手动填进工具
2. **再配置进工具**：环境变量（如 `ANTHROPIC_API_KEY`、`OPENAI_API_KEY`）或工具内配置页（如 qwen 的 `/auth`、Cherry Studio 的"添加服务商"、aider 的 `--api-key`）。

完整调用链路：

```
模型平台注册/充值 → 创建 API Key（可能还要改 Base URL）
        ↓
把 Key / Base URL 填进 Agent 工具（环境变量 or 配置页）
        ↓
运行工具 → 工具用你的凭据向模型 API 发请求 → 返回结果
```

**照着做就能跑的具体例子：**
- **Claude Code**：买了订阅 → `claude` 直接浏览器登录；或去 platform.claude.com 拿 Key → `export ANTHROPIC_API_KEY=sk-ant-xxx` → `claude`
- **Codex**：ChatGPT 订阅 → `codex login`；或 `printenv OPENAI_API_KEY | codex login --with-api-key`
- **DeepSeek + aider**：platform.deepseek.com 充值拿 Key → `aider --model deepseek --api-key deepseek=sk-xxx`
- **Qwen Code**：阿里云百炼拿 Key → `qwen` → 会话内 `/auth` 填写
- **多模型统一**：Cherry Studio 里逐个"添加服务商"填各家 Key；或用 One API 聚合后给一个地址（见第 13 节）

> 一句话：**没配好某个模型的 API，工具就无模型可用**——工具负责"干活"，模型 API 负责"出脑子"。

---

## 1. Claude Code（`claude`）

Anthropic 官方的终端编码智能体，目前最流行的 AI 编码 CLI。

### 1.1 系统要求
- macOS 13.0+ / Windows 10 1809+ / Ubuntu 20.04+ / Debian 10+ / Alpine 3.19+
- 内存 4GB+，x64 或 ARM64
- 用 npm 方式安装才需要 Node.js（**v2.1.198 起要求 Node 22+**）；原生安装包运行时不依赖 Node

### 1.2 安装方法（任选其一）

**方法 A：官方原生安装脚本（推荐，自动更新）**
```bash
# macOS / Linux / WSL
curl -fsSL https://claude.ai/install.sh | bash

# Windows PowerShell
irm https://claude.ai/install.ps1 | iex

# Windows CMD
curl -fsSL https://claude.ai/install.cmd -o install.cmd && install.cmd && del install.cmd
```
- 默认装到 `~/.local/bin/claude`，后台自动更新
- 指定通道/版本：`curl -fsSL https://claude.ai/install.sh | bash -s stable`（或版本号如 `2.1.89`）

**方法 B：npm 全局安装**
```bash
npm install -g @anthropic-ai/claude-code
```
- ⚠️ 不要用 `sudo npm install -g`
- 国内可配 npm 镜像加速**下载**，但**实际使用仍需代理**（见 1.5）

**方法 C：Homebrew（macOS）**
```bash
brew install --cask claude-code          # 稳定通道（约落后 1 周）
brew install --cask claude-code@latest   # 最新通道
```

**方法 D：WinGet（Windows）**
```powershell
winget install Anthropic.ClaudeCode
```

**方法 E：Linux 包管理器（apt / dnf / apk）**
- 官方签名仓库：`downloads.claude.ai/claude-code/apt|rpm|apk`（stable / latest 通道），完整命令见官方 setup 文档

**验证安装：**
```bash
claude --version   # 例：2.1.211 (Claude Code)
claude doctor      # 健康检查
```

### 1.3 登录/认证
需要 **Claude Pro / Max / Team / Enterprise 订阅**，或 **Claude Console（platform.claude.com）账号**（免费版 claude.ai 不含 Claude Code）。

```bash
claude   # 首次运行 → 浏览器 OAuth 登录 claude.ai
```
- **API Key 方式**（按量计费）：
  ```bash
  export ANTHROPIC_API_KEY="sk-ant-..."
  claude
  ```
  Key 在 platform.claude.com 获取；设置后优先于订阅登录。
- **云厂商接入**（企业可避开直连封禁，见 1.5）：Bedrock（`CLAUDE_CODE_USE_BEDROCK`）、Vertex（`CLAUDE_CODE_USE_VERTEX`）、Foundry（`CLAUDE_CODE_USE_FOUNDRY`）
- **网关/代理 API**：`ANTHROPIC_BASE_URL` 指向第三方网关，`ANTHROPIC_AUTH_TOKEN` 传 Bearer token

认证优先级（从高到低）：云厂商 → `ANTHROPIC_AUTH_TOKEN` → `ANTHROPIC_API_KEY` → 订阅登录。

### 1.4 更新
```bash
claude update                        # 原生安装：手动更新（默认后台自动更新）
npm install -g @anthropic-ai/claude-code@latest   # npm 方式
brew upgrade claude-code             # Homebrew
winget upgrade Anthropic.ClaudeCode  # WinGet
sudo apt upgrade claude-code         # apt
```
- 关闭自动更新：`DISABLE_AUTOUPDATER=1`

### 1.5 中国大陆使用 / 翻墙说明 ⚠️
- **Anthropic 不向中国大陆提供服务**：claude.ai 注册/支付仅限支持的国家地区，中国大陆（通常香港 IP 也被拦）的 API 请求会被封。
- 使用前提：**① 代理/VPN；② 非大陆支付方式**（境外信用卡）用于订阅或充值 API。
- 代理配置：Claude Code 支持 `HTTPS_PROXY` / `HTTP_PROXY`（**不支持 SOCKS**）：
  ```bash
  export HTTPS_PROXY="http://127.0.0.1:7890"
  export HTTP_PROXY="http://127.0.0.1:7890"
  ```
  自定义 CA 证书：`NODE_EXTRA_CA_CERTS=/path/to/ca.pem`
- 需放行域名：`api.anthropic.com`、`claude.ai`、`claude.com`、`platform.claude.com`、`downloads.claude.ai`（npm 方式还要 `registry.npmjs.org`）
- **替代路线**：① 走云厂商 Bedrock / Vertex / Foundry；② 走 LLM 网关（`ANTHROPIC_BASE_URL`）；③ 见第 7 节，把国内 API 接进 OpenCode/aider 用。

---

## 2. OpenAI Codex CLI（`codex`）

OpenAI 官方的终端编码智能体。

### 2.1 系统要求
- 支持 macOS / Linux / Windows
- npm 方式需要 Node.js 18+

### 2.2 安装方法（任选其一）

**方法 A：官方安装脚本（推荐）**
```bash
# macOS / Linux
curl -fsSL https://chatgpt.com/codex/install.sh | sh

# Windows PowerShell
powershell -ExecutionPolicy ByPass -c "irm https://chatgpt.com/codex/install.ps1 | iex"
```
- 默认从 `https://releases.openai.com/codex` 下载，失败时回退 GitHub Releases
- 强制走 GitHub Releases：`CODEX_INSTALLER_USE_RELEASES_OPENAI_COM=false`

**方法 B：npm 全局安装**
```bash
npm install -g @openai/codex
```

**方法 C：Homebrew（macOS）**
```bash
brew install --cask codex
```

**方法 D：GitHub Releases 二进制**
- https://github.com/openai/codex/releases ，下载对应平台包解压后重命名为 `codex` 加入 PATH：
  - macOS 苹果芯片：`codex-aarch64-apple-darwin.tar.gz`
  - macOS Intel：`codex-x86_64-apple-darwin.tar.gz`
  - Linux x64：`codex-x86_64-unknown-linux-musl.tar.gz`
  - Linux arm64：`codex-aarch64-unknown-linux-musl.tar.gz`

### 2.3 登录/认证
需要 **ChatGPT 订阅（Plus / Pro / Business / Edu / Enterprise）**，或 **OpenAI API Key**（按量计费）。

```bash
codex                     # 首次运行自动引导登录
codex login               # 主动触发浏览器登录（ChatGPT 账号，推荐）
codex login status        # 查看当前认证方式
codex logout              # 退出登录
```
- **API Key 方式**：
  ```bash
  printenv OPENAI_API_KEY | codex login --with-api-key
  ```
  Key 在 platform.openai.com/api-keys 获取；用 API Key 时部分依赖 ChatGPT 工作区的功能不可用。
- **企业/自动化**：`CODEX_ACCESS_TOKEN` + `codex login --with-access-token`
- **无头服务器**：`codex login --device-auth`（设备码，beta）或拷贝 `~/.codex/auth.json`
- 代理相关：`CODEX_CA_CERTIFICATE` 指定企业 TLS 代理自签 CA；凭据默认存 `~/.codex/auth.json`

### 2.4 更新
```bash
npm install -g @openai/codex@latest   # npm 方式
brew upgrade --cask codex             # Homebrew
# 或重新执行安装脚本
```

### 2.5 中国大陆使用 / 翻墙说明 ⚠️
- **OpenAI 同样不支持中国大陆**：账号注册、ChatGPT 登录、API 请求均受地区限制。
- 使用前提：**① 代理/VPN；② 非大陆支付方式**。
- 需放行域名：`chatgpt.com`、`openai.com`、`api.openai.com`、`releases.openai.com`（或 GitHub Releases）
- 代理配置（设置系统/环境代理即可）：
  ```bash
  export HTTPS_PROXY="http://127.0.0.1:7890"
  export HTTP_PROXY="http://127.0.0.1:7890"
  ```

---

## 3. 补充：Claude CLI 与 `ant`（Anthropic API CLI）

| 名称 | 作用 | 安装 |
|---|---|---|
| **`claude`（Claude Code）** | 终端编码智能体 | 见第 1 节，`curl -fsSL https://claude.ai/install.sh \| bash` 装的就是它 |
| **`ant`（Anthropic API CLI）** | 直接调 Claude API 的 CLI（`ant messages create ...` 等） | `brew install anthropics/tap/ant`（macOS）；Linux 从 github.com/anthropics/anthropic-cli/releases 下载；或 `go install github.com/anthropics/anthropic-cli/cmd/ant@latest`（Go 1.25+） |

- `ant` 登录：`ant auth login`
- 文档：https://platform.claude.com/docs/en/cli-sdks-libraries/cli/quickstart
- ⚠️ 2025 年初曾有一个名为 `@anthropic-ai/claude-cli` 的旧 npm 包，现已不推荐，官方只认 `@anthropic-ai/claude-code`。

---

## 4. Gemini CLI（`gemini`，谷歌）

### 安装
```bash
npx @google/gemini-cli            # 免安装直接跑
npm install -g @google/gemini-cli # 全局安装
brew install gemini-cli           # macOS/Linux
sudo port install gemini-cli      # macOS (MacPorts)
```

### 登录
```bash
gemini   # 选择 "Sign in with Google" 走浏览器 OAuth
```
- 免费档：60 次请求/分钟、1000 次请求/天，无需管理 API Key
- 组织可用 `GOOGLE_CLOUD_PROJECT` 指定项目（Code Assist 许可）

### 更新
```bash
npm install -g @google/gemini-cli@latest    # 稳定版（每周二更新）
npm install -g @google/gemini-cli@preview   # 预览版
npm install -g @google/gemini-cli@nightly   # 每日版（不稳定）
```

### 中国大陆使用 / 翻墙说明
- Google 服务在大陆被屏蔽，Google 账号 OAuth 登录需要代理。
- 备选：用 Gemini API Key（需境外 Google 云账号/支付）配合 `GEMINI_API_KEY`。

---

## 5. GitHub Copilot CLI（`copilot`）

### 安装
```bash
curl -fsSL https://gh.io/copilot-install | bash    # macOS/Linux（root 加 sudo 装到 /usr/local/bin）
brew install copilot-cli                           # Homebrew
winget install GitHub.Copilot                      # Windows
npm install -g @github/copilot                     # 全平台
```

### 登录
```bash
copilot   # 未登录时按提示执行 /login 走 GitHub 浏览器授权
```
- 需有效的 **Copilot 订阅**
- 或用细粒度 PAT（需 "Copilot Requests" 权限）设置 `GH_TOKEN` / `GITHUB_TOKEN`

### 中国大陆使用 / 翻墙说明
- GitHub 大陆一般可直连（偶有不稳），登录通常不需翻墙。
- 但 **Copilot 订阅/付费有地区限制**，直连质量不稳定，建议挂代理更稳妥。

---

## 6. Qwen Code（`qwen`，阿里）

阿里巴巴的开源终端编码智能体（Apache-2.0），**国内直连可用，无需翻墙**，是中国大陆最顺手的 AI 编码 CLI。

### 安装
```bash
# macOS / Linux 官方脚本
curl -fsSL https://qwen-code-assets.oss-cn-hangzhou.aliyuncs.com/installation/install-qwen-standalone.sh | bash

# Windows PowerShell
irm https://qwen-code-assets.oss-cn-hangzhou.aliyuncs.com/installation/install-qwen-standalone.ps1 | iex

# npm（需 Node.js 22+）
npm install -g @qwen-code/qwen-code@latest

# Homebrew
brew install qwen-code
```
- 装完重启终端使环境变量生效。

### 配置模型
```bash
qwen        # 打开终端界面
/auth       # 在会话内配置 Provider 和 API Key
```
- 多协议：**支持 OpenAI、Anthropic、Gemini、Qwen API**，也支持 Ollama / vLLM 本地模型，运行时可切换。
- 国内使用：在 `/auth` 里填阿里云百炼的 API Key 即可直连；也支持接 DeepSeek。

### 更新 / 其他
- 更新：重新执行安装脚本或 `npm install -g @qwen-code/qwen-code@latest`
- 另有 VS Code / Zed / JetBrains 插件和 Qwen Code Desktop 桌面版（GitHub Releases）。
- 文档：https://qwenlm.github.io/qwen-code/

---

## 7. DeepSeek（`deepseek`，API 接入）

**DeepSeek 官方没有独立的编码 CLI**（GitHub 上是内核/框架类基础设施）。它靠 **OpenAI 兼容 API** 接入各种现有工具，是国内唯一既免翻墙、又能用人民币直接充值的顶流模型方案。

### 怎么用（接入其他工具）
1. 去 https://platform.deepseek.com 注册并充值（**支付宝/微信支付**），创建 API Key。
2. API Base URL：`https://api.deepseek.com`（或 `https://api.deepseek.com/v1`），模型名以官方平台为准（历史上如 `deepseek-chat`、`deepseek-reasoner`）。
3. 在下列工具里填 DeepSeek 的 Base URL + Key：
   - **aider**：`aider --model deepseek --api-key deepseek=<key>`（官方直接支持）
   - **OpenCode / Cline / Roo Code / Continue**：Provider 选 DeepSeek 或自定义 OpenAI 兼容端点
   - **Claude Code / Codex**：不能直接填，需经 LLM 网关（如 One API、new-api、LiteLLM 等）把 DeepSeek 转成 Anthropic/OpenAI 兼容协议
   - **Cherry Studio** 等桌面客户端直接支持
4. 官方集成清单：https://github.com/deepseek-ai/awesome-deepseek-integration

### 中国大陆使用
- ✅ **无需翻墙**，国内直连，人民币充值——是"国内零门槛用上顶级模型"的首选。
- 缺点：无独立 CLI（官方层面的编码 CLI），配置略繁琐；高峰时段可能限流。

### 7.5 DeepSeek Harness（`dsh`，官方智能体平台）
DeepSeek 官方开源的 Agent Harness，口号 **"Everything is a Plugin"**（一切皆插件），基于 Cordis 架构，通过 Web UI 使用，**国内直连**。

```bash
# 免安装直接跑（需要 Node.js）
npx @deepseek-ai/dsh web

# 或从源码构建
git clone https://github.com/deepseek-ai/deepseek-harness.git
cd deepseek-harness
pnpm install && pnpm run build
pnpm dsh web
```
- 启动后默认打开 Web UI：`http://127.0.0.1:3080`（加 `--no-open` 不自动开浏览器）
- 模型、工具、Provider 都以插件形式通过 Cordis 组合装配，插件话题见 GitHub 的 `dsh-plugin`
- ⚠️ 当前为 **developer preview**，官方声明可能有破坏性变更
- 文档：https://deepseek-harness.github.io/deepseek-harness/
- 许可证：MIT

---

## 8. Ollama（本地模型，离线）

在本地跑开源大模型的运行时，**完全离线、无需翻墙、无需账号**，还能给其他 CLI 当后端。

### 安装
```bash
# macOS / Linux
curl -fsSL https://ollama.com/install.sh | sh

# Windows PowerShell
irm https://ollama.com/install.ps1 | iex
# 或手动下载 OllamaSetup.exe

# Docker
docker run -d -v ollama:/root/.ollama -p 11434:11434 --name ollama ollama/ollama
```

### 拉取并运行模型
```bash
ollama run qwen3        # 例：拉取并聊天（模型名以 ollama.com/library 为准）
ollama list             # 查看已下载模型
ollama pull <model>     # 只下载不运行
ollama serve            # 启动 API 服务（默认端口 11434）
```

### 给其他工具当后端
- Ollama 提供 OpenAI 兼容端点：`http://localhost:11434/v1`
- Claude Code / Codex / OpenCode / aider 等均可指向该端点使用本地模型。
- 硬件要求：跑 7B/8B 级模型建议 8GB+ 显存（或内存足够可跑 CPU 版）；模型越大要求越高。

### 中国大陆使用
- ✅ 完全本地运行，无需翻墙。
- ⚠️ 拉取模型走 GitHub/模型服务器，国内偶尔要加速（可配置镜像源或代理）。

---

## 9. OpenCode（`opencode`）

开源终端编码智能体，支持多 Provider，**可作为国内 API 的轻量入口**。

### 安装
```bash
curl -fsSL https://opencode.ai/install | bash          # 一键脚本
npm i -g opencode-ai@latest                            # npm
brew install anomalyco/tap/opencode                    # macOS/Linux（推荐，常更新）
scoop install opencode                                 # Windows
sudo pacman -S opencode                                # Arch
nix run nixpkgs#opencode                               # Nix
```
- 安装目录优先级：`$OPENCODE_INSTALL_DIR` > `$XDG_BIN_DIR` > `$HOME/bin` > `$HOME/.opencode/bin`

### 配置
- 支持 Anthropic / OpenAI / Gemini / OpenCode Zen / 本地模型等；内置 build（默认）/ plan / general 三种 agent，Tab 切换。
- 文档：https://opencode.ai/docs
- **国内使用**：可配置 DeepSeek 或 Ollama 端点，免翻墙；若用 Anthropic/OpenAI 则需代理。

---

## 10. aider（`aider`）

老牌开源 AI 结对编程工具（Python），**多模型、轻量**，直连 DeepSeek 是国内常用组合。

### 安装
```bash
# 推荐：pipx（隔离环境）
pipx install aider-chat

# 或 pip / uv
pip install aider-chat
uv tool install aider-chat

# 或官方安装器
python -m pip install aider-install
aider-install

# 或 Homebrew
brew install aider
```
- 需要 Python 3.10+（较新版本要求 3.10–3.14 区间，以官方为准）

### 使用
```bash
cd /path/to/project
aider --model sonnet --api-key anthropic=<key>     # 用 Claude
aider --model deepseek --api-key deepseek=<key>    # 用 DeepSeek（国内直连）
aider --model o3-mini --api-key openai=<key>       # 用 OpenAI
```
- 更新：`aider --update`，或用 pip/pipx 重装
- 文档：https://aider.chat/docs/

---

## 11. Goose（Block 开源 AI Agent）

支持 15+ Provider、70+ MCP 扩展的通用 Agent。

### 安装
```bash
# macOS / Linux（官方脚本，以下载页为准）
curl -fsSL https://github.com/aaif-goose/goose/releases/download/stable/download_cli.sh | bash
```
- 另有 macOS / Linux / Windows 桌面版（官网下载）和 PowerShell 脚本
- 支持 Anthropic / OpenAI / Google / Ollama / OpenRouter / Azure / Bedrock 等
- 文档：https://goose-docs.ai

---

## 12. 智谱 ZCode（智谱 AI）

智谱出品的**桌面 AI 编程应用**（官网自称 "GLM-5.3 官方 Harness"，"新一代氛围编程工具"），多智能体协作，**国内直连可用**。

### 安装/下载（Electron 桌面应用，官网下载）
- 官网：https://zcode.z.ai
- 直接下载示例（v3.11.2，以官网最新版本为准，CDN 前缀 `https://cdn-zcode.z.ai/zcode/electron/releases/`）：
  - macOS 苹果芯片：`.../3.11.2/macos-arm64/ZCode-3.11.2-mac-arm64.dmg`
  - macOS Intel：`.../3.11.2/macos-x64/ZCode-3.11.2-mac-x64.dmg`
  - Windows x64：`.../3.11.2/windows-x64/ZCode-3.11.2-win-x64.exe`
  - Linux x64 / arm64：`.deb / .rpm / .AppImage`（Linux 标注 Beta）
- 插件市场：https://github.com/zai-org/zcode-plugins（应用内置官方插件市场，在插件管理器里直接装）
- 反馈渠道：https://github.com/zai-org/feedback

### 模型与付费
- 针对 **GLM-5.3** 深度优化；**GLM-5.3-Flash** 支持截图理解、看图分析等多模态任务
- 功能：任务/目标系统、终端面板、命令面板、工作区技能、可通过**微信/飞书/Telegram 远程唤起**
- 付费走 **GLM Coding Plan**（BigModel.cn 订阅页，价格以官方为准）：
  - **Lite**：¥94.4/月，周 1 万额度，支持 ZCode、Claude Code 及 20+ 编码工具
  - **Pro**：¥430.4/月，Lite 的 6 倍额度，优先新模型，含 MCP 工具
  - **Max**：¥862.4/月，Lite 的 14 倍额度，旗舰模型首发

### 中国大陆使用
- ✅ 国内直连，官网/CDN（cdn-zcode.z.ai）下载，**无需翻墙**；订阅用微信/支付宝。

---

## 13. 模型 API 导入/管理工具推荐

目标：把**多家模型 API 统一管理**，或喂给 Claude Code / Codex / aider / OpenCode 等 CLI，或在一个客户端里自由切换各家模型。

### A. 自建统一网关（把多家 API 合并成一个 OpenAI 兼容端点，喂给 CLI 用）

**One API**（入门首选，MIT）
```bash
docker run --name one-api -d --restart always -p 3000:3000 \
  -e TZ=Asia/Shanghai -v /home/ubuntu/data/one-api:/data \
  justsong/one-api
```
- 支持 OpenAI / Azure / Anthropic Claude / Gemini / DeepSeek / 豆包 / ChatGLM / 文心一言 / 讯飞星火 / 通义千问 / 腾讯混元 等
- 默认登录 `root` / `123456`（务必修改）；"渠道"页填各上游 key，"令牌"页生成统一 key 给客户端

**new-api**（One API 增强版，功能更全）
```bash
docker pull calciumion/new-api:latest
docker run --name new-api -d --restart always \
  -p 3000:3000 -e TZ=Asia/Shanghai -v ./data:/data \
  calciumion/new-api:latest
```
- 额外支持 Midjourney / Suno / Realtime / 图像视频接口、**OpenAI⇄Claude⇄Gemini 协议互转**、模型别名、按请求成本核算
- 授权 AGPLv3；国内社区活跃

**LiteLLM**（国际主流，Python 代理，100+ Provider）
```bash
pip install 'litellm[proxy]'
# 写好 config.yaml 后：
litellm --config config.yaml --port 4000
```
- 企业级预算、限流、审计；中文资料相对少

### B. 桌面客户端（图形界面导入多家 API，聊天 + 轻度智能体）

**Cherry Studio**（国内最火）
- 下载：https://github.com/CherryHQ/cherry-studio/releases ；官网 https://cherry-ai.com
- 图形化添加 OpenAI / Anthropic / Gemini / DeepSeek / Qwen / Ollama / LM Studio 等
- 支持 MCP、300+ 预设助手、多模型同屏对话；AGPL-3.0

**备选**：ChatBox、LobeChat（同为多 Provider 桌面客户端，界面风格不同）

### C. 云聚合（一个 key 用多家模型，不用自己部署）
- **OpenRouter**（海外）：一个 key 调几十家模型，需代理 + 境外支付
- **硅基流动 SiliconFlow**（国内）：直连、人民币充值、有免费模型额度，聚合大量开源模型
- **各官方平台**（DeepSeek / 智谱 / 通义百炼 / Kimi）：各自原生 key，最简单但只能用自家模型

### 组合建议
- **纯个人用**：Cherry Studio 直接填各家 key（零部署），再配硅基流动补充免费模型。
- **喂给 CLI**（Claude Code / aider / OpenCode）：One API 或 new-api 聚合后，给一个 OpenAI 兼容地址（配合第 7 节 DeepSeek、或用 Claude Code 的 `ANTHROPIC_BASE_URL` 指向网关）。
- **团队/企业**：LiteLLM 或 new-api（限流、预算、审计更完善）。

---

## 14. 常见坑与通用提示

1. **先确认 Node.js 版本**：Claude Code 的 npm 包要求 Node 22+，Codex/Gemini/Copilot 一般要求 Node 18+。查版本：`node -v`。
2. **不要 `sudo npm install -g`**：权限问题会引发各种诡异错误，用 nvm 或 npm prefix 配置管理全局包。
3. **代理环境变量**（多数工具通用，注意只支持 HTTP(S) 代理）：
   ```bash
   export HTTPS_PROXY="http://127.0.0.1:7890"
   export HTTP_PROXY="http://127.0.0.1:7890"
   export ALL_PROXY="socks5://127.0.0.1:7891"   # 部分工具支持 SOCKS
   ```
4. **国内 npm 镜像**（仅加速"安装下载"，**不能**绕过服务直连封禁）：
   ```bash
   npm config set registry https://registry.npmmirror.com
   # 或临时用：
   npm install -g @openai/codex --registry=https://registry.npmmirror.com
   ```
5. **登录时"浏览器没打开"**：多为代理/默认浏览器问题，可用设备码登录（如 `codex login --device-auth`）或设置 `BROWSER` 环境变量。
6. **token/凭据文件别提交到 git**：Claude Code 的 `~/.claude/.credentials.json`、Codex 的 `~/.codex/auth.json` 都等同密码。

---

## 15. 中国大陆使用"一条龙"建议

按"成本由低到高 / 省事程度"排序：

| 方案 | 是否需翻墙 | 是否需境外卡 | 说明 |
|---|---|---|---|
| **① Ollama 本地** | ❌ | ❌ | 完全免费离线，效果受限于本地硬件 |
| **② DeepSeek API + aider/OpenCode** | ❌ | ❌ | 人民币充值，性价比高，首选 |
| **③ DeepSeek Harness（dsh）** | ❌ | ❌ | 官方开源 Web UI 智能体平台，插件化 |
| **④ Qwen Code** | ❌ | ❌ | 阿里云百炼，国内官方原生体验 |
| **⑤ 智谱 ZCode** | ❌ | ❌ | 智谱官方桌面编码应用（GLM-5.3），需 GLM 订阅（¥94/月起） |
| **⑥ Copilot CLI** | ⚠️ 部分 | 部分 | 有 GitHub 账号即可，订阅受地区限制 |
| **⑦ Gemini CLI** | ✅ | ✅ | Google 账号需代理，免费档够用 |
| **⑧ Claude Code / Codex** | ✅ | ✅ | 需稳定代理 + 境外支付；效果最好 |
| **⑨ 云厂商路线（Bedrock/Vertex）** | 合法接入 | 企业 | 企业已开通云服务时最省事，费用最高 |

**纯个人、无境外卡、想用最好的模型**：推荐 **② DeepSeek API + aider（或 OpenCode）** 打底，配 **④ Qwen Code / ⑤ 智谱 ZCode** 做双保险；多家 API 可统一塞进 **One API / Cherry Studio** 管理（见第 13 节）；等有稳定代理和境外卡后再上 Claude Code / Codex。

---

## 参考链接

- Claude Code 安装/系统要求：https://code.claude.com/docs/en/setup.md
- Claude Code 认证：https://code.claude.com/docs/en/authentication.md
- Claude Code 网络/代理/白名单：https://code.claude.com/docs/en/network-config.md
- Anthropic API CLI（ant）：https://platform.claude.com/docs/en/cli-sdks-libraries/cli/quickstart
- Anthropic 支持的国家地区：https://www.anthropic.com/supported-countries
- Codex CLI 仓库：https://github.com/openai/codex ；认证：https://learn.chatgpt.com/docs/auth
- Gemini CLI 仓库：https://github.com/google-gemini/gemini-cli
- Copilot CLI 仓库：https://github.com/github/copilot-cli
- Qwen Code：https://github.com/QwenLM/qwen-code ；文档：https://qwenlm.github.io/qwen-code/
- DeepSeek 平台：https://platform.deepseek.com ；集成清单：https://github.com/deepseek-ai/awesome-deepseek-integration
- Ollama：https://github.com/ollama/ollama ；模型库：https://ollama.com/library
- OpenCode：https://github.com/sst/opencode ；文档：https://opencode.ai/docs
- aider：https://github.com/Aider-AI/aider ；文档：https://aider.chat/docs/
- Goose：https://github.com/block/goose ；文档：https://goose-docs.ai
- DeepSeek Harness：https://github.com/deepseek-ai/deepseek-harness ；文档：https://deepseek-harness.github.io/deepseek-harness/
- 智谱 ZCode：https://zcode.z.ai ；插件市场：https://github.com/zai-org/zcode-plugins
- One API：https://github.com/songquanpeng/one-api
- new-api：https://github.com/Calcium-Ion/new-api
- LiteLLM：https://github.com/BerriAI/litellm
- Cherry Studio：https://github.com/CherryHQ/cherry-studio ；官网：https://cherry-ai.com
- 硅基流动 SiliconFlow：https://siliconflow.cn
- OpenRouter：https://openrouter.ai
