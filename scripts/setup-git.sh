#!/usr/bin/env zsh
# =============================================================================
# setup-git.sh — Git 配置 + SSH 密钥生成
# =============================================================================
set -euo pipefail

echo "============================================"
echo "  🔧 Git & SSH 配置"
echo "============================================"
echo ""

# ---------- Git 用户信息 ----------
current_name=$(git config --global user.name 2>/dev/null || echo "")
current_email=$(git config --global user.email 2>/dev/null || echo "")

if [[ -n "$current_name" && -n "$current_email" ]]; then
  echo "当前 Git 配置:"
  echo "  user.name  = $current_name"
  echo "  user.email = $current_email"
  echo ""
  read "reply?是否重新配置？[y/N] "
  if [[ ! "$reply" =~ ^[Yy]$ ]]; then
    echo "保持现有配置。"
  else
    current_name=""
  fi
fi

if [[ -z "$current_name" ]]; then
  read "name?请输入 Git 用户名: "
  read "email?请输入 Git 邮箱: "
  git config --global user.name "$name"
  git config --global user.email "$email"
  echo "✅ Git 用户信息已配置"
fi

# ---------- Git 常用设置 ----------
git config --global init.defaultBranch main
git config --global core.autocrlf input
git config --global pull.rebase true
git config --global push.autoSetupRemote true
git config --global core.editor "code --wait"
echo "✅ Git 常用设置已配置"

# ---------- SSH 密钥 ----------
SSH_KEY="$HOME/.ssh/id_ed25519"

if [[ -f "$SSH_KEY" ]]; then
  echo ""
  echo "SSH 密钥已存在: $SSH_KEY"
  echo "公钥内容:"
  echo ""
  cat "${SSH_KEY}.pub"
else
  echo ""
  echo "正在生成 SSH 密钥..."
  email=$(git config --global user.email)
  mkdir -p "$HOME/.ssh"
  ssh-keygen -t ed25519 -C "$email" -f "$SSH_KEY" -N ""
  echo ""
  echo "✅ SSH 密钥已生成"
  echo ""
  echo "请将以下公钥添加到 GitHub (https://github.com/settings/keys):"
  echo ""
  cat "${SSH_KEY}.pub"
fi

echo ""
echo "============================================"
echo "  ✅ Git & SSH 配置完成"
echo "============================================"
