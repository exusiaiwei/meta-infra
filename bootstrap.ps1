<#
.SYNOPSIS
    meta-infra Bootstrap — 裸机一行命令入口 (chezmoi 版)
.DESCRIPTION
    在全新 Windows 上执行，自动完成：
    1. 安装 Git + chezmoi
    2. chezmoi init --apply（拉取仓库 + 执行所有 run_once 脚本）
       → 安装核心工具（MSYS2, Mise, Starship, WT, Clash Verge）
       → 配置 Windows Terminal
       → 同步 dotfiles
       → 配置 Git + SSH
.EXAMPLE
    irm https://raw.githubusercontent.com/exusiaiwei/meta-infra/master/bootstrap.ps1 | iex
#>

#Requires -Version 5.1
$ErrorActionPreference = "Stop"

# 解除执行策略限制（新装系统默认 Restricted，会阻止 .ps1 脚本运行）
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding = [System.Text.Encoding]::UTF8

function Write-Step {
    param([string]$Message, [string]$Color = "Cyan")
    Write-Host ">> $Message" -ForegroundColor $Color
}

function Refresh-Path {
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
    $extraPaths = @(
        "C:\Program Files\Git\cmd",
        "C:\Program Files\Git\bin",
        "$env:LOCALAPPDATA\Microsoft\WinGet\Links"
    )
    foreach ($p in $extraPaths) {
        if ((Test-Path $p) -and ($env:Path -notlike "*$p*")) {
            $env:Path = "$p;$env:Path"
        }
    }
    # chezmoi
    $chezmoiPaths = Get-ChildItem "$env:LOCALAPPDATA\Microsoft\WinGet\Packages\twpayne.chezmoi_*" -Directory -ErrorAction SilentlyContinue
    foreach ($p in $chezmoiPaths) {
        if ($env:Path -notlike "*$($p.FullName)*") {
            $env:Path = "$($p.FullName);$env:Path"
        }
    }
}

# ========================================
Clear-Host
Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  🚀 meta-infra Bootstrap (chezmoi)" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# 1. Winget 检查
if (-not (Get-Command "winget" -ErrorAction SilentlyContinue)) {
    Write-Host "[错误] 需要 Winget: https://aka.ms/getwinget" -ForegroundColor Red
    exit 1
}

# 2. 安装 Git
if (-not (Get-Command "git" -ErrorAction SilentlyContinue)) {
    Write-Step "安装 Git..."
    winget install Git.Git --source winget --silent --accept-package-agreements --accept-source-agreements
    Start-Sleep -Seconds 2
    Refresh-Path
}
Write-Step "Git ✓" "Green"

# 3. 安装 chezmoi
if (-not (Get-Command "chezmoi" -ErrorAction SilentlyContinue)) {
    Write-Step "安装 chezmoi..."
    winget install twpayne.chezmoi --source winget --silent --accept-package-agreements --accept-source-agreements
    Start-Sleep -Seconds 2
    Refresh-Path
}
Write-Step "chezmoi ✓" "Green"

# 4. 清理上次可能失败的残留状态
$chezmoiSource = "$env:USERPROFILE\.local\share\chezmoi"
$chezmoiConfig = "$env:USERPROFILE\.config\chezmoi"
if ((Test-Path $chezmoiSource) -or (Test-Path $chezmoiConfig)) {
    Write-Step "检测到 chezmoi 残留状态，清理中..."
    Remove-Item -Recurse -Force $chezmoiSource -ErrorAction SilentlyContinue
    Remove-Item -Recurse -Force $chezmoiConfig -ErrorAction SilentlyContinue
    Write-Step "清理完成 ✓" "Green"
}

# 5. 一键部署
Write-Host ""
Write-Step "开始部署..."
Write-Host ""

chezmoi init --apply "https://github.com/exusiaiwei/meta-infra.git"

Write-Host ""
Write-Host "============================================" -ForegroundColor Green
Write-Host "  ✅ 基础环境部署完成！" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Write-Host ""
Write-Host "下一步（打开 Windows Terminal，在 zsh 中运行）:" -ForegroundColor Yellow
Write-Host ""
Write-Host "  cd ~/_Meta/meta-infra && mise install && mise run install" -ForegroundColor Cyan
Write-Host ""
Write-Host "  → 安装 CLI 工具 (Python, Node, jq, yq, ripgrep...)" -ForegroundColor DarkGray
Write-Host "  → 安装 GUI 应用 (VS Code, Obsidian, ...)" -ForegroundColor DarkGray
Write-Host ""
