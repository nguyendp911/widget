import SwiftUI

struct GalleryView: View {
    @State private var selectedKind: WidgetKind? = nil
    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    private var templates: [WidgetDesign] {
        SampleTemplates.catalog.filter { selectedKind == nil || $0.kind == selectedKind }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 15) {
                Picker("Loại", selection: $selectedKind) {
                    Text("Tất cả").tag(Optional<WidgetKind>.none)
                    ForEach(WidgetKind.allCases) { kind in
                        Text(kind.title).tag(Optional(kind))
                    }
                }
                .pickerStyle(.menu)
                .frame(maxWidth: .infinity, alignment: .leading)

                LazyVGrid(columns: columns, spacing: 15) {
                    ForEach(templates) { template in
                        NavigationLink {
                            WidgetEditorView(design: template.duplicate())
                        } label: {
                            VStack(alignment: .leading, spacing: 6) {
                                WidgetDesignView(design: template, date: Date(), habitCompleted: false)
                                    .frame(height: 160)
                                Text(template.name)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(.primary)
                                Text(template.kind.title)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Explore")
    }
}
