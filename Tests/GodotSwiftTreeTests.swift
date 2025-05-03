import Foundation
import XCTest

@testable import GodotSwiftTree

final class GodotSwiftTreeTests: XCTestCase {
  func testSingleSceneWithNestedNodes() throws {
    try test(testCase: "physics-test")
  }

  func testSpacesInNodeNames() throws {
    try test(testCase: "simple")
  }

  func testMultipleIndependentScenes() throws {
    try test(testCase: "scene-changer")
  }

  func testSceneWithNestedScenes() throws {
    try test(testCase: "waypoints")
  }

  func testMultipleScenes() throws {
    try test(testCase: "dodge-the-creeps")
  }

  private func test(testCase: String) throws {
    let generateTreeCommand = try setUpTestCommand(testCase: testCase)
    defer { try? cleanUpTestProject(generateTreeCommand) }
    try generateTreeCommand.run()
    try assertGeneratedOutput(generateTreeCommand)
  }

  private func setUpTestCommand(testCase: String) throws -> GenerateTreeCommand {
    let libPath = URL(filePath: "Tests").appending(path: "libGodotNodeTreeCore.dylib").path()
    let testCaseDir = URL(filePath: "Tests").appending(components: "Resources", testCase)
    let projectPath = testCaseDir.appending(path: "scenes").path()
    let outputPath = testCaseDir.appending(path: "Actual").path()

    return GenerateTreeCommand(
      libPath: libPath,
      projectPath: projectPath,
      outputPath: outputPath
    )
  }

  private func cleanUpTestProject(_ command: GenerateTreeCommand) throws {
    let outputFilePath = URL(filePath: command.outputPath)
    try FileManager.default.removeItem(at: outputFilePath)
  }

  private func assertGeneratedOutput(_ command: GenerateTreeCommand) throws {
    let expectedPath = URL(filePath: command.outputPath)
      .deletingLastPathComponent().appending(path: "Expected").path()
    let actualPath = command.outputPath

    let expected = try String(contentsOfFile: expectedPath, encoding: .utf8)
    let actual = try String(contentsOfFile: actualPath, encoding: .utf8)

    XCTAssertEqual(expected, actual)
  }
}
