import Foundation

extension URL {
    func walkTopDown() throws -> any Sequence<URL> {
        let fm = FileManager.default

        func isDirectory(_ path: String) -> Bool? {
            var isDirectory: ObjCBool = false
            if fm.fileExists(atPath: path, isDirectory: &isDirectory) {
                return isDirectory.boolValue
            } else {
                return nil
            }
        }

        var directories = [self]
        var files = [URL]()

        while !directories.isEmpty {
            let directory = directories.removeFirst()

            try fm.contentsOfDirectory(atPath: directory.absoluteString).forEach { item in
                let path = directory.appending(path: item)
                
                switch isDirectory(path.absoluteString) {
                case .some(true):
                    directories.append(path)
                case .some(false):
                    files.append(path)
                case .none:
                    break
                }
            }
        }

        return files
    }
}
