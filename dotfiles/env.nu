# ================================================================================================
# Nushell 环境配置文件 (env.nu)
# ================================================================================================
# 此文件配置环境变量和 PATH
# ================================================================================================

# ========== PATH 配置 ==========
# 添加自定义路径到 PATH
$env.PATH = ($env.PATH | split row (char esep) | append [
    # 添加你的自定义路径
    # ($env.USERPROFILE | path join "bin")
])

# ========== 环境变量 ==========
# 设置默认编辑器
$env.EDITOR = "code"

# 设置默认浏览器（可选）
# $env.BROWSER = "chrome"

# Mise 配置目录
$env.MISE_CONFIG_DIR = ($env.USERPROFILE | path join ".config" "mise")

# ========== 代理设置（如需要）==========
# $env.HTTP_PROXY = "http://proxy.example.com:8080"
# $env.HTTPS_PROXY = "http://proxy.example.com:8080"
