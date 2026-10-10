# 新建文件

一个轻量 macOS Finder 扩展：在桌面或 Finder 文件夹空白处右键，创建空白 `.txt` 或 `.md` 文件。新文件会自动选中；如果名称已存在，会依次添加 ` 2`、` 3` 等后缀，不覆盖旧文件。

## 构建与安装

要求 macOS 14+ 和 Xcode Command Line Tools。

```bash
./build.sh
open dist/新建文件.app
```

将 `dist/新建文件.app` 移到“应用程序”，启动一次，然后在“系统设置 → 通用 → 登录项与扩展 → Finder 扩展”中开启“新建文件”。之后在桌面或 Finder 文件夹空白处右键使用。也可在 Finder“显示 → 自定工具栏”中添加“新建文件”按钮。

`build.sh` 使用 ad hoc 签名，适合本机自行构建。公开分发需要 Apple Developer 证书签名及公证。

## 验证

```bash
swiftc Sources/NewFileCore.swift Tests/CoreSmoke.swift -o /tmp/new-file-core-smoke
/tmp/new-file-core-smoke
```

此测试覆盖空文件创建和重名编号。Finder 菜单出现与桌面行为还需在安装并开启扩展后验证。

## 已知限制

macOS 可能不会在由 iCloud 云盘等其他扩展管理的文件夹中显示 Finder Sync 右键项。此时可使用 Finder 工具栏按钮。
