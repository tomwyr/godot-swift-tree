class NodeTreeRenderer {
  func render(scenes: [Scene]) -> String {
    let header = renderHeader()
    let nodeTree = renderNodeTree(scenes: scenes)
    let sceneNodes = scenes.map(renderScene).joinLines(spacing: 2).trimEmptyLines()
    let types = renderTypes()

    return [header, nodeTree, sceneNodes, types]
      .joinLines(spacing: 2) + "\n"
  }

  private func renderHeader() -> String {
    return "import SwiftGodot"
  }

  private func renderNodeTree(scenes: [Scene]) -> String {
    let rootNodes = scenes.map {
      """
      static let \($0.name) = \($0.name)Scene("/root")
      """
    }.joinLines().indentLine()

    return """
      class GDTree {
          private init() {}

          \(rootNodes)
      }
      """
  }

  private func renderScene(scene: Scene) -> String {
    let nodePath = #"\(path)/\#(scene.root.name)"#

    return switch scene.root {
    case let .parentNode(root):
      renderParentNode(
        node: root,
        nodePath: nodePath,
        className: "\(scene.name)Scene"
      )

    case let .leafNode(root):
      """
      class \(scene.name)Scene : NodeKey<\(root.type)> {
          init(_ path: String) {
              super.init("\(nodePath)", "\(root.type)")
          }
      }
      """

    case let .nestedScene(root):
      """
      class \(scene.name)Scene : \(root.scene)Scene {}
      """
    }
  }

  private func renderNode(node: NodeType, parentPath: String) -> RenderNodeResult {
    let nodePath = "\(parentPath)/\(node.name)"
    let symbolName = node.name
      .split(separator: #/\s+/#)
      .enumerated().map { index, s in index == 0 ? String(s) : s.firstCapitalized }
      .joined()

    return switch node {
    case let .parentNode(node):
      (
        field: "let \(symbolName): \(symbolName)Tree",
        initializer: #"\#(symbolName) = \#(symbolName)Tree("\#(parentPath)")"#,
        nestedClass: renderParentNode(
          node: node,
          nodePath: #"\(path)/\#(node.name)"#,
          className: "\(symbolName)Tree"
        )
      )

    case let .leafNode(node):
      (
        field: "let \(symbolName): NodeKey<\(node.type)>",
        initializer: #"\#(symbolName) = NodeKey("\#(nodePath)", "\#(node.type)")"#,
        nestedClass: nil
      )

    case .nestedScene(_):
      (
        field: "let \(symbolName): \(symbolName)Scene",
        initializer: #"\#(symbolName) = \#(symbolName)Scene("\#(parentPath)")"#,
        nestedClass: nil
      )
    }
  }

  private func renderParentNode(node: ParentNode, nodePath: String, className: String) -> String {
    let header = "class \(className): NodeKey<\(node.type)>"
    let initSuper = #"super.init("\#(nodePath)", "\#(node.type)")"#

    let children = node.children.map { child in renderNode(node: child, parentPath: nodePath) }
    let fields = children.map(\.field).joinLines().indentLine()
    let initializers = children.map(\.initializer).joinLines().indentLine(times: 2)
    let nestedClasses = children.compactMap(\.nestedClass).joinLines(spacing: 2).indentLine()

    var body = """
          \(fields)

          init(_ path: String) {
              \(initializers)
              \(initSuper)
          }
      """

    if !nestedClasses.isEmpty {
      body += """


            \(nestedClasses)
        """
    }

    return """
      \(header) {
      \(body)
      }
      """
  }

  private func renderTypes() -> String {
    return """
      class NodeKey<T: Node> {
          private let path: String
          private let type: String

          init(_ path: String, _ type: String) {
              self.path = path
              self.type = type
          }

          func getValue(thisRef: Node) throws -> T {
              guard let node = thisRef.getNode(path: NodePath(from: path)) else {
                  throw NodeTreeError.nodeNotFound(expectedPath: path)
              }
              guard let node = node as? T else {
                  throw NodeTreeError.nodeInvalidType(expectedType: type)
              }
              return node
          }
      }

      @propertyWrapper class NodeRef<T: Node> {
          let nodeRef: NodeKey<T>

          init(_ nodeRef: NodeKey<T>) {
              self.nodeRef = nodeRef
          }

          static subscript<E: Node>(
              _enclosingInstance instance: E,
              wrapped _: ReferenceWritableKeyPath<E, T>,
              storage storageKeyPath: ReferenceWritableKeyPath<E, NodeRef<T>>
          ) -> T {
              return instance[keyPath: storageKeyPath].wrappedValue(node: instance)
          }

          func wrappedValue(node: Node) -> T {
              do {
                  return try nodeRef.getValue(thisRef: node)
              } catch let error as NodeTreeError {
                  fatalError(error.message)
              } catch {
                  fatalError("Unexpected error: \\(error)")
              }
          }

          @available(*, unavailable, message: "NodeRef's value cannot be accessed without a reference to another node object. Use wrappedValue(:node), or declare the referenced node with @NodeRef property wrapper instead.")
          var wrappedValue: T {
              get { fatalError() }
              set { fatalError() }
          }
      }

      enum NodeTreeError: Error {
          case nodeNotFound(expectedPath: String)
          case nodeInvalidType(expectedType: String?)

          var message: String {
              return switch self {
              case let .nodeNotFound(expectedPath):
                  "Node not found under given path \\(expectedPath)"
              case let .nodeInvalidType(expectedType):
                  "Node is not an instance of \\(expectedType)"
              }
          }
      }
      """
  }
}

extension Sequence<String> {
  fileprivate func joinLines(spacing: Int = 1) -> String {
    return joined(separator: String(repeating: "\n", count: spacing))
  }
}

extension String {
  fileprivate func indentLine(times: Int = 1) -> String {
    let whiteSpace = String(repeating: "    ", count: times)
    return components(separatedBy: .newlines).joined(separator: "\n" + whiteSpace)
  }

  fileprivate func trimEmptyLines() -> String {
    return split(separator: "\n", omittingEmptySubsequences: false)
      .map {
        $0.replacingOccurrences(of: #"^.*\s+$"#, with: "", options: .regularExpression)
      }.joined(separator: "\n")
  }
}

private typealias RenderNodeResult = (field: String, initializer: String, nestedClass: String?)
