import Foundation
import Darwin

enum NewFileError: LocalizedError {
    case invalidDirectory
    case cannotCreate(Int32)

    var errorDescription: String? {
        switch self {
        case .invalidDirectory: return "目标文件夹不可用。"
        case .cannotCreate(let code): return String(cString: strerror(code))
        }
    }
}

enum NewFileCore {
    static func create(in directory: URL, name: String, extension fileExtension: String, content: Data = Data()) throws -> URL {
        var isDirectory: ObjCBool = false
        guard directory.isFileURL,
              FileManager.default.fileExists(atPath: directory.path, isDirectory: &isDirectory),
              isDirectory.boolValue else { throw NewFileError.invalidDirectory }

        for number in 1...10_000 {
            let suffix = number == 1 ? "" : " \(number)"
            let filename = "\(name)\(suffix).\(fileExtension)"
            let destination = directory.appendingPathComponent(filename, isDirectory: false)
            let descriptor = destination.withUnsafeFileSystemRepresentation { path -> Int32 in
                guard let path else { return -1 }
                return open(path, O_WRONLY | O_CREAT | O_EXCL, 0o644)
            }
            if descriptor >= 0 {
                do {
                    let handle = FileHandle(fileDescriptor: descriptor, closeOnDealloc: true)
                    try handle.write(contentsOf: content)
                    try handle.close()
                    return destination
                } catch {
                    try? FileManager.default.removeItem(at: destination)
                    throw error
                }
            }
            let code = errno
            if code != EEXIST { throw NewFileError.cannotCreate(code) }
        }
        throw NewFileError.cannotCreate(EEXIST)
    }
}
