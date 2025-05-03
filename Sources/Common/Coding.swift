extension NodeType {
  enum CodingKeys: String, CodingKey {
    case nodeType
  }

  enum NodeTypeKey: String, Codable {
    case parentNode, leafNode, nestedScene
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)

    switch self {
    case let .parentNode(node):
      try container.encode(NodeTypeKey.parentNode.rawValue, forKey: .nodeType)
      try node.encode(to: encoder)
    case let .leafNode(node):
      try container.encode(NodeTypeKey.leafNode.rawValue, forKey: .nodeType)
      try node.encode(to: encoder)
    case let .nestedScene(node):
      try container.encode(NodeTypeKey.nestedScene.rawValue, forKey: .nodeType)
      try node.encode(to: encoder)
    }
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let nodeType = try container.decode(NodeTypeKey.self, forKey: .nodeType)

    switch nodeType {
    case .parentNode:
      self = .parentNode(try ParentNode(from: decoder))
    case .leafNode:
      self = .leafNode(try LeafNode(from: decoder))
    case .nestedScene:
      self = .nestedScene(try NestedScene(from: decoder))
    }
  }
}
