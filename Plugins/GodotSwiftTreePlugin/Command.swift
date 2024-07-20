import PackagePlugin

class GenerateTreeCommand {
    func run(context: PluginContext, config: GodotNodeTreeConfig) throws {
        let projectPath = context.package.directory.string
        let godotProject = try GodotSwiftProject.create(rootPath: projectPath, config: config)
        let treeInfo = try NodeTreeGenerator().generate(project: godotProject)
        Log.nodeTreeGenerated(treeInfo: treeInfo)
    }
}
