# meta-infra Interactive Installer
# Usage: .\install.ps1

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

# ========================================
# Interactive Menu Function (Arrow keys)
# ========================================
function Show-Menu {
    param(
        [string]$Title,
        [array]$Options,
        [bool]$MultiSelect = $false
    )

    $cursorPos = 0
    $selected = @{}

    [Console]::CursorVisible = $false

    Write-Host ""
    Write-Host $Title -ForegroundColor Cyan
    if ($MultiSelect) {
        Write-Host "(Up/Down: move, Space: toggle, Enter: confirm)" -ForegroundColor DarkGray
    } else {
        Write-Host "(Up/Down: move, Enter: confirm)" -ForegroundColor DarkGray
    }
    Write-Host ""

    $startLine = [Console]::CursorTop

    function Render {
        [Console]::SetCursorPosition(0, $startLine)

        for ($i = 0; $i -lt $Options.Count; $i++) {
            $prefix = if ($i -eq $cursorPos) { ">" } else { " " }
            $checkbox = ""
            if ($MultiSelect) {
                $checkbox = if ($selected[$i]) { "[x]" } else { "[ ]" }
            }

            $line = " $prefix $checkbox $($Options[$i].Name)"
            $padding = " " * [Math]::Max(0, 55 - $line.Length)

            if ($i -eq $cursorPos) {
                Write-Host "$line$padding" -ForegroundColor Green
            } else {
                Write-Host "$line$padding" -ForegroundColor White
            }
        }
    }

    Render

    while ($true) {
        $key = [Console]::ReadKey($true)

        switch ($key.Key) {
            "UpArrow" { if ($cursorPos -gt 0) { $cursorPos-- } }
            "DownArrow" { if ($cursorPos -lt $Options.Count - 1) { $cursorPos++ } }
            "Spacebar" { if ($MultiSelect) { $selected[$cursorPos] = -not $selected[$cursorPos] } }
            "A" { if ($MultiSelect) { for ($i = 0; $i -lt $Options.Count; $i++) { $selected[$i] = $true } } }
            "N" { if ($MultiSelect) { $selected = @{} } }
            "Enter" {
                [Console]::CursorVisible = $true
                Write-Host ""

                if ($MultiSelect) {
                    $result = @()
                    foreach ($k in $selected.Keys) {
                        if ($selected[$k]) { $result += $Options[$k] }
                    }
                    return $result
                } else {
                    return $Options[$cursorPos]
                }
            }
            "Escape" {
                [Console]::CursorVisible = $true
                Write-Host ""
                return $null
            }
        }

        Render
    }
}

# ========================================
# App Definitions
# ========================================
$CoreApps = @(
    @{Name="Git"; Id="Git.Git"}
    @{Name="Mise"; Id="jdx.mise"}
    @{Name="Nushell"; Id="Nushell.Nushell"}
    @{Name="Starship"; Id="Starship.Starship"}
    @{Name="Windows Terminal"; Id="Microsoft.WindowsTerminal"}
    @{Name="NanaZip"; Id="M2Team.NanaZip"}
)

$ToolsApps = @(
    @{Name="PowerToys"; Id="Microsoft.PowerToys"}
    @{Name="Flow Launcher"; Id="FlowLauncher.FlowLauncher"}
    @{Name="Files App"; Id="49306atecsolution.FilesUWP"}
    @{Name="Auto Dark Mode"; Id="ArminOsaj.AutoDarkMode"}
    @{Name="Bitwarden"; Id="Bitwarden.Bitwarden"}
    @{Name="AdGuard"; Id="AdGuard.AdGuard"}
    @{Name="Zen Browser"; Id="Zen-Team.Zen-Browser"}
    @{Name="FastCopy"; Id="FastCopy.FastCopy"}
    @{Name="GeekUninstaller"; Id="GeekUninstaller.GeekUninstaller"}
    @{Name="Quicker"; Id="LiErHeXun.Quicker"}
    @{Name="NanaGet"; Id="9PD5F2D90LS5"}
    @{Name="pot (Translator)"; Id="Pylogmon.pot"}
    @{Name="AB Download Manager"; Id="amir1376.ABDownloadManager"}
    @{Name="Winget-AutoUpdate"; Id="Romanitho.Winget-AutoUpdate"}
    @{Name="O&O AppBuster"; Id="OO-Software.AppBuster"}
)

$UIApps = @(
    @{Name="Mica For Everyone"; Id="MicaForEveryone.MicaForEveryone"}
    @{Name="Lively Wallpaper"; Id="rocksdanister.LivelyWallpaper"}
    @{Name="Dynamic Theme"; Id="9NBLGGH1ZBKW"}
    @{Name="yasb (Taskbar)"; Id="AmN.yasb"}
)

$DevApps = @(
    @{Name="VS Code"; Id="Microsoft.VisualStudioCode"}
    @{Name="Cursor"; Id="Anysphere.Cursor"}
    @{Name="Docker Desktop"; Id="Docker.DockerDesktop"}
    @{Name="GitHub CLI"; Id="GitHub.cli"}
    @{Name="VS Build Tools"; Id="Microsoft.VisualStudio.2022.BuildTools"}
    @{Name="PyCharm"; Id="JetBrains.PyCharm.Professional"}
    @{Name="Quarto"; Id="Posit.Quarto"}
    @{Name="Typst"; Id="Typst.Typst"}
)

$AcademicApps = @(
    @{Name="Obsidian"; Id="Obsidian.Obsidian"}
    @{Name="Anki"; Id="Anki.Anki"}
    @{Name="Zotero"; Id="DigitalScholar.Zotero"}
)

$AIApps = @(
    @{Name="Cherry Studio"; Id="kangfenmao.CherryStudio"}
    @{Name="Ollama"; Id="Ollama.Ollama"}
)

$MediaApps = @(
    @{Name="PotPlayer"; Id="Daum.PotPlayer"}
    @{Name="VLC"; Id="VideoLAN.VLC"}
)

$CommApps = @(
    @{Name="WeChat"; Id="Tencent.WeChat"}
    @{Name="QQ"; Id="Tencent.QQ.NT"}
    @{Name="Teams"; Id="Microsoft.Teams"}
)

$GamingApps = @(
    @{Name="Steam"; Id="Valve.Steam"}
    @{Name="Battle.net"; Id="Blizzard.BattleNet"}
)

$OfficeApps = @(
    @{Name="Microsoft 365"; Id="Microsoft.Office"}
)

# ========================================
# Install Function
# ========================================
function Install-Apps {
    param([array]$Apps)

    if ($Apps.Count -eq 0) {
        Write-Host "No apps selected" -ForegroundColor Yellow
        return
    }

    Write-Host ""
    Write-Host "Apps to install:" -ForegroundColor Cyan
    foreach ($app in $Apps) {
        Write-Host "  + $($app.Name)" -ForegroundColor Green
    }

    Write-Host ""
    $confirm = Read-Host "Confirm? (Y/n)"

    if ($confirm -eq '' -or $confirm -eq 'Y' -or $confirm -eq 'y') {
        foreach ($app in $Apps) {
            Write-Host ""
            Write-Host "Installing: $($app.Name)" -ForegroundColor Cyan
            winget install $app.Id --accept-package-agreements --accept-source-agreements --disable-interactivity
        }
        Write-Host ""
        Write-Host "Done!" -ForegroundColor Green
    } else {
        Write-Host "Cancelled" -ForegroundColor Yellow
    }
}

# ========================================
# Main Program
# ========================================
Clear-Host
Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "     meta-infra Interactive Installer" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan

$modes = @(
    @{Name="Quick    - Core only (6 apps)"; Value="quick"}
    @{Name="Standard - Core + Tools + UI + Dev (35 apps)"; Value="standard"}
    @{Name="Full     - All apps (50+ apps)"; Value="full"}
    @{Name="Custom   - Select by category"; Value="custom"}
    @{Name="Exit"; Value="exit"}
)

$mode = Show-Menu -Title "Select installation mode:" -Options $modes

if (-not $mode -or $mode.Value -eq "exit") {
    Write-Host "Bye!" -ForegroundColor Yellow
    exit
}

$appsToInstall = @()

switch ($mode.Value) {
    "quick" {
        $appsToInstall = $CoreApps
    }
    "standard" {
        $appsToInstall = $CoreApps + $ToolsApps + $UIApps + $DevApps
    }
    "full" {
        $appsToInstall = $CoreApps + $ToolsApps + $UIApps + $DevApps + $AcademicApps + $AIApps + $MediaApps + $CommApps + $GamingApps + $OfficeApps
    }
    "custom" {
        Write-Host ""
        Write-Host "============================================" -ForegroundColor Cyan
        Write-Host "  Custom Installation" -ForegroundColor Cyan
        Write-Host "============================================" -ForegroundColor Cyan
        Write-Host "(A: select all, N: select none)" -ForegroundColor DarkGray

        $categories = @(
            @{Name="Core (6)"; Apps=$CoreApps}
            @{Name="Tools (15)"; Apps=$ToolsApps}
            @{Name="UI/Theme (4)"; Apps=$UIApps}
            @{Name="Dev (8)"; Apps=$DevApps}
            @{Name="Academic (3)"; Apps=$AcademicApps}
            @{Name="AI (2)"; Apps=$AIApps}
            @{Name="Media (2)"; Apps=$MediaApps}
            @{Name="Communication (3)"; Apps=$CommApps}
            @{Name="Gaming (2)"; Apps=$GamingApps}
            @{Name="Office (1)"; Apps=$OfficeApps}
        )

        foreach ($cat in $categories) {
            $selected = Show-Menu -Title "Select from $($cat.Name):" -Options $cat.Apps -MultiSelect $true
            if ($selected) {
                $appsToInstall += $selected
            }
        }
    }
}

Install-Apps -Apps $appsToInstall
