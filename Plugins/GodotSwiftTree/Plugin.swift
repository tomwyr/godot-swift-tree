import PackagePlugin

@main
struct GodotSwiftTreePlugin: CommandPlugin {
    func performCommand(context: PluginContext, arguments: [String]) throws {
        initLogger(arguments)
        try generateTree(context, arguments)
    }
    
    private func initLogger(_ arguments: [String]) {
        if arguments.contains("--verbose") {
            Log.logger = Logger.stdOut()
        }
    }
    
    private func generateTree(_ context: PluginContext, _ arguments: [String]) throws {
        let config = GodotNodeTreeConfig(arguments: arguments)
        try GenerateTreeCommand().run(context: context, config: config)
    }
}

struct GodotNodeTreeConfig {
    let projectPath: String?
    
    init(arguments: [String]) {
        self.projectPath = arguments.findArg(named: "project-path")
    }
}

private extension [String] {
    func findArg(named arg: String) -> String? {
        if let index = firstIndex(of: arg), index < count - 1 {
            return self[index]
        }
        return nil
    }
}
