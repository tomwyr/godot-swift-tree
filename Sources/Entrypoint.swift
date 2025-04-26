import ArgumentParser
import Foundation

@main
struct GodotSwiftTreeCommand: ParsableCommand {
  @Option()
  var projectPath: String? = nil

  @Option()
  var outputDir: String? = nil

  func run() throws {
    let environment = GodotSwiftTreeEnvironment()
    let config = GodotNodeTreeConfig(projectPath: projectPath, outputDir: outputDir)
    try GenerateTreeCommand(environment: environment, config: config).run()
  }
}

extension GodotSwiftTreeEnvironment {
  fileprivate init() {
    pluginPath = FileManager.default.currentDirectoryPath
    libPath =
      Bundle.module.url(forResource: "libGodotNodeTreeCore", withExtension: "dylib")!.path
  }
}
