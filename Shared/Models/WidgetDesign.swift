import Foundation

enum WidgetKind: String, CaseIterable, Codable, Identifiable {
    case clock, calendar, photo, quote, countdown, habit, smart, memory
    var id: String { rawValue }

    var title: String {
        switch self {
        case .clock: return "Đồng hồ"
        case .calendar: return "Lịch"
        case .photo: return "Ảnh"
        case .quote: return "Trích dẫn"
        case .countdown: return "Đếm ngược"
        case .habit: return "Thói quen"
        case .smart: return "Daily Command"
        case .memory: return "Memory Timeline"
        }
    }

    var symbol: String {
        switch self {
        case .clock: return "clock"
        case .calendar: return "calendar"
        case .photo: return "photo"
        case .quote: return "quote.opening"
        case .countdown: return "hourglass"
        case .habit: return "checkmark.seal"
        case .smart: return "sparkles.rectangle.stack"
        case .memory: return "heart.text.square"
        }
    }
}

enum FontPreset: String, Codable, CaseIterable, Identifiable {
    case rounded, system, serif, monospaced
    var id: String { rawValue }
    var title: String {
        switch self {
        case .rounded: return "Rounded"
        case .system: return "System"
        case .serif: return "Serif"
        case .monospaced: return "Mono"
        }
    }
}

/// Codable is explicit to migrate v0.1 saved designs that did not have scenes/layers.
struct WidgetDesign: Codable, Identifiable, Equatable {
    var id: UUID = UUID()
    var name: String
    var kind: WidgetKind
    var title: String
    var message: String
    var backgroundHex: String
    var foregroundHex: String
    var accentHex: String
    var fontPreset: FontPreset = .rounded
    var fontScale: Double = 1.0
    var showBorder: Bool = false
    var targetDate: Date? = nil
    var imageFileName: String? = nil
    var scene: LivingScene? = nil
    var layers: [CanvasLayer] = []
    var smartGoals: [String] = ["Việc quan trọng nhất", "15 phút cho bản thân", "Một điều biết ơn"]

    enum CodingKeys: String, CodingKey {
        case id, name, kind, title, message, backgroundHex, foregroundHex, accentHex
        case fontPreset, fontScale, showBorder, targetDate, imageFileName, scene, layers, smartGoals
    }

    init(name: String, kind: WidgetKind, title: String, message: String,
         backgroundHex: String, foregroundHex: String, accentHex: String,
         fontPreset: FontPreset = .rounded, fontScale: Double = 1,
         showBorder: Bool = false, targetDate: Date? = nil, imageFileName: String? = nil,
         scene: LivingScene? = nil, layers: [CanvasLayer] = [],
         smartGoals: [String] = ["Việc quan trọng nhất", "15 phút cho bản thân", "Một điều biết ơn"]) {
        self.name = name; self.kind = kind; self.title = title; self.message = message
        self.backgroundHex = backgroundHex; self.foregroundHex = foregroundHex
        self.accentHex = accentHex; self.fontPreset = fontPreset; self.fontScale = fontScale
        self.showBorder = showBorder; self.targetDate = targetDate; self.imageFileName = imageFileName
        self.scene = scene; self.layers = layers; self.smartGoals = smartGoals
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        name = try c.decode(String.self, forKey: .name)
        kind = try c.decode(WidgetKind.self, forKey: .kind)
        title = try c.decode(String.self, forKey: .title)
        message = try c.decode(String.self, forKey: .message)
        backgroundHex = try c.decode(String.self, forKey: .backgroundHex)
        foregroundHex = try c.decode(String.self, forKey: .foregroundHex)
        accentHex = try c.decode(String.self, forKey: .accentHex)
        fontPreset = try c.decodeIfPresent(FontPreset.self, forKey: .fontPreset) ?? .rounded
        fontScale = try c.decodeIfPresent(Double.self, forKey: .fontScale) ?? 1
        showBorder = try c.decodeIfPresent(Bool.self, forKey: .showBorder) ?? false
        targetDate = try c.decodeIfPresent(Date.self, forKey: .targetDate)
        imageFileName = try c.decodeIfPresent(String.self, forKey: .imageFileName)
        scene = try c.decodeIfPresent(LivingScene.self, forKey: .scene)
        layers = try c.decodeIfPresent([CanvasLayer].self, forKey: .layers) ?? []
        smartGoals = try c.decodeIfPresent([String].self, forKey: .smartGoals) ?? ["Việc quan trọng nhất", "15 phút cho bản thân", "Một điều biết ơn"]
    }

    func duplicate() -> WidgetDesign {
        var result = self
        result.id = UUID()
        result.layers = result.layers.map { layer in
            var copy = layer; copy.id = UUID(); return copy
        }
        return result
    }

    static func fresh(_ kind: WidgetKind, scene: LivingScene = .aurora) -> WidgetDesign {
        let (background, foreground, accent) = scene.colors
        return WidgetDesign(name: "My \(kind.title)", kind: kind,
            title: kind.title, message: "Một ngày đáng nhớ!", backgroundHex: background,
            foregroundHex: foreground, accentHex: accent, fontPreset: .rounded,
            targetDate: (kind == .countdown || kind == .memory)
                ? Calendar.current.date(byAdding: .day, value: 14, to: Date()) : nil,
            scene: scene)
    }
}
