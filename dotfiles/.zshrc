# =============================================================================
# .zshrc — 仅交互式 shell 加载
# =============================================================================

# ---------- History ----------
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE

# ---------- 补全 ----------
autoload -Uz compinit && compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# ---------- 按键绑定 ----------
bindkey -e  # Emacs 模式

# ---------- Aliases ----------
alias ll='ls -lah --color=auto'
alias la='ls -A --color=auto'
alias l='ls -CF --color=auto'
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline -20'
alias gd='git diff'

# ---------- Mise ----------
if command -v mise &>/dev/null; then
  eval "$(mise activate zsh)"
fi

# ---------- Starship ----------
if command -v starship &>/dev/null; then
  eval "$(starship init zsh)"
fi
