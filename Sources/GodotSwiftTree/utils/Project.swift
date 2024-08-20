import Foundation

public struct GodotNodeTreeConfig {
  let projectPath: String?
}

public class GodotSwiftProject {
  private let projectPath: String
  private let outputPath: String

  init(projectPath: String, outputPath: String) {
    self.projectPath = projectPath
    self.outputPath = outputPath
  }

  func readScenes() throws -> [SceneData] {
    let directory = URL(fileURLWithPath: projectPath, isDirectory: true)

    return try directory.walkTopDown()
      .filter { $0.pathExtension == "tscn" }
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
    let projectRelativePath = config.projectPath
    let projectPath = try getProjectPath(rootPath: rootPath, relativePath: projectRelativePath)
    let outputPath = getOutputPath(rootPath: rootPath)

    return GodotSwiftProject(projectPath: projectPath, outputPath: outputPath)
  }

  private static func getProjectPath(rootPath: String, relativePath: String?) throws -> String {
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

  private static func getOutputPath(rootPath: String) -> String {
    let fileName = "GodotNodeTree.swift"
    return URL(filePath: rootPath).appending(path: fileName).absoluteString
  }
}
