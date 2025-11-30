# 🚀 meta-infra

> 声明式、零污染、跨架构的 Windows 环境配置系统

[![Architecture](https://img.shields.io/badge/Architecture-Three--Layer-blue)](./ARCHITECTURE.md)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](./LICENSE)

---

## 🎯 核心特性

- **📦 声明式配置** - 使用 Winget DSC + Mise TOML
- **♻️ 零污染** - 所有配置有迹可循，可完全还原
- **🔄 跨架构** - 同时支持 x86 和 ARM64 (Surface Pro X)
- **🎨 模块化** - 按需选择安装模块
- **🔧 LTSC 支持** - 完整的 LTSC 系统增强方案

---

## ⚡ 快速开始

### 方法 1：一键安装（推荐）

在 PowerShell 中运行：

```powershell
irm https://raw.githubusercontent.com/用户名/meta-infra/main/bootstrap/init.ps1 | iex
```

### 方法 2：手动安装

```powershell
# 1. 克隆仓库
git clone https://github.com/用户名/meta-infra.git
cd meta-infra

# 2. 安装核心工具
winget configure manifests/core/base.yaml

# 3. 重启终端，然后运行
mise run bootstrap
```

---

## 📊 架构设计

```
┌─────────────────────────────────────────┐
│  PowerShell (BIOS 层)                   │
│  ├─ init.ps1 - 轻量引导                 │
│  └─ 仅负责: Git + 仓库克隆              │
└─────────────────┬───────────────────────┘
                  ↓
┌─────────────────────────────────────────┐
│  Mise (操作系统层)                      │
│  ├─ mise run bootstrap - 主安装向导     │
│  ├─ mise run init - 初始化配置          │
│  └─ 负责: 任务编排 + CLI 工具管理       │
└─────────────────┬───────────────────────┘
                  ↓
┌─────────────────────────────────────────┐
│  Nushell (应用层)                       │
│  ├─ scripts/*.nu - 具体实现逻辑         │
│  └─ 负责: 交互界面 + 系统配置           │
└─────────────────────────────────────────┘
```

---

## 📦 软件模块

### 核心层 (Core) - 必装
- **base** - Git, Mise, Nushell, Starship, Windows Terminal, NanaZip

### 标准层 (Standard) - 推荐
- **tools** - PowerToys, Flow Launcher, FastCopy, 浏览器
- **dev** - VS Code, Cursor, Docker, GitHub CLI
- **academic** - Obsidian, Zotero, Anki
- **ai** - Cherry Studio
- **media** - PotPlayer, File Converter
- **communication** - 微信, QQ, Teams

### 可选层 (Optional) - 按需
- **gaming** - Steam, Battle.net, MSI Afterburner
- **security** - 火绒安全软件
- **cloud** - OneDrive, Google Drive
- **hardware-nvidia** - NVIDIA App (仅 N 卡用户)

---

## 🛠️ 常用命令

```powershell
# 查看系统状态
mise run status

# 安装 CLI 工具
mise install

# 初始化配置
mise run init

# 更新所有工具
mise run update

# 验证安装
mise run verify
```

---

## 📚 文档

- [架构设计](./ARCHITECTURE.md) - 详细的技术架构
- [软件清单](./SOFTWARE_MANIFEST.md) - 所有软件及 Winget ID
- [Mise 工具](./MISE_TOOLS.md) - CLI 工具配置说明
- [LTSC 增强](./bootstrap/LTSC_ENHANCEMENT_GUIDE.md) - LTSC 系统增强指南

---

## 🔧 针对不同系统

### Win11 LTSC x86 (主力机)
```powershell
mise run bootstrap
# 选择: 0 (全部安装)
```

### Win11 ARM64 (Surface Pro X)
```powershell
mise run bootstrap
# 选择: 1,2,4,7 (core + tools + academic + communication)
```

### Win11 LTSC (精简系统)
```powershell
# 先运行 LTSC 增强 (可选)
# 然后运行 bootstrap
mise run bootstrap
```

---

## 🤝 贡献

欢迎 Issues 和 Pull Requests！

---

## 📄 许可证

MIT License - 详见 [LICENSE](./LICENSE)

---

**⭐ 如果这个项目对你有帮助，请给个 Star！**
