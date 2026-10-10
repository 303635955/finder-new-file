# 新建文件

一个轻量 macOS Finder 扩展：在桌面或 Finder 文件夹空白处右键，打开“新建文件”二级菜单。TXT 排第一，另外支持 Word、Excel、PowerPoint、RTF、Markdown、CSV、HTML、JSON。Office 文件由有效空白模板创建；其余类型按需放入最小初始内容。新文件会自动选中；如果名称已存在，会依次添加 ` 2`、` 3` 等后缀，不覆盖旧文件。

## 构建与安装

要求 macOS 14+ 和 Xcode Command Line Tools。

```bash
./build.sh
open dist/新建文件.app
```

将 `dist/新建文件.app` 移到“应用程序”，启动一次，然后在“系统设置 → 通用 → 登录项与扩展 → Finder 扩展”中开启“新建文件”。之后在桌面或 Finder 文件夹空白处右键使用。也可在 Finder“显示 → 自定工具栏”中添加“新建文件”按钮。

如果桌面由 iCloud 云盘管理，Finder 可能隐藏扩展的右键项。运行 `python3 scripts/install_desktop_action.py` 可另外安装“在桌面新建文本文档”快捷操作，在桌面右键菜单的“快速操作”或“服务”中使用。它始终在桌面创建文件。删除 `~/Library/Services/在桌面新建文本文档.workflow` 即可卸载此快捷操作。

`build.sh` 使用 ad hoc 签名，适合本机自行构建。公开分发需要 Apple Developer 证书签名及公证。

## 验证

```bash
swiftc Sources/NewFileCore.swift Tests/CoreSmoke.swift -o /tmp/new-file-core-smoke
/tmp/new-file-core-smoke
swiftc -parse-as-library Sources/NewFileCore.swift Sources/FinderSync.swift Tests/MenuSmoke.swift -framework AppKit -framework FinderSync -o /tmp/new-file-menu-smoke
/tmp/new-file-menu-smoke
```

此测试覆盖空文件创建、初始内容和重名编号。Finder 菜单出现与桌面行为还需在安装并开启扩展后验证。

## 已知限制

macOS 可能不会在由 iCloud 云盘等其他扩展管理的文件夹中显示 Finder Sync 右键项。Finder 文件夹可使用工具栏按钮；iCloud 桌面可使用上面的快捷操作。
