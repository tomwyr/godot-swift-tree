enum GeneratorError: Error, CustomStringConvertible {
  case invalidGodotProject

  var description: String {
    switch self {
    case .invalidGodotProject:
      "The project in which GodotNodeTree annotation was used isn't a valid Godot project directory."
    }
  }
}
