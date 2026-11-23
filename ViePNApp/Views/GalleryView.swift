import SwiftUI

struct GalleryView: View {
    @State private var selectedKind: WidgetKind? = nil
    private let columns = [GridItem(.flexible(), spacing: 13), GridItem(.flexible(), spacing: 13)]

    private var templates: [WidgetDesign] {
        SampleTemplates.catalog.filter { selectedKind == nil || $0.kind == selectedKind }
    }

    var body: some View {
        StudioPage {
            VStack(alignment: .leading, spacing: 19) {
                StudioHeader(overline: "The gallery", title: "Discover worlds", subtitle: "Bộ sưu tập nghệ thuật, mỗi widget là một câu chuyện.")
                ScrollView(.horizontal) {
                    HStack(spacing: 8) {
                        Button { selectedKind = nil } label: {
                            AccentChip(text: "All worlds", icon: "square.grid.2x2.fill", active: selectedKind == nil)
                        }
                        ForEach(WidgetKind.allCases) { kind in
                            Button { selectedKind = kind } label: {
                                AccentChip(text: kind.title, icon: kind.symbol, active: selectedKind == kind)
                            }
                        }
                    }
                }
                .buttonStyle(.plain).scrollIndicators(.hidden)
                LazyVGrid(columns: columns, spacing: 14) {
                    ForEach(templates) { template in
                        NavigationLink {
                            WidgetEditorView(design: template.duplicate())
                        } label: {
                            VStack(alignment: .leading, spacing: 7) {
                                SceneShowcaseCard(design: template, height: 174)
                                Text(template.name)
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundStyle(.white)
                                Text(template.kind.title.uppercased())
                                    .font(.system(size: 9, weight: .heavy))
                                    .tracking(1.4).foregroundStyle(StudioPalette.muted)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .navigationTitle("Discover")
        .navigationBarTitleDisplayMode(.inline)
    }
}
