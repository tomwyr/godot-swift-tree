import Foundation

struct GenerateTreeCommand {
  let libPath: String
  let projectPath: String
  let outputPath: String

  func run() throws {
    let tree = try generateNodeTree(libPath: libPath, projectPath: projectPath)
    let content = NodeTreeRenderer().render(tree: tree)
    try NodeTreeWriter().write(content: content, at: outputPath)
  }
}
