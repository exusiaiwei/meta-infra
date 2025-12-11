# meta-infra Verify Install Script
# Usage: .\scripts\verify-install.ps1

Write-Host ""
Write-Host "🔍 验证依赖工具安装状态..." -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
Write-Host ""

$AllOk = $true

$Tools = @(
    @{"Name"="Git"; "Cmd"="git"; "Required"=$true; "Args"="--version"}
    @{"Name"="Mise"; "Cmd"="mise"; "Required"=$true; "Args"="--version"}
    @{"Name"="Nushell"; "Cmd"="nu"; "Required"=$true; "Args"="--version"}
    @{"Name"="Starship"; "Cmd"="starship"; "Required"=$true; "Args"="--version"}
    @{"Name"="Windows Terminal"; "Cmd"="wt"; "Required"=$false; "Args"="-v"}
)

Write-Host "📦 核心工具：" -ForegroundColor Yellow
Write-Host ""

foreach ($tool in $Tools) {
    try {
        $cmd = $tool.Cmd
        if (Get-Command $cmd -ErrorAction SilentlyContinue) {
            try {
                $output = & $cmd $tool.Args 2>&1 | Select-Object -First 1
                if ($output) {
                    Write-Host "  ✅ $($tool.Name): $output" -ForegroundColor Green
                } else {
                    Write-Host "  ✅ $($tool.Name): Detected" -ForegroundColor Green
                }
            } catch {
                Write-Host "  ✅ $($tool.Name): Detected (Version check failed)" -ForegroundColor Green
            }
        } else {
            if ($tool.Required) {
                Write-Host "  ❌ $($tool.Name): 未安装或不可用" -ForegroundColor Red
                $AllOk = $false
            } else {
                Write-Host "  ⚠️  $($tool.Name): 未安装（可选）" -ForegroundColor DarkGray
            }
        }
    } catch {
        if ($tool.Required) {
            Write-Host "  ❌ $($tool.Name): Error checking" -ForegroundColor Red
            $AllOk = $false
        }
    }
}

Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray

if ($AllOk) {
    Write-Host "✅ 所有必需工具已正确安装！" -ForegroundColor Green
} else {
    Write-Host "❌ 部分必需工具未安装" -ForegroundColor Red
    exit 1
}
Write-Host ""
