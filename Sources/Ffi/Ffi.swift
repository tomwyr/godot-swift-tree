import Foundation

func generateNodeTree(libPath: String, projectPath: String, validateProjectPath: Bool)
  throws(GodotSwiftTreeError) -> NodeTree
{
  let resultStr = try callGenerateNodeTree(
    libPath: libPath,
    projectPath: projectPath,
    validateProjectPath: validateProjectPath,
  )
  guard let result = Result<NodeTree, GodotNodeTreeError>(json: resultStr) else {
    throw .generatorUnexpectedResult
  }
  do {
    return try result.unwrap()
  } catch {
    throw .generatorError(cause: error)
  }
}

private func callGenerateNodeTree(libPath: String, projectPath: String, validateProjectPath: Bool)
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

  let resultPtr = cGenerateNodeTree(projectPathPtr, validateProjectPath)
  defer { free(UnsafeMutableRawPointer(mutating: resultPtr)) }

  return String(cString: resultPtr)
}

private typealias ResolveProjectTree = @convention(c) (UnsafePointer<CChar>, Bool) ->
  UnsafeMutablePointer<CChar>
