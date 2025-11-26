import SwiftUI

@main
struct InterectNoteApp: App {
    @StateObject private var canvasStore = CanvasStore()
    @AppStorage("isDarkMode") private var isDarkMode = false

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(canvasStore)
                .preferredColorScheme(isDarkMode ? .dark : .light)
        }
        #if os(macOS)
        .windowStyle(.hiddenTitleBar)
        .defaultSize(width: 1200, height: 800)
        #endif

        #if os(macOS)
        Settings {
            SettingsView()
                .environmentObject(canvasStore)
        }
        #endif
    }
}
