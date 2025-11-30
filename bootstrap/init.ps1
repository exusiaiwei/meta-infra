# ================================================================================================
# meta-infra - Bootstrap Loader (BIOS Layer)
# ================================================================================================
# 用途：轻量级引导程序，仅负责：
#   1. 检查并安装 Git
#   2. 克隆仓库
#   3. 启动 Mise 任务系统
#
# 设计理念：最小化 PowerShell 代码，所有复杂逻辑交给 Mise + Nushell
#
# 使用方式：
#   irm https://raw.githubusercontent.com/用户名/meta-infra/main/bootstrap/init.ps1 | iex
# ================================================================================================

#Requires -Version 5.1
$ErrorActionPreference = "Stop"

# ========================================
# 配置
# ========================================
$REPO_URL = "https://github.com/用户名/meta-infra.git"  # TODO: 替换
$INSTALL_DIR = Join-Path $env:USERPROFILE "meta-infra"

# ========================================
# 最小化辅助函数
# ========================================
function Write-Step {
    param([string]$Message, [string]$Color = "Cyan")
    Write-Host "➤ $Message" -ForegroundColor $Color
}

function Test-CommandExists {
    param([string]$Command)
    $null = Get-Command $Command -ErrorAction SilentlyContinue
    return $?
}

# ========================================
# BIOS 引导流程
# ========================================
function Start-Bootstrap {
    Clear-Host
    Write-Host ""
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host "  🚀 meta-infra Bootstrap Loader" -ForegroundColor Cyan
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host ""

    # 步骤 1: 检查/安装 Git
    Write-Step "检查 Git..."
    if (-not (Test-CommandExists "git")) {
        Write-Step "Git 未安装，正在安装..." "Yellow"

        if (-not (Test-CommandExists "winget")) {
            Write-Host ""
            Write-Host "❌ 需要 Winget 来安装 Git" -ForegroundColor Red
            Write-Host ""
            Write-Host "请先安装 App Installer:" -ForegroundColor Yellow
            Write-Host "  1. 访问: https://aka.ms/getwinget"
            Write-Host "  2. 或运行: winget install Git.Git"
            Write-Host ""
            exit 1
        }

        winget install Git.Git --silent --accept-package-agreements --accept-source-agreements

        # 刷新环境变量
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
    }

    Write-Step "✓ Git 已就绪" "Green"

    # 步骤 2: 克隆/更新仓库
    if (Test-Path $INSTALL_DIR) {
        Write-Step "仓库已存在，正在更新..."
        Push-Location $INSTALL_DIR
        git pull
        Pop-Location
    } else {
        Write-Step "克隆仓库: $REPO_URL"
        git clone $REPO_URL $INSTALL_DIR
    }

    Write-Step "✓ 仓库已就绪" "Green"

    # 步骤 3: 移交给 Mise
    Write-Host ""
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host "  🎯 启动 Mise 任务系统" -ForegroundColor Cyan
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host ""

    Push-Location $INSTALL_DIR

    # 检查 Mise
    if (Test-CommandExists "mise") {
        Write-Step "Mise 已安装，启动安装向导..."
        mise run bootstrap
    } else {
        Write-Step "Mise 未安装，请先运行 Winget 安装:" "Yellow"
        Write-Host ""
        Write-Host "  winget configure manifests/core/base.yaml" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "然后运行:" -ForegroundColor Yellow
        Write-Host "  mise run bootstrap" -ForegroundColor Cyan
        Write-Host ""
    }

    Pop-Location
}

# 运行引导程序
Start-Bootstrap
