# 📦 Manifests — Winget DSC 配置

> **三层架构**: Core → Standard → Optional
>
> 两台设备完全同构，一套 manifest 通吃

---

## 🏗️ 目录结构

```
manifests/
├── core/                    # 核心层（必装）
│   └── base.yaml            # 5 个基础工具
│
├── standard/                # 标准层（推荐）
│   ├── tools.yaml           # 效率工具
│   ├── dev.yaml             # 开发环境
│   ├── academic.yaml        # 学术工具
│   ├── ai.yaml              # AI 工具
│   ├── media.yaml           # 多媒体
│   └── communication.yaml   # 通讯
│
└── optional/                # 可选层（按需）
    ├── gaming.yaml          # 游戏
    ├── security.yaml        # 安全软件
    ├── cloud.yaml           # 云存储
    ├── hardware-nvidia.yaml # NVIDIA 工具
    └── hardware-amd.yaml    # AMD 工具
```

---

## 🎯 安装方式

### 通过 Mise（推荐）

```bash
# 安装核心 + 标准层
mise run install

# 安装可选模块（交互式选择）
mise run install:optional

# 仅安装核心层
mise run install:core
```

### 手动安装

```powershell
# 核心
winget configure manifests/core/base.yaml --accept-configuration-agreements

# 标准（选择需要的）
winget configure manifests/standard/tools.yaml --accept-configuration-agreements
winget configure manifests/standard/dev.yaml --accept-configuration-agreements
# ...

# 可选
winget configure manifests/optional/gaming.yaml --accept-configuration-agreements
```

---

## 📋 各层级概览

### 🔴 Core — 必装 (5 个)
Git, Mise, MSYS2, Starship, Windows Terminal

### 🟡 Standard — 推荐
- **tools** (14 个) — PowerToys, Bitwarden, Clash Verge, NanaZip, Edge...
- **dev** (5 个) — VS Code, Cursor, Docker, GitHub CLI
- **academic** (2 个) — Obsidian, Zotero
- **ai** (1 个) — Cherry Studio
- **media** (2 个) — PotPlayer, File Converter
- **communication** (3 个) — 微信, QQ, Teams

### 🔵 Optional — 按需
- **gaming** — Steam, Battle.net, MSI Afterburner
- **security** — 火绒
- **cloud** — OneDrive, Google Drive
- **hardware** — NVIDIA / AMD 工具

---

## 📚 参考

- [Winget DSC 文档](https://learn.microsoft.com/windows/package-manager/configuration/)
- [Winget 包搜索](https://winget.run/)
- [软件清单](../PACKAGES.md)
