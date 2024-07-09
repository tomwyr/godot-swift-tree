protocol Logger {
    func debug(_ message: String)
    func info(_ message: String)
    func warn(_ message: String)
}

class Log {
    static var logger: any Logger = NoopLogger()

    private init() {}

    private static func debug(_ message: String) {
        logger.debug(message)
    }

    private static func info(_ message: String) {
        logger.info(message)
    }

    private static func warn(_ message: String) {
        logger.warn(message)
    }
}

// ProcessorLog
extension Log {
    static func kotlinProjectPath(rootPath: String) {
        info("Kotlin project found under \(rootPath)")
    }

    static func kotlinOutputPath(filePath: String) {
        info("Generated code will be saved at \(filePath)")
    }

    static func godotCustomProjectPath(projectRelativePath: String) {
        info("Custom path set as the Godot project relative path \(projectRelativePath)")
    }

    static func godotProjectPath(projectPath: String) {
        info("Godot project found under \(projectPath)")
    }

    static func targetPackage(targetPackage: String) {
        info("Package for which code will be generated identified as \(targetPackage)")
    }

    static func nodeTreeGenerated(treeInfo: NodeTreeInfo) {
        info("Node tree generated successfully!")
        info("Scenes number: \(treeInfo.scenes)")
        info("Nodes total: \(treeInfo.nodes)")
        info("Tree depth: \(treeInfo.depth)")
    }
}

// ParserLog
extension Log {
    static func parsingScenePaths() {
        info("Parsing scene paths by id from scene file")
    }

    static func parsingSceneNodes() {
        info("Parsing scene nodes from scene file")
    }

    static func skippingNode(params: [String: String]) {
        info("Skipping node missing at least one of the required keys")
        debug("Received params were \(params)")
    }

    static func skippingSceneResource(params: [String: String]) {
        info("Skipping scene resource missing at least one of the required keys")
        debug("Received params were \(params)")
    }

    static func duplicatedSceneResources(duplicates: [String: [String]]) {
        warn("Found duplicated scenes for the following resource ids \(duplicates)")
        warn("Only the last resource id for each scene will be retained")
    }

    static func creatingRootNode() {
        info("Creating node tree structure for the extracted nodes")
    }

    static func splittingEntries(entryType: String) {
        info("Splitting file to entries of type \(entryType)")
    }

    static func parsingEntryParams(entry: String) {
        info("Parsing params from entry \(entry)")
    }

    static func parsingSceneName(scenePath: String) {
        info("Parsing scene name for path \(scenePath)")
    }
}

// RendererLog
extension Log {
    static func renderingNode(node: Node, nodePath: String) {
        switch node {
        case let node as ParentNode:
            debug("Rendering \(nodePath) parent node of type \(node.type)")
        case let node as LeafNode:
            debug("Rendering \(nodePath) left node of type \(node.type)")
        case let node as NestedScene:
            debug("Rendering \(nodePath) nested scene \(node.scene)")
        default:
            // TODO: Explore using enum to represent node hierarchy.
            break
        }
    }
}

// GeneratorLog
extension Log {
    static func readingScenes() {
        info("Reading scenes from the Godot project")
    }

    static func scenesFound(scenes: [SceneData]) {
        info("\(scenes.count) scene files found")
    }

    static func parsingScene(scene: SceneData) {
        info("Parsing scene \(scene.name)")
    }

    static func renderingNodeTree() {
        info("Rendering node tree for the found scene(s)")
    }

    static func savingResult() {
        info("Writing generated code to the output file")
    }

    static func resultSaved() {
        info("Output file saved")
    }
}

private class NoopLogger: Logger {
    func debug(_: String) {}
    func info(_: String) {}
    func warn(_: String) {}
}
