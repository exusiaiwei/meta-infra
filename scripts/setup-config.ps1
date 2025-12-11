# meta-infra Setup Config Script
# Usage: .\scripts\setup-config.ps1 [-Target "all"|"nushell"|"starship"|"terminal"]

param (
    [string]$Target = "all"
)

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Split-Path -Parent $ScriptDir
$DotfilesDir = Join-Path $RepoRoot "dotfiles"

function Copy-Config {
    param($Source, $Dest, $Name)
    if (Test-Path $Source) {
        Copy-Item $Source $Dest -Force
        Write-Host "  ✓ 已复制 $Name" -ForegroundColor Green
    } else {
        Write-Host "  ⚠️  $Name 不存在，将使用默认配置" -ForegroundColor Yellow
    }
}

if ($Target -eq "all" -or $Target -eq "nushell") {
    Write-Host "⚙️  配置 Nushell..." -ForegroundColor Cyan
    $NuConfigDir = "$env:APPDATA\nushell"
    if (!(Test-Path $NuConfigDir)) { New-Item -ItemType Directory -Path $NuConfigDir -Force | Out-Null }

    Copy-Config "$DotfilesDir\config.nu" "$NuConfigDir\config.nu" "config.nu"
    Copy-Config "$DotfilesDir\env.nu" "$NuConfigDir\env.nu" "env.nu"
    Write-Host "✅ Nushell 配置完成" -ForegroundColor Green
    Write-Host ""
}

if ($Target -eq "all" -or $Target -eq "starship") {
    Write-Host "⚙️  配置 Starship..." -ForegroundColor Cyan
    $ConfigDir = "$env:USERPROFILE\.config"
    if (!(Test-Path $ConfigDir)) { New-Item -ItemType Directory -Path $ConfigDir -Force | Out-Null }

    Copy-Config "$DotfilesDir\starship.toml" "$ConfigDir\starship.toml" "starship.toml"
    Write-Host "✅ Starship 配置完成" -ForegroundColor Green
    Write-Host ""
}

if ($Target -eq "all" -or $Target -eq "terminal") {
    Write-Host "⚙️  配置 Windows Terminal..." -ForegroundColor Cyan
    $TerminalDir = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState"
    $SettingsPath = "$TerminalDir\settings.json"

    if (Test-Path $TerminalDir) {
        # 1. Copy config file if source exists
        if (Test-Path "$DotfilesDir\windows-terminal-settings.json") {
            Copy-Item "$DotfilesDir\windows-terminal-settings.json" $SettingsPath -Force
            Write-Host "  ✓ 已复制 Windows Terminal 配置文件" -ForegroundColor Green
        } else {
            Write-Host "  ℹ️  未找到项目内的 Windows Terminal 配置文件，将修改现有配置" -ForegroundColor DarkGray
        }

        # 2. Set Nushell as default if installed
        if (Get-Command nu -ErrorAction SilentlyContinue) {
            if (Test-Path $SettingsPath) {
                try {
                    $json = Get-Content $SettingsPath -Raw | ConvertFrom-Json
                    $profiles = $json.profiles.list
                    $nuProfile = $profiles | Where-Object { $_.commandline -like "*nu.exe*" -or $_.name -eq "Nushell" }

                    if ($nuProfile) {
                        $json.defaultProfile = $nuProfile.guid
                        $json | ConvertTo-Json -Depth 10 | Set-Content $SettingsPath
                        Write-Host "  ✓ 已将 Nushell 设置为默认终端 Profile" -ForegroundColor Green
                    } else {
                        Write-Host "  ⚠️  未在 Terminal 配置文件中找到 Nushell Profile" -ForegroundColor Yellow
                    }
                } catch {
                    Write-Host "  ❌ 修改 settings.json 失败: $_" -ForegroundColor Red
                }
            }
        }
    } else {
        Write-Host "  ℹ️  未安装 Windows Terminal，跳过配置" -ForegroundColor DarkGray
    }
    Write-Host "✅ Windows Terminal 配置完成" -ForegroundColor Green
    Write-Host ""
}
