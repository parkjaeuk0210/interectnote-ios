import SwiftUI

struct FloatingButtonView: View {
    @EnvironmentObject var store: CanvasStore
    @State private var isPressed = false

    var body: some View {
        Button(action: addNoteAtCenter) {
            ZStack {
                // Gradient background
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 59/255, green: 130/255, blue: 246/255),
                                Color(red: 147/255, green: 51/255, blue: 234/255)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 56, height: 56)
                    .shadow(
                        color: Color(red: 79/255, green: 70/255, blue: 229/255).opacity(0.4),
                        radius: 12,
                        x: 0,
                        y: 4
                    )
                    .shadow(
                        color: Color.black.opacity(0.1),
                        radius: 4,
                        x: 0,
                        y: 2
                    )

                // Ripple effect on hover
                Circle()
                    .fill(Color.white.opacity(isPressed ? 0.2 : 0))
                    .frame(width: 56, height: 56)

                // Plus icon
                Image(systemName: "plus")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.white)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .onLongPressGesture(minimumDuration: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }

    private func addNoteAtCenter() {
        let centerX = -store.viewport.x / store.viewport.scale
        let centerY = -store.viewport.y / store.viewport.scale
        // Offset to center the note (note width: 260, height: 180)
        store.addNote(at: CGPoint(x: centerX - 130, y: centerY - 90))
    }
}

#Preview {
    ZStack {
        Color.gray.opacity(0.3)
        VStack {
            Spacer()
            FloatingButtonView()
                .environmentObject(CanvasStore())
                .padding(.bottom, 24)
        }
    }
}
