// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GodotSwiftTree",
    platforms: [
        .macOS(.v13),
    ],
    products: [
        .plugin(
            name: "GodotSwiftTreePlugin",
            targets: ["GodotSwiftTreePlugin"]
        )
    ],
    targets: [
        .plugin(
            name: "GodotSwiftTreePlugin",
            capability: .command(
                intent: .custom(
                    verb: "generate",
                    description: "Generates statically typed node tree representation of Godot project"
                ),
                permissions: [
                    .writeToPackageDirectory(
                        reason: "Godot Swift Tree writes generated source code to make it accessible from the project"
                    ),
                ]
            )
        ),
        .testTarget(
            name: "GodotSwiftTreeTests"
        ),
    ]
)
