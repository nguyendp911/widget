import SwiftUI
import PhotosUI

struct WidgetEditorView: View {
    @EnvironmentObject private var studio: WidgetStudioStore
    @Environment(\.dismiss) private var dismiss
    @State private var design: WidgetDesign
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var localError: String?

    init(design: WidgetDesign) {
        _design = State(initialValue: design)
    }

    var body: some View {
        Form {
            Section("Xem trước") {
                WidgetDesignView(design: design, date: Date(), habitCompleted: false)
                    .frame(height: 185)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .listRowInsets(EdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12))
            }
            Section("Nội dung") {
                TextField("Tên thiết kế", text: $design.name)
                TextField("Tiêu đề", text: $design.title)
                TextField("Thông điệp", text: $design.message, axis: .vertical)
                    .lineLimit(2...5)
                if design.kind == .countdown {
                    DatePicker("Ngày sự kiện", selection: Binding(
                        get: { design.targetDate ?? Date() },
                        set: { design.targetDate = $0 }
                    ), displayedComponents: [.date, .hourAndMinute])
                }
                if design.kind == .photo {
                    PhotosPicker(selection: $selectedPhoto, matching: .images) {
                        Label("Chọn ảnh từ thư viện", systemImage: "photo.on.rectangle")
                    }
                }
            }
            Section("Thiết kế") {
                colorRow("Nền", keyPath: \.backgroundHex)
                colorRow("Chữ", keyPath: \.foregroundHex)
                colorRow("Điểm nhấn", keyPath: \.accentHex)
                Picker("Font", selection: $design.fontPreset) {
                    ForEach(FontPreset.allCases) { font in
                        Text(font.title).tag(font)
                    }
                }
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("Kích thước chữ")
                        Spacer()
                        Text("\(Int(design.fontScale * 100))%")
                            .foregroundStyle(.secondary)
                    }
                    Slider(value: $design.fontScale, in: 0.7...1.3, step: 0.05)
                }
                Toggle("Viền trang trí", isOn: $design.showBorder)
            }
            Section {
                Button {
                    studio.save(design)
                    if studio.errorMessage == nil { dismiss() }
                } label: {
                    Label("Lưu thiết kế", systemImage: "square.and.arrow.down")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .listRowBackground(Color.clear)
            }
        }
        .navigationTitle("Widget Editor")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: selectedPhoto) { _, photo in
            Task {
                guard let photo, let data = try? await photo.loadTransferable(type: Data.self) else { return }
                do {
                    design.imageFileName = try SharedRepository().saveImage(data)
                } catch {
                    localError = error.localizedDescription
                }
            }
        }
        .alert("Thông báo", isPresented: Binding(
            get: { localError != nil || studio.errorMessage != nil },
            set: { if !$0 { localError = nil; studio.errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) { localError = nil; studio.errorMessage = nil }
        } message: {
            Text(localError ?? studio.errorMessage ?? "")
        }
    }

    private func colorRow(_ label: String, keyPath: WritableKeyPath<WidgetDesign, String>) -> some View {
        ColorPicker(label, selection: Binding(
            get: { Color(hex: design[keyPath: keyPath]) },
            set: { design[keyPath: keyPath] = $0.hexRGB }
        ), supportsOpacity: false)
    }
}
