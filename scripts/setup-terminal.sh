#!/usr/bin/env zsh
# =============================================================================
# setup-terminal.sh — 自动将 zsh 添加到 Windows Terminal
# =============================================================================
# 在 Windows Terminal 的 settings.json 中注入 zsh profile
# 如果已存在则跳过
# =============================================================================
set -euo pipefail

echo '============================================'
echo '  🖥️  配置 Windows Terminal'
echo '============================================'
echo ''

# Windows Terminal settings.json 路径
WT_SETTINGS_DIR="/c/Users/${USERNAME:-$(whoami)}/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState"
WT_SETTINGS="$WT_SETTINGS_DIR/settings.json"

if [[ ! -f "$WT_SETTINGS" ]]; then
  echo '  ⚠ Windows Terminal 配置文件未找到，跳过'
  echo "    (预期路径: $WT_SETTINGS)"
  exit 0
fi

# 检查 zsh profile 是否已存在
if grep -q 'msys64.*zsh' "$WT_SETTINGS" 2>/dev/null; then
  echo '  ✓ zsh profile 已存在'
  exit 0
fi

# 备份
cp "$WT_SETTINGS" "${WT_SETTINGS}.bak"
echo '  📦 已备份 settings.json'

# 用 python 注入 zsh profile（因为需要操作 JSON）
python3 << 'PYEOF'
import json, os, sys

settings_path = os.environ.get("WT_SETTINGS_PATH", r"PLACEHOLDER")
# 从环境中获取路径
wt_dir = os.path.join(
    os.environ.get("LOCALAPPDATA", ""),
    "Packages", "Microsoft.WindowsTerminal_8wekyb3d8bbwe", "LocalState"
)
settings_path = os.path.join(wt_dir, "settings.json")

try:
    with open(settings_path, "r", encoding="utf-8-sig") as f:
        settings = json.load(f)
except Exception as e:
    print(f"  ❌ 读取配置失败: {e}")
    sys.exit(1)

profiles = settings.setdefault("profiles", {}).setdefault("list", [])

# 检查是否已存在
for p in profiles:
    cmd = p.get("commandline", "")
    if "zsh" in cmd.lower() and "msys" in cmd.lower():
        print("  ✓ zsh profile 已存在")
        sys.exit(0)

# 固定 GUID（所有设备一致，方便同步）
zsh_profile = {
    "guid": "{17da3cac-b318-431e-8a3e-7fcdefe6d114}",
    "name": "zsh",
    "commandline": "C:\\msys64\\usr\\bin\\zsh.exe --login",
    "icon": "C:\\msys64\\msys2.ico",
    "startingDirectory": "%USERPROFILE%",
    "env": {
        "MSYSTEM": "MSYS",
        "CHERE_INVOKING": "1"
    }
}

# 插入到列表最前面
profiles.insert(0, zsh_profile)

# 设为默认 profile
settings["defaultProfile"] = zsh_profile["guid"]

with open(settings_path, "w", encoding="utf-8") as f:
    json.dump(settings, f, indent=4, ensure_ascii=False)

print("  + zsh profile 已添加并设为默认")
PYEOF

echo ''
echo '  ✅ Windows Terminal 配置完成'
echo '  提示: 重新打开 Windows Terminal 即可看到 zsh 选项'
