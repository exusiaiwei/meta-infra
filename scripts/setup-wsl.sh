#!/usr/bin/env zsh
# =============================================================================
# setup-wsl.sh — WSL 一键配置
# =============================================================================
# 从 Windows 侧调用: wsl.exe -e bash -c "$(cat scripts/setup-wsl.sh)"
# 或者在 WSL 内直接运行
# =============================================================================
set -euo pipefail

echo "============================================"
echo "  🐧 WSL 环境配置"
echo "============================================"
echo ""

# ---------- 检测是否在 WSL 内 ----------
if ! grep -qi microsoft /proc/version 2>/dev/null; then
  echo "❌ 此脚本需要在 WSL 内运行"
  echo "请先运行: wsl.exe"
  exit 1
fi

# ---------- 系统更新 ----------
echo ">> 更新系统包..."
sudo apt update && sudo apt upgrade -y

# ---------- 基础工具 ----------
echo ">> 安装基础开发工具..."
sudo apt install -y \
  build-essential \
  python3-pip \
  python3-venv \
  unzip \
  curl \
  wget \
  zsh \
  zsh-syntax-highlighting \
  zsh-autosuggestions \
  git

# ---------- 设置 zsh 为默认 shell ----------
if [[ "$SHELL" != */zsh ]]; then
  echo ">> 设置 zsh 为默认 shell..."
  chsh -s $(which zsh)
fi

# ---------- Starship ----------
if ! command -v starship &>/dev/null; then
  echo ">> 安装 Starship..."
  curl -sS https://starship.rs/install.sh | sh -s -- -y
fi

# ---------- Pixi ----------
if ! command -v pixi &>/dev/null; then
  echo ">> 安装 Pixi..."
  curl -fsSL https://pixi.sh/install.sh | bash
fi

# ---------- Mise ----------
if ! command -v mise &>/dev/null; then
  echo ">> 安装 Mise..."
  curl https://mise.run | sh
fi

# ---------- 配置 .zshrc ----------
ZSHRC="$HOME/.zshrc"

# 只在没有相关配置时追加
if ! grep -q "pixi" "$ZSHRC" 2>/dev/null; then
  cat >> "$ZSHRC" << 'EOF'

# === meta-infra 自动配置 ===

# Pixi
export PATH="$HOME/.pixi/bin:$PATH"

# Mise
eval "$(~/.local/bin/mise activate zsh)"

# Starship
eval "$(starship init zsh)"
EOF
  echo "✅ .zshrc 已配置"
fi

# ---------- 用 Mise 安装 Node.js ----------
echo ">> 安装 Node.js LTS..."
~/.local/bin/mise use --global node@lts 2>/dev/null || true

# ---------- 验证 ----------
echo ""
echo "============================================"
echo "  ✅ WSL 环境配置完成"
echo "============================================"
echo ""
echo "已安装:"
echo "  - zsh:      $(zsh --version 2>/dev/null | head -1)"
echo "  - git:      $(git --version 2>/dev/null)"
echo "  - python3:  $(python3 --version 2>/dev/null)"
echo "  - starship: $(starship --version 2>/dev/null | head -1)"
echo "  - pixi:     $(pixi --version 2>/dev/null)"
echo "  - mise:     $(~/.local/bin/mise --version 2>/dev/null)"
echo ""
echo "请重新打开终端以应用 zsh 配置。"
