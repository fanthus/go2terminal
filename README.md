# Go2Terminal

一个轻量的 macOS Finder 工具栏小工具：点击图标即可在当前 Finder 目录打开终端。

支持 `Terminal.app` 与 `iTerm2`，并提供偏好设置切换默认终端。

## 功能特性

- Finder 工具栏一键打开当前目录终端
- 支持 `Terminal.app` 和 `iTerm2`
- 标准 macOS 设置窗口（Option/Shift + 点击，或 `./scripts/open-settings.sh`）
- Finder 无窗口时自动回退到用户主目录
- iTerm2 未安装时给出可操作提示
- 自动化权限缺失时引导到系统设置

## 运行环境

- macOS 13+
- Xcode 15+

## 快速开始

### 方式一：命令行安装

```bash
./scripts/install.sh
```

会构建 Release 版本并安装到 `/Applications/Go2Terminal.app`。

### 方式二：Xcode 开发

```bash
open Go2Terminal.xcodeproj
```

在 Xcode 中选择 **Go2Terminal** scheme，按 `Cmd+R` 运行或 `Cmd+B` 构建。

### 安装到 Finder 工具栏

1. 打开 Finder。
2. 按住 `Command` 键。
3. 将 `Go2Terminal.app` 拖到 Finder 工具栏。

### 使用

- **普通点击** 工具栏图标：在当前 Finder 目录打开终端
- **Option 或 Shift + 点击** 工具栏图标：打开 Go2Terminal 设置（按住修饰键直到点击完成）
- **命令行打开设置**：

```bash
./scripts/open-settings.sh
# 或
open -a Go2Terminal --args --settings
```

> 安装脚本会在应用入口加入启动包装层，在进程启动前检测 Option/Shift，以支持 Finder 工具栏的修饰键点击。
>
> 若无法删除或覆盖应用（提示「已打开」），先退出进程：
>
> ```bash
> ./scripts/quit.sh
> ```

## 权限说明

Go2Terminal 需要读取 Finder 当前目录，首次使用可能触发 Automation 权限请求。

如被拒绝，可在以下位置开启：

`System Settings -> Privacy & Security -> Automation`

## 开发

```bash
# 构建并安装到 /Applications
./scripts/install.sh

# 打包分发（测试 + 构建 + 签名 + zip）
./scripts/package.sh

# 运行单元测试
xcodebuild -project Go2Terminal.xcodeproj -scheme Go2Terminal \
  -configuration Debug -derivedDataPath .build/xcode test

# 清理构建产物
xcodebuild -project Go2Terminal.xcodeproj -scheme Go2Terminal \
  -derivedDataPath .build/xcode clean
rm -rf .build/xcode Go2Terminal.app dist
```

## 项目结构

```text
.
├── Go2Terminal.xcodeproj       # Xcode 工程
├── Go2Terminal/
│   ├── App/                    # 应用源码
│   │   ├── Go2TerminalApp.swift
│   │   ├── SettingsView.swift
│   │   ├── AppDelegate.swift
│   │   ├── FinderPathResolver.swift
│   │   ├── TerminalLauncher.swift
│   │   └── TerminalType.swift
│   └── Resources/
│       ├── Info.plist
│       ├── Go2Terminal.entitlements
│       └── Assets.xcassets     # 应用图标
├── Go2TerminalTests/           # 单元测试
└── scripts/
    ├── package.sh              # 打包 zip
    ├── install.sh              # 构建并安装到 /Applications
    └── codesign.sh             # 代码签名
```

## 设计要点

- Finder 当前路径解析：`FinderPathResolver`
- 终端启动：`TerminalLauncher`（`open -a`）
- 终端偏好持久化：`TerminalType` + `@AppStorage`
- 标准设置界面：SwiftUI `Settings` scene
- 无 Dock 图标的轻量工具体验：`LSUIElement`

## License

如需开源发布，建议补充 `LICENSE` 文件（例如 MIT）。
