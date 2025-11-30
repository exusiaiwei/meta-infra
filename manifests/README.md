# 📦 Manifests - Winget 配置文件

> **三层架构**: Core → Standard → Optional
>
> **文件格式**: `.yaml` (不需要 `.dsc` 后缀)

---

## 🏗️ 目录结构

```
manifests/
├── core/                    # 核心层（必装）
│   └── base.yaml            # 6 个基础工具
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
    ├── gaming.yaml          # 游戏（平台+辅助+MOD）
    ├── security.yaml        # 火绒安全软件
    ├── cloud.yaml           # 云存储（OneDrive + Google Drive）
    ├── hardware-nvidia.yaml # NVIDIA 显卡工具
    └── hardware-amd.yaml    # AMD 显卡工具
```

---

## 🎯 安装策略

### 策略 A：完整安装（推荐新手）

```powershell
# 1. 核心层（必装）
winget configure manifests/core/base.yaml

# 2. 标准层（全部安装）
Get-ChildItem manifests/standard/*.yaml | ForEach-Object {
    winget configure $_.FullName
}

# 3. 可选层（按需选择）
# winget configure manifests/optional/gaming.yaml
# winget configure manifests/optional/hardware-nvidia.yaml
```

### 策略 B：选择性安装（推荐高级用户）

```powershell
# 核心
winget configure manifests/core/base.yaml

# 标准（选择需要的）
winget configure manifests/standard/tools.yaml
winget configure manifests/standard/dev.yaml
# ...

# 可选（按需）
winget configure manifests/optional/gaming.yaml
```

---

## 📋 各层级详情

### 🔴 Core 层 - 核心（必装）

**`core/base.yaml`** (6 个)
- Git - 版本控制
- Mise - 环境管理 + 任务编排
- Nushell - 现代化 Shell
- Starship - Shell 提示符美化
- Windows Terminal - 终端
- NanaZip - 压缩工具

**特点**:
- ✅ 必须安装
- ✅ 所有设备通用
- ✅ 依赖关系已配置

---

### 🟡 Standard 层 - 标准（推荐）

#### `standard/tools.yaml` - 效率工具 (13 个)

**系统增强**:
- PowerToys, Flow Launcher, Files App
- Windhawk, Auto Dark Mode, MacType, yasb

**网络与工具**:
- Pot (翻译), AdGuard (广告拦截)
- ~~NanaGet~~ (待查找 ID)

**浏览器**:
- Zen Browser, Microsoft Edge

**卸载工具**:
- ~~Geek Uninstaller~~ (待查找 ID)

---

#### `standard/dev.yaml` - 开发环境 (6 个)

- Visual Studio Code
- Cursor
- ~~Antigravity~~ (待查找 ID)
- VS Build Tools 2022 (C++ 编译环境)
- Docker Desktop
- GitHub CLI

---

#### `standard/academic.yaml` - 学术工具 (4 个)

- Obsidian (笔记)
- Anki (记忆卡片)
- Zotero (文献管理)
- ~~Microsoft 365~~ (待查找 ID)

**适用**: Surface Pro X 主要使用

---

#### `standard/ai.yaml` - AI 工具 (1 个)

- Cherry Studio

**说明**: PWA 应用用 Pake 单独管理

---

#### `standard/media.yaml` - 多媒体 (2 个)

- PotPlayer (视频播放)
- ~~File Converter~~ (待查找 ID)

---

#### `standard/communication.yaml` - 通讯 (3 个)

- 微信
- QQ (NT 架构最新版)
- Microsoft Teams

---

### 🔵 Optional 层 - 可选（按需）

#### `optional/gaming.yaml` - 游戏 (5+ 个)

**游戏平台**:
- Steam
- Battle.net (暴雪战网)

**游戏辅助**:
- MSI Afterburner (显卡超频监控)
- RivaTuner Statistics Server (随 Afterburner 安装)

**游戏 MOD**（待查找 ID）:
- ~~红警3日冕启动器~~
- ~~RA3BattleNet~~
- ~~SCNexus 星际枢纽~~

**特点**:
- ⚠️ 仅游戏玩家需要
- ⚠️ 主力机专用
- ⚠️ Surface Pro X 不推荐

---

#### `optional/security.yaml` - 安全软件 (1 个)

- ~~火绒安全软件~~ (待查找 ID)

**⚠️ 重要警告**:
- 会禁用 Windows Defender
- 需要用户明确决策
- 不建议同时运行多个安全软件

---

#### `optional/cloud.yaml` - 云存储 (2 个)

- Microsoft OneDrive
- Google Drive

**特点**:
- 持续同步占用资源
- 需要登录账号
- 按需安装

---

#### `optional/hardware-nvidia.yaml` - NVIDIA 工具 (1 个)

- ~~NVIDIA App~~ (待查找 ID)

**⚠️ 硬件要求**:
- 仅 NVIDIA 显卡用户
- AMD 用户请使用 `hardware-amd.yaml`

---

#### `optional/hardware-amd.yaml` - AMD 工具

- ~~AMD Adrenalin~~ (待查找 ID)

**⚠️ 硬件要求**:
- 仅 AMD 显卡用户
- NVIDIA 用户请使用 `hardware-nvidia.yaml`

---

## ⚠️ 待查找 Winget ID 清单

以下软件需要查找正确的 Winget ID：

| 软件 | 分类 | 优先级 |
|------|------|--------|
| NanaGet | tools.yaml | 🟡 中 |
| Geek Uninstaller | tools.yaml | 🟡 中 |
| Antigravity | dev.yaml | 🟡 中 |
| Microsoft 365 | academic.yaml | 🟡 中 |
| File Converter | media.yaml | 🟡 中 |
| Battle.net | gaming.yaml | 🔵 低 |
| 红警3日冕启动器 | gaming.yaml | 🔵 低 |
| RA3BattleNet | gaming.yaml | 🔵 低 |
| SCNexus | gaming.yaml | 🔵 低 |
| 火绒安全软件 | security.yaml | 🔵 低 |
| NVIDIA App | hardware-nvidia.yaml | 🔵 低 |
| AMD Adrenalin | hardware-amd.yaml | 🔵 低 |

**查找方式**:
```powershell
winget search "软件名称"
```

---

## 📝 设备配置组合建议

### 主力机 (Win11 LTSC x86)

```powershell
# 完整版
winget configure manifests/core/base.yaml
Get-ChildItem manifests/standard/*.yaml | ForEach-Object { winget configure $_ }
winget configure manifests/optional/gaming.yaml
winget configure manifests/optional/hardware-nvidia.yaml  # 如果是 N 卡
```

### Surface Pro X (Win11 ARM64)

```powershell
# 学术为主
winget configure manifests/core/base.yaml
winget configure manifests/standard/tools.yaml
winget configure manifests/standard/dev.yaml
winget configure manifests/standard/academic.yaml
winget configure manifests/standard/ai.yaml
winget configure manifests/standard/communication.yaml
```

---

## 🔄 迁移说明

### 从旧的 `.dsc.yaml` 迁移

旧文件已移除，新结构：
- `manifests/base.dsc.yaml` → `manifests/core/base.yaml`
- `manifests/dev.dsc.yaml` → `manifests/standard/dev.yaml`
- `manifests/gaming.dsc.yaml` → `manifests/optional/gaming.yaml`

### 使用新结构

所有新的配置文件都在三层目录中：
- `core/` - 必装
- `standard/` - 推荐
- `optional/` - 可选

---

## 📚 参考

- [Winget DSC 文档](https://learn.microsoft.com/windows/package-manager/configuration/)
- [Winget 包搜索](https://winget.run/)
- [项目主 README](../README.md)
