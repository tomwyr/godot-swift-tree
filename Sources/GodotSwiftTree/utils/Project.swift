import Foundation

public struct GodotNodeTreeConfig {
  let projectPath: String?
  let outputDir: String?
}

public class GodotSwiftProject {
  let projectPath: String
  let outputPath: String

  init(projectPath: String, outputPath: String) {
    self.projectPath = projectPath
    self.outputPath = outputPath
  }

  func readScenes() throws -> [SceneData] {
    let directory = URL(fileURLWithPath: projectPath).deletingLastPathComponent()

    return try directory.walkTopDown(includeHidden: false)
      .filter { $0.pathExtension == "tscn" }
      .map { file in
        let fileName = file.deletingPathExtension().lastPathComponent
        let name = fileName.split(whereSeparator: ["_", "-"].contains)
          .map(\.firstCapitalized)
          .joined()
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
    let projectPath = try getProjectPath(rootPath: rootPath, config: config)
    let outputPath = getOutputPath(rootPath: rootPath, config: config)

    return GodotSwiftProject(projectPath: projectPath, outputPath: outputPath)
  }

  private static func getProjectPath(rootPath: String, config: GodotNodeTreeConfig) throws -> String
  {
    var url = URL(filePath: rootPath)
    if let projectPath = config.projectPath {
      url = url.appending(path: projectPath)
    }
    url = url.appending(path: "project.godot")

    let path = url.path()

    let fm = FileManager.default
    guard fm.fileExists(atPath: path) else {
      throw GeneratorError.invalidGodotProject
    }

    return path
  }

  private static func getOutputPath(rootPath: String, config: GodotNodeTreeConfig) -> String {
    print(rootPath)
    print(config)
    var url = URL(filePath: rootPath)
    if let outputDir = config.outputDir {
      url.append(path: outputDir)
    }
    url.append(path: "GodotNodeTree.swift")
    return url.path()
  }
}
