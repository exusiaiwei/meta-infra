# 📘 LTSC 系统增强指南

## 🎯 概述

`LTSC-Enhancement.psm1` 是专为 Windows LTSC 版本设计的增强功能模块，帮助你为精简的 LTSC 系统添加缺失的组件。

---

## ✨ 功能特性

### 1. Winget (App Installer) 安装 🔴 必需
- 自动下载并安装最新版本
- 适用于所有 LTSC 版本
- 无需 Microsoft Store

### 2. Microsoft Store 安装 🔵 可选
提供 **3 种方法**：

#### 方法 1：官方方法 (wsreset -i)
- ✅ 适用于：Win10 LTSC 2021+ / Win11 LTSC 2024
- ✅ 最简单、最可靠
- ✅ 官方支持

#### 方法 2：kkkgo 社区脚本
- ✅ 适用于：Win10 LTSC 2019 及更早版本
- ✅ GitHub: [kkkgo/LTSC-Add-MicrosoftStore](https://github.com/kkkgo/LTSC-Add-MicrosoftStore)
- ⭐ 11k+ stars

#### 方法 3：fernvenue 社区脚本
- ✅ 适用于：Win10 LTSC 2019/2021, Win11 LTSC 2024
- ✅ GitHub: [fernvenue/microsoft-store](https://github.com/fernvenue/microsoft-store)
- ✅ 多版本测试通过

### 3. Xbox Services 安装 🎮 可选
- Xbox Game Bar
- Xbox Live 服务
- Xbox Identity Provider
- **依赖**：需要先安装 Microsoft Store

---

## 🚀 使用方式

### 方法 1：集成在安装向导中

当检测到 LTSC 时，安装向导会自动显示增强菜单。

### 方法 2：独立运行

```powershell
# 导入模块
Import-Module ./bootstrap/LTSC-Enhancement.psm1

# 显示菜单
$selection = Show-LTSCEnhancementMenu

# 处理选择
Process-LTSCEnhancements -Selection $selection
```

---

## 📋 安装流程

### 场景 A：全新 LTSC 系统

```
步骤 1: 检测到 LTSC
     ↓
步骤 2: 显示增强菜单
     ├─ 选项 1: Winget  ✅ 必装
     ├─ 选项 2: Microsoft Store
     └─ 选项 3: Xbox Services
     ↓
步骤 3: 安装选中组件
     ↓
步骤 4: 继续主安装流程
```

### 场景 B：已有 Winget 的 LTSC

```
步骤 1: 检测到 Winget 已安装
     ↓
步骤 2: 跳过 Winget，仅提供 Store/Xbox 选项
     ↓
步骤 3: 继续主安装流程
```

---

## 🎨 菜单界面示例

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  🔧 LTSC 系统增强选项
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

检测到 Windows LTSC 版本！

LTSC 版本默认不包含某些组件，您可以选择安装：

请选择要安装的组件（多选用逗号分隔）：

  [必需组件]
  1. Winget (App Installer) - Windows 包管理器 🔴 必装

  [可选组件]
  2. Microsoft Store        - 微软应用商店（访问 MSIX 应用）
  3. Xbox Services          - Xbox 游戏服务（仅游戏玩家需要）

  0. 全部安装
  Q. 跳过，稍后手动配置

请输入选项 (例如: 1,2 或 0 或 Q): _
```

---

## 📝 各版本 LTSC 推荐方案

### Windows 11 LTSC 2024
```
推荐：
  ✅ Winget: 方法 1 (必装)
  ✅ Store: 方法 1 (wsreset -i) - 官方支持
  ⚠️  Xbox: 按需
```

### Windows 10 LTSC 2021
```
推荐：
  ✅ Winget: 方法 1 (必装)
  ✅ Store: 方法 1 (wsreset -i) - 官方支持
  ⚠️  Xbox: 按需
```

### Windows 10 LTSC 2019
```
推荐：
  ✅ Winget: 方法 1 (必装)
  ✅ Store: 方法 2 (kkkgo) - 社区方案
  ⚠️  Xbox: 不推荐（兼容性问题）
```

### Windows 10 LTSB 2016 及更早
```
推荐：
  ✅ Winget: 方法 1 (必装)
  ⚠️  Store: 方法 2 (kkkgo) - 可能不稳定
  ❌ Xbox: 不支持
```

---

## ⚠️ 注意事项

### Microsoft Store 安装后

1. **初次使用可能需要**：
   - 重启计算机
   - 运行 `wsreset.exe` 清除缓存
   - 登录 Microsoft 账户

2. **故障排除**：
   ```powershell
   # 清除 Store 缓存
   wsreset.exe

   # 重新注册 Store 应用
   Get-AppxPackage *store* | Remove-AppxPackage
   Add-AppxPackage -register "C:\Program Files\WindowsApps\*Store*\AppxManifest.xml" -DisableDevelopmentMode
   ```

### Winget 安装后

- ✅ 需要重启终端才能使用
- ✅ 或手动刷新环境变量：
  ```powershell
  $env:Path = [System.Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' + [System.Environment]::GetEnvironmentVariable('Path', 'User')
  ```

---

## 🔗 参考资源

### 官方文档
- [Windows Package Manager (Winget)](https://github.com/microsoft/winget-cli)
- [LTSC Overview](https://docs.microsoft.com/windows/deployment/update/waas-overview)

### 社区脚本
- [kkkgo/LTSC-Add-MicrosoftStore](https://github.com/kkkgo/LTSC-Add-MicrosoftStore) - ⭐ 11k+ stars
- [fernvenue/microsoft-store](https://github.com/fernvenue/microsoft-store) - 多版本支持
- [massgrave.dev](https://massgrave.dev/) - Windows 激活工具（如需要）

---

## 🛠️ 高级用法

### 仅安装 Winget

```powershell
Import-Module ./bootstrap/LTSC-Enhancement.psm1
Install-Winget-LTSC
```

### 仅安装 Microsoft Store

```powershell
Import-Module ./bootstrap/LTSC-Enhancement.psm1
Install-MicrosoftStore-LTSC
```

### 批量部署

```powershell
# 自动化脚本
$selection = "1,2"  # Winget + Store
Process-LTSCEnhancements -Selection $selection
```

---

## ❓ 常见问题

### Q: LTSC 是否推荐安装 Microsoft Store？

**A**: 取决于你的需求：
- ✅ **推荐安装**：如果你需要使用 MSIX 应用、PWA 应用
- ❌ **不推荐安装**：如果追求极致精简、仅使用传统软件

### Q: 安装 Store 会影响 LTSC 的稳定性吗？

**A**:
- Win10 LTSC 2021+ / Win11 LTSC 2024: ✅ 官方方法，稳定性好
- Win10 LTSC 2019 及更早: ⚠️ 社区方案，可能有小问题

### Q: Xbox Services 是否必需？

**A**: ❌ 非必需
- 仅游戏玩家需要（Xbox Game Pass, Xbox Game Bar）
- 普通用户无需安装

---

## 🎯 总结

**最小化方案**（仅必需）：
```
✅ Winget
```

**推荐方案**（平衡）：
```
✅ Winget
✅ Microsoft Store
```

**完整方案**（游戏玩家）：
```
✅ Winget
✅ Microsoft Store
✅ Xbox Services
```

选择适合你的方案，享受增强后的 LTSC 系统！🚀
