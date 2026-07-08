import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @EnvironmentObject var store: CanvasStore
    @Environment(\.colorScheme) var colorScheme
    @State private var isDroppingFile = false

    #if os(macOS)
    @State private var keyDownMonitor: Any?
    #endif

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
        .onDisappear {
            tearDownKeyboardShortcuts()
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
                            let position = dropPosition(for: size)
                            store.addImage(data, at: position, size: size)
                        }
                        #elseif os(macOS)
                        if let image = NSImage(data: data) {
                            let size = calculateImageSize(image.size)
                            let position = dropPosition(for: size)
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
                        let size = CGSize(width: 300, height: 400)
                        let position = dropPosition(for: size)
                        store.addFile(
                            data,
                            fileName: "Document.pdf",
                            fileType: .pdf,
                            at: position,
                            size: size
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
                        let size = CGSize(width: 300, height: 400)

                        DispatchQueue.main.async {
                            let position = dropPosition(for: size)
                            store.addFile(
                                fileData,
                                fileName: fileName,
                                fileType: fileType,
                                at: position,
                                size: size
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

    private func dropPosition(for size: CGSize) -> CGPoint {
        let center = visibleCanvasCenter()
        // Add some randomness to avoid stacking.
        return CGPoint(
            x: center.x - size.width / 2 + CGFloat.random(in: -50...50),
            y: center.y - size.height / 2 + CGFloat.random(in: -50...50)
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

    private func setupKeyboardShortcuts() {
        #if os(macOS)
        guard keyDownMonitor == nil else { return }

        keyDownMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            // Let the active TextEditor own text-editing shortcuts and Delete/Backspace.
            guard store.editingNoteId == nil else {
                return event
            }

            // Cmd+Z for canvas undo/redo.
            if event.modifierFlags.contains(.command) && event.charactersIgnoringModifiers == "z" {
                if event.modifierFlags.contains(.shift) {
                    store.redo()
                } else {
                    store.undo()
                }
                return nil
            }

            // Delete/Backspace for deleting selected canvas items only when not editing text.
            if event.keyCode == 51 || event.keyCode == 117 { // Backspace or Delete
                store.deleteSelected()
                return nil
            }

            return event
        }
        #endif
    }

    private func tearDownKeyboardShortcuts() {
        #if os(macOS)
        if let keyDownMonitor {
            NSEvent.removeMonitor(keyDownMonitor)
            self.keyDownMonitor = nil
        }
        #endif
    }
}

#Preview {
    ContentView()
        .environmentObject(CanvasStore())
}
