import Foundation

struct GodotProjectReader {
  func readScenes(projectPath: String) throws -> [SceneData] {
    let directory = URL(fileURLWithPath: projectPath).deletingLastPathComponent()

    return try directory.walkTopDown(includeHidden: false)
      .filter { $0.pathExtension == "tscn" }
      .map { file in
        let fileName = file.deletingPathExtension().lastPathComponent
        let name = fileName.split(whereSeparator: ["_", "-"].contains)
          .map(\.firstCapitalized)
          .joined()
        let content = try String(contentsOf: file)
        return SceneData(name: name, content: content)
      }.sorted(by: { $0.name <= $1.name })
  }
}
