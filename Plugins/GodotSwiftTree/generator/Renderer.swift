class NodeTreeRenderer {
  func render(packageName: String?, scenes: [Scene]) -> String {
    let package = packageName.map { "package \($0)" }
    let imports = renderImports()
    let nodeTree = renderNodeTree(scenes: scenes)
    let sceneNodes = scenes.map(renderScene).joinLines(spacing: 2)
    let nodeRef = renderNodeRef()

    return [package, imports, nodeTree, sceneNodes, nodeRef].compactMap { $0 }
      .joinLines(spacing: 2) + "\n"
  }

  private func renderImports() -> String {
    return ""
  }

  private func renderNodeTree(scenes _: [Scene]) -> String {
    return ""
  }

  private func renderScene(scene _: Scene) -> String {
    return ""
  }

  private func renderNode(node _: Node, parentPath _: String) -> String {
    return ""
  }

  private func renderNodeRef() -> String {
    return ""
  }
}

private extension Sequence<String> {
  func joinLines(spacing: Int = 1) -> String {
    return joined(separator: String(repeating: "\n", count: spacing))
  }
}

private extension String {
  func indentLine(times: Int = 1) -> String {
    let whiteSpace = String(repeating: "    ", count: times)
    return components(separatedBy: .newlines).joined(separator: "\n" + whiteSpace)
  }
}
