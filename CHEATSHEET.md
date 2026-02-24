# 🔧 速查命令

> 跨设备使用，直接复制粘贴

---

## 裸机部署（管理员 PowerShell）

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; irm https://raw.githubusercontent.com/exusiaiwei/meta-infra/master/bootstrap.ps1 | iex
```

---

## 高级环境（zsh）

```bash
cd ~/_Meta/meta-infra && mise install && mise run install
```

---

## 同步最新配置（zsh）

```bash
chezmoi update
```

---

## 重置 chezmoi 并重新部署（管理员 PowerShell）

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; Remove-Item -Recurse -Force "$env:USERPROFILE\.local\share\chezmoi" -ErrorAction SilentlyContinue; irm https://raw.githubusercontent.com/exusiaiwei/meta-infra/master/bootstrap.ps1 | iex
```

> 注：用户配置（Git 用户名/邮箱）保存在 `~/.config/chezmoi/chezmoi.toml`，不会被清除。
> 如果需要完全重置（包括重新输入 Git 信息），加上：`Remove-Item -Recurse -Force "$env:USERPROFILE\.config\chezmoi" -ErrorAction SilentlyContinue;`

---

## 查看 SSH 公钥（添加到 GitHub）

```powershell
Get-Content "$env:USERPROFILE\.ssh\id_ed25519.pub"
```

GitHub 添加地址：https://github.com/settings/keys

---

## 诊断（zsh，排查问题用）

```bash
echo "HOME=$HOME" && which mise && which starship && ls -la ~/.zshenv ~/.zshrc
```
