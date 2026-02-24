# 🚀 meta-infra

> 声明式、零污染的 Windows + WSL 环境配置系统（chezmoi 驱动）

---

## 🎯 核心特性

- **⚡ 一行部署** — 裸机跑一条命令，基础环境全部就绪
- **📦 声明式配置** — chezmoi + Winget + Mise，所有软件有迹可循
- **🐚 Zsh 主体** — MSYS2 zsh (Windows) + WSL zsh (Linux)，统一体验
- **🔗 Dotfiles 同步** — chezmoi 管理，一处修改全局生效
- **🎨 模块化** — 核心/标准/可选三层架构，按需安装

---

## ⚡ 裸机速查

> 以下命令在 **管理员 PowerShell** 中运行

### 第一行：基础环境（全自动）

```powershell
irm https://raw.githubusercontent.com/exusiaiwei/meta-infra/master/bootstrap.ps1 | iex
```

这一条命令会自动完成：
1. ✅ 安装 Git + chezmoi
2. ✅ 安装核心工具（MSYS2, Mise, Starship, Windows Terminal, Clash Verge）
3. ✅ 安装 Zsh + 插件
4. ✅ 配置 Windows Terminal（zsh 设为默认）
5. ✅ 同步 Dotfiles（.zshrc, .zshenv, starship.toml）
6. ✅ 配置 Git 用户信息 + 生成 SSH 密钥

### 第二行：高级环境（在 zsh 中）

```bash
cd ~/_Meta/meta-infra && mise install && mise run install
```

这一步完成：
- CLI 工具安装（Python, Node, jq, yq, ripgrep, pixi...）
- GUI 应用安装（VS Code, Obsidian, Docker... 可选择模块）

---

## 📊 架构设计

```
裸机
  ↓
┌──────────────────────────────────────┐
│  PowerShell (引导层)                  │
│  └─ bootstrap.ps1                    │
│     装 Git + chezmoi                 │
│     chezmoi init --apply             │
└──────────────┬───────────────────────┘
               ↓  chezmoi apply
┌──────────────────────────────────────┐
│  chezmoi (配置层)                     │
│  ├─ run_once_01: 装核心工具 (winget)  │
│  ├─ run_once_02: 装 zsh + 插件       │
│  ├─ run_once_03: 配置 Windows Terminal│
│  ├─ run_once_04: Git + SSH           │
│  └─ dotfiles: .zshrc, starship.toml  │
└──────────────┬───────────────────────┘
               ↓  第二行命令
┌──────────────────────────────────────┐
│  Mise (工具层)                        │
│  ├─ mise install    → CLI 工具        │
│  └─ mise run install→ GUI 应用       │
└──────────────────────────────────────┘
```

---

## 📦 软件模块

### 核心层 (Core) — chezmoi 自动安装
- **Git** — 版本控制
- **Mise** — 环境与任务管理
- **MSYS2** — Zsh + Unix 工具链
- **Starship** — Shell 提示符美化
- **Windows Terminal** — 终端
- **Clash Verge** — 代理（加速后续下载）

### 标准层 (Standard) — mise run install
- **tools** — PowerToys, Bitwarden, NanaZip, FastCopy...
- **dev** — VS Code, Cursor, Docker, GitHub CLI
- **academic** — Obsidian, Zotero
- **media** — PotPlayer, File Converter
- **communication** — 微信, QQ, Teams

### 可选层 (Optional) — mise run install:optional
- **gaming** — Steam, Battle.net
- **security** — 火绒
- **cloud** — OneDrive, Google Drive
- **hardware** — NVIDIA / AMD 工具

### CLI 工具 (Mise 管理) — mise install
- Python 3.12, Node.js LTS
- pixi, jq, yq, ripgrep
- Claude Code CLI, Gemini CLI
- Typst, Quarto

---

## 🛠️ 常用命令

```bash
# 日常维护
mise run status      # 查看状态
mise run verify      # 验证安装
mise run update      # 更新所有

# 配置
mise run setup:git   # 重新配置 Git + SSH
mise run setup:wsl   # 一键配置 WSL

# chezmoi
chezmoi update       # 从 GitHub 拉取最新配置并应用
chezmoi diff         # 查看待同步的变更
chezmoi edit ~/.zshrc  # 编辑配置文件
```

---

## 📁 项目结构

```
meta-infra/
├── .chezmoi.toml.tmpl              # chezmoi 初始化交互配置
├── .chezmoiignore                  # 不部署到 ~ 的文件列表
├── .chezmoiscripts/                # 首次部署自动执行的脚本
│   ├── run_once_before_01-install-core.ps1.tmpl
│   ├── run_once_before_02-install-zsh.ps1.tmpl
│   ├── run_once_03-configure-terminal.ps1.tmpl
│   └── run_once_04-configure-git.ps1.tmpl
├── dot_zshenv                      # → ~/.zshenv
├── dot_zshrc                       # → ~/.zshrc
├── private_dot_config/
│   └── starship.toml               # → ~/.config/starship.toml
├── bootstrap.ps1                   # 裸机引导入口
├── manifests/                      # Winget DSC 清单
│   ├── core/base.yaml
│   ├── standard/*.yaml
│   └── optional/*.yaml
├── mise.toml                       # CLI 工具 + 任务定义
└── README.md
```

---

## ⚠️ 常见问题

### Clash Verge TUN 模式与 WSL 冲突

Clash Verge → 设置 → Clash 字段 → 覆写 → 添加：

```yaml
tun:
  enable: true
  strict-route: false
  inet4-route-exclude-address:
    - 127.0.0.0/8
    - 172.16.0.0/12
    - 192.168.0.0/16
```

---

## 📄 许可证

MIT License — 详见 [LICENSE](./LICENSE)
