import Foundation
import SwiftGodot

@Godot
class ColorAnimator: Node2D {
    @NodeRef(GDTree.Main.ColorRect)
    var colorRect: ColorRect

    let colorFrom = Color.red
    let colorTo = Color.blue

    var colorPeriod = 0.0

    override func _process(delta: Double) {
        colorPeriod = (colorPeriod + delta * 2).truncatingRemainder(dividingBy: 2 * Double.pi)
        let progress = sin(colorPeriod) / 2 + 0.5
        colorRect.color = colorFrom.lerp(to: colorTo, weight: progress)
    }
}
