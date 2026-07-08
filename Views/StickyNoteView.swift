import SwiftUI

struct StickyNoteView: View {
    let note: Note
    @EnvironmentObject var store: CanvasStore
    @State private var isDragging = false
    @State private var dragOffset: CGSize = .zero
    @State private var isResizing = false
    @State private var resizeStart: CGSize = .zero
    @FocusState private var isTextFocused: Bool

    private var isSelected: Bool {
        store.selectedNoteId == note.id
    }

    private var isEditing: Bool {
        store.editingNoteId == note.id
    }

    var body: some View {
        noteContent
            .position(
                x: note.x + note.width / 2 + (isDragging ? dragOffset.width : 0),
                y: note.y + note.height / 2 + (isDragging ? dragOffset.height : 0)
            )
            .gesture(dragGesture)
            .onTapGesture(count: 2) {
                store.editingNoteId = note.id
                store.selectNote(note.id)
            }
            .onTapGesture(count: 1) {
                if !isEditing {
                    store.selectNote(note.id)
                }
            }
    }

    private var noteContent: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 0) {
                // Header
                noteHeader

                // Content
                contentArea
            }
            .frame(width: note.width, height: note.height)
            .background(noteBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(selectionBorder)
            .shadow(
                color: note.color.shadowColor.opacity(0.25),
                radius: isSelected ? 24 : 20,
                x: 0,
                y: isSelected ? 12 : 8
            )
            .shadow(
                color: Color.black.opacity(0.08),
                radius: isSelected ? 12 : 8,
                x: 0,
                y: isSelected ? 6 : 4
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)

            // Resize handle
            if isSelected {
                resizeHandle
            }
        }
    }

    private var noteHeader: some View {
        HStack {
            // Color dots
            HStack(spacing: 6) {
                ForEach(NoteColor.allCases.prefix(3), id: \.self) { color in
                    Circle()
                        .fill(color.color)
                        .frame(width: 8, height: 8)
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.5), lineWidth: 0.5)
                        )
                        .onTapGesture {
                            store.updateNote(note.id) { $0.color = color }
                        }
                }
            }

            Spacer()

            // Delete button
            if isSelected {
                Button(action: { store.deleteNote(note.id) }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.black.opacity(0.5))
                        .frame(width: 20, height: 20)
                        .background(
                            Circle()
                                .fill(Color.white.opacity(0.3))
                        )
                }
                .buttonStyle(PlainButtonStyle())
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color.white.opacity(0.08))
    }

    private var contentArea: some View {
        Group {
            if isEditing {
                TextEditor(text: Binding(
                    get: { note.content },
                    set: { newValue in
                        store.updateNoteContent(note.id, content: newValue)
                    }
                ))
                .font(.system(size: 15))
                .foregroundColor(.black.opacity(0.85))
                .scrollContentBackground(.hidden)
                .background(Color.clear)
                .focused($isTextFocused)
                .onAppear { isTextFocused = true }
                .onDisappear { store.editingNoteId = nil }
            } else {
                Text(note.content.isEmpty ? "메모를 입력하세요..." : note.content)
                    .font(.system(size: 15))
                    .foregroundColor(note.content.isEmpty ? .black.opacity(0.4) : .black.opacity(0.85))
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
        }
        .padding(16)
    }

    private var noteBackground: some View {
        ZStack {
            note.color.gradient

            // Glass overlay
            LinearGradient(
                colors: [
                    Color.white.opacity(0.05),
                    Color.white.opacity(0.02),
                    Color.white.opacity(0.05)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.5),
                            Color.white.opacity(0.2),
                            Color.white.opacity(0.3)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
    }

    private var selectionBorder: some View {
        RoundedRectangle(cornerRadius: 16)
            .stroke(
                isSelected ? Color.blue.opacity(0.6) : Color.clear,
                lineWidth: 2
            )
    }

    private var resizeHandle: some View {
        Image(systemName: "arrow.up.left.and.arrow.down.right")
            .font(.system(size: 10))
            .foregroundColor(.black.opacity(0.4))
            .frame(width: 24, height: 24)
            .background(
                Circle()
                    .fill(Color.white.opacity(0.5))
            )
            .offset(x: -8, y: -8)
            .gesture(resizeGesture)
    }

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                if !isDragging {
                    isDragging = true
                    store.selectNote(note.id)
                }
                dragOffset = canvasTranslation(value.translation)
            }
            .onEnded { value in
                let translation = canvasTranslation(value.translation)
                store.updateNote(note.id) { note in
                    note.x += translation.width
                    note.y += translation.height
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
                    resizeStart = CGSize(width: note.width, height: note.height)
                    store.recordUndoCheckpoint()
                }

                let translation = canvasTranslation(value.translation)
                let newWidth = max(150, resizeStart.width + translation.width)
                let newHeight = max(100, resizeStart.height + translation.height)

                store.updateNote(note.id, recordUndo: false) { note in
                    note.width = newWidth
                    note.height = newHeight
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
        StickyNoteView(note: Note(x: 100, y: 100, content: "테스트 메모입니다."))
            .environmentObject(CanvasStore())
    }
}
