# meta-infra Maintenance Script
# Usage: .\scripts\maintenance.ps1 -Task "update"|"status"|"clean"|"init"

param (
    [Parameter(Mandatory=$true)]
    [ValidateSet("update", "status", "clean", "init")]
    [string]$Task
)

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Split-Path -Parent $ScriptDir

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

switch ($Task) {
    "init" {
        Write-Host ""
        Write-Host "🚀 开始初始化 meta-infra 配置系统..." -ForegroundColor Cyan
        Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
        Write-Host ""

        # 1. Verify
        Write-Host "📋 步骤 1/4: 验证依赖工具..." -ForegroundColor Yellow
        mise run verify
        Write-Host ""

        # 2. Setup Nushell
        Write-Host "⚙️  步骤 2/4: 配置 Nushell..." -ForegroundColor Yellow
        & "$ScriptDir\setup-config.ps1" -Target nushell

        # 3. Setup Starship
        Write-Host "⚙️  步骤 3/4: 配置 Starship..." -ForegroundColor Yellow
        & "$ScriptDir\setup-config.ps1" -Target starship

        # 4. Setup Terminal
        Write-Host "⚙️  步骤 4/4: 配置 Windows Terminal..." -ForegroundColor Yellow
        & "$ScriptDir\setup-config.ps1" -Target terminal

        Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
        Write-Host "✅ 初始化完成！" -ForegroundColor Green
        Write-Host ""
        Write-Host "🎯 下一步：" -ForegroundColor Cyan
        Write-Host "   1. 重启终端以应用新配置"
        Write-Host "   2. 运行 'mise run status' 查看系统状态"
        Write-Host ""
    }

    "update" {
        Write-Host "📦 更新系统..." -ForegroundColor Cyan
        Write-Host ""

        Write-Host "1️⃣  更新 Winget 包..." -ForegroundColor Yellow
        winget upgrade --all --include-unknown --accept-package-agreements --accept-source-agreements
        Write-Host ""

        Write-Host "2️⃣  更新 Mise 工具..." -ForegroundColor Yellow
        mise upgrade
        Write-Host ""

        if (Test-Path "$RepoRoot\docs\package.json") {
            Write-Host "3️⃣  更新文档依赖..." -ForegroundColor Yellow
            Push-Location "$RepoRoot\docs"
            npm update
            Pop-Location
        }

        Write-Host "✅ 所有工具已更新！" -ForegroundColor Green
    }

    "status" {
        Write-Host ""
        Write-Host "📊 meta-infra 系统状态" -ForegroundColor Cyan
        Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
        Write-Host ""

        Write-Host "🛠️  核心工具版本：" -ForegroundColor Yellow
        Write-Host "  Git:      $((git --version).Trim())"
        Write-Host "  Mise:     $((mise --version).Trim())"
        if (Get-Command nu -ErrorAction SilentlyContinue) {
             Write-Host "  Nushell:  $((nu --version).Trim())"
        }
        if (Get-Command starship -ErrorAction SilentlyContinue) {
             Write-Host "  Starship: $((starship --version).Trim())"
        }
        if (Get-Command pwsh -ErrorAction SilentlyContinue) {
             Write-Host "  PowerShell:$((pwsh --version).Trim())"
        }
        Write-Host ""

        Write-Host "📦 Mise 管理的工具：" -ForegroundColor Yellow
        mise list
        Write-Host ""

        Write-Host "💻 系统信息：" -ForegroundColor Yellow
        Get-ComputerInfo | Select-Object OsName, OsVersion, OsArchitecture | Format-List
    }

    "clean" {
        Write-Host "🧹 清理缓存和临时文件..." -ForegroundColor Cyan

        Write-Host "  清理 Mise 缓存..."
        mise cache clear

        if (Test-Path "$RepoRoot\docs\dist") {
            Write-Host "  清理文档构建产物..."
            Remove-Item "$RepoRoot\docs\dist" -Recurse -Force
        }

        if (Test-Path "$RepoRoot\docs\node_modules") {
            Write-Host "  清理 Node 模块..."
            Remove-Item "$RepoRoot\docs\node_modules" -Recurse -Force
        }

        Write-Host "✅ 清理完成！" -ForegroundColor Green
    }
}
