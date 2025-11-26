// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "InterectNote",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .executable(name: "InterectNote", targets: ["InterectNote"])
    ],
    targets: [
        .executableTarget(
            name: "InterectNote",
            path: ".",
            exclude: ["InterectNote.xcodeproj", "Assets.xcassets"],
            sources: [
                "InterectNoteApp.swift",
                "Models/Note.swift",
                "Models/CanvasImage.swift",
                "Models/CanvasFile.swift",
                "Models/Viewport.swift",
                "Store/CanvasStore.swift",
                "Views/ContentView.swift",
                "Views/InfiniteCanvasView.swift",
                "Views/StickyNoteView.swift",
                "Views/CanvasImageView.swift",
                "Views/CanvasFileView.swift",
                "Views/SettingsView.swift",
                "Views/Components/ToolbarView.swift",
                "Views/Components/FloatingButtonView.swift",
                "Views/Components/TopBarView.swift"
            ]
        )
    ]
)
