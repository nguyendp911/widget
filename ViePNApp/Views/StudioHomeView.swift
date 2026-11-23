import SwiftUI

struct StudioHomeView: View {
    var body: some View {
        List {
            Section {
                Text("Bắt đầu từ một widget trống, sau đó tùy chỉnh màu, font, văn bản và hình ảnh.")
                    .foregroundStyle(.secondary)
            }
            Section("Tạo widget mới") {
                ForEach(WidgetKind.allCases) { kind in
                    NavigationLink {
                        WidgetEditorView(design: .fresh(kind))
                    } label: {
                        Label(kind.title, systemImage: kind.symbol)
                            .padding(.vertical, 4)
                    }
                }
            }
        }
        .navigationTitle("Widget Studio")
    }
}
