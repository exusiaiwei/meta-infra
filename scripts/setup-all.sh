#!/usr/bin/env zsh
# ============================================================
# meta-infra :: setup-all.sh
# 在 zsh 里运行，完成 init.ps1 之后的所有配置
# 用法: cd ~/_Meta/meta-infra && zsh scripts/setup-all.sh
# ============================================================

# nullglob: glob 无匹配时返回空而非报错
setopt nullglob

# ---------- 路径修复 ----------
export PATH="/usr/local/bin:/usr/bin:/bin:$PATH"
_add_path() { [[ -d "$1" ]] && export PATH="$1:$PATH"; }
_add_path "/c/Windows/System32"
_add_path "/c/Windows"
_add_path "$HOME/AppData/Local/Microsoft/WinGet/Links"
_add_path "$HOME/.local/share/mise/bin"
_add_path "$HOME/.local/bin"
_add_path "/c/Program Files/starship/bin"
_add_path "$HOME/.pixi/bin"
for d in "$HOME/AppData/Local/Microsoft/WinGet/Packages"/jdx.mise_*/mise/bin; do
  _add_path "$d"
done
_add_path "/c/Program Files/Git/cmd"
unset -f _add_path

REPO_DIR="${0:a:h:h}"  # 脚本所在目录的父目录
cd "$REPO_DIR"

echo ''
echo '╔══════════════════════════════════════════╗'
echo '║   meta-infra :: 完整环境配置             ║'
echo '╚══════════════════════════════════════════╝'
echo ''

# ---------- 1. Zsh 插件 ----------
echo '━━━ 1/6: Zsh 插件 (pacman) ━━━'
pacman -S --noconfirm --needed zsh-syntax-highlighting zsh-autosuggestions 2>&1 || echo '[警告] Zsh 插件安装失败'
echo ''

# ---------- 2. Dotfiles 同步 ----------
echo '━━━ 2/6: Dotfiles 同步 ━━━'
zsh scripts/sync-dotfiles.sh
echo ''

# ---------- 3. Mise 信任 + CLI 工具 ----------
echo '━━━ 3/6: CLI 工具 (mise) ━━━'
if command -v mise &>/dev/null; then
  mise trust -a 2>/dev/null
  mise install 2>&1 || echo '[警告] 部分 CLI 工具安装失败'
else
  echo '[跳过] mise 未找到，请确认 PATH 中包含 mise'
fi
echo ''

# ---------- 4. GUI 应用 (winget) ----------
echo '━━━ 4/6: GUI 应用 (winget) ━━━'
export MSYS2_ARG_CONV_EXCL="*"

# 检测 winget configure 是否可用
USE_CONFIGURE=0
if winget.exe configure --help &>/dev/null; then
  USE_CONFIGURE=1
fi

# 核心层（自动装）
echo '  [核心层] base.yaml'
if [[ $USE_CONFIGURE -eq 1 ]]; then
  winget.exe configure "$(cygpath -w manifests/core/base.yaml)" --accept-configuration-agreements 2>/dev/null || true
else
  grep 'id:' manifests/core/base.yaml 2>/dev/null | grep -v WinGet | grep -v '_' | sed 's/.*id:\s*//' | tr -d '[:space:]' | while read -r pkg_id; do
    [[ -z "$pkg_id" ]] && continue
    echo "    安装: $pkg_id"
    winget.exe install "$pkg_id" --source winget --silent --accept-package-agreements --accept-source-agreements 2>/dev/null || true
  done
fi

# 标准层（逐个选择）
echo ''
echo '  [标准层] 选择要安装的模块：'
for f in manifests/standard/*.yaml; do
  fname=$(basename "$f")
  modname="${fname%.yaml}"
  echo -n "  安装 ${modname}? [Y/n] "
  read -r choice
  if [[ "$choice" == "n" || "$choice" == "N" ]]; then
    echo "    跳过 $modname"
    continue
  fi
  echo "    安装: $fname"
  if [[ $USE_CONFIGURE -eq 1 ]]; then
    winget.exe configure "$(cygpath -w "$f")" --accept-configuration-agreements 2>/dev/null || true
  else
    grep 'id:' "$f" 2>/dev/null | grep -v WinGet | grep -v '_' | sed 's/.*id:\s*//' | tr -d '[:space:]' | while read -r pkg_id; do
      [[ -z "$pkg_id" ]] && continue
      echo "      安装: $pkg_id"
      winget.exe install "$pkg_id" --source winget --silent --accept-package-agreements --accept-source-agreements 2>/dev/null || true
    done
  fi
done
echo ''

# ---------- 5. WSL (可选) ----------
echo '━━━ 5/6: WSL 环境 ━━━'
echo -n '  配置 WSL? [y/N] '
read -r wsl_choice
if [[ "$wsl_choice" == "y" || "$wsl_choice" == "Y" ]]; then
  zsh scripts/setup-wsl.sh
else
  echo '  跳过 WSL 配置'
fi
echo ''

# ---------- 6. Git + SSH ----------
echo '━━━ 6/6: Git + SSH ━━━'
echo -n '  配置 Git + SSH? [Y/n] '
read -r git_choice
if [[ "$git_choice" != "n" && "$git_choice" != "N" ]]; then
  zsh scripts/setup-git.sh
else
  echo '  跳过 Git 配置'
fi

echo ''
echo '╔══════════════════════════════════════════╗'
echo '║   ✅ 全部配置完成！                      ║'
echo '╚══════════════════════════════════════════╝'
echo ''
echo '提示：重启终端让所有配置生效'
echo ''
