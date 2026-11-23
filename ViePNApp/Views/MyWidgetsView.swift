import SwiftUI

struct MyWidgetsView: View {
    @EnvironmentObject private var studio: WidgetStudioStore

    var body: some View {
        Group {
            if studio.designs.isEmpty {
                ContentUnavailableView("Chưa có thiết kế", systemImage: "square.stack", description: Text("Tạo widget trong Studio hoặc chọn mẫu ở Explore."))
            } else {
                List {
                    ForEach(studio.designs) { design in
                        NavigationLink {
                            WidgetEditorView(design: design)
                        } label: {
                            HStack(spacing: 12) {
                                WidgetDesignView(design: design, date: Date(), habitCompleted: false)
                                    .frame(width: 104, height: 104)
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(design.name).font(.headline)
                                    Text(design.kind.title).font(.caption).foregroundStyle(.secondary)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .onDelete { indexSet in
                        let toDelete = indexSet.map { studio.designs[$0] }
                        toDelete.forEach(studio.delete)
                    }
                }
            }
        }
        .navigationTitle("My Widgets")
        .toolbar { if !studio.designs.isEmpty { EditButton() } }
    }
}
