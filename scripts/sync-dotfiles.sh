#!/usr/bin/env zsh
# =============================================================================
# sync-dotfiles.sh — 配置文件符号链接同步
# =============================================================================
# 将仓库中的 dotfiles 链接到系统对应位置
# 支持 MSYS2 (Windows) 和 WSL (Linux) 两种环境
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/../dotfiles" && pwd)"

echo "============================================"
echo "  🔗 Dotfiles 同步"
echo "============================================"
echo ""
echo "源目录: $DOTFILES_DIR"
echo ""

# ---------- 辅助函数 ----------
link_file() {
  local src="$1"
  local dst="$2"
  local name="$(basename "$src")"

  if [[ -L "$dst" ]]; then
    # 已经是符号链接
    local current=$(readlink "$dst")
    if [[ "$current" == "$src" ]]; then
      echo "  ✓ $name (已链接)"
      return
    else
      echo "  ↻ $name (更新链接: $current → $src)"
      rm "$dst"
    fi
  elif [[ -f "$dst" ]]; then
    # 已存在普通文件，备份
    echo "  📦 $name (备份旧文件为 ${dst}.bak)"
    mv "$dst" "${dst}.bak"
  else
    echo "  + $name (新建链接)"
  fi

  ln -sf "$src" "$dst"
}

# ---------- 检测环境 ----------
if grep -qi microsoft /proc/version 2>/dev/null; then
  ENV="wsl"
  echo "检测到环境: WSL (Linux)"
  TARGET_HOME="$HOME"
elif [[ -d "/c/Users" ]]; then
  ENV="msys2"
  echo "检测到环境: MSYS2 (Windows)"
  # MSYS2 的 $HOME 通常是 /home/<user> 或 /c/msys64/home/<user>
  TARGET_HOME="$HOME"
else
  echo "❌ 无法识别环境"
  exit 1
fi

echo ""

# ---------- 同步 zsh 配置 ----------
echo ">> Zsh 配置:"
link_file "$DOTFILES_DIR/.zshenv" "$TARGET_HOME/.zshenv"
link_file "$DOTFILES_DIR/.zshrc" "$TARGET_HOME/.zshrc"

# ---------- 同步 Starship 配置 ----------
echo ""
echo ">> Starship 配置:"

if [[ "$ENV" == "msys2" ]]; then
  # Windows: Starship 配置在 %USERPROFILE%/.config/starship.toml
  WIN_HOME="/c/Users/$(whoami)"
  mkdir -p "$WIN_HOME/.config"
  link_file "$DOTFILES_DIR/starship.toml" "$WIN_HOME/.config/starship.toml"
else
  # WSL/Linux
  mkdir -p "$TARGET_HOME/.config"
  link_file "$DOTFILES_DIR/starship.toml" "$TARGET_HOME/.config/starship.toml"
fi

# ---------- 同步 Git 配置（如果存在）----------
if [[ -f "$DOTFILES_DIR/.gitconfig" ]]; then
  echo ""
  echo ">> Git 配置:"
  link_file "$DOTFILES_DIR/.gitconfig" "$TARGET_HOME/.gitconfig"
fi

# ---------- OneDrive 云盘链接 (仅 MSYS2/Windows) ----------
if [[ "$ENV" == "msys2" ]]; then
  echo ""
  echo ">> OneDrive 云盘链接:"
  WIN_HOME="/c/Users/$(whoami)"
  META_DIR="$WIN_HOME/_Meta"
  CLOUD_LINK="$META_DIR/99_Cloud"

  # 自动检测 OneDrive 文件夹（个人版 / 企业版名称不同）
  ONEDRIVE_DIR=""
  for candidate in \
    "$WIN_HOME/OneDrive - MSFT"/* \
    "$WIN_HOME/OneDrive"/* \
    "$WIN_HOME/OneDrive - Personal"/*; do
    parent="$(dirname "$candidate")"
    if [[ -d "$parent" ]]; then
      ONEDRIVE_DIR="$parent"
      break
    fi
  done

  if [[ -n "$ONEDRIVE_DIR" ]]; then
    # 查找 OneDrive 下的同步文件夹（优先找 Exusiai_Ark，否则用根目录）
    if [[ -d "$ONEDRIVE_DIR/Exusiai_Ark" ]]; then
      CLOUD_TARGET="$ONEDRIVE_DIR/Exusiai_Ark"
    else
      CLOUD_TARGET="$ONEDRIVE_DIR"
    fi

    mkdir -p "$META_DIR"
    if [[ -L "$CLOUD_LINK" ]]; then
      echo "  ✓ 99_Cloud (已链接)"
    elif [[ -d "$CLOUD_LINK" ]]; then
      echo "  ⚠ 99_Cloud 是真实目录，跳过"
    else
      ln -sf "$CLOUD_TARGET" "$CLOUD_LINK"
      echo "  + 99_Cloud → $CLOUD_TARGET"
    fi
  else
    echo "  ⚠ 未检测到 OneDrive 文件夹，跳过"
  fi
fi

echo ""
echo "============================================"
echo "  ✅ Dotfiles 同步完成"
echo "============================================"
echo ""
echo "提示: 重新打开终端以应用更改"
