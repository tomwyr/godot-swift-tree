import PackagePlugin
import Foundation

@main
struct GodotSwiftTreePlugin: CommandPlugin {
    func performCommand(context: PluginContext, arguments: [String]) throws {
        try writeToFile(context, content: "Test", fileName: "test")
    }
    
    private func writeToFile(_ context: PluginContext, content: String, fileName: String) throws {
        let directory = URL(fileURLWithPath: context.package.directory.string)
        let file = directory.appending(path: fileName)
        try content.write(to: file, atomically: true, encoding: .utf8)
    }
}
