#!/usr/bin/env zsh
# ============================================================
# meta-infra :: setup-all.sh
# 用法: cd ~/_Meta/meta-infra && zsh scripts/setup-all.sh
# ============================================================

# ---------- 修复 CRLF ----------
find . -name '*.sh' -exec sed -i 's/\r$//' {} + 2>/dev/null
find ./dotfiles -type f -exec sed -i 's/\r$//' {} + 2>/dev/null

# ---------- PATH ----------
setopt nullglob
export PATH="/usr/local/bin:/usr/bin:/bin:$PATH"
export PATH="/c/Windows/System32:/c/Windows:$PATH"
[[ -d "$HOME/AppData/Local/Microsoft/WinGet/Links" ]] && export PATH="$HOME/AppData/Local/Microsoft/WinGet/Links:$PATH"
[[ -d "$HOME/.local/share/mise/bin" ]] && export PATH="$HOME/.local/share/mise/bin:$PATH"
[[ -d "$HOME/.local/bin" ]] && export PATH="$HOME/.local/bin:$PATH"
for d in "$HOME/AppData/Local/Microsoft/WinGet/Packages"/jdx.mise_*/mise/bin; do
  [[ -d "$d" ]] && export PATH="$d:$PATH"
done
export PATH="/c/Program Files/starship/bin:/c/Program Files/Git/cmd:$PATH"

cd "${0:a:h:h}"
REPO_WIN=$(cygpath -w "$(pwd)")
export MSYS2_ARG_CONV_EXCL="*"

echo ''
echo '╔══════════════════════════════════════════╗'
echo '║   meta-infra 环境配置                    ║'
echo '╚══════════════════════════════════════════╝'

# ==================== 1. Zsh 插件 ====================
echo ''
echo '>>> 1/6: Zsh 插件'
pacman -S --noconfirm --needed zsh-syntax-highlighting zsh-autosuggestions 2>&1 || true

# ==================== 2. Dotfiles ====================
echo ''
echo '>>> 2/6: Dotfiles 同步'
zsh scripts/sync-dotfiles.sh 2>&1 || echo '[!] Dotfiles 同步失败'

# ==================== 3. CLI 工具 ====================
echo ''
echo '>>> 3/6: CLI 工具 (mise)'
if command -v mise &>/dev/null; then
  mise trust -a 2>/dev/null || true
  mise install 2>&1 || echo '[!] 部分工具安装失败'
else
  echo '[跳过] mise 不在 PATH 中'
  echo '  手动运行: mise trust && mise install'
fi

# ==================== 4. GUI 应用 ====================
echo ''
echo '>>> 4/6: GUI 应用 (winget install)'
echo ''

# 直接用 winget install，不依赖 winget configure
install_from_yaml() {
  local yaml_file="$1"
  local name=$(basename "$yaml_file" .yaml)
  echo "  [$name]"
  # 从 yaml 提取 winget 包 ID（settings 下面的 id 行，不包含 DSC 资源 ID）
  grep -A1 'settings:' "$yaml_file" 2>/dev/null | grep 'id:' | sed 's/.*id:\s*//' | tr -d ' \r' | while IFS= read -r pkg_id; do
    [[ -z "$pkg_id" ]] && continue
    [[ "$pkg_id" == *"Microsoft.WinGet"* ]] && continue
    echo "    $pkg_id"
    winget.exe install "$pkg_id" --source winget --silent --accept-package-agreements --accept-source-agreements 2>&1 | tail -1 || true
  done
}

# 核心层（自动）
echo '  [核心层 - 自动安装]'
install_from_yaml manifests/core/base.yaml

# 标准层（选择）
echo ''
echo '  [标准层 - 选择安装]'
for f in manifests/standard/*.yaml; do
  modname=$(basename "$f" .yaml)
  echo -n "  安装 ${modname}? [Y/n] "
  read -r choice
  if [[ "$choice" == "n" || "$choice" == "N" ]]; then
    echo "    跳过"
  else
    install_from_yaml "$f"
  fi
done

# ==================== 5. WSL ====================
echo ''
echo '>>> 5/6: WSL'
if command -v wsl.exe &>/dev/null; then
  # 检查 WSL 是否有发行版
  if wsl.exe -l -q 2>/dev/null | grep -qi 'ubuntu\|debian'; then
    echo -n '  WSL 已安装，配置环境? [y/N] '
    read -r choice
    if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
      WSL_SCRIPT=$(echo "$REPO_WIN" | sed 's|\\|/|g; s|^\([A-Za-z]\):|/mnt/\L\1|')
      wsl.exe -e bash "${WSL_SCRIPT}/scripts/setup-wsl.sh" || echo '[!] WSL 配置失败'
    fi
  else
    echo '  WSL 已安装但无发行版'
    echo '  运行: wsl --install -d Ubuntu'
  fi
else
  echo '  [跳过] WSL 未安装'
  echo '  运行: wsl --install'
fi

# ==================== 6. Git + SSH ====================
echo ''
echo '>>> 6/6: Git + SSH'

# Git 用户信息
current_name=$(git config --global user.name 2>/dev/null || true)
current_email=$(git config --global user.email 2>/dev/null || true)
if [[ -n "$current_name" ]]; then
  echo "  当前: $current_name <$current_email>"
  echo -n '  重新配置? [y/N] '
  read -r choice
  [[ "$choice" != "y" && "$choice" != "Y" ]] && current_name="KEEP"
fi
if [[ "$current_name" != "KEEP" ]]; then
  echo -n '  Git 用户名: '
  read -r name
  echo -n '  Git 邮箱: '
  read -r email
  git config --global user.name "$name"
  git config --global user.email "$email"
fi
git config --global init.defaultBranch main
git config --global core.autocrlf input
git config --global pull.rebase true
git config --global push.autoSetupRemote true

# SSH 密钥
SSH_KEY="$HOME/.ssh/id_ed25519"
if [[ -f "$SSH_KEY" ]]; then
  echo ''
  echo "  SSH 密钥已存在"
  echo "  $(cat ${SSH_KEY}.pub)"
else
  echo ''
  email=$(git config --global user.email 2>/dev/null || true)
  hname=$(hostname 2>/dev/null || echo "pc")
  uname=$(whoami 2>/dev/null || echo "user")
  default_comment="${uname}@${hname}"
  echo -n "  SSH 备注 [${default_comment}]: "
  read -r comment
  comment="${comment:-$default_comment}"
  mkdir -p "$HOME/.ssh"
  ssh-keygen -t ed25519 -C "$comment" -f "$SSH_KEY" -N "" 2>&1
  echo ''
  echo '  公钥（复制到 https://github.com/settings/keys）:'
  echo ''
  cat "${SSH_KEY}.pub"
fi

echo ''
echo '╔══════════════════════════════════════════╗'
echo '║   完成！重启终端生效                     ║'
echo '╚══════════════════════════════════════════╝'
echo ''
