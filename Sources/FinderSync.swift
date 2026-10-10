import AppKit
import FinderSync

@objc(FinderSync)
final class FinderSync: FIFinderSync {
    private let types: [(title: String, name: String, ext: String)] = [
        ("新建文本文档 (.txt)", "未命名文本文档", "txt"),
        ("新建 Markdown 文档 (.md)", "未命名文档", "md")
    ]

    override init() {
        super.init()
        FIFinderSyncController.default().directoryURLs = [URL(fileURLWithPath: "/", isDirectory: true)]
    }

    override func menu(for menuKind: FIMenuKind) -> NSMenu? {
        guard menuKind == .contextualMenuForContainer || menuKind == .toolbarItemMenu else { return nil }
        let menu = NSMenu(title: "新建文件")
        for (index, type) in types.enumerated() {
            let item = NSMenuItem(title: type.title, action: #selector(createFile(_:)), keyEquivalent: "")
            item.target = self
            item.tag = index
            menu.addItem(item)
        }
        return menu
    }

    @objc private func createFile(_ sender: NSMenuItem) {
        guard types.indices.contains(sender.tag),
              let directory = FIFinderSyncController.default().targetedURL() else { return }
        let type = types[sender.tag]
        do {
            let created = try NewFileCore.create(in: directory, name: type.name, extension: type.ext)
            NSWorkspace.shared.activateFileViewerSelecting([created])
        } catch {
            let alert = NSAlert()
            alert.messageText = "无法新建文件"
            alert.informativeText = error.localizedDescription
            alert.alertStyle = .warning
            alert.runModal()
        }
    }

    override var toolbarItemName: String { "新建文件" }
    override var toolbarItemToolTip: String { "在当前文件夹新建文件" }
    override var toolbarItemImage: NSImage {
        NSImage(systemSymbolName: "doc.badge.plus", accessibilityDescription: "新建文件")
            ?? NSImage(size: NSSize(width: 18, height: 18))
    }
}
