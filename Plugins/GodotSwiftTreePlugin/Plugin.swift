import PackagePlugin

@main
struct GodotSwiftTreePlugin: CommandPlugin {
  func performCommand(context: PluginContext, arguments: [String]) throws {
    let config = GodotNodeTreeConfig(arguments: arguments)
    try GenerateTreeCommand().run(context: context, config: config)
  }
}

extension [String] {
  fileprivate func findArg(named arg: String) -> String? {
    if let index = firstIndex(of: arg), index < count - 1 {
      return self[index + 1]
    }
    return nil
  }
}

extension GodotNodeTreeConfig {
  init(arguments: [String]) {
    projectPath = arguments.findArg(named: "--project-path")
    outputDir = arguments.findArg(named: "--output-dir")
  }
}
