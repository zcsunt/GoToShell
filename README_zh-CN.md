<p align="center">
  <a href="https://github.com/covoyage/GoToShell">
    <img width="200px" src="https://github.com/covoyage/GoToShell/raw/main/GoToShell/Assets.xcassets/AppIcon.appiconset/icon_256x256.png">
  </a>
</p>

<h1 align="center">
  GoToShell - 在 Finder 当前目录快速打开终端。
</h1>

<div align="left">

**简体中文 | [English](./README.md)**

</div>

<p align="center">
  <img src="screenshots/gotoshell.png" alt="Main Window" style="max-width: 100%; height: auto;" />
</p>

## 功能特点

- 🚀 从任意 Finder 位置一键打开终端
- 🎯 支持 10 款主流终端应用（Terminal、iTerm2、Warp、Alacritty、Ghostty、Hyper、Kitty、WezTerm、Tabby、Black Box）
- 🌍 双语界面（中文 & 英文）
- 🍎 原生 macOS 应用，轻量快速
- ⚡ 每次点击都会打开新窗口，即使应用已在运行

## 使用方法

### 第一步：配置应用

1. 打开 `GoToShell.app`
2. 选择你常用的终端应用
3. 点击"保存设置"

### 第二步：添加到 Finder 工具栏

1. 点击"添加到 Finder 工具栏"按钮
2. 应用会自动：
   - 打开包含 `GoToShellHelper.app` 的文件夹（文件已被选中）
3. 按住 Command (⌘) 键
4. 将 `GoToShellHelper.app` 拖到任意 Finder 窗口的工具栏
5. 松开鼠标完成添加

就这么简单！无需手动查找文件路径。

### 第三步：开始使用

1. 在 Finder 中打开任意文件夹
2. 点击工具栏中的 GoToShell 图标
3. 终端会在该目录打开一个新窗口

## 支持的终端

- **Terminal** - macOS 系统自带终端
- **iTerm2** - 功能丰富的终端替代品
- **Warp** - 带 AI 功能的现代终端
- **Alacritty** - GPU 加速的终端模拟器
- **Ghostty** - 快速的原生终端
- **Hyper** - 基于 Electron 的终端
- **Kitty** - GPU 加速终端
- **WezTerm** - 跨平台终端
- **Tabby** - 带标签页的现代终端
- **Black Box** - 基于 GTK4 的终端

应用会自动检测已安装的终端，只显示可用的选项。

## 系统要求

- macOS 14.0 或更高版本
- 支持 Apple Silicon (arm64) 和 Intel (x86_64) 架构

## 常见问题

### 问：点击工具栏图标没反应？

答：请确保：
1. `GoToShellHelper.app` 已正确添加到工具栏
2. 已在应用设置中选择了终端
3. 检查"系统设置" → "隐私与安全性" → "辅助功能"中的权限

### 问：如何切换到其他终端？

答：打开 `GoToShell.app`，选择新的终端，然后点击"保存设置"。

### 问：如何移除工具栏图标？

答：右键点击 Finder 工具栏，选择"自定工具栏"，然后将图标拖出工具栏。

### 问：如何验证下载文件的完整性？

答：下载对应的 `.sha256` 文件，然后运行：
```bash
shasum -a 256 -c GoToShell-x.x.x-arm64.dmg.sha256
```

### 贡献

欢迎提交 Issue 和 Pull Request！

## 许可证

AGPL-3.0 License

## 致谢

感谢所有贡献者和用户的支持！
