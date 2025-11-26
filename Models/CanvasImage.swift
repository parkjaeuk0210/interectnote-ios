import Foundation
import SwiftUI

#if os(iOS)
import UIKit
typealias PlatformImage = UIImage
#elseif os(macOS)
import AppKit
typealias PlatformImage = NSImage
#endif

struct CanvasImage: Identifiable, Codable, Equatable {
    let id: UUID
    var x: CGFloat
    var y: CGFloat
    var width: CGFloat
    var height: CGFloat
    var imageData: Data
    var zIndex: Int
    var createdAt: Date

    init(
        id: UUID = UUID(),
        x: CGFloat,
        y: CGFloat,
        width: CGFloat,
        height: CGFloat,
        imageData: Data,
        zIndex: Int = 0,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.x = x
        self.y = y
        self.width = width
        self.height = height
        self.imageData = imageData
        self.zIndex = zIndex
        self.createdAt = createdAt
    }

    var position: CGPoint {
        get { CGPoint(x: x, y: y) }
        set { x = newValue.x; y = newValue.y }
    }

    var size: CGSize {
        get { CGSize(width: width, height: height) }
        set { width = newValue.width; height = newValue.height }
    }

    var image: Image? {
        #if os(iOS)
        guard let uiImage = UIImage(data: imageData) else { return nil }
        return Image(uiImage: uiImage)
        #elseif os(macOS)
        guard let nsImage = NSImage(data: imageData) else { return nil }
        return Image(nsImage: nsImage)
        #endif
    }
}
