import Darwin
import Foundation

func generateNodeTree(libPath: String, projectPath: String) throws -> NodeTree {
  guard let handle = dlopen(libPath, RTLD_NOW) else {
    throw GenerateNodeTreeError.unknown
  }
  defer { dlclose(handle) }

  guard let sym = dlsym(handle, "generateNodeTree") else {
    throw GenerateNodeTreeError.unknown
  }
  let cGenerateNodeTree = unsafeBitCast(sym, to: ResolveProjectTree.self)

  guard let projectPathPtr = strdup(projectPath) else {
    throw GenerateNodeTreeError.unknown
  }
  defer { free(projectPathPtr) }

  let resultPtr = cGenerateNodeTree(projectPathPtr)
  defer { free(UnsafeMutableRawPointer(mutating: resultPtr)) }

  let resultStr = String(cString: resultPtr)
  guard let result = Result<NodeTree, GenerateNodeTreeError>(json: resultStr) else {
    throw GenerateNodeTreeError.unknown
  }
  return try result.unwrap()
}

private typealias ResolveProjectTree = @convention(c) (UnsafePointer<CChar>) ->
  UnsafeMutablePointer<CChar>

enum GenerateNodeTreeError: Error, Codable {
  // TODO Add proper error handling
  case unknown
}
