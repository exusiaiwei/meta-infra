# =============================================================================
# .zshenv — 所有 zsh 实例都会加载（包括非交互式，如 AI agent 调用）
# =============================================================================
# 这个文件只设置 PATH 和环境变量，不做任何交互式配置

# MSYS2 工具链
export PATH="/clangarm64/bin:/usr/local/bin:/usr/bin:/bin:$PATH"

# Mise（如果存在）
if [ -d "$HOME/.local/share/mise/bin" ]; then
  export PATH="$HOME/.local/share/mise/bin:$PATH"
fi

# Pixi（如果存在）
if [ -d "$HOME/.pixi/bin" ]; then
  export PATH="$HOME/.pixi/bin:$PATH"
fi

# 编辑器
export EDITOR="code"
export VISUAL="code"

# 语言
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"
