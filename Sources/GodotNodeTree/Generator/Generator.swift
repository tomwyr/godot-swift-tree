public struct NodeTreeGenerator {
  let reader: GodotProjectReader
  let parser: GodotNodesParser

  init(
    reader: GodotProjectReader = GodotProjectReader(),
    parser: GodotNodesParser = GodotNodesParser()
  ) {
    self.reader = reader
    self.parser = parser
  }

  func generate(projectPath: String) throws(GenerateNodeTreeError) -> NodeTree {
    do {
      let scenesData = try reader.readScenes(projectPath: projectPath)
      let scenes = try scenesData.map { data in
        let root = try parser.parse(sceneData: data)
        return Scene(name: data.name, root: root)
      }
      return NodeTree(scenes: scenes)
    } catch {
      throw .unknown
    }
  }
}

enum GenerateNodeTreeError: Error, Codable {
  // TODO Add proper error handling
  case unknown
}
