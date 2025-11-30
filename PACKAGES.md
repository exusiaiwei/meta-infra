# 📦 软件包清单

> 所有通过 Winget 和 Mise 管理的软件包列表

---

## 🔴 Winget 应用 (GUI)

### Core - 核心层 (必装)
```
Git.Git                                 # Git
jdx.mise                                # Mise
Nushell.Nushell                         # Nushell
Starship.Starship                       # Starship
Microsoft.WindowsTerminal               # Windows Terminal
M2Team.NanaZip                          # NanaZip (7-Zip 替代)
```

### Standard - 标准层 (推荐)

#### Tools - 效率工具
```
Microsoft.PowerToys                     # PowerToys
FlowLauncher.FlowLauncher               # Flow Launcher
49306atecsolution.FilesUWP              # Files App
RamenSoftware.Windhawk                  # Windhawk
ArminOsaj.AutoDarkMode                  # Auto Dark Mode
MacType.MacType                         # MacType
AmN.yasb                                # yasb
Pylogmon.pot                            # Pot (翻译)
AdGuard.AdGuard                         # AdGuard
Zen-Team.Zen-Browser                    # Zen Browser
Microsoft.Edge                          # Microsoft Edge
FastCopy.FastCopy                       # FastCopy
GeekUninstaller.GeekUninstaller         # Geek Uninstaller
```

#### Dev - 开发环境
```
Microsoft.VisualStudioCode              # VS Code
Anysphere.Cursor                        # Cursor
Google.Antigravity                      # Antigravity (Google AI 助手)
Microsoft.VisualStudio.2022.BuildTools  # VS Build Tools 2022
Docker.DockerDesktop                    # Docker Desktop
GitHub.cli                              # GitHub CLI
```

#### Academic - 学术工具
```
Obsidian.Obsidian                       # Obsidian
Anki.Anki                               # Anki
DigitalScholar.Zotero                   # Zotero
Microsoft.Office                        # Microsoft 365
```

#### AI - AI 工具
```
kangfenmao.CherryStudio                 # Cherry Studio
```

#### Media - 多媒体
```
Daum.PotPlayer                          # PotPlayer
AdrienAllard.FileConverter              # File Converter
```

#### Communication - 通讯
```
Tencent.WeChat                          # 微信
Tencent.QQ.NT                           # QQ (NT 架构)
Microsoft.Teams                         # Microsoft Teams
```

### Optional - 可选层 (按需)

#### Gaming - 游戏
```
Valve.Steam                             # Steam
Blizzard.BattleNet                      # Battle.net
Guru3D.Afterburner                      # MSI Afterburner
```

#### Security - 安全
```
XPDNH1FMW7NB40                          # 火绒 (Microsoft Store)
```

#### Cloud - 云存储
```
Microsoft.OneDrive                      # OneDrive
Google.GoogleDrive                      # Google Drive
```

#### Hardware - 硬件工具
```
Nvidia.GeForceExperience                # NVIDIA GeForce Experience (x86)
```

---

## 🟢 Mise CLI 工具

### 语言运行时
```
python = "3.12"                                # Python 3.12 (固定版本)
node = "lts"                                   # Node.js LTS
```

### 文档与排版 (通过 ubi backend)
```
ubi:quarto-dev/quarto-cli = "latest"           # Quarto
ubi:typst/typst = "latest"                     # Typst
```

### 多媒体 (通过 ubi backend)
```
ubi:BtbN/FFmpeg-Builds = "latest"              # FFmpeg
```

### 数据处理
```
jq = "latest"                                   # jq (JSON 处理)
yq = "latest"                                   # yq (YAML 处理)
ripgrep = "latest"                              # ripgrep (搜索)
```

### Python 包管理
```
pixi = "latest"                                 # Pixi
```

### AI CLI (通过 npm)
```
npm:@anthropic-ai/claude-code = "latest"       # Claude Code CLI (官方)
npm:@google/gemini-cli = "latest"              # Gemini CLI (官方)
```

---

## 📝 添加新软件

### Winget 应用
1. 找到 Winget ID: `winget search 软件名`
2. 添加到对应的 `manifests/*/**.yaml` 文件
3. 在本文件中添加记录

### Mise 工具
1. 检查可用性: `mise registry | grep 工具名`
2. 或使用 ubi backend: `ubi:owner/repo`
3. 在 `mise.toml` 的 `[tools]` 部分添加
4. 在本文件中添加记录

---

## 📊 统计

- **Winget GUI 应用**: 37 个
- **Mise CLI 工具**: 11 个 (全部通过 Mise 管理)
- **总计**: 48 个软件包
