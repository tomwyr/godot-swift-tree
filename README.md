# Godot Swift Tree

Godot Swift Tree enhances development of Godot games using Swift bindings by generating a statically typed object mapping the Godot project nodes to Swift.

In short, instead of referencing node with a string path and casting:

```swift
getNode(NodePath("/root/Path/To/Some/Nested/Area/Node")) as Area2D
```

the same can be achieved using generated typed fields:

```swift
GDTree.Scene.Path.To.Some.Nested.Area.Node
```

The references are generated automatically based on the project and scenes declarations meaning that any modifications to the node tree structure can be easily tracked in Swift sources. Rebuilding Swift project after node paths change will result in compile-time errors that otherwise could become difficult to debug runtime errors.

For more information about developing Godot games using Swift, head to [SwiftGodot](https://github.com/migueldeicaza/SwiftGodot) repository.

## Setup

### Swift

Configure plugin in the `Package.swift` file:

```swift
// Add plugin dependency
let package = Package(
    dependencies: [
        .package(url: "https://github.com/tomwyr/godot-swift-tree", branch: "master"),
    ]
)

```

### Godot

No additional setup of the Godot project is needed.

## Usage

Create a scene with nodes in Godot Editor and run `generate-node-tree` plugin command:

```
swift package generate-node-tree --allow-writing-to-package-directory
```

The output path for the generated file can be specified by adding `--output-dir <directory-path>`.

![image](https://github.com/tomwyr/godot-kotlin-tree/assets/9600796/5231f627-2db4-48e3-9b31-57eff7949f77)

The command will scan your Godot project files and generate node tree representing the scene:

```swift
class GDTree {
    private init() {}

    static let Main = MainScene("/root")
}

class MainScene: NodeKey<Node> {
    let ColorRect: NodeKey<ColorRect>
    let ColorAnimator: NodeKey<Node2D>
    //...

    init(_ path: String) {
      ColorRect = NodeKey("\(path)/Main/ColorRect", "ColorRect")
      ColorAnimator = NodeKey("\(path)/Main/ColorAnimator", "Node2D")
      //...
    }
}
```

Reference the generated tree from within `Node` classes:

```swift
import SwiftGodot

@Godot
class ColorAnimator: Node2D {
    @NodeRef(GDTree.Main.ColorRect)
    var colorRect: ColorRect

    override func _process(delta: Double) {
        colorRect.color = calcColorForDelta(delta)
    }

    //...
}
```

Run project:

https://github.com/tomwyr/godot-kotlin-tree/assets/9600796/61637bbc-103f-48d0-a2af-696e1931bf87

## Contributing

Every kind of help aiming to improve quality and add new functionalities is welcome. Feel free to:

- Open an issue to request new features, report bugs, ask for help.
- Open a pull request to propose changes, fix bugs, improve documentation.
- Tell others about this project.
