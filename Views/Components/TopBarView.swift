import SwiftUI

struct TopBarView: View {
    @EnvironmentObject var store: CanvasStore
    @AppStorage("isDarkMode") private var isDarkMode = false
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        HStack {
            // Left side - Canvas selector (if logged in) and Undo/Redo
            HStack(spacing: 8) {
                // Undo button
                Button(action: { store.undo() }) {
                    TopBarButton(icon: "arrow.uturn.backward")
                }
                .disabled(!store.canUndo)
                .opacity(store.canUndo ? 1.0 : 0.5)

                // Redo button
                Button(action: { store.redo() }) {
                    TopBarButton(icon: "arrow.uturn.forward")
                }
                .disabled(!store.canRedo)
                .opacity(store.canRedo ? 1.0 : 0.5)
            }

            Spacer()

            // Right side - Dark mode toggle
            HStack(spacing: 8) {
                Button(action: { isDarkMode.toggle() }) {
                    ZStack {
                        TopBarButton(
                            icon: isDarkMode ? "sun.max.fill" : "moon.fill"
                        )
                        .foregroundColor(isDarkMode ? .yellow : .indigo)
                    }
                }
            }
        }
    }
}

// MARK: - Top Bar Button

struct TopBarButton: View {
    let icon: String
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Image(systemName: icon)
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(colorScheme == .dark ? .white : .black.opacity(0.7))
            .frame(width: 40, height: 40)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        Color.white.opacity(colorScheme == .dark ? 0.2 : 0.4),
                        lineWidth: 1
                    )
            )
            .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    VStack {
        TopBarView()
            .environmentObject(CanvasStore())
            .padding()
        Spacer()
    }
    .background(Color.gray.opacity(0.3))
}
