# ================================================================================================
# LTSC Enhancement Menu - LTSC 增强功能菜单
# ================================================================================================
# 用途：为 Windows LTSC 版本提供可选的增强功能
# 包含：
#   - Microsoft Store 安装
#   - Winget 安装
#   - 其他系统组件
# ================================================================================================

function Show-LTSCEnhancementMenu {
    Write-Banner "🔧 LTSC 系统增强选项"

    Write-ColoredMessage "检测到 Windows LTSC 版本！" "Yellow"
    Write-Host ""
    Write-Host "LTSC 版本默认不包含某些组件，您可以选择安装："
    Write-Host ""

    Write-ColoredMessage "请选择要安装的组件（多选用逗号分隔）：" "Cyan"
    Write-Host ""

    Write-Host "  [必需组件]"
    Write-ColoredMessage "  1. Winget (App Installer)" "Green" -NoNewline
    Write-Host " - Windows 包管理器 🔴 必装"
    Write-Host ""

    Write-Host "  [可选组件]"
    Write-ColoredMessage "  2. Microsoft Store" "Cyan" -NoNewline
    Write-Host "        - 微软应用商店（访问 MSIX 应用）"
    Write-ColoredMessage "  3. Xbox Services" "Cyan" -NoNewline
    Write-Host "          - Xbox 游戏服务（仅游戏玩家需要）"
    Write-Host ""

    Write-ColoredMessage "  0. 全部安装" "Yellow"
    Write-ColoredMessage "  Q. 跳过，稍后手动配置" "Gray"
    Write-Host ""

    Write-ColoredMessage "请输入选项 (例如: 1,2 或 0 或 Q): " "Yellow" -NoNewline
    $selection = Read-Host

    return $selection
}

function Install-Winget-LTSC {
    Write-Step "正在为 LTSC 安装 Winget..."

    try {
        # 方法 1：直接下载 App Installer
        $appInstallerUrl = "https://aka.ms/getwinget"
        $tempFile = Join-Path $env:TEMP "AppInstaller.msixbundle"

        Write-Step "下载 App Installer..."
        Invoke-WebRequest -Uri $appInstallerUrl -OutFile $tempFile -UseBasicParsing

        Write-Step "安装 App Installer..."
        Add-AppxPackage $tempFile

        # 清理临时文件
        Remove-Item $tempFile -ErrorAction SilentlyContinue

        # 刷新环境变量
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

        if (Test-CommandExists "winget") {
            Write-Step "✅ Winget 安装成功！" "Success"
            return $true
        } else {
            Write-Step "⚠️  Winget 已安装，但需要重启终端" "Warning"
            return $false
        }
    } catch {
        Write-Step "❌ Winget 安装失败: $_" "Error"
        Write-Host ""
        Write-ColoredMessage "请手动安装：" "Yellow"
        Write-Host "  1. 访问: https://github.com/microsoft/winget-cli/releases"
        Write-Host "  2. 下载最新的 .msixbundle 文件"
        Write-Host "  3. 双击安装"
        return $false
    }
}

function Install-MicrosoftStore-LTSC {
    Write-Step "正在为 LTSC 安装 Microsoft Store..."
    Write-Host ""

    Write-ColoredMessage "选择安装方法：" "Cyan"
    Write-Host ""
    Write-Host "  1. 官方方法 (wsreset -i) - 适用于 Win10 LTSC 2021+ / Win11 LTSC"
    Write-Host "  2. 社区脚本 (kkkgo) - 适用于 Win10 LTSC 2019 及更早版本"
    Write-Host "  3. 社区脚本 (fernvenue) - 经过测试的多版本支持"
    Write-Host ""
    Write-ColoredMessage "请选择方法 (1/2/3): " "Yellow" -NoNewline
    $method = Read-Host

    switch ($method) {
        "1" {
            # 官方方法
            try {
                Write-Step "使用官方方法安装..."
                Write-Host ""
                Write-ColoredMessage "即将运行: wsreset -i" "Cyan"
                Write-ColoredMessage "这将打开 Microsoft Store 安装程序" "Yellow"
                Write-Host ""
                Write-ColoredMessage "按任意键继续..." "Gray"
                $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

                Start-Process "wsreset" -ArgumentList "-i" -Wait

                Write-Step "✅ Microsoft Store 安装已启动" "Success"
                Write-Host ""
                Write-ColoredMessage "如果商店未出现，请尝试：" "Yellow"
                Write-Host "  1. 重启计算机"
                Write-Host "  2. 运行 'wsreset.exe' 清除缓存"

            } catch {
                Write-Step "❌ 官方方法失败: $_" "Error"
            }
        }

        "2" {
            # kkkgo 脚本
            Write-Step "使用 kkkgo 社区脚本..."
            Write-Host ""
            Write-ColoredMessage "正在下载脚本..." "Cyan"

            $repoUrl = "https://github.com/kkkgo/LTSC-Add-MicrosoftStore"
            $downloadUrl = "https://github.com/kkkgo/LTSC-Add-MicrosoftStore/archive/refs/heads/main.zip"
            $tempDir = Join-Path $env:TEMP "LTSC-Store-kkkgo"
            $zipFile = Join-Path $env:TEMP "ltsc-store.zip"

            try {
                # 下载
                Invoke-WebRequest -Uri $downloadUrl -OutFile $zipFile -UseBasicParsing

                # 解压
                Expand-Archive -Path $zipFile -DestinationPath $tempDir -Force

                # 运行安装脚本
                $scriptPath = Get-ChildItem -Path $tempDir -Filter "Add-Store.cmd" -Recurse | Select-Object -First 1

                if ($scriptPath) {
                    Write-Step "正在运行安装脚本..."
                    Start-Process -FilePath $scriptPath.FullName -Verb RunAs -Wait

                    Write-Step "✅ 脚本执行完成" "Success"
                } else {
                    Write-Step "❌ 未找到安装脚本" "Error"
                }

                # 清理
                Remove-Item $zipFile -ErrorAction SilentlyContinue
                Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue

            } catch {
                Write-Step "❌ 脚本下载/执行失败: $_" "Error"
                Write-Host ""
                Write-ColoredMessage "请手动安装：" "Yellow"
                Write-Host "  1. 访问: $repoUrl"
                Write-Host "  2. 下载并解压"
                Write-Host "  3. 以管理员身份运行 Add-Store.cmd"
            }
        }

        "3" {
            # fernvenue 脚本
            Write-Step "使用 fernvenue 社区脚本..."
            Write-Host ""

            $repoUrl = "https://github.com/fernvenue/microsoft-store"

            Write-ColoredMessage "请访问以下链接手动下载：" "Yellow"
            Write-Host "  $repoUrl"
            Write-Host ""
            Write-Host "安装步骤："
            Write-Host "  1. 下载对应您系统版本的包"
            Write-Host "  2. 解压后以管理员身份运行安装脚本"
            Write-Host "  3. 重启系统"

            # 打开浏览器
            Write-ColoredMessage "是否现在打开浏览器？(Y/N): " "Yellow" -NoNewline
            $openBrowser = Read-Host

            if ($openBrowser -eq "Y" -or $openBrowser -eq "y") {
                Start-Process $repoUrl
            }
        }

        default {
            Write-Step "❌ 无效的选择" "Error"
        }
    }
}

function Install-XboxServices {
    Write-Step "正在安装 Xbox 服务..."

    Write-ColoredMessage "Xbox 服务包含以下组件：" "Cyan"
    Write-Host "  • Xbox Game Bar"
    Write-Host "  • Xbox Live 服务"
    Write-Host "  • Xbox Identity Provider"
    Write-Host ""

    Write-ColoredMessage "这需要先安装 Microsoft Store。" "Yellow"
    Write-Host "安装 Microsoft Store 后，Xbox 服务将自动可用。"
    Write-Host ""

    Write-Step "ℹ️  Xbox 服务将在 Microsoft Store 安装后可用" "Info"
}

function Process-LTSCEnhancements {
    param([string]$Selection)

    if ($Selection -eq "Q" -or $Selection -eq "q") {
        Write-ColoredMessage "跳过 LTSC 增强功能" "Gray"
        return $false
    }

    $choices = $Selection -split ',' | ForEach-Object { $_.Trim() }

    $installWinget = $false
    $installStore = $false
    $installXbox = $false

    if ($choices -contains "0") {
        $installWinget = $true
        $installStore = $true
        $installXbox = $true
    } else {
        $installWinget = $choices -contains "1"
        $installStore = $choices -contains "2"
        $installXbox = $choices -contains "3"
    }

    # 安装 Winget
    if ($installWinget) {
        Write-Host ""
        Write-ColoredMessage "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" "Gray"
        $success = Install-Winget-LTSC

        if (-not $success) {
            Write-ColoredMessage "⚠️  请在安装 Winget 后重新运行此脚本" "Yellow"
            return $false
        }
    }

    # 安装 Microsoft Store
    if ($installStore) {
        Write-Host ""
        Write-ColoredMessage "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" "Gray"
        Install-MicrosoftStore-LTSC
    }

    # 安装 Xbox Services
    if ($installXbox) {
        Write-Host ""
        Write-ColoredMessage "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" "Gray"
        Install-XboxServices
    }

    Write-Host ""
    Write-ColoredMessage "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" "Gray"
    Write-Step "✅ LTSC 增强功能配置完成" "Success"
    Write-Host ""

    return $true
}

# 导出函数
Export-ModuleMember -Function @(
    'Show-LTSCEnhancementMenu',
    'Process-LTSCEnhancements',
    'Install-Winget-LTSC',
    'Install-MicrosoftStore-LTSC',
    'Install-XboxServices'
)
