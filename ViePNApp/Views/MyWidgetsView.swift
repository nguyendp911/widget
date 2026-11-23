import SwiftUI

struct MyWidgetsView: View {
    @EnvironmentObject private var studio: WidgetStudioStore
    @State private var showSettings = false

    var body: some View {
        StudioPage {
            VStack(alignment: .leading, spacing: 18) {
                StudioHeader(overline: "Your collection", title: "Made by you.",
                             subtitle: "Thiết kế cá nhân lưu trên iPhone, chọn từng mẫu để sửa và gắn lên Home Screen.")
                if studio.designs.isEmpty {
                    StudioPanel {
                        VStack(alignment: .leading, spacing: 10) {
                            Image(systemName: "square.stack.3d.up.slash")
                                .font(.largeTitle).foregroundStyle(StudioPalette.mint)
                            Text("Your collection is waiting")
                                .font(.title3.bold()).foregroundStyle(.white)
                            Text("Mở Discover hoặc Magic Canvas để bắt đầu thiết kế đầu tiên.")
                                .font(.subheadline).foregroundStyle(StudioPalette.muted)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                } else {
                    ForEach(studio.designs) { design in
                        HStack(spacing: 12) {
                            NavigationLink {
                                WidgetEditorView(design: design)
                            } label: {
                                HStack(spacing: 13) {
                                    WidgetDesignView(design: design, date: .now, habitCompleted: false)
                                        .frame(width: 112, height: 107)
                                        .clipShape(RoundedRectangle(cornerRadius: 16))
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text(design.name).font(.headline)
                                            .foregroundStyle(.white).lineLimit(2)
                                        Text(design.kind.title).font(.caption)
                                            .foregroundStyle(StudioPalette.muted)
                                        Label("Edit in Canvas", systemImage: "arrow.up.right")
                                            .font(.caption.bold()).foregroundStyle(StudioPalette.mint)
                                    }
                                    Spacer(minLength: 0)
                                }
                            }
                            .buttonStyle(.plain)
                            Button(role: .destructive) { studio.delete(design) } label: {
                                Image(systemName: "trash").font(.caption).foregroundStyle(.red.opacity(0.85))
                            }
                        }
                        .padding(12)
                        .background(StudioPalette.surface, in: RoundedRectangle(cornerRadius: 20))
                    }
                }
                StudioPanel {
                    VStack(alignment: .leading, spacing: 10) {
                        Label("HOW TO ADD A WIDGET", systemImage: "iphone.gen3")
                            .font(.subheadline.bold()).foregroundStyle(StudioPalette.mint)
                        Text("Lưu thiết kế → Nhấn giữ Home Screen → + → ViePN Widget+ → Chọn kích thước → Giữ widget để Edit Widget và chọn thiết kế.")
                            .font(.caption).foregroundStyle(.white.opacity(0.8))
                    }
                }
            }
        }
        .navigationTitle("My Widgets")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { showSettings = true } label: { Image(systemName: "gearshape") }
                    .tint(StudioPalette.mint)
            }
        }
        .sheet(isPresented: $showSettings) {
            NavigationStack { SettingsView() }
        }
    }
}
