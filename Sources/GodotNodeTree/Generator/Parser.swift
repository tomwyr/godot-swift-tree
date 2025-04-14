import RegexBuilder

struct GodotNodesParser {
  func parse(sceneData: SceneData) throws -> NodeType {
    let scenePathsById = ScenesParser().parse(sceneData: sceneData)
    return try NodesParser(scenePathsById: scenePathsById).parse(sceneData: sceneData)
  }
}

private struct ScenesParser {
  func parse(sceneData: SceneData) -> [String: String] {
    let sceneIdsToPaths = splitToEntries(data: sceneData.content, entryType: "ext_resource")
      .map(parseEntryParams)
      .compactMap(extractSceneIdToPath)
    return Dictionary(uniqueKeysWithValues: sceneIdsToPaths)
  }

  private func extractSceneIdToPath(params: [String: String]) -> (String, String)? {
    let id = params["id"]
    let path = params["path"]

    guard let id, let path else {
      return nil
    }

    return (id, path)
  }
}

private struct NodesParser {
  let scenePathsById: [String: String]

  func parse(sceneData: SceneData) throws -> NodeType {
    let nodeParams = splitToEntries(data: sceneData.content, entryType: "node")
      .map(parseEntryParams)
      .compactMap(extractNodeParams)
    return try createRootNode(sceneName: sceneData.name, params: nodeParams)
  }

  private func extractNodeParams(params: [String: String]) -> NodeParams? {
    let name = params["name"]
    let type = params["type"]
    let instance = params["instance"]
    let parent = params["parent"]

    guard let name, type != nil || instance != nil, type == nil || instance == nil else {
      return nil
    }

    return NodeParams(name: name, type: type, instance: instance, parent: parent)
  }

  private func createRootNode(sceneName: String, params: [NodeParams]) throws -> NodeType {
    let childrenByParent = Dictionary(grouping: params, by: { $0.parent })
    let rootParams = params.first { $0.parent == nil }

    guard let rootParams else {
      throw GodotNodeTreeError.parentNodeNotFound(sceneName: sceneName)
    }

    return try rootParams.toNode(childrenByParent, scenePathsById)
  }
}

extension NodeParams {
  func toNode(_ childrenByParent: [String?: [NodeParams]], _ scenePathsById: [String: String])
    throws -> NodeType
  {
    if case let (type?, nil) = (type, instance) {
      let childrenKey =
        switch parent {
        case nil: "."
        case ".": name
        default: "\(parent!)/\(name)"
        }

      let children = try (childrenByParent[childrenKey] ?? [])
        .map { params in try params.toNode(childrenByParent, scenePathsById) }

      return if !children.isEmpty {
        .parentNode(ParentNode(name: name, type: type, children: children))
      } else {
        .leafNode(LeafNode(name: name, type: type))
      }
    }

    if case let (nil, instance?) = (type, instance) {
      if let scenePath = scenePathsById[instance],
        let scene = parseSceneName(scenePath: scenePath)?.firstCapitalized
      {
        return .nestedScene(NestedScene(name: name, scene: scene))
      }
      throw GodotNodeTreeError.unexpectedSceneResource(instance: instance)
    }

    throw GodotNodeTreeError.unexpectedNodeParameters(nodeParams: self)
  }
}

private func splitToEntries(data: String, entryType: String) -> [String] {
  let pattern = #"\[\#(entryType) .*\]"#
  let regex = try! Regex<Substring>(pattern)
  let matches = data.matches(of: regex)
  return matches.compactMap { String($0.output) }
}

private func parseEntryParams(entry: String) -> [String: String] {
  let regex = #/(?:(\w+)=(?:\w+\("(.+)"\)|"(.+?)"))+/#
  let matches = entry.matches(of: regex)
  return matches.reduce(into: [String: String]()) { params, match in
    let (_, key, argumentValue, plainValue) = match.output
    let value = argumentValue ?? plainValue ?? ""
    params[String(key)] = String(value)
  }
}

private func parseSceneName(scenePath: String) -> String? {
  let regex = #/^res://(.*).tscn$/#
  let matches = scenePath.matches(of: regex)
  let groups = matches.first?.output
  return (groups?.1).map { String($0) }
}
