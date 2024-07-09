class SceneData {
    let name: String
    let content: String

    init(name: String, content: String) {
        self.name = name
        self.content = content
    }
}

class GodotSwiftProject {
    private let projectPath: String
    private let outputPath: String

    init(projectPath: String, outputPath: String) {
        self.projectPath = projectPath
        self.outputPath = outputPath
    }

    func readScenes() -> [SceneData] {
        return []
    }

    func writeNodeTree(content: String) {
        
    }
}
