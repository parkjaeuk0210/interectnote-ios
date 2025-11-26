import SwiftUI

struct ColorPickerView: View {
    let currentColor: NoteColor
    let onColorChange: (NoteColor) -> Void

    @State private var isOpen = false
    @Environment(\.colorScheme) var colorScheme

    // Light mode preview colors
    private let lightColors: [(color: NoteColor, hex: Color)] = [
        (.yellow, Color(red: 254/255, green: 240/255, blue: 138/255)),
        (.pink, Color(red: 251/255, green: 207/255, blue: 232/255)),
        (.blue, Color(red: 147/255, green: 197/255, blue: 253/255)),
        (.green, Color(red: 134/255, green: 239/255, blue: 172/255)),
        (.purple, Color(red: 196/255, green: 181/255, blue: 253/255)),
        (.orange, Color(red: 254/255, green: 215/255, blue: 170/255)),
    ]

    // Dark mode preview colors
    private let darkColors: [(color: NoteColor, hex: Color)] = [
        (.yellow, Color(red: 245/255, green: 158/255, blue: 11/255)),
        (.pink, Color(red: 236/255, green: 72/255, blue: 153/255)),
        (.blue, Color(red: 59/255, green: 130/255, blue: 246/255)),
        (.green, Color(red: 34/255, green: 197/255, blue: 94/255)),
        (.purple, Color(red: 147/255, green: 51/255, blue: 234/255)),
        (.orange, Color(red: 249/255, green: 115/255, blue: 22/255)),
    ]

    private var colors: [(color: NoteColor, hex: Color)] {
        colorScheme == .dark ? darkColors : lightColors
    }

    private var currentColorHex: Color {
        colors.first { $0.color == currentColor }?.hex ?? colors[0].hex
    }

    // Calculate position for each color in the wheel (like original)
    private func getColorPosition(index: Int) -> CGPoint {
        let angle = Double(index * 60 - 90) * .pi / 180
        let radius: Double = 45
        return CGPoint(
            x: cos(angle) * radius,
            y: sin(angle) * radius
        )
    }

    var body: some View {
        ZStack {
            // Current color button
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    isOpen.toggle()
                }
            }) {
                Circle()
                    .fill(currentColorHex)
                    .frame(width: 28, height: 28)
                    .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.5), lineWidth: 1)
                    )
            }
            .buttonStyle(PlainButtonStyle())

            // Color wheel popover
            if isOpen {
                ZStack {
                    // Backdrop to close on tap outside
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                isOpen = false
                            }
                        }

                    // Color wheel
                    ZStack {
                        // Glass background
                        Circle()
                            .fill(.ultraThinMaterial)
                            .frame(width: 130, height: 130)
                            .overlay(
                                Circle()
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                            .shadow(color: .black.opacity(0.2), radius: 16, x: 0, y: 8)

                        // Center current color
                        Circle()
                            .fill(currentColorHex)
                            .frame(width: 32, height: 32)
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: 2)
                            )
                            .shadow(color: .black.opacity(0.2), radius: 4)

                        // Color options in wheel pattern
                        ForEach(Array(colors.enumerated()), id: \.offset) { index, colorItem in
                            let position = getColorPosition(index: index)
                            let isSelected = colorItem.color == currentColor
                            let delay = Double(index) * 0.03

                            Button(action: {
                                onColorChange(colorItem.color)
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    isOpen = false
                                }
                            }) {
                                Circle()
                                    .fill(colorItem.hex)
                                    .frame(width: 28, height: 28)
                                    .overlay(
                                        Circle()
                                            .stroke(
                                                isSelected ? Color.white : Color.clear,
                                                lineWidth: 2
                                            )
                                    )
                                    .shadow(color: colorItem.hex.opacity(0.5), radius: 4)
                                    .scaleEffect(isSelected ? 1.1 : 1.0)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .offset(x: position.x, y: position.y)
                            .scaleEffect(isOpen ? 1 : 0)
                            .opacity(isOpen ? 1 : 0)
                            .animation(
                                .spring(response: 0.3, dampingFraction: 0.6)
                                .delay(delay),
                                value: isOpen
                            )
                        }
                    }
                    .offset(y: -90) // Position above the button
                    .scaleEffect(isOpen ? 1 : 0.8)
                    .opacity(isOpen ? 1 : 0)
                    .animation(.spring(response: 0.2, dampingFraction: 0.7), value: isOpen)
                }
                .frame(width: 200, height: 250)
                .offset(y: -60)
            }
        }
    }
}

#Preview {
    ZStack {
        Color.gray.opacity(0.3)
        ColorPickerView(currentColor: .yellow) { color in
            print("Selected: \(color)")
        }
    }
}
