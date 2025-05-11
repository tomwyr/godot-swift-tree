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

extension GodotNodeTreeError {
  enum CodingKeys: String, CodingKey {
    case errorType
    case projectPath
    case scenePath
    case nodeParams
    case instance
    case sceneName
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)

    switch self {
    case .invalidGodotProject(let path):
      try container.encode("invalidGodotProject", forKey: .errorType)
      try container.encode(path, forKey: .projectPath)
    case .scanningScenesFailed(let path):
      try container.encode("scanningScenesFailed", forKey: .errorType)
      try container.encode(path, forKey: .projectPath)
    case .readingSceneFailed(let path):
      try container.encode("readingSceneFailed", forKey: .errorType)
      try container.encode(path, forKey: .scenePath)
    case .unexpectedNodeParameters(let params):
      try container.encode("unexpectedNodeParameters", forKey: .errorType)
      try container.encode(params, forKey: .nodeParams)
    case .unexpectedSceneResource(let instance):
      try container.encode("unexpectedSceneResource", forKey: .errorType)
      try container.encode(instance, forKey: .instance)
    case .parentNodeNotFound(let name):
      try container.encode("parentNodeNotFound", forKey: .errorType)
      try container.encode(name, forKey: .sceneName)
    }
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let type = try container.decode(String.self, forKey: .errorType)

    switch type {
    case "invalidGodotProject":
      self = .invalidGodotProject(
        projectPath: try container.decode(String.self, forKey: .projectPath))
    case "scanningScenesFailed":
      self = .scanningScenesFailed(
        projectPath: try container.decode(String.self, forKey: .projectPath))
    case "readingSceneFailed":
      self = .readingSceneFailed(scenePath: try container.decode(String.self, forKey: .scenePath))
    case "unexpectedNodeParameters":
      self = .unexpectedNodeParameters(
        nodeParams: try container.decode(NodeParams.self, forKey: .nodeParams))
    case "unexpectedSceneResource":
      self = .unexpectedSceneResource(
        instance: try container.decode(String.self, forKey: .instance))
    case "parentNodeNotFound":
      self = .parentNodeNotFound(sceneName: try container.decode(String.self, forKey: .sceneName))
    default:
      throw DecodingError.dataCorruptedError(
        forKey: .errorType, in: container, debugDescription: "Unknown errorType")
    }
  }
}
