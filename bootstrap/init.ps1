<#
.SYNOPSIS
    meta-infra Bootstrap Loader (全自动引导)
.DESCRIPTION
    裸机一键配置，全程自动：
    1. 安装 Git + MSYS2 + Mise + Starship
    2. 克隆仓库
    3. 自动调 zsh 完成后续安装
    无需手动切换 shell。
.EXAMPLE
    irm https://raw.githubusercontent.com/exusiaiwei/meta-infra/master/bootstrap/init.ps1 | iex
#>

#Requires -Version 5.1
$ErrorActionPreference = "Stop"

# 编码设置
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding = [System.Text.Encoding]::UTF8

# 配置
$REPO_URL = "https://github.com/exusiaiwei/meta-infra.git"
$INSTALL_DIR = Join-Path $env:USERPROFILE "_Meta\meta-infra"
$ZSH_EXE = "C:\msys64\usr\bin\zsh.exe"
$MSYS2_ENV = "MSYSTEM=MSYS"

# 辅助函数
function Write-Step {
    param([string]$Message, [string]$Color = "Cyan")
    Write-Host ">> $Message" -ForegroundColor $Color
}

function Test-CommandExists {
    param([string]$Command)
    $null = Get-Command $Command -ErrorAction SilentlyContinue
    return $?
}

function Refresh-Path {
    # 从注册表重新读取 PATH
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

    # 手动追加常见安装路径（winget 安装后注册表可能还没写入）
    $extraPaths = @(
        "C:\Program Files\Git\cmd",
        "C:\Program Files\Git\bin",
        "C:\msys64\usr\bin",
        "$env:LOCALAPPDATA\Programs\mise\bin",
        "$env:LOCALAPPDATA\Programs\starship\bin",
        "C:\Program Files\Starship\bin"
    )
    foreach ($p in $extraPaths) {
        if ((Test-Path $p) -and ($env:Path -notlike "*$p*")) {
            $env:Path = "$p;$env:Path"
        }
    }
}

function Install-WingetPackage {
    param([string]$Id, [string]$Name)
    Write-Step "安装 $Name..."
    # --source winget: 避免搜索 msstore 源（新系统 Store 未初始化会报错）
    winget install $Id --source winget --silent --accept-package-agreements --accept-source-agreements
    Start-Sleep -Seconds 2  # 等待安装程序写入 PATH
    Refresh-Path
}

# ========================================
# 引导流程
# ========================================
function Start-Bootstrap {
    Clear-Host
    Write-Host ""
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host "  meta-infra 全自动引导" -ForegroundColor Cyan
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host ""

    # ---- 检查 Winget ----
    if (-not (Test-CommandExists "winget")) {
        Write-Host "[错误] 需要 Winget，请先安装: https://aka.ms/getwinget" -ForegroundColor Red
        exit 1
    }

    # ---- 阶段 1: 安装核心工具 ----
    Write-Host "阶段 1/3: 安装核心工具" -ForegroundColor Yellow
    Write-Host ""

    # Git
    if (-not (Test-CommandExists "git")) {
        Install-WingetPackage "Git.Git" "Git"
    }
    Write-Step "Git ✓" "Green"

    # MSYS2
    if (-not (Test-Path $ZSH_EXE)) {
        Install-WingetPackage "MSYS2.MSYS2" "MSYS2 (Zsh + Unix 工具链)"
    }
    Write-Step "MSYS2 ✓" "Green"

    # Mise
    if (-not (Test-CommandExists "mise")) {
        Install-WingetPackage "jdx.mise" "Mise (环境管理)"
    }
    Write-Step "Mise ✓" "Green"

    # Starship
    if (-not (Test-CommandExists "starship")) {
        Install-WingetPackage "Starship.Starship" "Starship (提示符)"
    }
    Write-Step "Starship ✓" "Green"

    # Windows Terminal
    if (-not (Test-CommandExists "wt")) {
        Install-WingetPackage "Microsoft.WindowsTerminal" "Windows Terminal"
    }
    Write-Step "Windows Terminal ✓" "Green"

    # Clash Verge Rev（代理，后续下载加速）
    if (-not (Get-Command "clash-verge" -ErrorAction SilentlyContinue)) {
        Install-WingetPackage "ClashVergeRev.ClashVergeRev" "Clash Verge Rev (代理)"
    }
    Write-Step "Clash Verge ✓" "Green"

    Write-Host ""
    Write-Host "  💡 建议：打开 Clash Verge，导入订阅并开启系统代理" -ForegroundColor Yellow
    Write-Host "     后续下载速度会显著提升" -ForegroundColor DarkGray
    Write-Host ""
    Read-Host "  配置好代理后按 Enter 继续（或直接按 Enter 跳过）"

    Write-Host ""

    # ---- 阶段 2: 系统精调（可选）----
    Write-Host "阶段 2/4: 系统精调" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  推荐在新装系统上运行，去除广告、遥测、Copilot 等" -ForegroundColor DarkGray
    Write-Host "  工具: Chris Titus Tech's winutil (开源社区标准工具)" -ForegroundColor DarkGray
    Write-Host ""
    $tweakChoice = Read-Host "  是否运行系统精调？[Y/n]"
    if ($tweakChoice -ne "n" -and $tweakChoice -ne "N") {
        Write-Step "启动 winutil..."
        try {
            Invoke-RestMethod https://christitus.com/win | Invoke-Expression
            Write-Step "系统精调完成 ✓" "Green"
        } catch {
            Write-Host "[警告] winutil 启动失败，可稍后手动运行: irm https://christitus.com/win | iex" -ForegroundColor Yellow
        }
    } else {
        Write-Step "跳过系统精调（可稍后运行: mise run tweak）" "DarkGray"
    }

    Write-Host ""

    # ---- 阶段 3: 克隆/更新仓库 ----
    Write-Host "阶段 3/4: 准备仓库" -ForegroundColor Yellow
    Write-Host ""

    $gitDir = Join-Path $INSTALL_DIR ".git"
    $miseToml = Join-Path $INSTALL_DIR "mise.toml"

    if (Test-Path $gitDir) {
        # 情况 1: 已有 Git 仓库 → pull 更新
        Write-Step "仓库已存在，同步中..."
        Push-Location $INSTALL_DIR
        try { git pull } catch { Write-Host "[警告] 同步失败（可能无网络）" -ForegroundColor Yellow }
        Pop-Location
    } elseif ((Test-Path $INSTALL_DIR) -and (Test-Path $miseToml)) {
        # 情况 2: 手动放置的 ZIP 解压目录 → 直接使用
        Write-Step "检测到手动放置的仓库文件，直接使用" "Yellow"
        Write-Host "  提示: 联网后运行 'git init && git remote add origin $REPO_URL' 可转为 Git 仓库" -ForegroundColor DarkGray
    } elseif (Test-Path $INSTALL_DIR) {
        Write-Host "[错误] 目录已存在但不是 meta-infra 仓库: $INSTALL_DIR" -ForegroundColor Red
        exit 1
    } else {
        # 情况 3: 全新安装 → 尝试 clone
        Write-Step "克隆仓库..."
        $parentDir = Split-Path $INSTALL_DIR -Parent
        if (-not (Test-Path $parentDir)) { New-Item -ItemType Directory -Path $parentDir -Force | Out-Null }

        git clone $REPO_URL $INSTALL_DIR
        if ($LASTEXITCODE -ne 0) {
            Write-Host ""
            Write-Host "[提示] Clone 失败（可能无法访问 GitHub）" -ForegroundColor Yellow
            Write-Host ""
            Write-Host "  请手动下载仓库 ZIP 并解压到：" -ForegroundColor Cyan
            Write-Host "    $INSTALL_DIR" -ForegroundColor Cyan
            Write-Host ""
            Write-Host "  下载地址：" -ForegroundColor Cyan
            Write-Host "    https://github.com/exusiaiwei/meta-infra/archive/refs/heads/master.zip" -ForegroundColor Cyan
            Write-Host ""
            Write-Host "  解压后确保目录结构为：" -ForegroundColor DarkGray
            Write-Host "    $INSTALL_DIR\mise.toml" -ForegroundColor DarkGray
            Write-Host "    $INSTALL_DIR\manifests\" -ForegroundColor DarkGray
            Write-Host "    $INSTALL_DIR\dotfiles\" -ForegroundColor DarkGray
            Write-Host ""
            Write-Host "  解压完成后重新运行此脚本即可继续。" -ForegroundColor Yellow
            exit 0
        }
    }
    Write-Step "仓库已就绪 ✓" "Green"
    Write-Host ""

    # ---- 阶段 4: 交给 zsh 完成剩余工作 ----
    Write-Host "阶段 4/4: 自动安装 (zsh + mise)" -ForegroundColor Yellow
    Write-Host ""

    # 确保 zsh 已安装（MSYS2 默认只带 bash）
    $BASH_EXE = "C:\msys64\usr\bin\bash.exe"
    if (-not (Test-Path $ZSH_EXE)) {
        if (Test-Path $BASH_EXE) {
            Write-Step "安装 zsh (pacman)..."
            $env:MSYSTEM = "MSYS"
            $env:CHERE_INVOKING = "1"
            & $BASH_EXE -lc "pacman -S --noconfirm --needed zsh"
        }
    }
    if (-not (Test-Path $ZSH_EXE)) {
        Write-Host "[错误] 找不到 zsh: $ZSH_EXE" -ForegroundColor Red
        Write-Host "  请确认 MSYS2 已正确安装" -ForegroundColor Yellow
        exit 1
    }
    Write-Step "zsh 已就绪 ✓" "Green"

    # 启用 winget configure 实验功能（在 PowerShell 里做，避免 python3 依赖）
    $wingetSettingsPath = "$env:LOCALAPPDATA\Packages\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe\LocalState\settings.json"
    if (Test-Path $wingetSettingsPath) {
        try {
            $ws = Get-Content $wingetSettingsPath -Raw | ConvertFrom-Json
            if (-not $ws.experimentalFeatures) {
                $ws | Add-Member -NotePropertyName "experimentalFeatures" -NotePropertyValue @{} -Force
            }
            $ws.experimentalFeatures | Add-Member -NotePropertyName "configuration" -NotePropertyValue $true -Force
            $ws | ConvertTo-Json -Depth 10 | Set-Content $wingetSettingsPath -Encoding UTF8
            Write-Step "winget configure 已启用 ✓" "Green"
        } catch {
            Write-Host "[警告] 无法修改 winget 设置" -ForegroundColor Yellow
        }
    }

    # 配置 Windows Terminal（在 PowerShell 里做，避免 python3 依赖）
    $wtSettingsPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
    if (Test-Path $wtSettingsPath) {
        try {
            $wt = Get-Content $wtSettingsPath -Raw | ConvertFrom-Json
            $hasZsh = $false
            foreach ($p in $wt.profiles.list) {
                if ($p.commandline -and $p.commandline -like "*zsh*") { $hasZsh = $true; break }
            }
            if (-not $hasZsh) {
                $zshProfile = @{
                    guid = "{17da3cac-b318-431e-8a3e-7fcdefe6d114}"
                    name = "zsh"
                    commandline = "C:\msys64\usr\bin\zsh.exe --login"
                    icon = "C:\msys64\msys2.ico"
                    startingDirectory = "%USERPROFILE%"
                    env = @{ MSYSTEM = "MSYS"; CHERE_INVOKING = "1" }
                }
                $list = [System.Collections.ArrayList]@($wt.profiles.list)
                $list.Insert(0, $zshProfile)
                $wt.profiles.list = $list.ToArray()
                $wt.defaultProfile = $zshProfile.guid
                $wt | ConvertTo-Json -Depth 10 | Set-Content $wtSettingsPath -Encoding UTF8
                Write-Step "Windows Terminal: zsh 已添加并设为默认 ✓" "Green"
            } else {
                Write-Step "Windows Terminal: zsh 已存在 ✓" "Green"
            }
        } catch {
            Write-Host "[警告] 无法配置 Windows Terminal: $_" -ForegroundColor Yellow
        }
    }

    # 调用独立的 zsh 安装脚本（避免 PowerShell here-string 转义问题）
    $msysPath = $INSTALL_DIR -replace '\\','/' -replace '^C:','/c'
    Write-Step "启动 zsh 自动安装..."
    $env:MSYSTEM = "MSYS"
    $env:CHERE_INVOKING = "1"
    & $ZSH_EXE "$msysPath/scripts/auto-install.sh" $msysPath $INSTALL_DIR

    Write-Host ""
    Write-Host "============================================" -ForegroundColor Green
    Write-Host "  ✅ meta-infra 引导完成！" -ForegroundColor Green
    Write-Host "============================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "打开 Windows Terminal，选择 zsh 配置，然后运行：" -ForegroundColor Yellow
    Write-Host "  cd $INSTALL_DIR" -ForegroundColor Cyan
    Write-Host "  mise trust" -ForegroundColor Cyan
    Write-Host "  mise run setup:git   # Git + SSH 配置" -ForegroundColor Cyan
    Write-Host "  mise run setup:wsl   # WSL 环境配置（可选）" -ForegroundColor Cyan
    Write-Host ""
}

# 运行
Start-Bootstrap
