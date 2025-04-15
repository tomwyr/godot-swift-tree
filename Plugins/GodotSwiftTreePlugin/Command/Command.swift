import Foundation

struct GenerateTreeCommand {
  let environment: GodotSwiftTreeEnvironment
  let config: GodotNodeTreeConfig

  func run() throws {
    let tree = try generateNodeTree(libPath: environment.libPath, projectPath: try getProjectPath())
    let content = NodeTreeRenderer().render(tree: tree)
    try NodeTreeWriter().write(content: content, at: getOutputPath())
  }

  private func getProjectPath() throws -> String {
    var url = URL(filePath: environment.pluginPath)
    if let projectPath = config.projectPath {
      url = url.appending(path: projectPath)
    }
    url = url.appending(path: "project.godot")
    let path = url.path()

    let fm = FileManager.default
    guard fm.fileExists(atPath: path) else {
      throw GodotSwiftTreeError.invalidGodotProject
    }

    return path
  }

  private func getOutputPath() -> String {
    var url = URL(filePath: environment.pluginPath)
    if let outputDir = config.outputDir {
      url.append(path: outputDir)
    }
    url.append(path: "GodotNodeTree.swift")
    return url.path()
  }
}
