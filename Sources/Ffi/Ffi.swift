import Darwin
import Foundation

func generateNodeTree(libPath: String, projectPath: String) throws -> NodeTree {
  let resultStr = try callGenerateNodeTree(libPath: libPath, projectPath: projectPath)
  guard let result = Result<NodeTree, GodotNodeTreeError>(json: resultStr) else {
    throw GodotSwiftTreeError.generatorUnexpectedResult
  }
  return try result.unwrap()
}

private func callGenerateNodeTree(libPath: String, projectPath: String)
  throws(GodotSwiftTreeError) -> String
{
  guard let handle = dlopen(libPath, RTLD_NOW) else {
    throw .generatorUnavailable(path: libPath)
  }
  defer { dlclose(handle) }

  guard let sym = dlsym(handle, "generateNodeTree") else {
    throw .generatorUnavailable(path: libPath)
  }
  let cGenerateNodeTree = unsafeBitCast(sym, to: ResolveProjectTree.self)

  let projectPathPtr = strdup(projectPath)!
  defer { free(projectPathPtr) }

  let resultPtr = cGenerateNodeTree(projectPathPtr)
  defer { free(UnsafeMutableRawPointer(mutating: resultPtr)) }

  return String(cString: resultPtr)
}

private typealias ResolveProjectTree = @convention(c) (UnsafePointer<CChar>) ->
  UnsafeMutablePointer<CChar>
