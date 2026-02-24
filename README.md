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
1. ✅ 安装核心工具（Git, MSYS2, Mise, Starship, Windows Terminal）
2. ✅ 克隆仓库（失败时提示手动下载 ZIP）
3. ✅ 安装 Zsh 插件 + CLI 工具 + GUI 应用
4. ✅ 同步 Dotfiles + 配置 WSL

### 3. 手动收尾

```bash
cd ~/_Meta/meta-infra
mise run setup:git   # Git 用户信息 + SSH 密钥
mise run setup:wsl   # WSL 环境（可选）
```

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

## 📄 许可证

MIT License — 详见 [LICENSE](./LICENSE)
