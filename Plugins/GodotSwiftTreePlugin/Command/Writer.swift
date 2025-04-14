import Foundation

struct NodeTreeWriter {
  func write(content: String, at path: String) throws {
    let file = URL(fileURLWithPath: path)
    try content.write(to: file, atomically: true, encoding: .utf8)
  }
}
