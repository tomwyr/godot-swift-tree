enum GodotNodeTreeError: Error, CustomStringConvertible {
  case unexpectedNodeParameters(nodeParams: NodeParams)
  case unexpectedSceneResource(instance: String)
  case parentNodeNotFound(sceneName: String)

  var description: String {
    switch self {
    case let .unexpectedNodeParameters(nodeParams):
      "A node with unexpected set of parameters encountered: \(nodeParams)."
    case let .unexpectedSceneResource(instance):
      "A node pointing to an unknown scene resource encountered with id: \(instance)."
    case let .parentNodeNotFound(sceneName):
      "None of the parsed nodes was identified as the parent node of scene \(sceneName)."
    }
  }
}
