# ✅ 使用 ubi backend 的优势

## 为什么使用 ubi backend？

根据 Mise 官方文档的推荐，使用 `ubi` backend 有以下优势：

### 1. **官方推荐** ⭐
- Mise 文档明确推荐使用 `ubi` 和 `aqua` backend
- 比传统的 `asdf` 插件更现代化

### 2. **零配置**
- 不需要额外的插件
- 直接从 GitHub releases 下载
- 自动识别正确的二进制文件

### 3. **跨平台支持**
- ✅ Windows 完全支持
- ✅ macOS 支持
- ✅ Linux 支持

### 4. **安全性**
- 直接从官方 GitHub releases 下载
- 无需第三方插件维护者

### 5. **性能**
- 更快的安装速度
- 不需要运行额外的插件脚本

---

## 当前使用 ubi backend 的工具

```toml
# mise.toml

# 文档与排版
"ubi:quarto-dev/quarto-cli" = "latest"
"ubi:typst/typst" = "latest"

# 多媒体
"ubi:BtbN/FFmpeg-Builds" = "latest"
```

---

## 对比：之前 vs 现在

### 之前的方案 ❌
```toml
# 需要手动安装
# quarto = "latest"  # 不在 Mise 注册表
# typst = "latest"   # 不在 Mise 注册表
# ffmpeg = "latest"  # 不在 Mise 注册表
```

**问题**:
- 报错:`tool not found in mise tool registry`
- 需要手动通过 Winget 安装
- 不能通过 `mise install` 统一管理

### 现在的方案 ✅
```toml
# 使用 ubi backend
"ubi:quarto-dev/quarto-cli" = "latest"
"ubi:typst/typst" = "latest"
"ubi:BtbN/FFmpeg-Builds" = "latest"
```

**优势**:
- ✅ 通过 `mise install` 一键安装
- ✅ 统一版本管理
- ✅ 从 GitHub releases 自动下载
- ✅ 跨平台兼容

---

## 如何找到 ubi backend 的仓库？

1. **搜索工具的官方 GitHub 仓库**
   ```bash
   # 例如搜索 Quarto
   # GitHub: quarto-dev/quarto-cli
   ```

2. **确认仓库有 releases**
   - 访问 `https://github.com/owner/repo/releases`
   - 确保有预编译的二进制文件

3. **在 mise.toml 中使用**
   ```toml
   "ubi:owner/repo" = "latest"
   ```

---

## 实际案例：三个工具的 GitHub 仓库

| 工具 | GitHub 仓库 | Mise 配置 |
|------|------------|-----------|
| Quarto | `quarto-dev/quarto-cli` | `"ubi:quarto-dev/quarto-cli" = "latest"` |
| Typst | `typst/typst` | `"ubi:typst/typst" = "latest"` |
| FFmpeg | `BtbN/FFmpeg-Builds` | `"ubi:BtbN/FFmpeg-Builds" = "latest"` |

---

## 测试安装

```bash
# 查看所有配置的工具
mise list

# 安装所有工具
mise install

# 应该会看到：
# - python@3.12
# - node@lts
# - ubi:quarto-dev/quarto-cli@latest
# - ubi:typst/typst@latest
# - ubi:BtbN/FFmpeg-Builds@latest
# - jq@latest
# - yq@latest
# - ripgrep@latest
# - pixi@latest
# - npm:@anthropic-ai/claude-code@latest
# - npm:@google/gemini-cli@latest
```

---

## 总结

使用 `ubi` backend 后：
- ✅ **11 个工具全部通过 Mise 管理**
- ✅ **无需手动安装任何工具**
- ✅ **一条命令安装所有 CLI 工具**
- ✅ **符合 Mise 官方最佳实践**

**这就是为什么应该使用 ubi backend！** 🎉
