# Go2Shell

一个轻量的 macOS Finder 工具栏小工具：点击图标即可在当前 Finder 目录打开终端。

支持 `Terminal.app` 与 `iTerm2`，并提供偏好设置切换默认终端。

## 功能特性

- Finder 工具栏一键打开当前目录终端
- 支持 `Terminal.app` 和 `iTerm2`
- `Option` + 点击图标打开偏好设置
- Finder 无窗口时自动回退到用户主目录
- iTerm2 未安装时给出可操作提示
- 自动化权限缺失时引导到系统设置

## 运行环境

- macOS 12+
- Swift 5.9+

## 快速开始

### 1. 构建应用

```bash
make bundle
```

构建完成后会生成 `Go2Shell.app`。

### 2. 安装到 Finder 工具栏

1. 打开 Finder。
2. 按住 `Command` 键。
3. 将 `Go2Shell.app` 拖到 Finder 工具栏。

### 3. 使用

- 普通点击：在当前 Finder 目录打开终端
- 按住 `Option` 点击：打开偏好设置，切换默认终端

## 权限说明

Go2Shell 依赖 AppleScript 控制 Finder 与终端应用，首次使用可能触发 Automation 权限请求。

如被拒绝，可在以下位置开启：

`System Settings -> Privacy & Security -> Automation`

## 开发

```bash
# 调试/开发构建
make build

# 运行测试
make test

# 生成 .app 包
make bundle

# 清理构建产物
make clean
```

## 项目结构

```text
.
├── Sources
│   ├── Go2Shell
│   │   └── main.swift
│   └── Go2ShellLib
│       ├── AppDelegate.swift
│       ├── FinderPathResolver.swift
│       ├── TerminalLauncher.swift
│       ├── TerminalType.swift
│       └── PreferencesWindowController.swift
├── Tests/Go2ShellTests
├── Resources
├── scripts
└── Package.swift
```

## 设计要点

- Finder 当前路径解析：`FinderPathResolver`
- 终端启动与脚本拼接：`TerminalLauncher`
- 终端偏好持久化：`TerminalType` + `UserDefaults`
- 无 Dock 图标的轻量工具体验：`LSUIElement`

## 测试状态

当前仓库测试已通过（本地执行 `swift test`）：

- 12 tests
- 0 failures

## License

如需开源发布，建议补充 `LICENSE` 文件（例如 MIT）。
