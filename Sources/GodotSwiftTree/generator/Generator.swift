public class NodeTreeGenerator {
    private let parser: SceneNodesParser
    private let renderer: NodeTreeRenderer

    init(
        parser: SceneNodesParser = SceneNodesParser(),
        renderer: NodeTreeRenderer = NodeTreeRenderer()
    ) {
        self.parser = parser
        self.renderer = renderer
    }

    func generate(project: GodotSwiftProject) throws -> NodeTreeInfo {
        Log.readingScenes()
        let scenesData = try project.readScenes()
        Log.scenesFound(scenes: scenesData)

        let scenes = try scenesData.map { data in
            Log.parsingScene(scene: data)
            let root = try parser.parse(sceneData: data)
            return Scene(name: data.name, root: root)
        }

        Log.renderingNodeTree()
        let content = renderer.render(scenes: scenes)

        Log.savingResult()
        try project.writeNodeTree(content: content)
        Log.resultSaved()

        return NodeTreeInfo(scenes: scenes)
    }
}
