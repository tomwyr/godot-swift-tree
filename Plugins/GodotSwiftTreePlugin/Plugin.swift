import Foundation
import PackagePlugin

@main
struct GodotSwiftTreePlugin: CommandPlugin {
  func performCommand(context: PluginContext, arguments: [String]) throws {
    let config = NodeTreeConfig(arguments: arguments)
    let environment = SwiftTreeEnvironment(context: context)
    try GenerateTreeCommand(environment: environment, config: config).run()
  }
}

extension NodeTreeConfig {
  fileprivate init(arguments: [String]) {
    projectPath = arguments.findArg(named: "--project-path")
    outputDir = arguments.findArg(named: "--output-dir")
  }
}

extension SwiftTreeEnvironment {
  fileprivate init(context: PluginContext) {
    pluginPath = context.package.directory.string
    libPath =
      URL(fileURLWithPath: #file)
      .deletingLastPathComponent()
      .appending(components: "libs", "libGodotNodeTree.dylib")
      .relativePath
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
