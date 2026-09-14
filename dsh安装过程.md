# DeepSeek Harness（dsh）安装过程 —— 完整手动操作版

> 更新时间：2026-09-14。本文按「从零开始、每一步都手动执行」来写，全部步骤在**本机实测通过**。
> DeepSeek Harness 是 DeepSeek 官方的**开源（MIT）插件化智能体框架**，通过浏览器 Web 界面使用，默认地址 `http://127.0.0.1:3080`。

## 〇、先看硬性要求（缺一个都跑不起来）

| 项目 | 要求 | 检查命令 |
|---|---|---|
| Node.js | **`^22.19.0 || >=24.0.0`**（22.19+ 或 24+） | `node -v` |
| pnpm | **`11.7.0`**（仓库 packageManager 指定） | `pnpm -v` |
| git | 任意较新版本 | `git --version` |
| 浏览器 | **Chrome 122+ / Firefox 141+** | — |

> ⚠️ Node 版本低于 22.19、或浏览器太老（Firefox 130 这种），会分别报错 / 页面 `Iterator is not defined`。**这是本项目最常见的两个坑。**

---

## 一、安装 Node.js（22+）

### 检查是否已装
```bash
node -v
```
- 显示 `v22.x.x` 或 `v24.x.x` → 满足，跳过本步
- 报「command not found」或版本低于 22 → 继续

### 方法 1（推荐）：用 nvm 装（版本独立，不动系统 Node）
```bash
# 装 nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.7/install.sh | bash
# 让 nvm 生效（或重开终端）
source ~/.bashrc
# 安装 Node 22 并设为默认
nvm install 22
nvm use 22
nvm alias default 22
```
（实测装的是 Node v22.23.2，满足要求）

### 方法 2：官方包 / 国内镜像
- 官方：https://nodejs.org/zh-cn 下载 LTS 的安装包
- 国内镜像（大陆快）：https://npmmirror.com/mirrors/node/ 下载 `node-v22.x.x-linux-x64.tar.xz`，解压后加进 PATH

### 验证
```bash
node -v && npm -v
```

---

## 二、安装 pnpm 11.7.0

```bash
npm install -g pnpm@11.7.0
```
验证：
```bash
pnpm -v   # 应显示 11.7.0
```

> 国内可顺手换镜像源（加速一切下载）：
> ```bash
> npm config set registry https://registry.npmmirror.com
> pnpm config set registry https://registry.npmmirror.com
> ```

---

## 三、克隆仓库

```bash
git clone https://github.com/deepseek-ai/deepseek-harness.git
cd deepseek-harness
```
> 国内直连 GitHub 可能慢/失败，失败就开梯子或用 GitHub 加速镜像。

---

## 四、安装依赖 + 构建（手动逐步执行）

```bash
# 1. 安装依赖（首次约几分钟）
pnpm install

# 2. 构建（把源码编译成可运行产物，约 1-4 分钟）
pnpm run build
```
> `pnpm run build` 会输出一堆构建日志，看到类似 `✓ built in xx s` 就是成功。出现红色 `error` 再贴出来排查。

---

## 五、启动 Web 界面

```bash
pnpm dsh web
```
启动成功会打印一行：
```
dsh web: http://127.0.0.1:3080/?token=XXXXXXXX...
```
**把这整行 URL 复制，用 Chrome（或 Firefox 141+）打开**。token 是访问凭证，掉了就从启动输出里找。

- 不想自动开浏览器：`pnpm dsh web --no-open`
- 停止服务：在该终端按 `Ctrl+C`

> 免构建的偷懒方式（官方也支持，跳过 三、四 步）：
> ```bash
> npx @deepseek-ai/dsh web
> ```

---

## 六、配置模型（必须，否则没有大脑）

打开 Web UI 后：**设置 → 模型**，选提供方填 key。

### 方案 A：DeepSeek 官方 API（最便宜）
- 注册：https://platform.deepseek.com ，充值后拿到 API Key
- 提供方选/新建「DeepSeek」，Base URL：`https://api.deepseek.com`
- 填 Key，点「获取可用模型」

### 方案 B：火山方舟 coding plan（你实测可用的方案）
- 提供方：自定义提供方
- 协议：`anthropic-messages`
- Base URL：`https://ark.cn-beijing.volces.com/api/coding`
- Key：火山方舟 API Key
- 模型：`deepseek-v4-pro`（主力）/ `deepseek-v4-flash-260731`（快）

> 密钥保存在本机 `~/.dsh/.credentials.yaml`，配置文件在 `~/.dsh/settings.yaml`（手动改配置也行，改完要重启服务）。

---

## 七、常见问题排查

| 现象 | 原因 | 解决 |
|---|---|---|
| 启动报 Node 版本相关错误 | Node < 22.19 | nvm 装 22 再试 |
| Firefox 报 `Iterator is not defined` / Failed to load plugins | 浏览器 < 141 | 换 Chrome 122+ 或升级 Firefox |
| 页面一直加载/白屏 | token 没带全、缓存 | 无痕窗口 + 复制完整带 token 的 URL + Ctrl+F5 强刷 |
| `pnpm` 报错找不到 | pnpm 没装或版本不对 | `npm install -g pnpm@11.7.0` |
| 问要不要翻墙 | — | **Web 界面完全本地，不用翻墙**；只有接国外模型（如 Claude/OpenAI）才需要 |

---

## 八、卸载 / 清理

- **卸载**：删掉 clone 的 `deepseek-harness` 文件夹即可（没有注册系统服务）
- **清配置**：删 `~/.dsh/` 目录（含模型配置和 key）
- 想换 Node 版本：`nvm uninstall 22`（nvm 装的才可这样删）

---

## 九、结论

- dsh = **开源 + 免费 + 大陆直连 + 可接任意模型** 的智能体框架，浏览器用
- 两大前置坑：**Node 22.19+** 和 **浏览器版本**，先检查再动手
- 完整流程：**装 Node → 装 pnpm → clone → install → build → dsh web → 配模型**
