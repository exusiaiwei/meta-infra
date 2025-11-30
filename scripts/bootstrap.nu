# ================================================================================================
# bootstrap.nu - 主安装向导 (由 Mise 调用)
# ================================================================================================
# 用途：完整的交互式安装流程
# 调用：mise run bootstrap
# ================================================================================================

# ========================================
# 辅助函数
# ========================================
def "print banner" [text: string] {
    print ""
    print $"(ansi cyan_bold)━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━(ansi reset)"
    print $"(ansi cyan_bold)  ($text)(ansi reset)"
    print $"(ansi cyan_bold)━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━(ansi reset)"
    print ""
}

def "print step" [message: string, status: string = "info"] {
    let icon = match $status {
        "success" => "✅",
        "error" => "❌",
        "warning" => "⚠️ ",
        "info" => "ℹ️ ",
        _ => "➤"
    }

    let color = match $status {
        "success" => "green",
        "error" => "red",
        "warning" => "yellow",
        "info" => "cyan",
        _ => "white"
    }

    print $"(ansi $color)($icon) ($message)(ansi reset)"
}

# ========================================
# 系统检测
# ========================================
def detect-system [] {
    let os_info = (sys host)
    let is_ltsc = (wmic os get Caption | str find-replace -a '\n' '' | str contains "LTSC")
    let is_arm = ($os_info.arch == "aarch64")

    {
        os: $os_info.name,
        version: $os_info.os_version,
        arch: $os_info.arch,
        is_ltsc: $is_ltsc,
        is_arm: $is_arm
    }
}

def check-command [cmd: string] {
    (which $cmd | length) > 0
}

# ========================================
# LTSC 增强菜单
# ========================================
def show-ltsc-menu [] {
    print banner "🔧 LTSC 系统增强选项"

    print $"(ansi yellow)检测到 Windows LTSC 版本！(ansi reset)"
    print ""
    print "LTSC 版本默认不包含某些组件，您可以选择安装："
    print ""

    print $"(ansi cyan)请选择要安装的组件（多选用逗号分隔）：(ansi reset)"
    print ""

    print "  [必需组件]"
    print $"  (ansi green)1. Winget (App Installer)(ansi reset) - Windows 包管理器 🔴 必装"
    print ""

    print "  [可选组件]"
    print $"  (ansi cyan)2. Microsoft Store(ansi reset)        - 微软应用商店"
    print ""

    print $"  (ansi yellow)0. 全部安装(ansi reset)"
    print $"  (ansi gray)Q. 跳过，稍后手动配置(ansi reset)"
    print ""

    input $"(ansi yellow)请输入选项 (例如: 1,2 或 0 或 Q): (ansi reset)"
}

# ========================================
# 模块选择菜单
# ========================================
def show-module-menu [sys_info: record] {
    print banner "📦 模块选择"

    print $"(ansi cyan)系统信息：(ansi reset)"
    print $"  操作系统：($sys_info.os)"
    print $"  架构：($sys_info.arch)"
    if $sys_info.is_ltsc {
        print $"  (ansi yellow)LTSC 版本(ansi reset)"
    }
    print ""

    print $"(ansi yellow)请选择要安装的模块（多选用逗号分隔，如: 1,2,3）：(ansi reset)"
    print ""

    print "  [核心层 - Core]"
    print $"  (ansi green)1. base(ansi reset)            - 核心基础工具 🔴 必装"
    print ""

    print "  [标准层 - Standard]"
    print $"  (ansi cyan)2. tools(ansi reset)          - 效率工具"
    print $"  (ansi cyan)3. dev(ansi reset)            - 开发环境"
    print $"  (ansi cyan)4. academic(ansi reset)       - 学术工具"
    print $"  (ansi cyan)5. ai(ansi reset)             - AI 工具"
    print $"  (ansi cyan)6. media(ansi reset)          - 多媒体"
    print $"  (ansi cyan)7. communication(ansi reset) - 通讯工具"
    print ""

    print "  [可选层 - Optional]"
    print $"  (ansi magenta)8. gaming(ansi reset)        - 游戏相关"
    print $"  (ansi magenta)9. security(ansi reset)      - 安全软件"
    print $"  (ansi magenta)10. cloud(ansi reset)         - 云存储"

    if not $sys_info.is_arm {
        print $"  (ansi magenta)11. hardware-nvidia(ansi reset) - NVIDIA 工具"
    }

    print ""
    print $"  (ansi yellow)0. 全部安装(ansi reset)"
    print ""

    input $"(ansi yellow)请输入选项: (ansi reset)"
}

# ========================================
# 解析选择
# ========================================
def parse-selection [selection: string, is_arm: bool] {
    let choices = ($selection | split row ',' | each { str trim })

    mut modules = {
        core: [],
        standard: [],
        optional: []
    }

    if ($choices | any { $in == "0" }) {
        $modules.core = ["base"]
        $modules.standard = ["tools", "dev", "academic", "ai", "media", "communication"]
        $modules.optional = ["gaming", "security", "cloud"]

        if not $is_arm {
            $modules.optional = ($modules.optional | append "hardware-nvidia")
        }
    } else {
        for choice in $choices {
            match $choice {
                "1" => { $modules.core = ($modules.core | append "base") },
                "2" => { $modules.standard = ($modules.standard | append "tools") },
                "3" => { $modules.standard = ($modules.standard | append "dev") },
                "4" => { $modules.standard = ($modules.standard | append "academic") },
                "5" => { $modules.standard = ($modules.standard | append "ai") },
                "6" => { $modules.standard = ($modules.standard | append "media") },
                "7" => { $modules.standard = ($modules.standard | append "communication") },
                "8" => { $modules.optional = ($modules.optional | append "gaming") },
                "9" => { $modules.optional = ($modules.optional | append "security") },
                "10" => { $modules.optional = ($modules.optional | append "cloud") },
                "11" => { if not $is_arm { $modules.optional = ($modules.optional | append "hardware-nvidia") } },
                _ => {}
            }
        }
    }

    # 确保 base 始终被选择
    if ($modules.core | length) == 0 {
        $modules.core = ["base"]
    }

    $modules
}

# ========================================
# 安装模块
# ========================================
def install-modules [modules: record] {
    print banner "📦 安装软件模块"

    let all_modules = (
        ($modules.core | each { {layer: "core", name: $in} }) ++
        ($modules.standard | each { {layer: "standard", name: $in} }) ++
        ($modules.optional | each { {layer: "optional", name: $in} })
    )

    let total = ($all_modules | length)
    mut current = 0

    for mod in $all_modules {
        $current = $current + 1
        let manifest_path = $"manifests/($mod.layer)/($mod.name).yaml"

        print ""
        print $"(ansi gray)━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━(ansi reset)"
        print $"(ansi cyan)[($current)/($total)] 安装: ($mod.layer)/($mod.name)(ansi reset)"
        print $"(ansi gray)━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━(ansi reset)"
        print ""

        if ($manifest_path | path exists) {
            try {
                winget configure $manifest_path --accept-configuration-agreements
                print step $"✅ ($mod.name) 安装完成" "success"
            } catch {
                print step $"❌ ($mod.name) 安装失败" "error"
            }
        } else {
            print step $"⚠️  清单文件不存在: ($manifest_path)" "warning"
        }
    }

    print ""
    print step "所有模块安装完成！" "success"
}

# ========================================
# 主流程
# ========================================
def main [] {
    print banner "🚀 meta-infra 安装向导"

    print $"(ansi cyan)欢迎使用 meta-infra Windows 环境配置工具！(ansi reset)"
    print ""
    print "这个向导将帮助您："
    print "  • 选择并安装所需的软件模块"
    print "  • 安装 CLI 工具 (通过 Mise)"
    print "  • 配置 Nushell、Starship 等"
    print ""

    let ready = (input $"(ansi yellow)准备好开始了吗？(Y/N): (ansi reset)")

    if $ready != "Y" and $ready != "y" {
        print $"(ansi yellow)安装已取消(ansi reset)"
        return
    }

    # 检测系统
    print banner "步骤 1/5: 检测系统"
    let sys_info = (detect-system)
    print step $"系统：($sys_info.os) ($sys_info.arch)" "info"

    # LTSC 增强（如果需要）
    if $sys_info.is_ltsc {
        let ltsc_choice = (show-ltsc-menu)

        if $ltsc_choice != "Q" and $ltsc_choice != "q" {
            print ""
            print step "LTSC 增强功能将通过 PowerShell 脚本处理" "info"
            print "请在完成此向导后运行相关脚本"
        }
    }

    # 模块选择
    print banner "步骤 2/5: 选择模块"
    let selection = (show-module-menu $sys_info)
    let modules = (parse-selection $selection $sys_info.is_arm)

    # 确认安装计划
    print banner "步骤 3/5: 确认安装计划"

    print $"(ansi cyan)将要安装以下模块：(ansi reset)"
    print ""

    if ($modules.core | length) > 0 {
        print $"(ansi green)🔴 核心层:(ansi reset)"
        for mod in $modules.core {
            print $"   - core/($mod).yaml"
        }
        print ""
    }

    if ($modules.standard | length) > 0 {
        print $"(ansi cyan)🟡 标准层:(ansi reset)"
        for mod in $modules.standard {
            print $"   - standard/($mod).yaml"
        }
        print ""
    }

    if ($modules.optional | length) > 0 {
        print $"(ansi magenta)🔵 可选层:(ansi reset)"
        for mod in $modules.optional {
            print $"   - optional/($mod).yaml"
        }
        print ""
    }

    let confirm = (input $"(ansi yellow)确认安装？(Y/N): (ansi reset)")

    if $confirm != "Y" and $confirm != "y" {
        print $"(ansi yellow)安装已取消(ansi reset)"
        return
    }

    # 安装模块
    print banner "步骤 4/5: 安装模块"
    install-modules $modules

    # 后续配置
    print banner "步骤 5/5: 后续配置"

    print $"(ansi green)🎉 GUI 软件安装完成！(ansi reset)"
    print ""

    print $"(ansi cyan)接下来您需要：(ansi reset)"
    print ""

    print "1️⃣  重启终端刷新环境"
    print ""

    print "2️⃣  安装 Mise CLI 工具："
    print $"   (ansi yellow)mise install(ansi reset)"
    print ""

    print "3️⃣  初始化配置："
    print $"   (ansi yellow)mise run init(ansi reset)"
    print ""

    print "4️⃣  验证安装："
    print $"   (ansi yellow)mise run status(ansi reset)"
    print ""
}

# 运行主程序
main
