# meta-infra 重构计划

## 核心变更：双设备同构 x86 LTSC + zsh 主体

### 阶段 1：清理过时内容
- [ ] 删除 `dotfiles/config.nu`, `dotfiles/env.nu`（Nushell 配置）
- [ ] 移除所有 ARM64 / SPX 相关描述
- [ ] 移除 Nushell 从 core manifest 和文档

### 阶段 2：更新软件清单
- [ ] manifests/core/base.yaml — 移除 Nushell，确认 zsh/MSYS2 策略
- [ ] manifests/standard/tools.yaml — 移除 Flow Launcher，新增 Clash Verge
- [ ] manifests/standard/academic.yaml — 移除 Anki
- [ ] manifests/standard/dev.yaml — 确认 Antigravity
- [ ] 更新 PACKAGES.md

### 阶段 3：Shell 体系迁移
- [ ] dotfiles/ 新增 `.zshrc`, `.zshenv`, `starship.toml`
- [ ] scripts/*.ps1 → scripts/*.sh（zsh 脚本）
- [ ] mise.toml tasks 全部改为调 zsh

### 阶段 4：引导层精简
- [ ] bootstrap/init.ps1 精简为：装 Git + MSYS2 + 克隆仓库

### 阶段 5：新增功能
- [ ] scripts/setup-wsl.sh — WSL 一键配置
- [ ] scripts/setup-git.sh — Git 配置 + SSH 密钥生成
- [ ] scripts/sync-dotfiles.sh — 配置文件符号链接同步

### 阶段 6：文档更新
- [ ] README.md 全面重写
- [ ] 删除过时文档（MISE_LIMITATIONS.md 等）
