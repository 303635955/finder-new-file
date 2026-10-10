import Foundation

@main
struct CoreSmoke {
    static func main() throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let first = try NewFileCore.create(in: directory, name: "未命名文本文档", extension: "txt")
        let second = try NewFileCore.create(in: directory, name: "未命名文本文档", extension: "txt")
        precondition(first.lastPathComponent == "未命名文本文档.txt")
        precondition(second.lastPathComponent == "未命名文本文档 2.txt")
        precondition((try? Data(contentsOf: first))?.isEmpty == true)
        let filled = try NewFileCore.create(in: directory, name: "新建 JSON 文件", extension: "json", content: Data("{}\n".utf8))
        let savedContent = try Data(contentsOf: filled)
        precondition(savedContent == Data("{}\n".utf8))
        print("Core smoke test passed")
    }
}
