import ArgumentParser
import Foundation

@main
struct GodotSwiftTreeCommand: ParsableCommand {
  @Option()
  var projectPath: String? = nil

  @Option()
  var outputDir: String? = nil

  func run() throws {
    try GenerateTreeCommand(
      libPath: try getLibPath(),
      projectPath: try getProjectPath(),
      outputPath: getOutputPath()
    ).run()
  }

  private var pluginPath: String {
    FileManager.default.currentDirectoryPath
  }

  private func getLibPath() throws(GodotSwiftTreeError)
    -> String
  {
    let (resource, type) = ("libGodotNodeTreeCore", "dylib")
    guard let libPath = Bundle.module.path(forResource: resource, ofType: type) else {
      throw .invalidLibResource
    }
    return libPath
  }

  private func getProjectPath() throws(GodotSwiftTreeError)
    -> String
  {
    var url = URL(filePath: pluginPath)
    if let projectPath = projectPath {
      url = url.appending(path: projectPath)
    }
    url = url.appending(path: "project.godot")
    let path = url.path()

    let fm = FileManager.default
    guard fm.fileExists(atPath: path) else {
      throw .invalidGodotProject
    }

    return path
  }

  private func getOutputPath() -> String {
    var url = URL(filePath: pluginPath)
    if let outputDir = outputDir {
      url.append(path: outputDir)
    }
    url.append(path: "GodotNodeTree.swift")
    return url.path()
  }
}
