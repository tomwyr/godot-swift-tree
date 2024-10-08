import SwiftGodot

class GDTree {
    private init() {}

    static let HUD = HUDScene("/root")
    static let Main = MainScene("/root")
    static let Mob = MobScene("/root")
    static let Player = PlayerScene("/root")
}

class HUDScene: NodeKey<CanvasLayer> {
    let ScoreLabel: NodeKey<Label>
    let MessageLabel: NodeKey<Label>
    let StartButton: NodeKey<Button>
    let MessageTimer: NodeKey<Timer>

    init(_ path: String) {
        ScoreLabel = NodeKey("\(path)/HUD/ScoreLabel", "Label")
        MessageLabel = NodeKey("\(path)/HUD/MessageLabel", "Label")
        StartButton = NodeKey("\(path)/HUD/StartButton", "Button")
        MessageTimer = NodeKey("\(path)/HUD/MessageTimer", "Timer")
        super.init("\(path)/HUD", "CanvasLayer")
    }
}

class MainScene: NodeKey<Node> {
    let ColorRect: NodeKey<ColorRect>
    let Player: PlayerScene
    let MobTimer: NodeKey<Timer>
    let ScoreTimer: NodeKey<Timer>
    let StartTimer: NodeKey<Timer>
    let StartPosition: NodeKey<Marker2D>
    let MobPath: MobPathTree
    let HUD: HUDScene
    let Music: NodeKey<AudioStreamPlayer>
    let DeathSound: NodeKey<AudioStreamPlayer>

    init(_ path: String) {
        ColorRect = NodeKey("\(path)/Main/ColorRect", "ColorRect")
        Player = PlayerScene("\(path)/Main")
        MobTimer = NodeKey("\(path)/Main/MobTimer", "Timer")
        ScoreTimer = NodeKey("\(path)/Main/ScoreTimer", "Timer")
        StartTimer = NodeKey("\(path)/Main/StartTimer", "Timer")
        StartPosition = NodeKey("\(path)/Main/StartPosition", "Marker2D")
        MobPath = MobPathTree("\(path)/Main")
        HUD = HUDScene("\(path)/Main")
        Music = NodeKey("\(path)/Main/Music", "AudioStreamPlayer")
        DeathSound = NodeKey("\(path)/Main/DeathSound", "AudioStreamPlayer")
        super.init("\(path)/Main", "Node")
    }

    class MobPathTree: NodeKey<Path2D> {
        let MobSpawnLocation: NodeKey<PathFollow2D>

        init(_ path: String) {
            MobSpawnLocation = NodeKey("\(path)/MobPath/MobSpawnLocation", "PathFollow2D")
            super.init("\(path)/MobPath", "Path2D")
        }
    }
}

class MobScene: NodeKey<RigidBody2D> {
    let AnimatedSprite2D: NodeKey<AnimatedSprite2D>
    let CollisionShape2D: NodeKey<CollisionShape2D>
    let VisibleOnScreenNotifier2D: NodeKey<VisibleOnScreenNotifier2D>

    init(_ path: String) {
        AnimatedSprite2D = NodeKey("\(path)/Mob/AnimatedSprite2D", "AnimatedSprite2D")
        CollisionShape2D = NodeKey("\(path)/Mob/CollisionShape2D", "CollisionShape2D")
        VisibleOnScreenNotifier2D = NodeKey(
            "\(path)/Mob/VisibleOnScreenNotifier2D", "VisibleOnScreenNotifier2D")
        super.init("\(path)/Mob", "RigidDynamicBody2D")
    }
}

class PlayerScene: NodeKey<Area2D> {
    let AnimatedSprite2D: NodeKey<AnimatedSprite2D>
    let CollisionShape2D: NodeKey<CollisionShape2D>
    let Trail: NodeKey<GPUParticles2D>

    init(_ path: String) {
        AnimatedSprite2D = NodeKey("\(path)/Player/AnimatedSprite2D", "AnimatedSprite2D")
        CollisionShape2D = NodeKey("\(path)/Player/CollisionShape2D", "CollisionShape2D")
        Trail = NodeKey("\(path)/Player/Trail", "GPUParticles2D")
        super.init("\(path)/Player", "Area2D")
    }
}

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

    static subscript<EnclosingSelf: Node>(
        _enclosingInstance instance: EnclosingSelf,
        wrapped wrappedKeyPath: ReferenceWritableKeyPath<EnclosingSelf, T>,
        storage storageKeyPath: ReferenceWritableKeyPath<EnclosingSelf, NodeRef<T>>
    ) -> T {
        get {
            instance[keyPath: storageKeyPath].wrappedValue(node: instance)
        }
        set {
            fatalError(
                "Node reference cannot point to a different node after it's been initialized."
            )
        }
    }

    func wrappedValue(node: Node) -> T {
        do {
            return try nodeRef.getValue(thisRef: node)
        } catch let error as NodeTreeError {
            fatalError(error.message)
        } catch {
            fatalError("Unexpected error: \(error)")
        }
    }

    @available(
        *, unavailable,
        message:
            "NodeRef's value cannot be accessed without a reference to another node object. Use wrappedValue(:node), or declare the referenced node with @NodeRef property wrapper instead."
    )
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
            "Node not found under given path \(expectedPath)"
        case let .nodeInvalidType(expectedType):
            "Node is not an instance of \(expectedType)"
        }
    }
}
