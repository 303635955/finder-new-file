import AppKit

@main
final class App: NSObject, NSApplicationDelegate {
    private var window: NSWindow?

    static func main() {
        let app = NSApplication.shared
        let delegate = App()
        app.delegate = delegate
        app.setActivationPolicy(.regular)
        app.run()
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 490, height: 275),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        window.title = "新建文件"
        window.center()
        let stack = NSStackView()
        stack.orientation = .vertical
        stack.alignment = .leading
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false

        let title = NSTextField(labelWithString: "在 Finder 中右键新建文件")
        title.font = .boldSystemFont(ofSize: 20)
        let instructions = NSTextField(wrappingLabelWithString:
            "安装到“应用程序”后，在系统设置 → 通用 → 登录项与扩展 → Finder 扩展中开启“新建文件”。然后在桌面或 Finder 文件夹空白处右键，选择新建文本文档或 Markdown 文档。")
        instructions.font = .systemFont(ofSize: 14)
        let note = NSTextField(wrappingLabelWithString:
            "如果右键菜单在 iCloud 云盘中未出现，可在 Finder 的“显示 → 自定工具栏”添加“新建文件”按钮。")
        note.textColor = .secondaryLabelColor
        note.font = .systemFont(ofSize: 12)
        let button = NSButton(title: "打开扩展设置", target: self, action: #selector(openSettings))
        button.bezelStyle = .rounded
        stack.addArrangedSubview(title)
        stack.addArrangedSubview(instructions)
        stack.addArrangedSubview(note)
        stack.addArrangedSubview(button)
        window.contentView?.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: window.contentView!.leadingAnchor, constant: 28),
            stack.trailingAnchor.constraint(equalTo: window.contentView!.trailingAnchor, constant: -28),
            stack.centerYAnchor.constraint(equalTo: window.contentView!.centerYAnchor)
        ])
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        self.window = window
    }

    @objc private func openSettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.ExtensionsPreferences") {
            NSWorkspace.shared.open(url)
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool { true }
}
