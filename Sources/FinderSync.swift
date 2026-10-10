import AppKit
import FinderSync

@objc(FinderSync)
final class FinderSync: FIFinderSync {
    private let types: [(title: String, name: String, ext: String, template: String?, text: String?)] = [
        ("文本文档 (.txt)", "新建文本文档", "txt", nil, nil),
        ("Word 文档 (.docx)", "新建 Word 文档", "docx", "blank.docx", nil),
        ("Excel 工作簿 (.xlsx)", "新建 Excel 工作簿", "xlsx", "blank.xlsx", nil),
        ("PowerPoint 演示文稿 (.pptx)", "新建 PowerPoint 演示文稿", "pptx", "blank.pptx", nil),
        ("RTF 文档 (.rtf)", "新建 RTF 文档", "rtf", nil, "{\\rtf1\\ansi\\deff0{\\fonttbl{\\f0\\fnil Helvetica;}}\\f0\\fs24\\par}\n"),
        ("Markdown 文档 (.md)", "新建 Markdown 文档", "md", nil, nil),
        ("CSV 表格 (.csv)", "新建 CSV 表格", "csv", nil, nil),
        ("HTML 文件 (.html)", "新建 HTML 文件", "html", nil, "<!doctype html>\n<html lang=\"zh-CN\">\n<head><meta charset=\"utf-8\"><title></title></head>\n<body></body>\n</html>\n"),
        ("JSON 文件 (.json)", "新建 JSON 文件", "json", nil, "{}\n")
    ]

    override init() {
        super.init()
        FIFinderSyncController.default().directoryURLs = [URL(fileURLWithPath: "/", isDirectory: true)]
    }

    override func menu(for menuKind: FIMenuKind) -> NSMenu? {
        guard menuKind == .contextualMenuForContainer || menuKind == .toolbarItemMenu else { return nil }
        let menu = NSMenu(title: "新建文件")
        let parent = NSMenuItem(title: "新建文件", action: nil, keyEquivalent: "")
        let submenu = NSMenu(title: "新建文件")
        for (index, type) in types.enumerated() {
            let item = NSMenuItem(title: type.title, action: #selector(createFile(_:)), keyEquivalent: "")
            item.target = self
            item.tag = index
            submenu.addItem(item)
        }
        parent.submenu = submenu
        menu.addItem(parent)
        return menu
    }

    @objc private func createFile(_ sender: NSMenuItem) {
        guard types.indices.contains(sender.tag),
              let directory = FIFinderSyncController.default().targetedURL() else { return }
        let type = types[sender.tag]
        do {
            let content: Data
            if let template = type.template {
                let parts = template.split(separator: ".", maxSplits: 1).map(String.init)
                guard parts.count == 2,
                      let templateURL = Bundle(for: FinderSync.self).url(
                        forResource: parts[0], withExtension: parts[1], subdirectory: "Templates") else {
                    throw CocoaError(.fileNoSuchFile)
                }
                content = try Data(contentsOf: templateURL)
            } else {
                content = Data((type.text ?? "").utf8)
            }
            let created = try NewFileCore.create(in: directory, name: type.name, extension: type.ext, content: content)
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
