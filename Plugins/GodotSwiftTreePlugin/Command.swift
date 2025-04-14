struct GenerateTreeCommand {
  let environment: SwiftTreeEnvironment
  let config: NodeTreeConfig

  func run() throws {
    let renderer = NodeTreeRenderer()
    let writer = NodeTreeWriter(rootPath: environment.pluginPath, config: config)
    if let tree = resolveProjectTree(
      projectPath: environment.pluginPath,
      libPath: environment.libPath
    ) {
      let content = renderer.render(tree: tree)
      try writer.write(content: content)
    }
  }
}
