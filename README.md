# 🚀 meta-infra

> 声明式、零污染的 Windows + WSL 环境配置系统

---

## 🎯 核心特性

- **📦 声明式配置** — Winget DSC + Mise TOML，所有软件有迹可循
- **🐚 Zsh 主体** — MSYS2 zsh (Windows) + WSL zsh (Linux)，统一体验
- **🔗 Dotfiles 同步** — 符号链接管理，一处修改全局生效
- **🔑 一键配置** — Git 信息、SSH 密钥、WSL 环境自动化
- **🎨 模块化** — 按需选择安装模块

---

## ⚡ 裸机速查（从 GitHub 网页直接复制）

> 以下命令均在 **管理员 PowerShell** 中运行

### 0. 系统激活

```powershell
irm https://get.activated.win | iex
```

### 1. 系统精调（去广告 / 去遥测 / 关 Copilot）

```powershell
irm https://christitus.com/win | iex
```

### 2. meta-infra 一键配置

```powershell
irm https://raw.githubusercontent.com/exusiaiwei/meta-infra/master/bootstrap/init.ps1 | iex
```

这一条命令会自动完成：
1. ✅ 安装核心工具（Git, MSYS2, zsh, Clash Verge, Mise, Starship, Windows Terminal）
2. ✅ 配置 Windows Terminal（zsh 设为默认）
3. ✅ 克隆仓库

### 3. 打开 Windows Terminal，运行一键配置

```bash
cd ~/_Meta/meta-infra && zsh scripts/setup-all.sh
```

这一步会交互式完成：
- Zsh 插件安装
- Dotfiles 同步
- CLI 工具安装（mise）
- GUI 应用安装（winget，可选择模块）
- WSL 环境配置（可选）
- Git + SSH 配置

### 离线 / 无法访问 GitHub？

手动下载 ZIP 并解压到 `C:\Users\你的用户名\_Meta\meta-infra\`：

```
https://github.com/exusiaiwei/meta-infra/archive/refs/heads/master.zip
```

解压后运行 `.\bootstrap\init.ps1` 即可继续。

---

## 📊 架构设计

```
裸机
  ↓
┌──────────────────────────────────────┐
│  PowerShell (引导层)                  │
│  └─ init.ps1: Git + MSYS2 + 克隆     │
└──────────────┬───────────────────────┘
               ↓  交棒
┌──────────────────────────────────────┐
│  Zsh + Mise (主体层)                  │
│  ├─ mise install     → CLI 工具       │
│  ├─ mise run install → GUI 应用       │
│  ├─ mise run setup   → 配置向导       │
│  │   ├─ setup:git      Git + SSH     │
│  │   ├─ setup:dotfiles 符号链接同步   │
│  │   └─ setup:wsl      WSL 环境      │
│  └─ mise run update  → 全量更新       │
└──────────────────────────────────────┘
```

---

## 📦 软件模块

### 核心层 (Core) — 必装
- **Git** — 版本控制
- **Mise** — 环境与任务管理
- **MSYS2** — Zsh + Unix 工具链
- **Starship** — Shell 提示符美化
- **Windows Terminal** — 终端

### 标准层 (Standard) — 推荐
- **tools** — PowerToys, Bitwarden, Clash Verge, Tailscale, NanaZip, FastCopy...
- **dev** — VS Code, Cursor, Docker, GitHub CLI
- **academic** — Obsidian, Zotero
- **media** — PotPlayer, File Converter
- **communication** — 微信, QQ, Teams

### 可选层 (Optional) — 按需
- **gaming** — Steam, Battle.net
- **security** — 火绒
- **cloud** — OneDrive, Google Drive
- **hardware** — NVIDIA / AMD 工具

### CLI 工具 (Mise 管理)
- Python 3.12, Node.js LTS
- pixi, jq, yq, ripgrep
- Claude Code CLI, Gemini CLI

---

## 🛠️ 常用命令

```bash
mise run status      # 查看系统状态
mise run verify      # 验证安装完整性
mise run update      # 更新所有工具和应用
mise run setup:git   # 配置 Git + SSH
mise run setup:wsl   # 一键配置 WSL
mise run setup:dotfiles  # 同步配置文件
```

---

## 🔧 设备配置

## ⚠️ 常见问题

### Clash Verge TUN 模式与 WSL 冲突

TUN 模式会劫持所有网络流量，导致 WSL2 无法联网。解决方案：

**方法 1：排除本地子网（推荐）**

Clash Verge → 设置 → Clash 字段 → 覆写 → 添加：

```yaml
tun:
  enable: true
  stack: mixed
  dns-hijack:
    - any:53
  auto-route: true
  strict-route: false
  inet4-route-exclude-address:
    - 127.0.0.0/8      # 本机回环
    - 172.16.0.0/12     # WSL / Docker 虚拟网络
    - 192.168.0.0/16    # 局域网
```

**方法 2：不用 TUN，改用系统代理**

系统代理模式下 WSL 不受影响，但 WSL 内需手动设置代理：

```bash
# 在 WSL 的 .zshrc 中加入（端口号按实际情况修改）
export http_proxy="http://$(cat /etc/resolv.conf | grep nameserver | awk '{print $2}'):7897"
export https_proxy="$http_proxy"
```

### TUN 模式下 Microsoft Store / UWP 应用无法联网

UWP 应用有**回环隔离（Loopback Restriction）**，TUN 模式的代理流量无法到达 UWP 沙箱，导致 Store 下载卡住。

**方法 1：Clash Verge 内置工具**

设置 → 杂项 → **UWP 工具**，勾选需要放行的 UWP 应用（如 Microsoft Store）。

**方法 2：命令行一键解除所有 UWP 回环限制**

```powershell
# 管理员 PowerShell
Get-AppxPackage | ForEach-Object {
    CheckNetIsolation.exe LoopbackExempt -a -n="$($_.PackageFamilyName)"
} 2>$null
```

---

## 🔧 设备配置

### 主力机 (Win11 LTSC x86)
```bash
mise run install              # 核心 + 标准层
mise run install:optional     # 选择: gaming, nvidia
```

### 便携机 (Win11 LTSC x86 — HP 星Book)
```bash
mise run install              # 核心 + 标准层（和主力机完全一致）
```

两台设备**完全同构**，同样的系统、同样的配置、一套 manifest。

---

## 📁 项目结构

```
meta-infra/
├── bootstrap/
│   ├── init.ps1                # 裸机引导（PowerShell）
│   ├── LTSC-Enhancement.psm1   # LTSC 系统增强
│   └── LTSC_ENHANCEMENT_GUIDE.md
├── manifests/                  # Winget DSC 配置
│   ├── core/base.yaml
│   ├── standard/*.yaml
│   └── optional/*.yaml
├── dotfiles/                   # 配置文件（符号链接源）
│   ├── .zshenv
│   ├── .zshrc
│   └── starship.toml
├── scripts/                    # Zsh 脚本
│   ├── setup-git.sh
│   ├── setup-wsl.sh
│   └── sync-dotfiles.sh
├── mise.toml                   # 核心编排文件
└── README.md
```

---

## 📋 TODO

- [ ] **跨设备配置文件同步** — 维护应用配置路径注册表（`app-paths.yaml`），通过 OneDrive + 符号链接自动同步 Windows Terminal / Antigravity / Clash Verge / PowerToys 等配置（类似 macOS 的 Mackup）

---

## 📄 许可证

MIT License — 详见 [LICENSE](./LICENSE)
