import Foundation
import SwiftUI

struct Viewport: Codable, Equatable {
    var x: CGFloat
    var y: CGFloat
    var scale: CGFloat

    init(x: CGFloat = 0, y: CGFloat = 0, scale: CGFloat = 1) {
        self.x = x
        self.y = y
        self.scale = scale
    }

    var offset: CGPoint {
        get { CGPoint(x: x, y: y) }
        set { x = newValue.x; y = newValue.y }
    }

    static let `default` = Viewport()

    static let minScale: CGFloat = 0.1
    static let maxScale: CGFloat = 5.0

    func clampedScale(_ newScale: CGFloat) -> CGFloat {
        min(max(newScale, Self.minScale), Self.maxScale)
    }
}
