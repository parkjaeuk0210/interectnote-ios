import Foundation
import SwiftUI

enum NoteColor: String, Codable, CaseIterable {
    case yellow
    case pink
    case blue
    case green
    case purple
    case orange

    var color: Color {
        switch self {
        case .yellow: return Color(red: 254/255, green: 243/255, blue: 199/255)
        case .pink: return Color(red: 252/255, green: 231/255, blue: 243/255)
        case .blue: return Color(red: 224/255, green: 242/255, blue: 254/255)
        case .green: return Color(red: 236/255, green: 253/255, blue: 245/255)
        case .purple: return Color(red: 243/255, green: 232/255, blue: 255/255)
        case .orange: return Color(red: 255/255, green: 237/255, blue: 213/255)
        }
    }

    var gradient: LinearGradient {
        switch self {
        case .yellow:
            return LinearGradient(
                colors: [
                    Color(red: 254/255, green: 243/255, blue: 199/255).opacity(0.95),
                    Color(red: 253/255, green: 230/255, blue: 138/255).opacity(0.88),
                    Color(red: 252/255, green: 211/255, blue: 77/255).opacity(0.82)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .pink:
            return LinearGradient(
                colors: [
                    Color(red: 252/255, green: 231/255, blue: 243/255).opacity(0.95),
                    Color(red: 251/255, green: 207/255, blue: 232/255).opacity(0.88),
                    Color(red: 249/255, green: 168/255, blue: 212/255).opacity(0.82)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .blue:
            return LinearGradient(
                colors: [
                    Color(red: 224/255, green: 242/255, blue: 254/255).opacity(0.95),
                    Color(red: 186/255, green: 230/255, blue: 253/255).opacity(0.88),
                    Color(red: 147/255, green: 197/255, blue: 253/255).opacity(0.82)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .green:
            return LinearGradient(
                colors: [
                    Color(red: 236/255, green: 253/255, blue: 245/255).opacity(0.95),
                    Color(red: 209/255, green: 250/255, blue: 229/255).opacity(0.88),
                    Color(red: 134/255, green: 239/255, blue: 172/255).opacity(0.82)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .purple:
            return LinearGradient(
                colors: [
                    Color(red: 243/255, green: 232/255, blue: 255/255).opacity(0.95),
                    Color(red: 233/255, green: 213/255, blue: 255/255).opacity(0.88),
                    Color(red: 196/255, green: 167/255, blue: 231/255).opacity(0.82)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .orange:
            return LinearGradient(
                colors: [
                    Color(red: 255/255, green: 237/255, blue: 213/255).opacity(0.95),
                    Color(red: 254/255, green: 215/255, blue: 170/255).opacity(0.88),
                    Color(red: 251/255, green: 191/255, blue: 36/255).opacity(0.82)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    var borderColor: Color {
        switch self {
        case .yellow: return Color(red: 251/255, green: 191/255, blue: 36/255).opacity(0.3)
        case .pink: return Color(red: 236/255, green: 72/255, blue: 153/255).opacity(0.3)
        case .blue: return Color(red: 59/255, green: 130/255, blue: 246/255).opacity(0.3)
        case .green: return Color(red: 34/255, green: 197/255, blue: 94/255).opacity(0.3)
        case .purple: return Color(red: 147/255, green: 51/255, blue: 234/255).opacity(0.3)
        case .orange: return Color(red: 245/255, green: 158/255, blue: 11/255).opacity(0.3)
        }
    }

    var shadowColor: Color {
        switch self {
        case .yellow: return Color(red: 251/255, green: 191/255, blue: 36/255)
        case .pink: return Color(red: 236/255, green: 72/255, blue: 153/255)
        case .blue: return Color(red: 59/255, green: 130/255, blue: 246/255)
        case .green: return Color(red: 34/255, green: 197/255, blue: 94/255)
        case .purple: return Color(red: 147/255, green: 51/255, blue: 234/255)
        case .orange: return Color(red: 245/255, green: 158/255, blue: 11/255)
        }
    }

    static func random() -> NoteColor {
        allCases.randomElement() ?? .yellow
    }
}

struct Note: Identifiable, Codable, Equatable {
    let id: UUID
    var x: CGFloat
    var y: CGFloat
    var width: CGFloat
    var height: CGFloat
    var content: String
    var color: NoteColor
    var zIndex: Int
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        x: CGFloat,
        y: CGFloat,
        width: CGFloat = 260,
        height: CGFloat = 180,
        content: String = "",
        color: NoteColor = .random(),
        zIndex: Int = 0,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.x = x
        self.y = y
        self.width = width
        self.height = height
        self.content = content
        self.color = color
        self.zIndex = zIndex
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    var position: CGPoint {
        get { CGPoint(x: x, y: y) }
        set { x = newValue.x; y = newValue.y }
    }

    var size: CGSize {
        get { CGSize(width: width, height: height) }
        set { width = newValue.width; height = newValue.height }
    }
}
