import Foundation

enum CanvasElementKind: String, CaseIterable, Codable, Identifiable {
    case text, clock, date, icon, image, shape
    var id: String { rawValue }
    var title: String {
        switch self {
        case .text: return "Văn bản"
        case .clock: return "Đồng hồ"
        case .date: return "Ngày tháng"
        case .icon: return "Biểu tượng"
        case .image: return "Ảnh"
        case .shape: return "Hình khối"
        }
    }
    var symbol: String {
        switch self {
        case .text: return "textformat"
        case .clock: return "clock"
        case .date: return "calendar"
        case .icon: return "sparkle"
        case .image: return "photo"
        case .shape: return "circle.hexagongrid"
        }
    }
}

/// Normalized placement: (0,0) top-left, (1,1) bottom-right. The same model is
/// rendered in the app preview and WidgetKit, independent of widget family.
struct CanvasLayer: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var kind: CanvasElementKind
    var text: String
    var x: Double
    var y: Double
    var scale: Double = 1
    var rotation: Double = 0
    var opacity: Double = 1
    var colorHex: String = "#FFFFFF"
    var symbol: String = "sparkles"
    var hidden: Bool = false

    static func make(_ kind: CanvasElementKind, foreground: String = "#FFFFFF") -> CanvasLayer {
        let content: String
        switch kind {
        case .text: content = "Your universe. Your rules."
        case .clock: content = ""
        case .date: content = ""
        case .icon: content = ""
        case .image: content = ""
        case .shape: content = ""
        }
        return CanvasLayer(kind: kind, text: content, x: 0.5, y: 0.5, colorHex: foreground)
    }
}

enum LivingScene: String, CaseIterable, Identifiable, Codable {
    case aurora, cosmos, zen, neon, dream, noir
    var id: String { rawValue }
    var name: String {
        switch self {
        case .aurora: return "Aurora Drift"
        case .cosmos: return "Cosmic Dust"
        case .zen: return "Zen Horizon"
        case .neon: return "Neon City"
        case .dream: return "Dreamscape"
        case .noir: return "Noir Glass"
        }
    }
    var subtitle: String {
        switch self {
        case .aurora: return "Ánh sáng phương Bắc"
        case .cosmos: return "Giữa các vì sao"
        case .zen: return "Bình yên mỗi ngày"
        case .neon: return "Đêm thành phố"
        case .dream: return "Những giấc mơ"
        case .noir: return "Tối giản sang trọng"
        }
    }
    var colors: (String, String, String) {
        switch self {
        case .aurora: return ("#071B35", "#F3FCFF", "#56EDDC")
        case .cosmos: return ("#180F3C", "#F9F3FF", "#CC91FF")
        case .zen: return ("#203A37", "#FFF8E4", "#F6C78A")
        case .neon: return ("#150F2B", "#FFFFFF", "#FB63D5")
        case .dream: return ("#403059", "#FFFFFF", "#FFD0DB")
        case .noir: return ("#11131D", "#FFFFFF", "#C6D0E8")
        }
    }
    var icon: String {
        switch self {
        case .aurora: return "wind"
        case .cosmos: return "moon.stars.fill"
        case .zen: return "sun.horizon.fill"
        case .neon: return "building.2.fill"
        case .dream: return "cloud.moon.fill"
        case .noir: return "circle.hexagongrid.fill"
        }
    }
}
