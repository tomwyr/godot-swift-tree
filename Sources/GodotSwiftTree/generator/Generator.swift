public class NodeTreeGenerator {
  private let parser: SceneNodesParser
  private let renderer: NodeTreeRenderer

  init(
    parser: SceneNodesParser = SceneNodesParser(),
    renderer: NodeTreeRenderer = NodeTreeRenderer()
  ) {
    self.parser = parser
    self.renderer = renderer
  }

  func generate(project: GodotSwiftProject) throws -> NodeTreeInfo {
    let scenesData = try project.readScenes()
    let scenes = try scenesData.map { data in
      let root = try parser.parse(sceneData: data)
      return Scene(name: data.name, root: root)
    }
    let content = renderer.render(scenes: scenes)
    try project.writeNodeTree(content: content)

    return NodeTreeInfo(scenes: scenes)
  }
}
