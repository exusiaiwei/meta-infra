#!/usr/bin/env zsh
# =============================================================================
# auto-install.sh — 阶段4自动安装（由 init.ps1 调用）
# =============================================================================
# 用法: zsh auto-install.sh <msys_path> <win_path>
#   msys_path: 仓库的 MSYS2 路径 (如 /c/Users/exusiai/_Meta/meta-infra)
#   win_path:  仓库的 Windows 路径 (如 C:\Users\exusiai\_Meta\meta-infra)
# =============================================================================

REPO_MSYS="${1:?用法: $0 <msys_path> <win_path>}"
REPO_WIN="${2:?用法: $0 <msys_path> <win_path>}"

export PATH="/usr/local/bin:/usr/bin:/bin:$PATH"
cd "$REPO_MSYS" || { echo "[错误] 无法进入目录: $REPO_MSYS"; exit 1; }

echo '============================================'
echo '  安装 Zsh 插件'
echo '============================================'
ZSH_PLUGIN_DIR="${HOME}/.zsh/plugins"
mkdir -p "$ZSH_PLUGIN_DIR"

for plugin in zsh-syntax-highlighting zsh-autosuggestions; do
  if [[ -d "$ZSH_PLUGIN_DIR/$plugin" ]]; then
    echo "  ✓ $plugin (已安装)"
  else
    echo "  + 安装 $plugin..."
    git clone --depth 1 "https://github.com/zsh-users/$plugin.git" "$ZSH_PLUGIN_DIR/$plugin" 2>&1 || echo "  [警告] $plugin 安装失败"
  fi
done

echo ''
echo '============================================'
echo '  安装 CLI 工具 (mise install)'
echo '============================================'
mise install 2>&1 || echo '[警告] 部分工具安装失败'

echo ''
echo '============================================'
echo '  安装 GUI 应用 (winget configure)'
echo '============================================'

# 启用 winget configure 功能（实验性功能，需先开启）
WINGET_SETTINGS="/c/Users/${USERNAME}/AppData/Local/Packages/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe/LocalState/settings.json"
if [[ -f "$WINGET_SETTINGS" ]]; then
  python3 -c "
import json, os
f = r'$(cygpath -w "$WINGET_SETTINGS")'
try:
    with open(f, 'r', encoding='utf-8-sig') as fp: s = json.load(fp)
except: s = {}
s.setdefault('experimentalFeatures', {})['configuration'] = True
with open(f, 'w', encoding='utf-8') as fp: json.dump(s, fp, indent=4)
print('  ✓ winget configure 功能已启用')
" 2>&1 || echo '  [警告] 无法修改 winget 设置'
fi

# 禁止 MSYS2 自动转换 winget.exe 的参数路径
export MSYS2_ARG_CONV_EXCL="*"

winget.exe configure "$REPO_WIN\manifests\core\base.yaml" --accept-configuration-agreements 2>/dev/null
for f in manifests/standard/*.yaml; do
  fname=$(basename "$f")
  echo "  安装: $fname"
  winget.exe configure "$REPO_WIN\manifests\standard\$fname" --accept-configuration-agreements 2>/dev/null
done

echo ''
echo '============================================'
echo '  同步 Dotfiles'
echo '============================================'
zsh "$REPO_MSYS/scripts/sync-dotfiles.sh" 2>&1 || echo '[警告] Dotfiles 同步失败'

echo ''
zsh "$REPO_MSYS/scripts/setup-terminal.sh" 2>&1 || echo '[警告] Windows Terminal 配置失败'

echo ''
echo '============================================'
echo '  配置 WSL 环境'
echo '============================================'
if command -v wsl.exe &>/dev/null; then
  if wsl.exe -l -q 2>/dev/null | head -1 | grep -qi '[a-z]'; then
    echo '检测到 WSL 已安装，自动配置中...'
    wsl.exe -e bash "$REPO_WIN\scripts\setup-wsl.sh" 2>&1 || echo '[警告] WSL 配置失败'
  else
    echo 'WSL 已安装但未初始化发行版'
    echo '请先运行: wsl.exe --install -d Ubuntu'
    echo '然后重启，再运行: mise run setup:wsl'
  fi
else
  echo 'WSL 未安装，跳过'
fi

echo ''
echo '============================================'
echo '  ✅ 全自动安装完成！'
echo '============================================'
echo ''
echo '还需要手动完成的:'
echo '  1. mise run setup:git   → 配置 Git 用户信息 + SSH 密钥'
echo '  2. 如果 WSL 未初始化: wsl --install -d Ubuntu → 重启 → mise run setup:wsl'
echo ''
