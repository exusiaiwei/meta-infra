# ================================================================================================
# Nushell 配置文件 (config.nu)
# ================================================================================================
# 此文件配置 Nushell 的行为和外观
# 路径：~/.config/nushell/config.nu (Linux/macOS) 或 ~/AppData/Roaming/nushell/config.nu (Windows)
# ================================================================================================

# ========== Starship 提示符 ==========
# 使用 Starship 作为提示符
$env.STARSHIP_CONFIG = ($env.USERPROFILE | path join ".config" "starship.toml")

# 配置 Starship 提示符
$env.PROMPT_COMMAND = { || starship prompt }
$env.PROMPT_INDICATOR = ""

# ========== 基础配置 ==========
$env.config = {
    show_banner: false  # 不显示启动横幅

    # 历史记录配置
    history: {
        max_size: 10000
        sync_on_enter: true
        file_format: "plaintext"
    }

    # 补全配置
    completions: {
        quick: true
        partial: true
        algorithm: "fuzzy"
    }

    # 文件大小格式
    filesize: {
        metric: false
        format: "auto"
    }

    # 表格配置
    table: {
        mode: rounded
        index_mode: always
        trim: {
            methodology: wrapping
            wrapping_try_keep_words: true
        }
    }
}

# ========== 别名 ==========
alias ll = ls -la
alias la = ls -a
alias cls = clear
alias .. = cd ..
alias ... = cd ../..

# Mise 别名
alias mi = mise
alias mr = mise run

# Git 别名
alias gs = git status
alias ga = git add
alias gc = git commit
alias gp = git push
alias gl = git log --oneline

# ========== 自定义命令 ==========
# 快速打开项目
def --env proj [] {
    cd ~/meta-infra
}

# ========== 环境初始化 ==========
# 初始化 Mise
if (which mise | is-not-empty) {
    mise activate nu | save -f ~/.config/nushell/mise.nu
    source ~/.config/nushell/mise.nu
}
