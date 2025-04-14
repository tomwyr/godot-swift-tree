import Foundation

@_cdecl("resolveProjectTree")
public func resolveProjectTree(projectPath: UnsafePointer<CChar>) -> UnsafeMutablePointer<CChar> {
  do {
    let tree = try NodeTreeGenerator().generate(projectPath: String(cString: projectPath))
    let data = try JSONEncoder().encode(tree)
    let string = String(data: data, encoding: .utf8)
    return strdup(string)
  } catch {
    return strdup("err")
  }
}
