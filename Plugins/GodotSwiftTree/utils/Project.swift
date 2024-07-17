import Foundation

class SceneData {
    let name: String
    let content: String

    init(name: String, content: String) {
        self.name = name
        self.content = content
    }
}

class GodotSwiftProject {
    private let projectPath: String
    private let outputPath: String

    init(projectPath: String, outputPath: String) {
        self.projectPath = projectPath
        self.outputPath = outputPath
    }

    func readScenes() throws -> [SceneData] {
        let directory = URL(fileURLWithPath: projectPath, isDirectory: true)

        return try directory.walkTopDown()
            .filter { $0.pathExtension == ".tscn" }
            .map { file in
                let fileName = file.deletingPathExtension().lastPathComponent
                let name = fileName.split(whereSeparator: ["_", "-"].contains).map(\.capitalized).joined()
                let content = try String(contentsOf: file)
                return SceneData(name: name, content: content)
            }.sorted(by: { $0.name <= $1.name })
    }

    func writeNodeTree(content: String) throws {
        let file = URL(fileURLWithPath: outputPath)
        try content.write(to: file, atomically: true, encoding: .utf8)
    }
}

extension String {
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
            let currentDirectory = directories.removeFirst()

            try fm.contentsOfDirectory(atPath: currentDirectory).forEach { item in
                let path = currentDirectory.appending(path: item)

                switch isDirectory(path) {
                case true:
                    directories.append(path)
                case false:
                    files.append(path)
                }
            }
        }

        return files
    }
}
