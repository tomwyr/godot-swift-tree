import Foundation
import XCTest

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
    let project = setUpTestProject(testCase: testCase)
    defer { try? cleanUpTestProject(project: project) }
    _ = try NodeTreeGenerator().generate(project: project)
    try assertGeneratorOutput(project: project)
  }

  private func setUpTestProject(testCase: String) -> GodotSwiftProject {
    let testDir = URL(filePath: #file).deletingLastPathComponent()
    let basePath = testDir.appending(path: "Resources").path()

    return GodotSwiftProject(
      projectPath: "\(basePath)/\(testCase)/scenes",
      outputPath: "\(basePath)/\(testCase)/Actual"
    )
  }

  private func cleanUpTestProject(project: GodotSwiftProject) throws {
    let outputFilePath = URL(filePath: project.outputPath)
    try FileManager.default.removeItem(at: outputFilePath)
  }

  private func assertGeneratorOutput(project: GodotSwiftProject) throws {
    let expectedPath = URL(filePath: project.outputPath)
      .deletingLastPathComponent().appending(path: "Expected").path()
    let actualPath = project.outputPath

    let expected = try String(contentsOfFile: expectedPath, encoding: .utf8)
    let actual = try String(contentsOfFile: actualPath, encoding: .utf8)

    XCTAssertEqual(expected, actual)
  }
}
