import Foundation

extension URL {
  func walkTopDown(includeHidden: Bool = true) throws -> any Sequence<URL> {
    let fm = FileManager.default

    func isDirectory(_ file: URL) -> Bool? {
      var isDirectory: ObjCBool = false
      if fm.fileExists(atPath: file.path(), isDirectory: &isDirectory) {
        return isDirectory.boolValue
      }
      return nil
    }

    var directories = [self]
    var files = [URL]()

    while !directories.isEmpty {
      let directory = directories.removeFirst()
      guard includeHidden || !directory.hidden else { continue }

      let dirFiles = try fm.contentsOfDirectory(atPath: directory.path()).map { item in
        directory.appending(path: item)
      }

      for file in dirFiles {
        guard let directory = isDirectory(file) else { continue }
        guard includeHidden || !file.hidden else { continue }
        directory ? directories.append(file) : files.append(file)
      }
    }

    return files
  }

  var hidden: Bool {
    lastPathComponent.starts(with: ".")
  }
}

extension String {
  var firstCapitalized: String {
    if let first {
      first.uppercased() + dropFirst()
    } else {
      ""
    }
  }
}

extension Substring {
  var firstCapitalized: String {
    if let first {
      first.uppercased() + dropFirst()
    } else {
      ""
    }
  }
}
