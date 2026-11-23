import SwiftUI

struct DashboardView: View {
    @EnvironmentObject private var studio: WidgetStudioStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Thiết kế iPhone của bạn")
                        .font(.largeTitle.bold())
                    Text("Chọn, chỉnh sửa và lưu widget theo phong cách riêng.")
                        .foregroundStyle(.secondary)
                }

                Text("MẪU NỔI BẬT")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)

                ScrollView(.horizontal) {
                    HStack(spacing: 12) {
                        ForEach(Array(SampleTemplates.catalog.prefix(5))) { template in
                            NavigationLink {
                                WidgetEditorView(design: template.duplicate())
                            } label: {
                                WidgetDesignView(design: template, date: Date(), habitCompleted: false)
                                    .frame(width: 180, height: 172)
                                    .clipShape(RoundedRectangle(cornerRadius: 18))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .scrollIndicators(.hidden)

                Text("Thiết kế đã lưu: \(studio.designs.count)")
                    .font(.headline)
                if studio.designs.isEmpty {
                    ContentUnavailableView("Chưa có widget", systemImage: "square.stack.3d.up", description: Text("Mở Explore hoặc Studio để tạo widget đầu tiên."))
                } else {
                    ForEach(Array(studio.designs.prefix(3))) { design in
                        NavigationLink {
                            WidgetEditorView(design: design)
                        } label: {
                            Label(design.name, systemImage: design.kind.symbol)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(12)
                                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("ViePN Widget+")
    }
}
