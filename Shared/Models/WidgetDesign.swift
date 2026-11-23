import Foundation

enum WidgetKind: String, CaseIterable, Codable, Identifiable {
    case clock, calendar, photo, quote, countdown, habit
    var id: String { rawValue }

    var title: String {
        switch self {
        case .clock: return "Đồng hồ"
        case .calendar: return "Lịch"
        case .photo: return "Ảnh"
        case .quote: return "Trích dẫn"
        case .countdown: return "Đếm ngược"
        case .habit: return "Thói quen"
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

    func duplicate() -> WidgetDesign {
        var result = self
        result.id = UUID()
        return result
    }

    static func fresh(_ kind: WidgetKind) -> WidgetDesign {
        WidgetDesign(
            name: "Widget \(kind.title)", kind: kind,
            title: kind.title, message: "Một ngày tốt lành!",
            backgroundHex: "#171B31", foregroundHex: "#FFFFFF", accentHex: "#A6B2FF",
            targetDate: kind == .countdown ? Calendar.current.date(byAdding: .day, value: 14, to: Date()) : nil
        )
    }
}
