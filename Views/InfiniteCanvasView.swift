import SwiftUI

struct InfiniteCanvasView: View {
    @EnvironmentObject var store: CanvasStore
    @State private var isDraggingCanvas = false
    @State private var lastDragPosition: CGPoint = .zero
    @State private var isMagnifying = false
    @State private var viewportAtMagnificationStart: Viewport = .default

    private let defaultNoteSize = CGSize(width: 260, height: 180)

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                CanvasBackgroundView()
                    .ignoresSafeArea()

                // Canvas content. The stored canvas origin maps to the visible center
                // plus viewport offset, and panning is applied after scaling so pan
                // velocity stays constant at every zoom level.
                canvasContent
                    .frame(width: geometry.size.width, height: geometry.size.height, alignment: .topLeading)
                    .scaleEffect(store.viewport.scale, anchor: .topLeading)
                    .offset(
                        x: geometry.size.width / 2 + store.viewport.x,
                        y: geometry.size.height / 2 + store.viewport.y
                    )
            }
            .contentShape(Rectangle())
            .gesture(combinedGesture)
            .onTapGesture(count: 2) { location in
                // Double tap to add a note centered on the tapped canvas point.
                let canvasPoint = screenToCanvas(location, in: geometry)
                store.addNote(at: CGPoint(
                    x: canvasPoint.x - defaultNoteSize.width / 2,
                    y: canvasPoint.y - defaultNoteSize.height / 2
                ))
            }
            .onTapGesture(count: 1) {
                // Single tap to deselect
                store.clearSelection()
            }
        }
        .clipped()
    }

    private var canvasContent: some View {
        ZStack(alignment: .topLeading) {
            // Render all items sorted by zIndex
            ForEach(sortedItems, id: \.id) { item in
                switch item {
                case .note(let note):
                    StickyNoteView(note: note)
                        .environmentObject(store)
                case .image(let image):
                    CanvasImageView(image: image)
                        .environmentObject(store)
                case .file(let file):
                    CanvasFileView(file: file)
                        .environmentObject(store)
                }
            }
        }
    }

    private enum CanvasItem: Identifiable {
        case note(Note)
        case image(CanvasImage)
        case file(CanvasFile)

        var id: UUID {
            switch self {
            case .note(let note): return note.id
            case .image(let image): return image.id
            case .file(let file): return file.id
            }
        }

        var zIndex: Int {
            switch self {
            case .note(let note): return note.zIndex
            case .image(let image): return image.zIndex
            case .file(let file): return file.zIndex
            }
        }
    }

    private var sortedItems: [CanvasItem] {
        let noteItems = store.notes.map { CanvasItem.note($0) }
        let imageItems = store.images.map { CanvasItem.image($0) }
        let fileItems = store.files.map { CanvasItem.file($0) }

        return (noteItems + imageItems + fileItems).sorted { $0.zIndex < $1.zIndex }
    }

    private var combinedGesture: some Gesture {
        SimultaneousGesture(dragGesture, magnificationGesture)
    }

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 1)
            .onChanged { value in
                if !isDraggingCanvas {
                    isDraggingCanvas = true
                    lastDragPosition = CGPoint(x: store.viewport.x, y: store.viewport.y)
                }

                let newX = lastDragPosition.x + value.translation.width
                let newY = lastDragPosition.y + value.translation.height

                store.setViewport(Viewport(
                    x: newX,
                    y: newY,
                    scale: store.viewport.scale
                ))
            }
            .onEnded { _ in
                isDraggingCanvas = false
            }
    }

    private var magnificationGesture: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                if !isMagnifying {
                    isMagnifying = true
                    viewportAtMagnificationStart = store.viewport
                }

                let startScale = max(viewportAtMagnificationStart.scale, 0.0001)
                let newScale = store.viewport.clampedScale(startScale * value)
                let ratio = newScale / startScale

                store.setViewport(Viewport(
                    x: viewportAtMagnificationStart.x * ratio,
                    y: viewportAtMagnificationStart.y * ratio,
                    scale: newScale
                ))
            }
            .onEnded { _ in
                isMagnifying = false
            }
    }

    private func screenToCanvas(_ point: CGPoint, in geometry: GeometryProxy) -> CGPoint {
        let centerX = geometry.size.width / 2
        let centerY = geometry.size.height / 2
        let scale = max(store.viewport.scale, 0.0001)

        let x = (point.x - centerX - store.viewport.x) / scale
        let y = (point.y - centerY - store.viewport.y) / scale

        return CGPoint(x: x, y: y)
    }
}

// MARK: - Canvas Background

struct CanvasBackgroundView: View {
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                colors: colorScheme == .dark
                    ? [Color(white: 0.11), Color(white: 0.13), Color(white: 0.11)]
                    : [Color(white: 0.97), Color(white: 0.96), Color(white: 0.95)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // Grid pattern
            GridPatternView()
                .opacity(colorScheme == .dark ? 0.03 : 0.015)
        }
    }
}

struct GridPatternView: View {
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let spacing: CGFloat = 60
                let width = geometry.size.width
                let height = geometry.size.height

                // Vertical lines
                var x: CGFloat = 0
                while x < width {
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: height))
                    x += spacing
                }

                // Horizontal lines
                var y: CGFloat = 0
                while y < height {
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: width, y: y))
                    y += spacing
                }
            }
            .stroke(Color.primary, lineWidth: 0.5)
        }
    }
}

#Preview {
    InfiniteCanvasView()
        .environmentObject(CanvasStore())
}
