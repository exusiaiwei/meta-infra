#!/usr/bin/env zsh
# =============================================================================
# setup-wsl.sh — WSL 一键配置
# =============================================================================
# 可以从 MSYS2 zsh 或 WSL 内直接运行
# 从 MSYS2 调用时会自动通过 wsl.exe 跳转
# =============================================================================

echo "============================================"
echo "  🐧 WSL 环境配置"
echo "============================================"
echo ""

# ---------- 检测环境，自动跳转到 WSL ----------
if ! grep -qi microsoft /proc/version 2>/dev/null; then
  # 不在 WSL 里，尝试通过 wsl.exe 调用
  if command -v wsl.exe &>/dev/null; then
    echo "  检测到 MSYS2 环境，通过 wsl.exe 执行..."
    # WSL 可以通过 /mnt/c/ 访问 Windows 文件
    SCRIPT_WIN=$(cygpath -w "${0:a}" 2>/dev/null || echo "$0")
    SCRIPT_WSL=$(echo "$SCRIPT_WIN" | sed 's|\\|/|g; s|^\([A-Za-z]\):|/mnt/\L\1|')
    wsl.exe -e bash "$SCRIPT_WSL"
    exit $?
  else
    echo "❌ 未检测到 WSL，请先安装 WSL"
    echo "  wsl --install"
    exit 1
  fi
fi

# ---------- 免密 sudo (仅限个人开发环境) ----------
echo ">> 配置免密码 sudo..."
echo "$USER ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/$USER >/dev/null
sudo chmod 0440 /etc/sudoers.d/$USER

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

# ---------- 同步 Windows 的 Git 配置 ----------
WIN_HOME="/mnt/c/Users/${USER:-$(whoami)}"
if [[ -f "$WIN_HOME/.gitconfig" ]] && [[ ! -f "$HOME/.gitconfig" ]]; then
  echo ">> 同步 Windows Git 配置..."
  cp "$WIN_HOME/.gitconfig" "$HOME/.gitconfig"
  echo "   ✅ Git 配置已同步"
elif [[ -f "$HOME/.gitconfig" ]]; then
  echo "   ✅ Git 配置已存在"
fi

# ---------- 同步 Windows 的 SSH 密钥 ----------
WIN_SSH="$WIN_HOME/.ssh"
if [[ -d "$WIN_SSH" ]] && [[ ! -f "$HOME/.ssh/id_ed25519" ]]; then
  echo ">> 同步 Windows SSH 密钥..."
  mkdir -p "$HOME/.ssh"
  cp "$WIN_SSH/id_ed25519" "$HOME/.ssh/id_ed25519" 2>/dev/null
  cp "$WIN_SSH/id_ed25519.pub" "$HOME/.ssh/id_ed25519.pub" 2>/dev/null
  cp "$WIN_SSH/known_hosts" "$HOME/.ssh/known_hosts" 2>/dev/null
  chmod 700 "$HOME/.ssh"
  chmod 600 "$HOME/.ssh/id_ed25519" 2>/dev/null
  chmod 644 "$HOME/.ssh/id_ed25519.pub" 2>/dev/null
  echo "   ✅ SSH 密钥已同步"
elif [[ -f "$HOME/.ssh/id_ed25519" ]]; then
  echo "   ✅ SSH 密钥已存在"
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
