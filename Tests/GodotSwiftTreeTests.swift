import Foundation
import Testing

@testable import GodotSwiftTree

@Suite
struct GodotSwiftTreeTests {
  @Test func testSingleSceneWithNestedNodes() throws {
    try test(testCase: "physics-test")
  }

  @Test func testSpacesInNodeNames() throws {
    try test(testCase: "simple")
  }

  @Test func testMultipleIndependentScenes() throws {
    try test(testCase: "scene-changer")
  }

  @Test func testSceneWithNestedScenes() throws {
    try test(testCase: "waypoints")
  }

  @Test func testMultipleScenes() throws {
    try test(testCase: "dodge-the-creeps")
  }

  private func test(testCase: String) throws {
    let generateTreeCommand = try setUpTestCommand(testCase: testCase)
    defer { try? cleanUpTestProject(generateTreeCommand) }
    try generateTreeCommand.run()
    try assertGeneratedOutput(generateTreeCommand)
  }

  private func setUpTestCommand(testCase: String) throws -> GenerateTreeCommand {
    let resourcesDir = URL(filePath: "Tests").appending(components: "Resources")
    let libPath = resourcesDir.appending(path: "libGodotNodeTreeCore.dylib").path()
    let projectPath = resourcesDir.appending(components: testCase, "scenes").path()
    let outputPath = resourcesDir.appending(components: testCase, "Actual").path()

    return GenerateTreeCommand(
      libPath: libPath,
      projectPath: projectPath,
      validateProjectPath: false,
      outputPath: outputPath
    )
  }

  private func cleanUpTestProject(_ command: GenerateTreeCommand) throws {
    let fm = FileManager.default
    let outputFilePath = URL(filePath: command.outputPath)
    if fm.fileExists(atPath: outputFilePath.path()) {
      try fm.removeItem(at: outputFilePath)
    }
  }

  private func assertGeneratedOutput(_ command: GenerateTreeCommand) throws {
    let expectedPath = URL(filePath: command.outputPath)
      .deletingLastPathComponent().appending(path: "Expected").path()
    let actualPath = command.outputPath

    let expected = try String(contentsOfFile: expectedPath, encoding: .utf8)
    let actual = try String(contentsOfFile: actualPath, encoding: .utf8)

    #expect(expected == actual)
  }
}
