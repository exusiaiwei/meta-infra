# 🖥️ 全新安装指南

> HP 星Book 14 Pro (或任何 x86 设备) 从零开始的完整流程

---

## 📋 前置准备

- [ ] 备份重要文件到外部存储或云端
- [ ] 确保电源接通（安装过程中不能断电）
- [ ] 准备好你想要的**英文用户名**（如 `exusiai`）
- [ ] 下载 Win11 官方 ISO

---

## 阶段 1：下载 ISO

1. 访问 [微软官方下载页](https://www.microsoft.com/software-download/windows11)
2. 选择「下载 Windows 11 磁盘映像 (ISO)」
3. 版本：**Windows 11 (multi-edition ISO)**
4. 语言：按需选择
5. 下载完成后不要删除，留着备用

---

## 阶段 2：安装系统

1. **双击 ISO 文件**（Windows 自动挂载为虚拟光驱）
2. 运行 `setup.exe`
3. 选择版本 → **Windows 11 Pro**
4. 「更改要保留的内容」→ **无（clean install）**
5. 等待安装，期间会自动重启若干次

---

## ⚠️ 阶段 3：OOBE 初始设置（最关键的一步）

> **目标：创建纯英文本地账户，避免中文用户名污染路径**

如果你登录了微软账户，Windows 会用你的邮箱前缀或中文名创建用户文件夹，
比如 `C:\Users\张三` 或 `C:\Users\exusi`（截断的邮箱），这会导致：
- Python/Node 包安装路径炸裂
- 很多命令行工具无法处理中文路径
- WSL 互操作路径出问题
- **几乎不可逆**（改用户名不会改文件夹名）

### 步骤

1. 系统安装完成，进入 OOBE（蓝色欢迎界面）
2. 选择地区、键盘布局

3. **到了联网步骤 → 断网！**
   - 如果是 WiFi：不要连接任何网络
   - 如果插了网线：拔掉
   - 如果界面强制要求联网（Win11 OOBE 会这样），按 `Shift + F10` 打开命令提示符，运行：
     ```cmd
     oobe\bypassnro
     ```
     系统会重启并回到 OOBE，此时会出现**「我没有 Internet 连接」**选项

4. 选择「我没有 Internet 连接」→「继续执行受限设置」

5. **输入你想要的英文用户名**（如 `exusiai`）
   - 这将创建 `C:\Users\exusiai`
   - 纯英文、无空格、全小写

6. 设置密码（可以先留空，之后再设）

7. 整完 OOBE 后，进入桌面 → **现在可以联网了**

### 联网后绑定微软账户（可选）

```
Settings → Accounts → Your info → Sign in with a Microsoft account instead
```

这样你既有了微软账户的同步功能，用户文件夹又保持了 `C:\Users\exusiai`。

---

## 阶段 4：系统激活

以**管理员身份**打开 PowerShell：

```powershell
irm https://get.activated.win | iex
```

选择 **HWID** 方式 → 绑定硬件，重装后自动激活。

验证：
```
Settings → System → Activation
→ 应显示「Windows is activated with a digital license」
```

---

## 阶段 5：系统更新 + 驱动

1. `Settings → Windows Update → Check for updates`
2. 安装所有更新（包括可选驱动更新）
3. 重启若干次直到没有新更新
4. 确认 HP 硬件（OLED 屏、键盘背光、指纹识别）全部正常工作

---

## 阶段 6：系统精调（去广告去遥测）

以**管理员身份**打开 PowerShell：

```powershell
irm https://christitus.com/win | iex
```

在 winutil 中：
- 选择 `Tweaks` → 勾选 `Standard` 预设
- 这会关闭：遥测、Copilot、消费者体验、建议、广告等
- 点击 `Run Tweaks` 执行

---

## 阶段 7：meta-infra 一键配置

```powershell
irm https://raw.githubusercontent.com/exusiaiwei/meta-infra/master/bootstrap/init.ps1 | iex
```

这一条命令会自动：
- ✅ 安装 Git, MSYS2, Mise, Starship, Windows Terminal
- ✅ 克隆 meta-infra 仓库
- ✅ 安装所有 CLI 工具 (Python, Node, pixi, jq, yq, ripgrep...)
- ✅ 安装所有 GUI 应用 (VS Code, Edge, Obsidian, Clash Verge...)
- ✅ 同步 Dotfiles

---

## 阶段 8：手动收尾

打开 Windows Terminal (zsh)：

```bash
cd ~/_Meta/meta-infra

# 配置 Git 用户信息 + 生成 SSH 密钥
mise run setup:git

# 配置 WSL 环境（可选）
mise run setup:wsl
```

---

## 阶段 9：登录账号

- [ ] Microsoft Edge — 登录同步
- [ ] Bitwarden — 导入密码库
- [ ] Obsidian — 打开知识库
- [ ] Zotero — 登录同步文献
- [ ] GitHub — 添加 SSH 公钥
- [ ] Clash Verge — 导入订阅
- [ ] 微信 / QQ — 登录

---

## ✅ 完成

至此你拥有一个：
- 🧹 干净无广告的 Win11 Pro
- 🔧 声明式管理的全套工具链
- 🐚 统一的 zsh 开发环境
- 🔗 可复现的配置（下次重装跑一条命令）

---

## 📝 注意事项

- **不要用系统自带的「重置此电脑」**：它会还原为 Home 版 + HP 预装垃圾
- **用户名必须纯英文**：一旦创建了中文用户名，几乎不可逆
- **先装驱动再折腾**：确保 OLED、指纹等硬件正常后再做其他配置
- **保留 ISO**：以后重装可以直接用，不需要重新下载
