import Foundation

struct NodeTreeWriter {
  let rootPath: String
  let config: NodeTreeConfig

  func write(content: String) throws {
    let outputPath = getOutputPath(rootPath: rootPath, config: config)
    let file = URL(fileURLWithPath: outputPath)
    try content.write(to: file, atomically: true, encoding: .utf8)
  }

  private func getOutputPath(rootPath: String, config: NodeTreeConfig) -> String {
    var url = URL(filePath: rootPath)
    if let outputDir = config.outputDir {
      url.append(path: outputDir)
    }
    url.append(path: "GodotNodeTree.swift")
    return url.path()
  }
}
