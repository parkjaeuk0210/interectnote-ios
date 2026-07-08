import SwiftUI
import PDFKit

struct CanvasFileView: View {
    let file: CanvasFile
    @EnvironmentObject var store: CanvasStore
    @State private var isDragging = false
    @State private var dragOffset: CGSize = .zero
    @State private var isResizing = false
    @State private var resizeStart: CGSize = .zero

    private var isSelected: Bool {
        store.selectedFileId == file.id
    }

    var body: some View {
        fileContent
            .position(
                x: file.x + file.width / 2 + (isDragging ? dragOffset.width : 0),
                y: file.y + file.height / 2 + (isDragging ? dragOffset.height : 0)
            )
            .gesture(dragGesture)
            .onTapGesture {
                store.selectFile(file.id)
            }
    }

    @ViewBuilder
    private var fileContent: some View {
        ZStack(alignment: .bottomTrailing) {
            Group {
                switch file.fileType {
                case .pdf:
                    PDFPreviewView(data: file.fileData)
                case .document, .other:
                    documentPreview
                }
            }
            .frame(width: file.width, height: file.height)
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
                        Button(action: { store.deleteFile(file.id) }) {
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

    private var documentPreview: some View {
        VStack(spacing: 12) {
            Image(systemName: iconForFileType)
                .font(.system(size: 40))
                .foregroundColor(.blue)

            Text(file.fileName)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.primary)
                .lineLimit(2)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(white: 0.95))
        )
    }

    private var iconForFileType: String {
        switch file.fileType {
        case .pdf: return "doc.fill"
        case .document: return "doc.text.fill"
        case .other: return "doc.fill"
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
                    store.selectFile(file.id)
                }
                dragOffset = canvasTranslation(value.translation)
            }
            .onEnded { value in
                let translation = canvasTranslation(value.translation)
                store.updateFile(file.id) { f in
                    f.x += translation.width
                    f.y += translation.height
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
                    resizeStart = CGSize(width: file.width, height: file.height)
                    store.recordUndoCheckpoint()
                }

                let translation = canvasTranslation(value.translation)
                let newWidth = max(100, resizeStart.width + translation.width)
                let newHeight = max(100, resizeStart.height + translation.height)

                store.updateFile(file.id, recordUndo: false) { f in
                    f.width = newWidth
                    f.height = newHeight
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

// MARK: - PDF Preview

struct PDFPreviewView: View {
    let data: Data

    var body: some View {
        #if os(iOS)
        PDFKitRepresentableView(data: data)
        #elseif os(macOS)
        PDFKitRepresentableViewMac(data: data)
        #endif
    }
}

#if os(iOS)
struct PDFKitRepresentableView: UIViewRepresentable {
    let data: Data

    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        pdfView.displayMode = .singlePage
        pdfView.displayDirection = .vertical
        if let document = PDFDocument(data: data) {
            pdfView.document = document
        }
        return pdfView
    }

    func updateUIView(_ uiView: PDFView, context: Context) {}
}
#endif

#if os(macOS)
struct PDFKitRepresentableViewMac: NSViewRepresentable {
    let data: Data

    func makeNSView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        pdfView.displayMode = .singlePage
        if let document = PDFDocument(data: data) {
            pdfView.document = document
        }
        return pdfView
    }

    func updateNSView(_ nsView: PDFView, context: Context) {}
}
#endif

#Preview {
    ZStack {
        Color.gray.opacity(0.2)
        CanvasFileView(file: CanvasFile(
            x: 100,
            y: 100,
            width: 200,
            height: 250,
            fileName: "test.pdf",
            fileType: .pdf,
            fileData: Data()
        ))
        .environmentObject(CanvasStore())
    }
}
