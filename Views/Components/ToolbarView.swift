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
            // Image upload button
            PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                ToolbarButton(icon: "photo.badge.plus")
            }
            .onChange(of: selectedPhotoItem) { _, newItem in
                Task {
                    await loadImage(from: newItem)
                }
            }

            // File/PDF upload button
            Button(action: { showingFilePicker = true }) {
                ToolbarButton(icon: "doc.badge.plus")
            }
            .buttonStyle(PlainButtonStyle())

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
            if !store.notes.isEmpty || !store.images.isEmpty || !store.files.isEmpty {
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
        .fileImporter(
            isPresented: $showingFilePicker,
            allowedContentTypes: [.pdf, .item],
            allowsMultipleSelection: false,
            onCompletion: handleFileImport
        )
    }

    private func loadImage(from item: PhotosPickerItem?) async {
        guard let item = item else { return }

        do {
            if let data = try await item.loadTransferable(type: Data.self) {
                await MainActor.run {
                    #if os(iOS)
                    if let uiImage = UIImage(data: data) {
                        let size = calculateImageSize(uiImage.size)
                        store.addImage(data, at: centeredOrigin(for: size), size: size)
                    }
                    #elseif os(macOS)
                    if let nsImage = NSImage(data: data) {
                        let size = calculateImageSize(nsImage.size)
                        store.addImage(data, at: centeredOrigin(for: size), size: size)
                    }
                    #endif
                }
            }
        } catch {
            print("Failed to load image: \(error)")
        }
    }

    private func handleFileImport(_ result: Result<[URL], Error>) {
        do {
            guard let url = try result.get().first else { return }
            try loadFile(from: url)
        } catch {
            print("Failed to import file: \(error)")
        }
    }

    private func loadFile(from url: URL) throws {
        let hasSecurityScope = url.startAccessingSecurityScopedResource()
        defer {
            if hasSecurityScope {
                url.stopAccessingSecurityScopedResource()
            }
        }

        let fileData = try Data(contentsOf: url)
        let fileName = url.lastPathComponent
        let fileType: FileType = url.pathExtension.lowercased() == "pdf" ? .pdf : .document
        let size: CGSize

        switch fileType {
        case .pdf:
            size = CGSize(width: 300, height: 400)
        case .document, .other:
            size = CGSize(width: 240, height: 180)
        }

        store.addFile(
            fileData,
            fileName: fileName,
            fileType: fileType,
            at: centeredOrigin(for: size),
            size: size
        )
    }

    private func centeredOrigin(for size: CGSize) -> CGPoint {
        let center = visibleCanvasCenter()
        return CGPoint(
            x: center.x - size.width / 2,
            y: center.y - size.height / 2
        )
    }

    private func visibleCanvasCenter() -> CGPoint {
        let scale = max(store.viewport.scale, 0.0001)
        return CGPoint(
            x: -store.viewport.x / scale,
            y: -store.viewport.y / scale
        )
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
