<#
.SYNOPSIS
    meta-infra Bootstrap Loader (BIOS Layer)
.DESCRIPTION
    轻量级引导程序，负责：
    1. 检查并安装 Git
    2. 克隆仓库
    3. 启动 Mise 任务系统
.NOTES
    设计理念：最小化 PowerShell 代码，复杂逻辑交给 Mise + Nushell
.EXAMPLE
    irm https://raw.githubusercontent.com/exusiaiwei/meta-infra/master/bootstrap/init.ps1 | iex
#>

#Requires -Version 5.1
$ErrorActionPreference = "Stop"

# ========================================
# 编码设置（解决中文乱码）
# ========================================
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding = [System.Text.Encoding]::UTF8

# ========================================
# 配置
# ========================================
$REPO_URL = "https://github.com/exusiaiwei/meta-infra.git"
$INSTALL_DIR = Join-Path $env:USERPROFILE "meta-infra"

# ========================================
# 辅助函数
# ========================================
function Write-Step {
    param([string]$Message, [string]$Color = "Cyan")
    Write-Host ">> $Message" -ForegroundColor $Color
}

function Test-CommandExists {
    param([string]$Command)
    $null = Get-Command $Command -ErrorAction SilentlyContinue
    return $?
}

# ========================================
# 引导流程
# ========================================
function Start-Bootstrap {
    Clear-Host
    Write-Host ""
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host "  meta-infra 引导程序" -ForegroundColor Cyan
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host ""

    # 步骤 1: 检查/安装 Git
    Write-Step "正在检查 Git..."
    if (-not (Test-CommandExists "git")) {
        Write-Step "Git 未安装，正在安装..." "Yellow"

        if (-not (Test-CommandExists "winget")) {
            Write-Host ""
            Write-Host "[错误] 需要 Winget 来安装 Git" -ForegroundColor Red
            Write-Host ""
            Write-Host "请先安装 App Installer：" -ForegroundColor Yellow
            Write-Host "  1. 访问: https://aka.ms/getwinget"
            Write-Host "  2. 或运行: winget install Git.Git"
            Write-Host ""
            exit 1
        }

        winget install Git.Git --silent --accept-package-agreements --accept-source-agreements

        # 刷新环境变量
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
    }

    Write-Step "[完成] Git 已就绪" "Green"

    # 步骤 2: 克隆/更新仓库
    # 步骤 2: 克隆/更新仓库
    $gitDir = Join-Path $INSTALL_DIR ".git"

    if (Test-Path $gitDir) {
        Write-Step "检测到现有仓库，正在同步..."
        Push-Location $INSTALL_DIR
        try {
            git pull
            if ($LASTEXITCODE -ne 0) { throw "Git pull failed" }
            Write-Step "[完成] 仓库已更新" "Green"
        } catch {
            Write-Host "[警告] 同步失败，请手动检查: $INSTALL_DIR" -ForegroundColor Yellow
        }
        Pop-Location
    } elseif (Test-Path $INSTALL_DIR) {
         # 目录存在但不是 Git 仓库
         Write-Host "[错误] 目标目录已存在但不是 Git 仓库: $INSTALL_DIR" -ForegroundColor Red
         Write-Host "请手动删除或备份该目录后重试。" -ForegroundColor Yellow
         exit 1
    } else {
        Write-Step "正在克隆仓库..."
        git clone $REPO_URL $INSTALL_DIR
        if ($LASTEXITCODE -ne 0) {
            Write-Host "[错误] 克隆失败" -ForegroundColor Red
            exit 1
        }
        Write-Step "[完成] 仓库克隆成功" "Green"
    }

    Write-Step "[完成] 仓库已就绪" "Green"

    # 步骤 3: 移交给 Mise
    Write-Host ""
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host "  启动 Mise 任务系统" -ForegroundColor Cyan
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host ""

    Push-Location $INSTALL_DIR

    # 检查 Mise
    if (Test-CommandExists "mise") {
        Write-Step "Mise 已安装，正在启动向导..."
        mise run bootstrap
    } else {
        Write-Step "Mise 未安装，请运行以下命令：" "Yellow"
        Write-Host ""
        Write-Host "  winget configure manifests/core/base.yaml --accept-configuration-agreements" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "安装完成后重启终端，然后运行：" -ForegroundColor Yellow
        Write-Host "  cd $INSTALL_DIR" -ForegroundColor Cyan
        Write-Host "  mise run bootstrap" -ForegroundColor Cyan
        Write-Host ""
    }

    Pop-Location
}

# 运行引导程序
Start-Bootstrap
