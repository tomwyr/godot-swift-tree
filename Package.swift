// swift-tools-version: 6.0

import PackageDescription

let package = Package(
  name: "GodotSwiftTree",
  platforms: [.macOS(.v14)],
  products: [
    .executable(name: "GenerateNodeTree", targets: ["GodotSwiftTree"])
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-argument-parser", from: "1.5.0")
  ],
  targets: [
    .executableTarget(
      name: "GodotSwiftTree",
      dependencies: [
        .product(name: "ArgumentParser", package: "swift-argument-parser")
      ],
      resources: [.copy("Resources")]
    ),
    .testTarget(
      name: "GodotSwiftTreeTests",
      dependencies: ["GodotSwiftTree"],
      exclude: ["Resources", "NodeTreeGenerator.dylib"]
    ),
  ]
)
