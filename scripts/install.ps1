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

    # Hide cursor
    try { [Console]::CursorVisible = $false } catch {}

    while ($true) {
        # Reduce flickering by clearing only when necessary or using simpler redraw
        Clear-Host

        Write-Host ""
        Write-Host $Title -ForegroundColor Cyan
        if ($MultiSelect) {
            Write-Host "(Up/Down: move, Space: toggle, Enter: confirm, A: all, N: none)" -ForegroundColor DarkGray
        } else {
            Write-Host "(Up/Down: move, Enter: confirm)" -ForegroundColor DarkGray
        }
        Write-Host ""

        for ($i = 0; $i -lt $Options.Count; $i++) {
            $prefix = if ($i -eq $cursorPos) { ">" } else { " " }
            $checkbox = ""
            if ($MultiSelect) {
                $checkbox = if ($selected[$i]) { "[x]" } else { "[ ]" }
            }

            $line = " $prefix $checkbox $($Options[$i].Name)"

            if ($i -eq $cursorPos) {
                Write-Host "$line" -ForegroundColor Green
            } else {
                Write-Host "$line" -ForegroundColor White
            }
        }

        $key = [Console]::ReadKey($true)

        switch ($key.Key) {
            "UpArrow" {
                if ($cursorPos -gt 0) { $cursorPos-- }
                else { $cursorPos = $Options.Count - 1 }
            }
            "DownArrow" {
                if ($cursorPos -lt $Options.Count - 1) { $cursorPos++ }
                else { $cursorPos = 0 }
            }
            "Spacebar" { if ($MultiSelect) { $selected[$cursorPos] = -not $selected[$cursorPos] } }
            "A" { if ($MultiSelect) { for ($i = 0; $i -lt $Options.Count; $i++) { $selected[$i] = $true } } }
            "N" { if ($MultiSelect) { $selected = @{} } }
            "Enter" {
                try { [Console]::CursorVisible = $true } catch {}
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
                try { [Console]::CursorVisible = $true } catch {}
                Write-Host ""
                return $null
            }
        }
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
    @{Name="Quicker"; Id="LiErHeXun.Quicker"}
    @{Name="NanaGet"; Id="9PD5F2D90LS5"}
    @{Name="pot (Translator)"; Id="Pylogmon.pot"}
    @{Name="AB Download Manager"; Id="amir1376.ABDownloadManager"}
    @{Name="Winget-AutoUpdate"; Id="Romanitho.Winget-AutoUpdate"}
)

$PortableApps = @(
    @{Name="GeekUninstaller"; Id="GeekUninstaller.GeekUninstaller"}
    @{Name="O&O AppBuster"; Id="OO-Software.AppBuster"}
    @{Name="RoboCopyEx (WinUI)"; Id="9MVWF8R6V6SJ"}
    @{Name="Everything"; Id="voidtools.Everything"}
    @{Name="Ditto Clipboard"; Id="Ditto.Ditto"}
    @{Name="WizTree"; Id="AntibodySoftware.WizTree"}
)

$UIApps = @(
    @{Name="Mica For Everyone"; Id="MicaForEveryone.MicaForEveryone"}
    @{Name="Lively Wallpaper"; Id="rocksdanister.LivelyWallpaper"}
    @{Name="Dynamic Theme"; Id="9NBLGGH1ZBKW"}
    @{Name="Nilesoft Shell"; Id="Nilesoft.Shell"}
    @{Name="TranslucentTB"; Id="CharlesMilette.TranslucentTB"}
    @{Name="Windhawk"; Id="RamenSoftware.Windhawk"}
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
# ========================================
# Install Function
# ========================================
function Install-Apps {
    param([array]$Apps)

    if ($Apps.Count -eq 0) {
        Write-Host "No apps selected" -ForegroundColor Yellow
        Start-Sleep -Seconds 1
        return $false
    }

    while ($true) {
        Clear-Host
        Write-Host ""
        Write-Host "============================================" -ForegroundColor Cyan
        Write-Host "  Review Selection" -ForegroundColor Cyan
        Write-Host "============================================" -ForegroundColor Cyan
        Write-Host ""

        Write-Host "Selected packages ($($Apps.Count)): " -ForegroundColor Yellow
        Write-Host ""

        $colCount = 3
        $rows = [Math]::Ceiling($Apps.Count / $colCount)
        for ($i = 0; $i -lt $rows; $i++) {
            $line = ""
            for ($j = 0; $j -lt $colCount; $j++) {
                $idx = $i + ($j * $rows)
                if ($idx -lt $Apps.Count) {
                    $line += "- {0,-25}" -f $Apps[$idx].Name
                }
            }
            Write-Host $line -ForegroundColor Green
        }

        Write-Host ""
        $confirm = Show-Menu -Title "Ready to install?" -Options @(
            @{Name="Yes, install now"; Value="yes"}
            @{Name="No, go back to menu"; Value="back"}
        )

        if ($confirm.Value -eq "yes") {
            foreach ($app in $Apps) {
                Write-Host ""
                Write-Host "Installing: $($app.Name)" -ForegroundColor Cyan
                winget install $app.Id --accept-package-agreements --accept-source-agreements --disable-interactivity
            }
            Write-Host ""
            Write-Host "Installation cycle complete!" -ForegroundColor Green
            Write-Host "Press any key to return to main menu..." -ForegroundColor DarkGray
            [Console]::ReadKey($true) | Out-Null
            return $true
        } else {
            return $false
        }
    }
}

# ========================================
# Main Program Loop
# ========================================
while ($true) {
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
    $goBack = $false

    switch ($mode.Value) {
        "quick" { $appsToInstall = $CoreApps }
        "standard" { $appsToInstall = $CoreApps + $ToolsApps + $PortableApps + $UIApps + $DevApps }
        "full" { $appsToInstall = $CoreApps + $ToolsApps + $PortableApps + $UIApps + $DevApps + $AcademicApps + $AIApps + $MediaApps + $CommApps + $GamingApps + $OfficeApps }
        "custom" {
            $categories = @(
                @{Name="Core (6)"; Apps=$CoreApps}
                @{Name="Tools (12)"; Apps=$ToolsApps}
                @{Name="Portable (6)"; Apps=$PortableApps}
                @{Name="UI/Theme (6)"; Apps=$UIApps}
                @{Name="Dev (8)"; Apps=$DevApps}
                @{Name="Academic (3)"; Apps=$AcademicApps}
                @{Name="AI (2)"; Apps=$AIApps}
                @{Name="Media (2)"; Apps=$MediaApps}
                @{Name="Communication (3)"; Apps=$CommApps}
                @{Name="Gaming (2)"; Apps=$GamingApps}
                @{Name="Office (1)"; Apps=$OfficeApps}
            )

            # Select categories first to avoid going through all
            $selectedCats = Show-Menu -Title "Select categories to browse (Space to toggle):" -Options $categories -MultiSelect $true

            if (-not $selectedCats) {
                $goBack = $true
            } else {
                foreach ($cat in $selectedCats) {
                    if ($goBack) { break }

                    while ($true) {
                        $selected = Show-Menu -Title "Select from $($cat.Name) (ESC to skip category):" -Options $cat.Apps -MultiSelect $true
                        if ($selected -eq $null) {
                             # Esc pressed in category view
                             $action = Show-Menu -Title "Category skipped. Action?" -Options @(
                                @{Name="Next Category"; Value="next"}
                                @{Name="Return to Main Menu"; Value="main"}
                             )
                             if ($action.Value -eq "main") { $goBack = $true; break }
                             if ($action.Value -eq "next") { break }
                        } else {
                            $appsToInstall += $selected
                            break
                        }
                    }
                }
            }
        }
    }

    if (-not $goBack) {
        Install-Apps -Apps $appsToInstall
    }
}
