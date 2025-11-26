import Foundation
import SwiftUI
import Combine

class CanvasStore: ObservableObject {
    @Published var notes: [Note] = []
    @Published var images: [CanvasImage] = []
    @Published var files: [CanvasFile] = []
    @Published var viewport: Viewport = .default
    @Published var selectedNoteId: UUID?
    @Published var selectedImageId: UUID?
    @Published var selectedFileId: UUID?
    @Published var editingNoteId: UUID?

    private var undoStack: [[CanvasState]] = []
    private var redoStack: [[CanvasState]] = []
    private let maxUndoSteps = 50

    private let saveKey = "interectnote-storage"

    init() {
        load()
    }

    // MARK: - Computed Properties

    var selectedNote: Note? {
        guard let id = selectedNoteId else { return nil }
        return notes.first { $0.id == id }
    }

    var canUndo: Bool { !undoStack.isEmpty }
    var canRedo: Bool { !redoStack.isEmpty }

    private var maxZIndex: Int {
        let noteMax = notes.map { $0.zIndex }.max() ?? 0
        let imageMax = images.map { $0.zIndex }.max() ?? 0
        let fileMax = files.map { $0.zIndex }.max() ?? 0
        return max(noteMax, imageMax, fileMax)
    }

    // MARK: - Note Actions

    func addNote(at position: CGPoint) {
        saveState()
        let note = Note(
            x: position.x,
            y: position.y,
            zIndex: maxZIndex + 1
        )
        notes.append(note)
        selectedNoteId = note.id
        selectedImageId = nil
        selectedFileId = nil
        editingNoteId = note.id
        save()
    }

    func updateNote(_ id: UUID, updates: (inout Note) -> Void) {
        saveState()
        guard let index = notes.firstIndex(where: { $0.id == id }) else { return }
        var note = notes[index]
        updates(&note)
        note.updatedAt = Date()
        notes[index] = note
        save()
    }

    func deleteNote(_ id: UUID) {
        saveState()
        notes.removeAll { $0.id == id }
        if selectedNoteId == id {
            selectedNoteId = nil
        }
        if editingNoteId == id {
            editingNoteId = nil
        }
        save()
    }

    func selectNote(_ id: UUID?) {
        if let id = id {
            // Bring to front
            if let index = notes.firstIndex(where: { $0.id == id }) {
                notes[index].zIndex = maxZIndex + 1
            }
        }
        selectedNoteId = id
        selectedImageId = nil
        selectedFileId = nil
        save()
    }

    // MARK: - Image Actions

    func addImage(_ imageData: Data, at position: CGPoint, size: CGSize) {
        saveState()
        let image = CanvasImage(
            x: position.x,
            y: position.y,
            width: size.width,
            height: size.height,
            imageData: imageData,
            zIndex: maxZIndex + 1
        )
        images.append(image)
        selectedImageId = image.id
        selectedNoteId = nil
        selectedFileId = nil
        save()
    }

    func updateImage(_ id: UUID, updates: (inout CanvasImage) -> Void) {
        saveState()
        guard let index = images.firstIndex(where: { $0.id == id }) else { return }
        var image = images[index]
        updates(&image)
        images[index] = image
        save()
    }

    func deleteImage(_ id: UUID) {
        saveState()
        images.removeAll { $0.id == id }
        if selectedImageId == id {
            selectedImageId = nil
        }
        save()
    }

    func selectImage(_ id: UUID?) {
        if let id = id {
            if let index = images.firstIndex(where: { $0.id == id }) {
                images[index].zIndex = maxZIndex + 1
            }
        }
        selectedImageId = id
        selectedNoteId = nil
        selectedFileId = nil
        save()
    }

    // MARK: - File Actions

    func addFile(_ fileData: Data, fileName: String, fileType: FileType, at position: CGPoint, size: CGSize) {
        saveState()
        let file = CanvasFile(
            x: position.x,
            y: position.y,
            width: size.width,
            height: size.height,
            fileName: fileName,
            fileType: fileType,
            fileData: fileData,
            zIndex: maxZIndex + 1
        )
        files.append(file)
        selectedFileId = file.id
        selectedNoteId = nil
        selectedImageId = nil
        save()
    }

    func updateFile(_ id: UUID, updates: (inout CanvasFile) -> Void) {
        saveState()
        guard let index = files.firstIndex(where: { $0.id == id }) else { return }
        var file = files[index]
        updates(&file)
        files[index] = file
        save()
    }

    func deleteFile(_ id: UUID) {
        saveState()
        files.removeAll { $0.id == id }
        if selectedFileId == id {
            selectedFileId = nil
        }
        save()
    }

    func selectFile(_ id: UUID?) {
        if let id = id {
            if let index = files.firstIndex(where: { $0.id == id }) {
                files[index].zIndex = maxZIndex + 1
            }
        }
        selectedFileId = id
        selectedNoteId = nil
        selectedImageId = nil
        save()
    }

    // MARK: - Viewport

    func setViewport(_ newViewport: Viewport) {
        viewport = newViewport
    }

    func resetViewport() {
        viewport = .default
    }

    // MARK: - Selection

    func clearSelection() {
        selectedNoteId = nil
        selectedImageId = nil
        selectedFileId = nil
        editingNoteId = nil
    }

    func deleteSelected() {
        if let id = selectedNoteId {
            deleteNote(id)
        } else if let id = selectedImageId {
            deleteImage(id)
        } else if let id = selectedFileId {
            deleteFile(id)
        }
    }

    // MARK: - Canvas Actions

    func clearCanvas() {
        saveState()
        notes = []
        images = []
        files = []
        viewport = .default
        selectedNoteId = nil
        selectedImageId = nil
        selectedFileId = nil
        editingNoteId = nil
        save()
    }

    // MARK: - Undo/Redo

    private struct CanvasState: Codable {
        let notes: [Note]
        let images: [CanvasImage]
        let files: [CanvasFile]
    }

    private func saveState() {
        let state = CanvasState(notes: notes, images: images, files: files)
        undoStack.append([state])
        if undoStack.count > maxUndoSteps {
            undoStack.removeFirst()
        }
        redoStack.removeAll()
    }

    func undo() {
        guard let lastState = undoStack.popLast()?.first else { return }
        let currentState = CanvasState(notes: notes, images: images, files: files)
        redoStack.append([currentState])

        notes = lastState.notes
        images = lastState.images
        files = lastState.files
        save()
    }

    func redo() {
        guard let nextState = redoStack.popLast()?.first else { return }
        let currentState = CanvasState(notes: notes, images: images, files: files)
        undoStack.append([currentState])

        notes = nextState.notes
        images = nextState.images
        files = nextState.files
        save()
    }

    // MARK: - Persistence

    private func save() {
        let state = CanvasState(notes: notes, images: images, files: files)
        do {
            let data = try JSONEncoder().encode(state)
            UserDefaults.standard.set(data, forKey: saveKey)
        } catch {
            print("Failed to save canvas: \(error)")
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: saveKey) else { return }
        do {
            let state = try JSONDecoder().decode(CanvasState.self, from: data)
            notes = state.notes
            images = state.images
            files = state.files
        } catch {
            print("Failed to load canvas: \(error)")
        }
    }
}
