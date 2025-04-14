import Darwin
import Foundation

func resolveProjectTree(projectPath: String, libPath: String) -> NodeTree? {
  guard let handle = dlopen(libPath, RTLD_NOW) else { return nil }
  defer { dlclose(handle) }

  guard let sym = dlsym(handle, "resolveProjectTree") else { return nil }
  let resolveProjectTreeBits = unsafeBitCast(sym, to: ResolveProjectTree.self)

  guard let projectPathPtr = strdup(projectPath) else { return nil }
  defer { free(projectPathPtr) }

  let resultPtr = resolveProjectTreeBits(projectPathPtr)
  defer { free(UnsafeMutableRawPointer(mutating: resultPtr)) }

  let resultStr = String(cString: resultPtr)
  return try? JSONDecoder().decode(NodeTree.self, from: Data(resultStr.utf8))
}

private typealias ResolveProjectTree = @convention(c) (UnsafePointer<CChar>) ->
  UnsafeMutablePointer<CChar>
