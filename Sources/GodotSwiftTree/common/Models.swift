class SceneData {
  let name: String
  let content: String

  init(name: String, content: String) {
    self.name = name
    self.content = content
  }
}

class Scene {
  let name: String
  let root: NodeType

  let nodesCount: Int
  let nodesDepth: Int

  init(name: String, root: NodeType) {
    self.name = name
    self.root = root

    nodesCount = root.flatten().count
    nodesDepth = root.longestPath().count
  }
}

enum NodeType: Node {
  case parentNode(ParentNode)
  case leafNode(LeafNode)
  case nestedScene(NestedScene)

  var name: String {
    unwrap().name
  }

  func flatten() -> [any Node] {
    unwrap().flatten()
  }

  func longestPath() -> [any Node] {
    unwrap().longestPath()
  }

  private func unwrap() -> Node {
    switch self {
    case let .parentNode(node):
      node
    case let .leafNode(node):
      node
    case let .nestedScene(node):
      node
    }
  }
}

protocol Node {
  var name: String { get }
  func flatten() -> [Node]
  func longestPath() -> [Node]
}

class ParentNode: Node {
  let name: String
  let type: String
  let children: [NodeType]

  init(name: String, type: String, children: [NodeType]) {
    self.name = name
    self.type = type
    self.children = children
  }

  func flatten() -> [any Node] {
    return children.flatMap { $0.flatten() } + [self]
  }

  func longestPath() -> [any Node] {
    let childrenPath = children.map { $0.longestPath() }.max(by: { $0.count > $1.count })
    return (childrenPath ?? []) + [self]
  }
}

class LeafNode: Node {
  let name: String
  let type: String

  init(name: String, type: String) {
    self.name = name
    self.type = type
  }

  func flatten() -> [any Node] {
    return [self]
  }

  func longestPath() -> [any Node] {
    return [self]
  }
}

class NestedScene: Node {
  let name: String
  let scene: String

  init(name: String, scene: String) {
    self.name = name
    self.scene = scene
  }

  func flatten() -> [any Node] {
    return [self]
  }

  func longestPath() -> [any Node] {
    return [self]
  }
}

class SceneNode: Node {
  let name: String
  let scene: String

  init(name: String, scene: String) {
    self.name = name
    self.scene = scene
  }

  func flatten() -> [any Node] {
    return [self]
  }

  func longestPath() -> [any Node] {
    return [self]
  }
}

class NodeTreeInfo {
  let nodes: Int
  let depth: Int
  let scenes: Int

  private init(nodes: Int, depth: Int, scenes: Int) {
    self.nodes = nodes
    self.depth = depth
    self.scenes = scenes
  }

  convenience init(scenes: [Scene]) {
    var nodes = 0
    var depth = 0

    for scene in scenes {
      nodes += scene.nodesCount
      depth = max(depth, scene.nodesDepth)
    }

    self.init(nodes: nodes, depth: depth, scenes: scenes.count)
  }
}
