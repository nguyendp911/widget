import SwiftUI
import PhotosUI

private enum EditorTool: String, CaseIterable, Identifiable {
    case layers = "Layers", style = "Style", scene = "Scenes", content = "Content"
    var id: String { rawValue }
}

private enum CanvasPreviewSize: String, CaseIterable, Identifiable {
    case small = "Small", medium = "Medium", large = "Large"
    var id: String { rawValue }
    var dimensions: CGSize {
        switch self {
        case .small: return CGSize(width: 180, height: 180)
        case .medium: return CGSize(width: 310, height: 172)
        case .large: return CGSize(width: 285, height: 305)
        }
    }
}

struct WidgetEditorView: View {
    @EnvironmentObject private var studio: WidgetStudioStore
    @Environment(\.dismiss) private var dismiss
    @State private var design: WidgetDesign
    @State private var tool: EditorTool = .layers
    @State private var previewSize: CanvasPreviewSize = .medium
    @State private var selectedLayerID: UUID?
    @State private var undoHistory: [WidgetDesign] = []
    @State private var redoHistory: [WidgetDesign] = []
    @State private var dragOrigin: CGPoint?
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var localError: String?
    @State private var showSaved = false

    init(design: WidgetDesign) { _design = State(initialValue: design) }

    private var selectedIndex: Int? {
        design.layers.firstIndex(where: { $0.id == selectedLayerID })
    }

    var body: some View {
        StudioPage {
            VStack(alignment: .leading, spacing: 20) {
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("THE MAGIC CANVAS").font(.system(size: 10, weight: .black))
                            .tracking(2).foregroundStyle(StudioPalette.mint)
                        Text(design.name).font(.system(size: 25, weight: .bold, design: .rounded))
                            .foregroundStyle(.white).lineLimit(1)
                    }
                    Spacer(minLength: 8)
                    Button { undo() } label: { Image(systemName: "arrow.uturn.backward") }
                        .disabled(undoHistory.isEmpty)
                    Button { redo() } label: { Image(systemName: "arrow.uturn.forward") }
                        .disabled(redoHistory.isEmpty)
                    Button { save() } label: {
                        Image(systemName: "checkmark")
                            .font(.headline)
                            .foregroundStyle(.black)
                            .frame(width: 36, height: 36)
                            .background(StudioPalette.mint, in: Circle())
                    }
                }
                .buttonStyle(.plain).foregroundStyle(.white)

                Picker("Preview", selection: $previewSize) {
                    ForEach(CanvasPreviewSize.allCases) { size in Text(size.rawValue).tag(size) }
                }
                .pickerStyle(.segmented)

                VStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 31).fill(.white.opacity(0.035))
                        canvas
                            .frame(width: previewSize.dimensions.width,
                                   height: previewSize.dimensions.height)
                            .shadow(color: design.accentColor.opacity(0.21), radius: 25, y: 10)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: max(previewSize.dimensions.height + 25, 210))
                    Text(selectedLayerID == nil
                         ? "Chạm phần tử để chọn · Kéo để di chuyển"
                         : "Đang chọn layer · Kéo để thay đổi vị trí")
                        .font(.caption).foregroundStyle(StudioPalette.muted)
                }
                StudioPanel {
                    HStack {
                        Label("\(design.layers.count) LAYERS", systemImage: "square.3.layers.3d")
                            .font(.system(size: 11, weight: .heavy)).tracking(1.2)
                        Spacer()
                        Text("\(design.scene?.name ?? "Solid Color")")
                            .font(.caption).foregroundStyle(StudioPalette.muted)
                    }
                    .foregroundStyle(.white)
                }
                Picker("Editor", selection: $tool) {
                    ForEach(EditorTool.allCases) { item in Text(item.rawValue).tag(item) }
                }
                .pickerStyle(.segmented)

                switch tool {
                case .layers: layerTools
                case .style: styleTools
                case .scene: sceneTools
                case .content: contentTools
                }
                Button { save() } label: {
                    Label("Save to My Widgets", systemImage: "square.and.arrow.down.fill")
                        .font(.headline).frame(maxWidth: .infinity).padding(.vertical, 15)
                        .foregroundStyle(.black)
                        .background(StudioPalette.mint, in: RoundedRectangle(cornerRadius: 17))
                }
            }
        }
        .navigationTitle("Magic Canvas")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: selectedPhoto) { _, photo in
            Task {
                guard let photo, let data = try? await photo.loadTransferable(type: Data.self) else { return }
                do {
                    let name = try SharedRepository().saveImage(data)
                    apply { $0.imageFileName = name }
                } catch { localError = error.localizedDescription }
            }
        }
        .alert("Thông báo", isPresented: Binding(
            get: { localError != nil || studio.errorMessage != nil || showSaved },
            set: { if !$0 { localError = nil; studio.errorMessage = nil; showSaved = false } }
        )) {
            Button("OK") { localError = nil; studio.errorMessage = nil; showSaved = false }
        } message: {
            Text(localError ?? studio.errorMessage ?? "Thiết kế đã được lưu vào My Widgets.")
        }
    }

    private var canvas: some View {
        WidgetDesignView(design: design, date: .now, habitCompleted: false)
            .overlay {
                GeometryReader { geo in
                    ForEach(design.layers) { layer in
                        if !layer.hidden {
                            RoundedRectangle(cornerRadius: 9)
                                .stroke(selectedLayerID == layer.id ? StudioPalette.mint : .clear, lineWidth: 2)
                                .background(Color.white.opacity(0.001))
                                .frame(width: 90, height: 56)
                                .overlay(alignment: .topTrailing) {
                                    if selectedLayerID == layer.id {
                                        Image(systemName: "arrow.up.left.and.arrow.down.right")
                                            .font(.system(size: 9)).padding(4)
                                            .foregroundStyle(.black)
                                            .background(StudioPalette.mint, in: Circle())
                                            .offset(x: 6, y: -6)
                                    }
                                }
                                .position(x: geo.size.width * layer.x, y: geo.size.height * layer.y)
                                .onTapGesture { selectedLayerID = layer.id }
                                .gesture(
                                    DragGesture(minimumDistance: 3)
                                        .onChanged { value in
                                            guard let index = design.layers.firstIndex(where: { $0.id == layer.id }) else { return }
                                            if dragOrigin == nil {
                                                remember()
                                                dragOrigin = CGPoint(x: design.layers[index].x, y: design.layers[index].y)
                                            }
                                            selectedLayerID = layer.id
                                            if let origin = dragOrigin {
                                                design.layers[index].x = min(0.92, max(0.08, origin.x + value.translation.width / geo.size.width))
                                                design.layers[index].y = min(0.92, max(0.08, origin.y + value.translation.height / geo.size.height))
                                            }
                                        }
                                        .onEnded { _ in dragOrigin = nil }
                                )
                        }
                    }
                }
            }
            .coordinateSpace(name: "magicCanvas")
    }

    private var layerTools: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("ADD AN ELEMENT")
                .font(.system(size: 11, weight: .heavy)).tracking(1.5).foregroundStyle(StudioPalette.muted)
            ScrollView(.horizontal) {
                HStack(spacing: 8) {
                    ForEach(CanvasElementKind.allCases) { kind in
                        Button { addLayer(kind) } label: {
                            VStack(spacing: 8) {
                                Image(systemName: kind.symbol).font(.title3)
                                Text(kind.title).font(.system(size: 10, weight: .medium))
                            }
                            .frame(width: 75, height: 65)
                            .foregroundStyle(.white)
                            .background(StudioPalette.surface, in: RoundedRectangle(cornerRadius: 14))
                        }
                    }
                }
            }
            .scrollIndicators(.hidden)
            ForEach(Array(design.layers.reversed())) { layer in
                HStack(spacing: 11) {
                    Image(systemName: layer.kind.symbol)
                        .foregroundStyle(StudioPalette.mint).frame(width: 24)
                    VStack(alignment: .leading, spacing: 3) {
                        Text(layer.kind.title).font(.subheadline.bold()).foregroundStyle(.white)
                        Text(layer.text.isEmpty ? "Drag, resize and customize" : layer.text)
                            .font(.caption).foregroundStyle(StudioPalette.muted).lineLimit(1)
                    }
                    Spacer(minLength: 6)
                    Button {
                        apply { item in
                            if let i = item.layers.firstIndex(where: { $0.id == layer.id }) { item.layers[i].hidden.toggle() }
                        }
                    } label: { Image(systemName: layer.hidden ? "eye.slash" : "eye") }
                    Button {
                        apply { item in item.layers.removeAll(where: { $0.id == layer.id }) }
                        if selectedLayerID == layer.id { selectedLayerID = nil }
                    } label: { Image(systemName: "trash") }
                }
                .padding(13)
                .background(selectedLayerID == layer.id ? StudioPalette.highlight.opacity(0.3) : StudioPalette.surface,
                            in: RoundedRectangle(cornerRadius: 15))
                .contentShape(RoundedRectangle(cornerRadius: 15))
                .onTapGesture { selectedLayerID = layer.id }
                .buttonStyle(.plain)
                .foregroundStyle(.white)
            }
            if let index = selectedIndex {
                selectedLayerEditor(index: index)
            }
        }
    }

    private func selectedLayerEditor(index: Int) -> some View {
        StudioPanel {
            VStack(alignment: .leading, spacing: 14) {
                Text("INSPECTOR").font(.system(size: 11, weight: .heavy)).tracking(1.5)
                    .foregroundStyle(StudioPalette.mint)
                if design.layers[index].kind == .text {
                    TextField("Layer text", text: Binding(
                        get: { selectedIndex.map { design.layers[$0].text } ?? "" },
                        set: { text in editSelected { $0.text = text } }
                    ), axis: .vertical)
                    .lineLimit(1...4).textFieldStyle(.roundedBorder)
                }
                if design.layers[index].kind == .icon {
                    TextField("SF Symbol name", text: Binding(
                        get: { selectedIndex.map { design.layers[$0].symbol } ?? "sparkles" },
                        set: { text in editSelected { $0.symbol = text } }
                    ))
                    .textFieldStyle(.roundedBorder)
                }
                slider("Scale", value: design.layers[index].scale, range: 0.3...2.5) { val in
                    editSelected { $0.scale = val }
                }
                slider("Rotate", value: design.layers[index].rotation, range: -180...180) { val in
                    editSelected { $0.rotation = val }
                }
                slider("Opacity", value: design.layers[index].opacity, range: 0.1...1) { val in
                    editSelected { $0.opacity = val }
                }
                ColorPicker("Layer color", selection: Binding(
                    get: { Color(hex: selectedIndex.map { design.layers[$0].colorHex } ?? "#FFFFFF") },
                    set: { val in editSelected { $0.colorHex = val.hexRGB } }
                ), supportsOpacity: false)
                HStack {
                    Button("Move forward") { reorderSelected(by: 1) }
                    Spacer()
                    Button("Move back") { reorderSelected(by: -1) }
                }
                .font(.caption.bold()).foregroundStyle(StudioPalette.mint)
            }
            .foregroundStyle(.white)
        }
    }

    private var styleTools: some View {
        StudioPanel {
            VStack(alignment: .leading, spacing: 14) {
                Text("TYPE & COLORS").font(.system(size: 11, weight: .heavy)).tracking(1.5)
                    .foregroundStyle(StudioPalette.mint)
                pickerColor("Background", keyPath: \.backgroundHex)
                pickerColor("Text", keyPath: \.foregroundHex)
                pickerColor("Accent", keyPath: \.accentHex)
                Picker("Typography", selection: Binding(
                    get: { design.fontPreset }, set: { value in apply { $0.fontPreset = value } }
                )) {
                    ForEach(FontPreset.allCases) { font in Text(font.title).tag(font) }
                }
                .tint(StudioPalette.mint)
                slider("Font size", value: design.fontScale, range: 0.6...1.7) { val in
                    apply { $0.fontScale = val }
                }
                Toggle("Decorative border", isOn: Binding(
                    get: { design.showBorder }, set: { val in apply { $0.showBorder = val } }
                ))
                .tint(StudioPalette.mint)
            }
            .foregroundStyle(.white)
        }
    }

    private var sceneTools: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("LIVING SCENES · CHANGES WITH TIME OF DAY")
                .font(.system(size: 11, weight: .heavy)).tracking(1.4)
                .foregroundStyle(StudioPalette.muted)
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(LivingScene.allCases) { scene in
                    Button {
                        apply { item in
                            item.scene = scene
                            let colors = scene.colors
                            item.backgroundHex = colors.0
                            item.foregroundHex = colors.1
                            item.accentHex = colors.2
                        }
                    } label: {
                        ZStack(alignment: .bottomLeading) {
                            LivingSceneView(scene: scene, date: .now)
                            Text(scene.name).font(.caption.bold()).foregroundStyle(.white).padding(11)
                        }
                        .frame(height: 120)
                        .clipShape(RoundedRectangle(cornerRadius: 17))
                        .overlay(RoundedRectangle(cornerRadius: 17)
                            .stroke(design.scene == scene ? StudioPalette.mint : .clear, lineWidth: 3))
                    }
                    .buttonStyle(.plain)
                }
            }
            Button("Use solid color instead") { apply { $0.scene = nil } }
                .foregroundStyle(StudioPalette.mint).font(.subheadline)
        }
    }

    private var contentTools: some View {
        StudioPanel {
            VStack(alignment: .leading, spacing: 15) {
                Text("CONTENT & DATA")
                    .font(.system(size: 11, weight: .heavy)).tracking(1.5)
                    .foregroundStyle(StudioPalette.mint)
                TextField("Design name", text: Binding(
                    get: { design.name }, set: { val in apply { $0.name = val } }
                )).textFieldStyle(.roundedBorder)
                TextField("Caption / title", text: Binding(
                    get: { design.title }, set: { val in apply { $0.title = val } }
                )).textFieldStyle(.roundedBorder)
                TextField("Message", text: Binding(
                    get: { design.message }, set: { val in apply { $0.message = val } }
                ), axis: .vertical).textFieldStyle(.roundedBorder).lineLimit(2...4)
                if design.kind == .smart {
                    TextField("Daily goals (one per line)", text: Binding(
                        get: { design.smartGoals.joined(separator: "\n") },
                        set: { val in apply { $0.smartGoals = val.components(separatedBy: "\n").filter { !$0.isEmpty } } }
                    ), axis: .vertical).textFieldStyle(.roundedBorder).lineLimit(3...6)
                }
                if design.kind == .memory || design.kind == .countdown {
                    DatePicker("Significant date", selection: Binding(
                        get: { design.targetDate ?? .now },
                        set: { val in apply { $0.targetDate = val } }
                    ), displayedComponents: [.date])
                    .tint(StudioPalette.mint)
                }
                PhotosPicker(selection: $selectedPhoto, matching: .images) {
                    Label("Import a photo", systemImage: "photo.on.rectangle.angled")
                        .font(.subheadline.bold())
                        .foregroundStyle(StudioPalette.mint)
                }
                Text("Tất cả thiết kế lưu trên thiết bị qua App Groups; ảnh không được tải lên máy chủ.")
                    .font(.caption).foregroundStyle(StudioPalette.muted)
            }
            .foregroundStyle(.white)
        }
    }

    private func slider(_ title: String, value: Double, range: ClosedRange<Double>,
                        onChange: @escaping (Double) -> Void) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text(title).font(.caption).foregroundStyle(.white)
                Spacer()
                Text(String(format: "%.1f", value)).font(.caption.monospacedDigit())
                    .foregroundStyle(StudioPalette.muted)
            }
            Slider(value: Binding(get: { value }, set: onChange), in: range)
                .tint(StudioPalette.mint)
        }
    }

    private func pickerColor(_ title: String, keyPath: WritableKeyPath<WidgetDesign, String>) -> some View {
        ColorPicker(title, selection: Binding(
            get: { Color(hex: design[keyPath: keyPath]) },
            set: { color in apply { $0[keyPath: keyPath] = color.hexRGB } }
        ), supportsOpacity: false)
    }

    private func addLayer(_ kind: CanvasElementKind) {
        var layer = CanvasLayer.make(kind, foreground: design.foregroundHex)
        if kind == .text { layer.text = "Your story starts here" }
        apply { $0.layers.append(layer) }
        selectedLayerID = layer.id
    }

    private func editSelected(_ mutate: (inout CanvasLayer) -> Void) {
        guard let index = selectedIndex else { return }
        apply { mutate(&$0.layers[index]) }
    }

    private func reorderSelected(by direction: Int) {
        guard let index = selectedIndex else { return }
        let next = index + direction
        guard design.layers.indices.contains(next) else { return }
        apply { $0.layers.swapAt(index, next) }
    }

    private func remember() {
        undoHistory.append(design)
        if undoHistory.count > 35 { undoHistory.removeFirst() }
        redoHistory.removeAll()
    }

    private func apply(_ edit: (inout WidgetDesign) -> Void) {
        var newDesign = design
        edit(&newDesign)
        guard newDesign != design else { return }
        remember()
        design = newDesign
    }

    private func undo() {
        guard let previous = undoHistory.popLast() else { return }
        redoHistory.append(design); design = previous
    }

    private func redo() {
        guard let next = redoHistory.popLast() else { return }
        undoHistory.append(design); design = next
    }

    private func save() {
        studio.save(design)
        if studio.errorMessage == nil { showSaved = true }
    }
}
