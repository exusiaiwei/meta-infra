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

    if (Test-Path $gitDir) {
        Write-Step "仓库已存在，同步中..."
        Push-Location $INSTALL_DIR
        try { git pull } catch { Write-Host "[警告] 同步失败" -ForegroundColor Yellow }
        Pop-Location
    } elseif (Test-Path $INSTALL_DIR) {
        Write-Host "[错误] 目录已存在但不是 Git 仓库: $INSTALL_DIR" -ForegroundColor Red
        exit 1
    } else {
        Write-Step "克隆仓库..."
        # 确保父目录存在
        $parentDir = Split-Path $INSTALL_DIR -Parent
        if (-not (Test-Path $parentDir)) { New-Item -ItemType Directory -Path $parentDir -Force | Out-Null }
        git clone $REPO_URL $INSTALL_DIR
        if ($LASTEXITCODE -ne 0) {
            Write-Host "[错误] 克隆失败" -ForegroundColor Red
            exit 1
        }
    }
    Write-Step "仓库已就绪 ✓" "Green"
    Write-Host ""

    # ---- 阶段 4: 交给 zsh 完成剩余工作 ----
    Write-Host "阶段 4/4: 自动安装 (zsh + mise)" -ForegroundColor Yellow
    Write-Host ""

    # 将 Windows 路径转为 MSYS2 路径
    $msysPath = $INSTALL_DIR -replace '\\','/' -replace '^C:','/c'

    # 构建 zsh 要执行的脚本
    $zshScript = @"
export PATH="/usr/local/bin:/usr/bin:/bin:`$PATH"
cd "$msysPath"

echo '============================================'
echo '  安装 Zsh 插件 (pacman)'
echo '============================================'
pacman -S --noconfirm --needed zsh-syntax-highlighting zsh-autosuggestions 2>&1 || echo '[警告] Zsh 插件安装失败'

echo ''
echo '============================================'
echo '  安装 CLI 工具 (mise install)'
echo '============================================'
mise install 2>&1 || echo '[警告] 部分工具安装失败'

echo ''
echo '============================================'
echo '  安装 GUI 应用 (winget configure)'
echo '============================================'

# 安装核心 + 标准层
winget.exe configure manifests/core/base.yaml --accept-configuration-agreements 2>/dev/null
for f in manifests/standard/*.yaml; do
  echo "  安装: `$f"
  winget.exe configure "`$f" --accept-configuration-agreements 2>/dev/null
done

echo ''
echo '============================================'
echo '  同步 Dotfiles'
echo '============================================'
zsh scripts/sync-dotfiles.sh 2>&1 || echo '[警告] Dotfiles 同步失败'

echo ''
echo '============================================'
echo '  配置 WSL 环境'
echo '============================================'
if command -v wsl.exe &>/dev/null; then
  # 检测 WSL 是否已初始化（有默认发行版）
  if wsl.exe -l -q 2>/dev/null | head -1 | grep -qi '[a-z]'; then
    echo '检测到 WSL 已安装，自动配置中...'
    wsl.exe -e bash -c "$(cat scripts/setup-wsl.sh)" 2>&1 || echo '[警告] WSL 配置失败'
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
"@

    # 调用 MSYS2 的 zsh 执行
    Write-Step "启动 zsh 自动安装..."
    $env:MSYSTEM = "MSYS"
    $env:CHERE_INVOKING = "1"
    & $ZSH_EXE -c $zshScript

    Write-Host ""
    Write-Host "============================================" -ForegroundColor Green
    Write-Host "  ✅ meta-infra 引导完成！" -ForegroundColor Green
    Write-Host "============================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "打开 Windows Terminal，选择 zsh 配置，然后运行：" -ForegroundColor Yellow
    Write-Host "  cd $INSTALL_DIR" -ForegroundColor Cyan
    Write-Host "  mise run setup:git   # Git + SSH 配置" -ForegroundColor Cyan
    Write-Host "  mise run setup:wsl   # WSL 环境配置（可选）" -ForegroundColor Cyan
    Write-Host ""
}

# 运行
Start-Bootstrap
