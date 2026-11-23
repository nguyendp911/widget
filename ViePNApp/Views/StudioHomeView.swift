import SwiftUI

struct StudioHomeView: View {
    private let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    var body: some View {
        StudioPage {
            VStack(alignment: .leading, spacing: 20) {
                StudioHeader(overline: "Magic Canvas", title: "Start creating.", subtitle: "Chọn một loại widget và tự tạo thế giới của bạn. Di chuyển từng phần tử trên canvas.")
                StudioPanel {
                    HStack(spacing: 14) {
                        Image(systemName: "hand.draw.fill")
                            .font(.largeTitle).foregroundStyle(StudioPalette.mint)
                        VStack(alignment: .leading, spacing: 5) {
                            Text("MULTI-LAYER EDITOR")
                                .font(.system(size: 11, weight: .heavy)).tracking(1.8)
                                .foregroundStyle(.white)
                            Text("Drag · Resize · Rotate · Layers · Undo")
                                .font(.caption).foregroundStyle(StudioPalette.muted)
                        }
                        Spacer(minLength: 0)
                    }
                }
                Text("CHOOSE YOUR CANVAS")
                    .font(.system(size: 12, weight: .black)).tracking(2)
                    .foregroundStyle(.white)
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(WidgetKind.allCases) { kind in
                        NavigationLink {
                            WidgetEditorView(design: .fresh(kind))
                        } label: {
                            VStack(alignment: .leading, spacing: 13) {
                                Image(systemName: kind.symbol)
                                    .font(.title2).foregroundStyle(StudioPalette.mint)
                                    .frame(width: 46, height: 46)
                                    .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 13))
                                Text(kind.title).font(.headline).foregroundStyle(.white)
                                HStack {
                                    Text("Create new")
                                        .font(.caption).foregroundStyle(StudioPalette.muted)
                                    Spacer()
                                    Image(systemName: "arrow.up.right")
                                        .font(.caption).foregroundStyle(StudioPalette.mint)
                                }
                            }
                            .padding(16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(StudioPalette.surface, in: RoundedRectangle(cornerRadius: 20))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .navigationTitle("Magic Canvas")
        .navigationBarTitleDisplayMode(.inline)
    }
}
