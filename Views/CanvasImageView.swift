import SwiftUI

struct CanvasImageView: View {
    let image: CanvasImage
    @EnvironmentObject var store: CanvasStore
    @State private var isDragging = false
    @State private var dragOffset: CGSize = .zero
    @State private var isResizing = false
    @State private var resizeStart: CGSize = .zero

    private var isSelected: Bool {
        store.selectedImageId == image.id
    }

    var body: some View {
        imageContent
            .position(
                x: image.x + image.width / 2 + (isDragging ? dragOffset.width : 0),
                y: image.y + image.height / 2 + (isDragging ? dragOffset.height : 0)
            )
            .gesture(dragGesture)
            .onTapGesture {
                store.selectImage(image.id)
            }
    }

    private var imageContent: some View {
        ZStack(alignment: .bottomTrailing) {
            Group {
                if let swiftUIImage = image.image {
                    swiftUIImage
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay(
                            Image(systemName: "photo")
                                .font(.largeTitle)
                                .foregroundColor(.gray)
                        )
                }
            }
            .frame(width: image.width, height: image.height)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isSelected ? Color.blue.opacity(0.6) : Color.white.opacity(0.3),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .shadow(
                color: Color.black.opacity(isSelected ? 0.3 : 0.2),
                radius: isSelected ? 16 : 10,
                x: 0,
                y: isSelected ? 8 : 4
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)

            // Controls overlay
            if isSelected {
                VStack {
                    HStack {
                        Spacer()
                        // Delete button
                        Button(action: { store.deleteImage(image.id) }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 28, height: 28)
                                .background(
                                    Circle()
                                        .fill(Color.black.opacity(0.5))
                                )
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(8)
                    }
                    Spacer()
                }

                // Resize handle
                resizeHandle
            }
        }
    }

    private var resizeHandle: some View {
        Image(systemName: "arrow.up.left.and.arrow.down.right")
            .font(.system(size: 10))
            .foregroundColor(.white)
            .frame(width: 24, height: 24)
            .background(
                Circle()
                    .fill(Color.black.opacity(0.5))
            )
            .offset(x: -8, y: -8)
            .gesture(resizeGesture)
    }

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                if !isDragging {
                    isDragging = true
                    store.selectImage(image.id)
                }
                dragOffset = canvasTranslation(value.translation)
            }
            .onEnded { value in
                let translation = canvasTranslation(value.translation)
                store.updateImage(image.id) { img in
                    img.x += translation.width
                    img.y += translation.height
                }
                dragOffset = .zero
                isDragging = false
            }
    }

    private var resizeGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                if !isResizing {
                    isResizing = true
                    resizeStart = CGSize(width: image.width, height: image.height)
                    store.recordUndoCheckpoint()
                }

                // Maintain aspect ratio
                let translation = canvasTranslation(value.translation)
                let aspectRatio = resizeStart.width / resizeStart.height
                let newWidth = max(50, resizeStart.width + translation.width)
                let newHeight = newWidth / aspectRatio

                store.updateImage(image.id, recordUndo: false) { img in
                    img.width = newWidth
                    img.height = newHeight
                }
            }
            .onEnded { _ in
                isResizing = false
            }
    }

    private func canvasTranslation(_ translation: CGSize) -> CGSize {
        let scale = max(store.viewport.scale, 0.0001)
        return CGSize(
            width: translation.width / scale,
            height: translation.height / scale
        )
    }
}

#Preview {
    ZStack {
        Color.gray.opacity(0.2)
        CanvasImageView(image: CanvasImage(
            x: 100,
            y: 100,
            width: 200,
            height: 150,
            imageData: Data()
        ))
        .environmentObject(CanvasStore())
    }
}
