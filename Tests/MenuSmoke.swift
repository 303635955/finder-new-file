import AppKit
import FinderSync

@main
struct MenuSmoke {
    static func main() {
        let extensionInstance = FinderSync()
        guard let menu = extensionInstance.menu(for: .contextualMenuForContainer),
              let submenu = menu.items.first?.submenu else {
            fatalError("Missing New File submenu")
        }
        precondition(menu.items.first?.title == "新建文件")
        precondition(submenu.items.first?.title == "文本文档 (.txt)")
        precondition(submenu.items.count == 9)
        print("Menu smoke test passed")
    }
}
