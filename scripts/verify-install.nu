# ================================================================================================
# verify-install.nu - 验证依赖工具安装状态
# ================================================================================================
# 用途：检查所有必需的工具是否正确安装并可用
# 使用：mise run verify 或 nu scripts/verify-install.nu
# ================================================================================================

def main [] {
    print ""
    print "🔍 验证依赖工具安装状态..."
    print "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    print ""

    mut all_ok = true

    # 检查核心工具
    let tools = [
        ["工具", "命令", "必需"],
        ["Git", "git", true],
        ["Mise", "mise", true],
        ["Nushell", "nu", true],
        ["Starship", "starship", true],
        ["Windows Terminal", "wt", false],
    ]

    print "📦 核心工具："
    print ""

    for tool in ($tools | skip 1) {
        let name = ($tool | get 0)
        let cmd = ($tool | get 1)
        let required = ($tool | get 2)

        try {
            let version = (do { ^$cmd --version } | complete)

            if $version.exit_code == 0 {
                let ver_str = ($version.stdout | str trim | lines | first)
                print $"  ✅ ($name): ($ver_str)"
            } else {
                if $required {
                    print $"  ❌ ($name): 未安装或不可用"
                    $all_ok = false
                } else {
                    print $"  ⚠️  ($name): 未安装（可选）"
                }
            }
        } catch {
            if $required {
                print $"  ❌ ($name): 未找到命令 '($cmd)'"
                $all_ok = false
            } else {
                print $"  ⚠️  ($name): 未安装（可选）"
            }
        }
    }

    print ""
    print "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    if $all_ok {
        print "✅ 所有必需工具已正确安装！"
    } else {
        print "❌ 部分必需工具未安装"
        exit 1
    }
    print ""
}
