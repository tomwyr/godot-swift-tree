enum GodotSwiftTreeError: Error, CustomStringConvertible {
  case invalidGodotProject
  case invalidLibResource
  case generatorUnavailable(path: String)
  case generatorUnexpectedResult
  case writingTreeFailed(path: String)

  var description: String {
    switch self {
    case .invalidGodotProject:
      "The project in which GodotNodeTree annotation was used isn't a valid Godot project directory."
    case .invalidLibResource:
      "The resource for the node tree generator library could not be located."
    case let .generatorUnavailable(path):
      "The node tree generator library is invalid or missing (expected at `\(path)`)."
    case .generatorUnexpectedResult:
      "The node tree generator returned an unexpected result data."
    case let .writingTreeFailed(path):
      "Unable to write generated node tree at `\(path)`."
    }
  }
}

enum GodotNodeTreeError: Error, CustomStringConvertible, Codable {
  case scanningScenesFailed(projectPath: String)
  case readingSceneFailed(scenePath: String)
  case unexpectedNodeParameters(nodeParams: NodeParams)
  case unexpectedSceneResource(instance: String)
  case parentNodeNotFound(sceneName: String)

  var description: String {
    switch self {
    case let .scanningScenesFailed(projectPath):
      "Unable to scan scene files for project at `\(projectPath)`."
    case let .readingSceneFailed(scenePath):
      "Unable to read contens of scene at `\(scenePath)`."
    case let .unexpectedNodeParameters(nodeParams):
      "A node with unexpected set of parameters encountered: \(nodeParams)."
    case let .unexpectedSceneResource(instance):
      "A node pointing to an unknown scene resource encountered with id: \(instance)."
    case let .parentNodeNotFound(sceneName):
      "None of the parsed nodes was identified as the parent node of scene \(sceneName)."
    }
  }
}
