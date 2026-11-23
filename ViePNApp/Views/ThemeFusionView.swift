import SwiftUI
import UniformTypeIdentifiers

/// Coordinated wallpaper + widgets. iOS does not allow third-party apps to
/// directly change the user's Home Screen layout, wallpaper, or app icons.
struct ThemeFusionView: View {
    @EnvironmentObject private var studio: WidgetStudioStore
    @State private var selected: LivingScene = .aurora
    @State private var wallpaperURL: URL?
    @State private var packURL: URL?
    @State private var iconsURL: URL?
    @State private var importingTheme = false
    @State private var confirmation: String?

    private var matching: [WidgetDesign] {
        SampleTemplates.catalog.filter { $0.scene == selected }
    }

    var body: some View {
        StudioPage {
            VStack(alignment: .leading, spacing: 21) {
                StudioHeader(overline: "Theme Fusion", title: "One screen. One mood.",
                             subtitle: "Hình nền và widget đồng bộ hoàn hảo cho màn hình iPhone.")
                ScrollView(.horizontal) {
                    HStack(spacing: 8) {
                        ForEach(LivingScene.allCases) { scene in
                            Button {
                                selected = scene
                                wallpaperURL = nil
                                packURL = nil
                                iconsURL = nil
                            } label: {
                                AccentChip(text: scene.name, icon: scene.icon, active: selected == scene)
                            }
                        }
                    }
                }
                .buttonStyle(.plain).scrollIndicators(.hidden)
                ZStack {
                    RoundedRectangle(cornerRadius: 34)
                        .fill(StudioPalette.surface)
                    VStack(spacing: 10) {
                        Text("THE LOCK SCREEN COLLECTION")
                            .font(.system(size: 10, weight: .black)).tracking(2)
                            .foregroundStyle(StudioPalette.muted)
                        ThemeWallpaperView(scene: selected)
                            .frame(width: 200, height: 373)
                            .clipShape(RoundedRectangle(cornerRadius: 32))
                            .overlay(RoundedRectangle(cornerRadius: 32)
                                .stroke(.white.opacity(0.37), lineWidth: 3))
                            .shadow(color: Color(hex: selected.colors.2).opacity(0.24), radius: 29)
                        Text(selected.name)
                            .font(.title2.bold()).foregroundStyle(.white)
                        Text(selected.subtitle)
                            .font(.caption).foregroundStyle(StudioPalette.muted)
                    }
                    .padding(.vertical, 24)
                }
                .frame(maxWidth: .infinity)
                VStack(alignment: .leading, spacing: 10) {
                    Text("MATCHING WIDGETS")
                        .font(.system(size: 11, weight: .black)).tracking(1.8)
                        .foregroundStyle(.white)
                    ScrollView(.horizontal) {
                        HStack(spacing: 10) {
                            ForEach(matching) { design in
                                NavigationLink {
                                    WidgetEditorView(design: design.duplicate())
                                } label: {
                                    WidgetDesignView(design: design, date: .now, habitCompleted: false)
                                        .frame(width: 165, height: 150)
                                        .clipShape(RoundedRectangle(cornerRadius: 20))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .scrollIndicators(.hidden)
                }
                HStack(spacing: 12) {
                    ForEach([selected.colors.0, selected.colors.1, selected.colors.2], id: \.self) { hex in
                        Circle().fill(Color(hex: hex)).frame(width: 33, height: 33)
                            .overlay(Circle().stroke(.white.opacity(0.28), lineWidth: 1))
                    }
                    Spacer()
                    Text("COORDINATED PALETTE")
                        .font(.system(size: 10, weight: .black)).tracking(1.4)
                        .foregroundStyle(StudioPalette.muted)
                }
                HStack(spacing: 12) {
                    ForEach(["camera.fill", "music.note", "message.fill", "calendar", "heart.fill", "moon.stars.fill"], id: \.self) { symbol in
                        Image(systemName: symbol)
                            .font(.system(size: 17, weight: .medium))
                            .foregroundStyle(Color(hex: selected.colors.1))
                            .frame(maxWidth: .infinity).frame(height: 43)
                            .background(Color(hex: selected.colors.0), in: RoundedRectangle(cornerRadius: 12))
                    }
                }
                StudioPanel {
                    VStack(alignment: .leading, spacing: 13) {
                        Text("YOUR COMPLETE SCREEN KIT")
                            .font(.system(size: 11, weight: .black)).tracking(1.5)
                            .foregroundStyle(StudioPalette.mint)
                        Text("Tải hình nền PNG, lưu mẫu widget phối hợp và xuất cấu hình JSON để chia sẻ.")
                            .font(.caption).foregroundStyle(StudioPalette.muted)
                        Button {
                            exportWallpaper()
                        } label: {
                            Label("Generate Wallpaper PNG", systemImage: "photo.artframe")
                                .frame(maxWidth: .infinity).padding(.vertical, 13)
                                .background(StudioPalette.mint, in: RoundedRectangle(cornerRadius: 13))
                                .foregroundStyle(.black)
                        }
                        if let wallpaperURL {
                            ShareLink(item: wallpaperURL) {
                                Label("Share / Save Wallpaper", systemImage: "square.and.arrow.up")
                                    .frame(maxWidth: .infinity).padding(.vertical, 12)
                                    .background(.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 13))
                            }
                        }
                        Button {
                            matching.map { $0.duplicate() }.forEach(studio.save)
                            confirmation = "Đã lưu \(matching.count) thiết kế vào My Widgets."
                        } label: {
                            Label("Install Matching Widgets", systemImage: "square.stack.3d.up")
                                .frame(maxWidth: .infinity).padding(.vertical, 12)
                                .background(.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 13))
                        }
                        Button { exportIcons() } label: {
                            Label("Generate Icon Sheet PNG", systemImage: "square.grid.3x3.fill")
                                .frame(maxWidth: .infinity).padding(.vertical, 12)
                                .background(.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 13))
                        }
                        if let iconsURL {
                            ShareLink(item: iconsURL) {
                                Label("Share Icon Sheet", systemImage: "square.and.arrow.up")
                                    .frame(maxWidth: .infinity).padding(.vertical, 12)
                                    .foregroundStyle(StudioPalette.mint)
                            }
                        }
                        Button { exportPack() } label: {
                            Label("Export Theme JSON", systemImage: "doc.zipper")
                                .frame(maxWidth: .infinity).padding(.vertical, 12)
                                .background(.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 13))
                        }
                        Button { importingTheme = true } label: {
                            Label("Import Theme JSON", systemImage: "square.and.arrow.down")
                                .frame(maxWidth: .infinity).padding(.vertical, 12)
                                .background(.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 13))
                        }
                        if let packURL {
                            ShareLink(item: packURL) {
                                Label("Share Theme Package", systemImage: "square.and.arrow.up")
                                    .frame(maxWidth: .infinity).padding(.vertical, 12)
                                    .foregroundStyle(StudioPalette.mint)
                            }
                        }
                    }
                    .foregroundStyle(.white)
                }
                Text("iOS yêu cầu bạn tự đặt wallpaper và thêm widget từ Home Screen; ứng dụng không thể tự sắp xếp icon hoặc thay đổi wallpaper hệ thống.")
                    .font(.caption).foregroundStyle(StudioPalette.muted)
            }
        }
        .navigationTitle("Theme Fusion")
        .navigationBarTitleDisplayMode(.inline)
        .fileImporter(isPresented: $importingTheme, allowedContentTypes: [.json]) { result in
            do {
                let url = try result.get()
                guard url.startAccessingSecurityScopedResource() else {
                    confirmation = "Không thể đọc tệp theme đã chọn."
                    return
                }
                defer { url.stopAccessingSecurityScopedResource() }
                let pack = try JSONDecoder().decode(ThemePackage.self, from: Data(contentsOf: url))
                guard pack.version == 2, pack.designs.count <= 150 else {
                    confirmation = "Phiên bản theme chưa hỗ trợ hoặc gói quá lớn."
                    return
                }
                pack.designs.map { $0.duplicate() }.forEach(studio.save)
                selected = pack.scene
                confirmation = "Đã nhập \(pack.designs.count) mẫu widget từ theme."
            } catch {
                confirmation = "Không nhập được theme: \(error.localizedDescription)"
            }
        }
        .alert("Theme Fusion", isPresented: Binding(
            get: { confirmation != nil }, set: { if !$0 { confirmation = nil } }
        )) { Button("OK") { confirmation = nil } } message: { Text(confirmation ?? "") }
    }

    @MainActor
    private func exportWallpaper() {
        let renderer = ImageRenderer(content:
            ThemeWallpaperView(scene: selected).frame(width: 390, height: 844))
        renderer.scale = 3
        guard let data = renderer.uiImage?.pngData() else {
            confirmation = "Không thể tạo hình nền trên thiết bị này."
            return
        }
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("ViePN-\(selected.rawValue)-wallpaper.png")
        do { try data.write(to: url, options: .atomic); wallpaperURL = url }
        catch { confirmation = "Không xuất được hình nền: \(error.localizedDescription)" }
    }

    @MainActor
    private func exportIcons() {
        let renderer = ImageRenderer(content: ThemeIconSheet(scene: selected).frame(width: 720, height: 540))
        renderer.scale = 2
        guard let data = renderer.uiImage?.pngData() else {
            confirmation = "Không thể xuất icon sheet."
            return
        }
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("ViePN-\(selected.rawValue)-icons.png")
        do { try data.write(to: url, options: .atomic); iconsURL = url }
        catch { confirmation = "Không xuất được icon: \(error.localizedDescription)" }
    }

    private func exportPack() {
        let pack = ThemePackage(version: 2, scene: selected, designs: matching)
        do {
            let data = try JSONEncoder().encode(pack)
            let url = FileManager.default.temporaryDirectory.appendingPathComponent("ViePN-\(selected.rawValue)-theme.json")
            try data.write(to: url, options: .atomic)
            packURL = url
        } catch { confirmation = "Không xuất được theme: \(error.localizedDescription)" }
    }
}

private struct ThemePackage: Codable {
    let version: Int
    let scene: LivingScene
    let designs: [WidgetDesign]
}

struct ThemeWallpaperView: View {
    let scene: LivingScene
    var body: some View {
        ZStack {
            LivingSceneView(scene: scene, date: .now)
            LinearGradient(colors: [.black.opacity(0.13), .clear, .black.opacity(0.20)],
                           startPoint: .top, endPoint: .bottom)
        }
        .clipped()
    }
}


struct ThemeIconSheet: View {
    let scene: LivingScene
    private let icons = ["camera.fill", "music.note", "message.fill", "calendar", "heart.fill", "moon.stars.fill", "phone.fill", "envelope.fill", "photo.fill", "clock.fill", "safari.fill", "gearshape.fill"]
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 20), count: 4)
    var body: some View {
        LazyVGrid(columns: columns, spacing: 20) {
            ForEach(icons, id: \.self) { icon in
                ZStack {
                    RoundedRectangle(cornerRadius: 30).fill(Color(hex: scene.colors.0))
                    RoundedRectangle(cornerRadius: 30)
                        .strokeBorder(Color(hex: scene.colors.2).opacity(0.6), lineWidth: 3)
                    Image(systemName: icon)
                        .font(.system(size: 52, weight: .light))
                        .foregroundStyle(Color(hex: scene.colors.1))
                }
                .frame(width: 155, height: 155)
            }
        }
        .padding(20)
        .background(StudioPalette.background)
    }
}
