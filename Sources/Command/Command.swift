import Foundation

struct GenerateTreeCommand {
  let libPath: String
  let projectPath: String
  let validateProjectPath: Bool
  let outputPath: String

  func run() throws(GodotSwiftTreeError) {
    let tree = try generateNodeTree(
      libPath: libPath,
      projectPath: projectPath,
      validateProjectPath: validateProjectPath,
    )
    let content = NodeTreeRenderer().render(tree: tree)
    try NodeTreeWriter().write(content: content, at: outputPath)
  }
}

extension GenerateTreeCommand {
  init(input: GodotSwiftTreeInput) throws(GodotSwiftTreeError) {
    self.init(
      libPath: try Self.getLibPath(),
      projectPath: try Self.getProjectPath(input),
      validateProjectPath: input.validateProjectPath,
      outputPath: Self.getOutputPath(input)
    )
  }

  static private var pluginPath: String {
    FileManager.default.currentDirectoryPath
  }

  static private func getLibPath() throws(GodotSwiftTreeError) -> String {
    let (resource, type) = ("libGodotNodeTreeCore", "dylib")
    guard let libPath = Bundle.module.path(forResource: resource, ofType: type) else {
      throw .invalidLibResource
    }
    return libPath
  }

  static private func getProjectPath(_ input: GodotSwiftTreeInput) throws(GodotSwiftTreeError)
    -> String
  {
    var url = URL(filePath: pluginPath)
    if let projectPath = input.projectPath {
      url = url.appending(path: projectPath)
    }
    url = url.appending(path: "project.godot")
    return url.path()
  }

  static private func getOutputPath(_ input: GodotSwiftTreeInput) -> String {
    var url = URL(filePath: pluginPath)
    if let outputDir = input.outputDir {
      url.append(path: outputDir)
    }
    url.append(path: "GodotNodeTree.swift")
    return url.path()
  }
}
