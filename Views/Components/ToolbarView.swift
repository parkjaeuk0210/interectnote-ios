import SwiftUI
import PhotosUI
import UniformTypeIdentifiers

struct ToolbarView: View {
    @EnvironmentObject var store: CanvasStore
    @Environment(\.colorScheme) var colorScheme
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var showingFilePicker = false

    private var selectedNote: Note? {
        guard let id = store.selectedNoteId else { return nil }
        return store.notes.first { $0.id == id }
    }

    var body: some View {
        VStack(spacing: 16) {
            // File upload button
            PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                ToolbarButton(icon: "icloud.and.arrow.up")
            }
            .onChange(of: selectedPhotoItem) { _, newItem in
                Task {
                    await loadImage(from: newItem)
                }
            }

            // Zoom percentage
            Text("\(Int(store.viewport.scale * 100))%")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary)

            // Show color picker and delete when note is selected
            if let note = selectedNote {
                Divider()
                    .frame(width: 24)
                    .background(Color.gray.opacity(0.3))

                ColorPickerView(currentColor: note.color) { newColor in
                    store.updateNote(note.id) { $0.color = newColor }
                }

                // Delete button
                Button(action: {
                    store.deleteNote(note.id)
                }) {
                    ToolbarButton(icon: "trash", tint: .red)
                }
                .buttonStyle(PlainButtonStyle())
            }

            // Show delete for image/file
            if store.selectedImageId != nil {
                Divider()
                    .frame(width: 24)
                    .background(Color.gray.opacity(0.3))

                Button(action: {
                    if let id = store.selectedImageId {
                        store.deleteImage(id)
                    }
                }) {
                    ToolbarButton(icon: "trash", tint: .red)
                }
                .buttonStyle(PlainButtonStyle())
            }

            if store.selectedFileId != nil {
                Divider()
                    .frame(width: 24)
                    .background(Color.gray.opacity(0.3))

                Button(action: {
                    if let id = store.selectedFileId {
                        store.deleteFile(id)
                    }
                }) {
                    ToolbarButton(icon: "trash", tint: .red)
                }
                .buttonStyle(PlainButtonStyle())
            }

            // Clear all button (if there are notes)
            if !store.notes.isEmpty {
                Divider()
                    .frame(width: 24)
                    .background(Color.gray.opacity(0.3))

                Button(action: {
                    store.clearCanvas()
                }) {
                    ToolbarButton(icon: "xmark.bin", tint: .red.opacity(0.8))
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 24)
        .background(
            ZStack {
                if colorScheme == .dark {
                    Color.black.opacity(0.3)
                } else {
                    Color.white.opacity(0.6)
                }
            }
            .background(.ultraThinMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: 28)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(colorScheme == .dark ? 0.2 : 0.5),
                                Color.white.opacity(colorScheme == .dark ? 0.05 : 0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 28))
        .shadow(color: .black.opacity(0.15), radius: 16, x: 0, y: 8)
    }

    private func loadImage(from item: PhotosPickerItem?) async {
        guard let item = item else { return }

        do {
            if let data = try await item.loadTransferable(type: Data.self) {
                await MainActor.run {
                    #if os(iOS)
                    if let uiImage = UIImage(data: data) {
                        let size = calculateImageSize(uiImage.size)
                        let centerX = -store.viewport.x / store.viewport.scale
                        let centerY = -store.viewport.y / store.viewport.scale
                        store.addImage(data, at: CGPoint(x: centerX, y: centerY), size: size)
                    }
                    #elseif os(macOS)
                    if let nsImage = NSImage(data: data) {
                        let size = calculateImageSize(nsImage.size)
                        let centerX = -store.viewport.x / store.viewport.scale
                        let centerY = -store.viewport.y / store.viewport.scale
                        store.addImage(data, at: CGPoint(x: centerX, y: centerY), size: size)
                    }
                    #endif
                }
            }
        } catch {
            print("Failed to load image: \(error)")
        }
    }

    private func calculateImageSize(_ originalSize: CGSize) -> CGSize {
        let maxDimension: CGFloat = 400
        let aspectRatio = originalSize.width / originalSize.height

        if originalSize.width > originalSize.height {
            return CGSize(width: maxDimension, height: maxDimension / aspectRatio)
        } else {
            return CGSize(width: maxDimension * aspectRatio, height: maxDimension)
        }
    }
}

// MARK: - Toolbar Button

struct ToolbarButton: View {
    let icon: String
    var tint: Color = .primary

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Image(systemName: icon)
            .font(.system(size: 18, weight: .medium))
            .foregroundColor(tint == .primary ? (colorScheme == .dark ? .white : .gray) : tint)
            .frame(width: 44, height: 44)
            .background(
                Circle()
                    .fill(
                        colorScheme == .dark
                            ? Color.white.opacity(0.1)
                            : Color.white.opacity(0.6)
                    )
            )
            .overlay(
                Circle()
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
            )
            .contentShape(Circle())
    }
}

#Preview {
    HStack {
        Spacer()
        ToolbarView()
            .environmentObject(CanvasStore())
            .padding()
    }
    .background(Color.gray.opacity(0.3))
}
