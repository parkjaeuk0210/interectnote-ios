import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var store: CanvasStore
    @AppStorage("isDarkMode") private var isDarkMode = false

    var body: some View {
        Form {
            Section("외관") {
                Toggle("다크 모드", isOn: $isDarkMode)
            }

            Section("캔버스") {
                Button("캔버스 비우기") {
                    store.clearCanvas()
                }
                .foregroundColor(.red)

                Button("보기 초기화") {
                    store.resetViewport()
                }
            }

            Section("정보") {
                HStack {
                    Text("버전")
                    Spacer()
                    Text("1.0.0")
                        .foregroundColor(.secondary)
                }

                HStack {
                    Text("노트 개수")
                    Spacer()
                    Text("\(store.notes.count)")
                        .foregroundColor(.secondary)
                }

                HStack {
                    Text("이미지 개수")
                    Spacer()
                    Text("\(store.images.count)")
                        .foregroundColor(.secondary)
                }

                HStack {
                    Text("파일 개수")
                    Spacer()
                    Text("\(store.files.count)")
                        .foregroundColor(.secondary)
                }
            }
        }
        .formStyle(.grouped)
        #if os(macOS)
        .frame(width: 400, height: 300)
        #endif
    }
}

#Preview {
    SettingsView()
        .environmentObject(CanvasStore())
}
