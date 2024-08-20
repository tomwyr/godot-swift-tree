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
    let project = setUpTestProject(testCase: "simple")
    _ = try NodeTreeGenerator().generate(project: project)
  }

  private func setUpTestProject(testCase: String) -> GodotSwiftProject {
    let testDir = URL(filePath: #file).deletingLastPathComponent()
    let basePath = testDir.appending(path: "Resources").path()

    return GodotSwiftProject(
      projectPath: "\(basePath)/\(testCase)/scenes",
      outputPath: "\(basePath)/\(testCase)/Actual"
    )
  }
}
