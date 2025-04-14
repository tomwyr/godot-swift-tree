struct SceneData {
  let name: String
  let content: String
}

struct NodeParams {
  let name: String
  let type: String?
  let instance: String?
  let parent: String?
}

struct NodeTree: Codable {
  let scenes: [Scene]
}

struct Scene: Codable {
  let name: String
  let root: NodeType
}

enum NodeType: Codable {
  case parentNode(ParentNode)
  case leafNode(LeafNode)
  case nestedScene(NestedScene)
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
