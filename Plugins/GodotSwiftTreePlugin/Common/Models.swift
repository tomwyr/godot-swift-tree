struct GodotSwiftTreeEnvironment {
  let pluginPath: String
  let libPath: String
}

struct GodotNodeTreeConfig {
  let projectPath: String?
  let outputDir: String?
}

struct NodeTree: Codable {
  let scenes: [Scene]
}

struct NodeParams: Codable {
  let name: String
  let type: String?
  let instance: String?
  let parent: String?
}

struct Scene: Codable {
  let name: String
  let root: NodeType
}

enum NodeType: Codable {
  case parentNode(ParentNode)
  case leafNode(LeafNode)
  case nestedScene(NestedScene)

  var name: String {
    switch self {
    case let .parentNode(node): node.name
    case let .leafNode(node): node.name
    case let .nestedScene(node): node.name
    }
  }
}

protocol Node: Codable {
  var name: String { get }
}

struct ParentNode: Node {
  let name: String
  let type: String
  let children: [NodeType]
}

struct LeafNode: Node {
  let name: String
  let type: String
}

struct NestedScene: Node {
  let name: String
  let scene: String
}
