import ArgumentParser
import Foundation

@main
struct GodotSwiftTree: ParsableCommand {
  @Option(help: "Relative path to the directory containing the Godot project.")
  var projectPath: String? = nil

  @Flag(
    inversion: .prefixedNo,
    help: "Whether to validate that Godot project exists at the resolved path.",
  )
  var validateProjectPath: Bool = true

  @Option(help: "Relative path to the directory where the node tree code will be generated.")
  var outputDir: String? = nil

  func run() throws(GodotSwiftTreeError) {
    let input = GodotSwiftTreeInput(
      projectPath: projectPath,
      validateProjectPath: validateProjectPath,
      outputDir: outputDir,
    )
    try GenerateTreeCommand(input: input).run()
  }
}

struct GodotSwiftTreeInput {
  let projectPath: String?
  let validateProjectPath: Bool
  let outputDir: String?
}
