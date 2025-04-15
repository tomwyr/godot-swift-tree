import Foundation

@_cdecl("generateNodeTree")
public func generateNodeTree(projectPath: UnsafePointer<CChar>) -> UnsafeMutablePointer<CChar> {
  let projectPath = String(cString: projectPath)
  let result = Result { () throws(GenerateNodeTreeError) in
    try NodeTreeGenerator().generate(projectPath: projectPath)
  }
  return strdup(result.jsonEncoded())
}
