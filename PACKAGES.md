# 📦 软件包清单

> 所有通过 Winget 和 Mise 管理的软件包列表

---

## 🔴 Winget 应用 (GUI)

### Core — 核心层 (必装)
| 软件 | Winget ID | 用途 |
|------|-----------|------|
| Git | `Git.Git` | 版本控制 |
| Mise | `jdx.mise` | 环境与任务管理 |
| MSYS2 | `MSYS2.MSYS2` | Zsh + Unix 工具链 |
| Starship | `Starship.Starship` | Shell 提示符美化 |
| Windows Terminal | `Microsoft.WindowsTerminal` | 终端 |

### Standard — 标准层 (推荐)

#### Tools — 效率工具
| 软件 | Winget ID | 用途 |
|------|-----------|------|
| PowerToys | `Microsoft.PowerToys` | 系统增强 (含 Command Palette) |
| Files App | `49306atecsolution.FilesUWP` | 现代文件管理器 |
| Windhawk | `RamenSoftware.Windhawk` | 系统定制 |
| Auto Dark Mode | `ArminOsaj.AutoDarkMode` | 自动暗色模式 |
| MacType | `MacType.MacType` | 字体渲染优化 |
| yasb | `AmN.yasb` | 状态栏 |
| Bitwarden | `Bitwarden.Bitwarden` | 密码管理器 |
| NanaZip | `M2Team.NanaZip` | 压缩工具 |
| Clash Verge | `ClashVergeRev.ClashVergeRev` | 代理客户端 |
| AdGuard | `AdGuard.AdGuard` | 广告拦截 |
| Pot | `Pylogmon.pot` | 翻译 |
| Tailscale | `Tailscale.Tailscale` | 设备互联 VPN |
| FastCopy | `FastCopy.FastCopy` | 快速复制 |
| Geek Uninstaller | `GeekUninstaller.GeekUninstaller` | 卸载工具 |
| Microsoft Edge | `Microsoft.Edge` | 浏览器 |

#### Dev — 开发环境
| 软件 | Winget ID | 用途 |
|------|-----------|------|
| VS Code | `Microsoft.VisualStudioCode` | 代码编辑器 |
| Cursor | `Anysphere.Cursor` | AI 代码编辑器 |
| Antigravity | `Google.Antigravity` | Google AI 编辑器 |
| VS Build Tools | `Microsoft.VisualStudio.2022.BuildTools` | C++ 编译环境 |
| Docker Desktop | `Docker.DockerDesktop` | 容器 |
| GitHub CLI | `GitHub.cli` | GitHub 命令行 |
| WSL | `Microsoft.WSL` | Windows Subsystem for Linux |

#### Academic — 学术工具
| 软件 | Winget ID | 用途 |
|------|-----------|------|
| Obsidian | `Obsidian.Obsidian` | 笔记 |
| Zotero | `DigitalScholar.Zotero` | 文献管理 |
| Microsoft 365 | `Microsoft.Office` | Office 套件 |

#### Media — 多媒体
| 软件 | Winget ID | 用途 |
|------|-----------|------|
| PotPlayer | `Daum.PotPlayer` | 视频播放 |
| File Converter | `AdrienAllard.FileConverter` | 格式转换 |

#### Communication — 通讯
| 软件 | Winget ID | 用途 |
|------|-----------|------|
| 微信 | `Tencent.WeChat` | 微信 |
| QQ | `Tencent.QQ.NT` | QQ (NT 架构) |
| Microsoft Teams | `Microsoft.Teams` | Teams |

### Optional — 可选层 (按需)

#### Gaming
| 软件 | Winget ID | 用途 |
|------|-----------|------|
| Steam | `Valve.Steam` | 游戏平台 |
| Battle.net | `Blizzard.BattleNet` | 暴雪战网 |
| MSI Afterburner | `Guru3D.Afterburner` | 显卡监控 |

#### Cloud
| 软件 | Winget ID | 用途 |
|------|-----------|------|
| OneDrive | `Microsoft.OneDrive` | 云存储 |
| Google Drive | `Google.GoogleDrive` | 云存储 |

---

## 🟢 Mise CLI 工具

| 工具 | 配置 | 用途 |
|------|------|------|
| Python | `python = "3.12"` | Python 解释器 |
| Node.js | `node = "lts"` | Node.js 运行时 |
| jq | `jq = "latest"` | JSON 处理 |
| yq | `yq = "latest"` | YAML 处理 |
| ripgrep | `ripgrep = "latest"` | 快速搜索 |
| Pixi | `pixi = "latest"` | Python/Conda 包管理 |
| Claude Code | `npm:@anthropic-ai/claude-code` | AI CLI |
| Gemini CLI | `npm:@google/gemini-cli` | AI CLI |
| Typst | `ubi:typst/typst` | 排版系统 |
| Quarto | `ubi:quarto-dev/quarto-cli` | 文档系统 |

---

## 📊 统计

- **Winget GUI 应用**: ~35 个
- **Mise CLI 工具**: 10 个
- **总计**: ~45 个软件包
