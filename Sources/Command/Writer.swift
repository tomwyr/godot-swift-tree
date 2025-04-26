import Foundation

struct NodeTreeWriter {
  func write(content: String, at path: String) throws(GodotSwiftTreeError) {
    let file = URL(fileURLWithPath: path)
    do {
      try content.write(to: file, atomically: true, encoding: .utf8)
    } catch {
      throw .writingTreeFailed(path: path)
    }
  }
}
