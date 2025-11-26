import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @EnvironmentObject var store: CanvasStore
    @Environment(\.colorScheme) var colorScheme
    @State private var isDroppingFile = false

    var body: some View {
        ZStack {
            // Canvas
            InfiniteCanvasView()
                .environmentObject(store)

            // UI Overlays - matching original layout
            VStack {
                // Top bar - left/right aligned
                TopBarView()
                    .padding(.horizontal, 16)
                    .padding(.top, topPadding)

                Spacer()

                // Bottom - FloatingButton centered, Toolbar on right
                ZStack {
                    // Floating button at center bottom
                    FloatingButtonView()

                    // Toolbar at right bottom
                    HStack {
                        Spacer()
                        ToolbarView()
                            .padding(.trailing, 24)
                            .padding(.bottom, 96) // Above the floating button
                    }
                }
                .padding(.bottom, bottomPadding)
            }

            // Drop overlay
            if isDroppingFile {
                dropOverlay
            }
        }
        .ignoresSafeArea()
        .onDrop(of: supportedDropTypes, isTargeted: $isDroppingFile) { providers in
            handleDrop(providers)
        }
        #if os(macOS)
        .frame(minWidth: 800, minHeight: 600)
        #endif
        .onAppear {
            setupKeyboardShortcuts()
        }
    }

    private var topPadding: CGFloat {
        #if os(iOS)
        return 60
        #else
        return 20
        #endif
    }

    private var bottomPadding: CGFloat {
        #if os(iOS)
        return 24
        #else
        return 16
        #endif
    }

    private var dropOverlay: some View {
        ZStack {
            Color.blue.opacity(0.1)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                Image(systemName: "arrow.down.doc.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.blue)

                Text("여기에 파일을 놓으세요")
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(.blue)
            }
            .padding(40)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.9))
                    .shadow(color: .blue.opacity(0.2), radius: 20)
            )
        }
    }

    private var supportedDropTypes: [UTType] {
        [.image, .pdf, .fileURL]
    }

    private func handleDrop(_ providers: [NSItemProvider]) -> Bool {
        for provider in providers {
            // Handle images
            if provider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
                provider.loadDataRepresentation(forTypeIdentifier: UTType.image.identifier) { data, error in
                    guard let data = data else { return }
                    DispatchQueue.main.async {
                        #if os(iOS)
                        if let image = UIImage(data: data) {
                            let size = calculateImageSize(image.size)
                            let position = dropPosition()
                            store.addImage(data, at: position, size: size)
                        }
                        #elseif os(macOS)
                        if let image = NSImage(data: data) {
                            let size = calculateImageSize(image.size)
                            let position = dropPosition()
                            store.addImage(data, at: position, size: size)
                        }
                        #endif
                    }
                }
                return true
            }

            // Handle PDFs
            if provider.hasItemConformingToTypeIdentifier(UTType.pdf.identifier) {
                provider.loadDataRepresentation(forTypeIdentifier: UTType.pdf.identifier) { data, error in
                    guard let data = data else { return }
                    DispatchQueue.main.async {
                        let position = dropPosition()
                        store.addFile(
                            data,
                            fileName: "Document.pdf",
                            fileType: .pdf,
                            at: position,
                            size: CGSize(width: 300, height: 400)
                        )
                    }
                }
                return true
            }

            // Handle file URLs
            if provider.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier) {
                provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { item, error in
                    guard let data = item as? Data,
                          let url = URL(dataRepresentation: data, relativeTo: nil) else { return }

                    do {
                        let fileData = try Data(contentsOf: url)
                        let fileName = url.lastPathComponent
                        let fileType: FileType = url.pathExtension.lowercased() == "pdf" ? .pdf : .document

                        DispatchQueue.main.async {
                            let position = dropPosition()
                            store.addFile(
                                fileData,
                                fileName: fileName,
                                fileType: fileType,
                                at: position,
                                size: CGSize(width: 300, height: 400)
                            )
                        }
                    } catch {
                        print("Failed to load dropped file: \(error)")
                    }
                }
                return true
            }
        }
        return false
    }

    private func dropPosition() -> CGPoint {
        let centerX = -store.viewport.x / store.viewport.scale
        let centerY = -store.viewport.y / store.viewport.scale
        // Add some randomness to avoid stacking
        return CGPoint(
            x: centerX + CGFloat.random(in: -50...50),
            y: centerY + CGFloat.random(in: -50...50)
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

    private func setupKeyboardShortcuts() {
        #if os(macOS)
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            // Cmd+Z for undo
            if event.modifierFlags.contains(.command) && event.charactersIgnoringModifiers == "z" {
                if event.modifierFlags.contains(.shift) {
                    store.redo()
                } else {
                    store.undo()
                }
                return nil
            }

            // Delete/Backspace for deleting selected items
            if event.keyCode == 51 || event.keyCode == 117 { // Backspace or Delete
                store.deleteSelected()
                return nil
            }

            return event
        }
        #endif
    }
}

#Preview {
    ContentView()
        .environmentObject(CanvasStore())
}
