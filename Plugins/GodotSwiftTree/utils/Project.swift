import Foundation

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

extension GodotSwiftProject {
    static func create(rootPath: String, config: GodotNodeTreeConfig) throws -> GodotSwiftProject {
        Log.swiftProjectPath(rootPath: rootPath)

        let projectRelativePath = config.projectPath
        if let projectRelativePath {
            Log.godotCustomProjectPath(projectRelativePath: projectRelativePath)
        }

        let projectPath = try getProjectPath(rootPath: rootPath, relativePath: projectRelativePath)
        Log.godotProjectPath(projectPath: projectPath)

        let outputPath = getOutputPath(rootPath: rootPath)
        Log.swiftOutputPath(filePath: outputPath)

        return GodotSwiftProject(projectPath: projectPath, outputPath: outputPath)
    }


    static private func getProjectPath(rootPath: String, relativePath: String?) throws -> String {
        var url = URL(filePath: rootPath)
        if let relativePath {
            url = url.appending(path: relativePath)
        }
        url = url.appending(path: "project.godot")
        
        let path = url.absoluteString

        let fm = FileManager.default
        guard fm.fileExists(atPath: path) else {
            throw GeneratorError.invalidGodotProject
        }
        
        return path
    }

    static private func getOutputPath(rootPath: String) -> String {
        let fileName = "GodotNodeTree.swift"
        return URL(filePath: rootPath).appending(path: fileName).absoluteString
    }

}
