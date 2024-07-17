class NodeTreeRenderer {
    func render(scenes: [Scene]) -> String {
        let header = renderHeader()
        let nodeTree = renderNodeTree(scenes: scenes)
        let sceneNodes = scenes.map(renderScene).joinLines(spacing: 2)
        let types = renderTypes()

        return [header, nodeTree, sceneNodes, types].compactMap { $0 }
            .joinLines(spacing: 2) + "\n"
    }

    private func renderHeader() -> String {
        return "import SwiftGodot"
    }

    private func renderNodeTree(scenes: [Scene]) -> String {
        let rootNodes = scenes.map { """
        static let \($0.name) = \($0.name)Scene("/root")
        """ }.joinLines().indentLine()

        return """
        class GDTree {
            private init() {}

            \(rootNodes)
        }
        """
    }

    private func renderScene(scene: Scene) -> String {
        let nodePath = #"\(path)/\#(scene.root.name)"#

        let renderNodeHeader = { (type: String) in
            "class \(scene.name)Scene : NodeKey<\(type)>"
        }

        switch scene.root {
        case let .parentNode(root):
            let header = renderNodeHeader(root.type)
            let initSuper = #"super.init("\#(nodePath)", "\#(root.type)")"#

            let children = root.children.map { node in renderNode(node: node, parentPath: nodePath) }
            let fields = children.map(\.field).joinLines().indentLine()
            let initializers = children.map(\.initializer).joinLines().indentLine()

            return """
            \(header) {
                \(fields)

                init() {
                    \(initializers)
                    \(initSuper)
                }
            }
            """

        case let .leafNode(root):
            let header = renderNodeHeader(root.type)
            
            return """
            \(header) {
                init() {
                    super.init("\(nodePath)", "\(root.type)")
                }
            }
            """

        case let .nestedScene(root):
            return """
            class \(scene.name)Scene : \(root.scene)Scene {}
            """
        }
    }

    private func renderNode(node: NodeType, parentPath: String) -> (field: String, initializer: String) {
        let nodePath = "\(parentPath)/\(node.name)"
        let symbolName = node.name
            .split(separator: #/\s+/#)
            .enumerated().map { index, s in index == 0 ? String(s) : s.capitalized }
            .joined()

        Log.renderingNode(node: node, nodePath: nodePath)

        return switch node {
        case let .parentNode(node):
            (field: "let \(symbolName): \(symbolName)Tree",
             initializer: #"\#(symbolName) = \#(symbolName)Tree(path)"#)

        case let .leafNode(node):
            (field: "let \(symbolName): NodeKey<\(node)>",
             initializer: #"\#(symbolName) = NodeKey("\#(nodePath)", "\#(node.type)")"#)

        case let .nestedScene(node):
            (field: "let \(symbolName): \(symbolName)Scene",
             initializer: #"\#(symbolName) = \#(symbolName)Scene("\#(nodePath)")"#)
        }
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

private extension Sequence<String> {
    func joinLines(spacing: Int = 1) -> String {
        return joined(separator: String(repeating: "\n", count: spacing))
    }
}

private extension String {
    func indentLine(times: Int = 1) -> String {
        let whiteSpace = String(repeating: "    ", count: times)
        return components(separatedBy: .newlines).joined(separator: "\n" + whiteSpace)
    }
}
