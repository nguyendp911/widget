import Foundation

/// Visual language: minimal modern + quiet Vietnamese heritage.
/// Keep the legacy cases so stored v1 appearance data can still decode.
enum LunarTheme: String, CaseIterable, Codable, Identifiable {
    case zen, heritage, luxury, tet, midAutumn
    case jade, gold, ink, lotus
    var id: String { rawValue }
    static var featured: [LunarTheme] { [.zen, .heritage, .luxury, .tet, .midAutumn] }
    var title: String {
        switch self {
        case .zen: return "Minimal Zen"
        case .heritage: return "Vietnamese Heritage"
        case .luxury: return "Luxury Dark"
        case .tet: return "Tết Edition"
        case .midAutumn: return "Mid-Autumn"
        case .jade: return "Ngọc bích (cũ)"
        case .gold: return "Vàng ấm (cũ)"
        case .ink: return "Mực tàu (cũ)"
        case .lotus: return "Sen hồng (cũ)"
        }
    }
    var background: String {
        switch self {
        case .zen: return "#F5F2E9"
        case .heritage: return "#EFE3CD"
        case .luxury: return "#111C22"
        case .tet: return "#F6EBDD"
        case .midAutumn: return "#1C2838"
        case .jade: return "#082C2B"
        case .gold: return "#3A2715"
        case .ink: return "#111828"
        case .lotus: return "#381B30"
        }
    }
    var foreground: String {
        switch self {
        case .zen: return "#242D2B"
        case .heritage: return "#44382C"
        case .tet: return "#493126"
        default: return "#FFF9ED"
        }
    }
    var accent: String {
        switch self {
        case .zen: return "#5D756D"
        case .heritage: return "#A34D3D"
        case .luxury: return "#CBB68C"
        case .tet: return "#AF3E37"
        case .midAutumn: return "#D9B57A"
        case .jade: return "#7CE6CB"
        case .gold: return "#FFCE78"
        case .ink: return "#AEC8FF"
        case .lotus: return "#FFA6C6"
        }
    }
    var muted: String {
        switch self {
        case .zen: return "#68726C"
        case .heritage: return "#7D7163"
        case .tet: return "#786358"
        default: return "#B5B7B1"
        }
    }
    var secondaryBackground: String {
        switch self {
        case .zen: return "#FFFFFF"
        case .heritage: return "#F8F0E0"
        case .luxury: return "#1C2A30"
        case .tet: return "#FFF9EF"
        case .midAutumn: return "#2A3546"
        default: return background
        }
    }
    var usesLightSurface: Bool { self == .zen || self == .heritage || self == .tet }
}

/// Choice of art cut from the user's original Vietnamese heritage sprite sheet.
/// `automatic` follows the selected theme; `none` provides the original minimal look.
enum LunarArtwork: String, Codable, CaseIterable, Identifiable {
    case automatic, none, spring, drum, lotus, moon, temple, chrysanthemum
    var id: String { rawValue }
    var title: String {
        switch self {
        case .automatic: return "Tự động"
        case .none: return "Không ảnh"
        case .spring: return "Xuân Việt"
        case .drum: return "Trống đồng"
        case .lotus: return "Sen xanh"
        case .moon: return "Trăng tre"
        case .temple: return "Cổng làng"
        case .chrysanthemum: return "Cúc vàng"
        }
    }
    var resourceName: String? {
        switch self {
        case .automatic, .none: return nil
        case .spring: return "HeritageSpring"
        case .drum: return "HeritageDrumPanel"
        case .lotus: return "HeritageLotusPanel"
        case .moon: return "HeritageMoonPanel"
        case .temple: return "HeritageTemplePanel"
        case .chrysanthemum: return "HeritageChrysanthemumPanel"
        }
    }
    func resolvedResource(theme: LunarTheme) -> String? {
        switch self {
        case .none: return nil
        case .automatic:
            switch theme {
            case .zen: return "HeritageSpring"
            case .heritage: return "HeritageTemplePanel"
            case .tet: return "HeritageSpring"
            case .midAutumn: return "HeritageMoonPanel"
            case .luxury: return "HeritageDrumPanel"
            case .jade: return "HeritageLotusPanel"
            case .gold: return "HeritageChrysanthemumPanel"
            case .ink: return "HeritageMoonPanel"
            case .lotus: return "HeritageLotusPanel"
            }
        default: return resourceName
        }
    }
}

enum LunarInformationDensity: String, Codable, CaseIterable, Identifiable {
    case essential, balanced, detailed
    var id: String { rawValue }
    var label: String {
        switch self {
        case .essential: return "Tối giản"
        case .balanced: return "Cân bằng"
        case .detailed: return "Chi tiết"
        }
    }
}

struct LunarAppearance: Codable, Equatable {
    var theme: LunarTheme = .heritage
    var useSerif: Bool = false
    var showCanChi: Bool = true
    var showFamilyEvents: Bool = true
    var density: LunarInformationDensity = .balanced
    var showOrnament: Bool = true
    var artwork: LunarArtwork = .automatic
    var remindMoonDays: Bool = false

    enum CodingKeys: String, CodingKey { case theme, useSerif, showCanChi, showFamilyEvents, density, showOrnament, remindMoonDays, artwork }
    init() {}
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        theme = try c.decodeIfPresent(LunarTheme.self, forKey: .theme) ?? .heritage
        useSerif = try c.decodeIfPresent(Bool.self, forKey: .useSerif) ?? false
        showCanChi = try c.decodeIfPresent(Bool.self, forKey: .showCanChi) ?? true
        showFamilyEvents = try c.decodeIfPresent(Bool.self, forKey: .showFamilyEvents) ?? true
        density = try c.decodeIfPresent(LunarInformationDensity.self, forKey: .density) ?? .balanced
        showOrnament = try c.decodeIfPresent(Bool.self, forKey: .showOrnament) ?? true
        artwork = try c.decodeIfPresent(LunarArtwork.self, forKey: .artwork) ?? .automatic
        remindMoonDays = try c.decodeIfPresent(Bool.self, forKey: .remindMoonDays) ?? false
    }
}

final class LunarAppearanceRepository {
    private let defaults: UserDefaults
    private let key = "viepn.lunar.appearance.v1"
    init(defaults: UserDefaults? = nil) {
        self.defaults = defaults ?? UserDefaults(suiteName: "group.com.viepn.widgetplus") ?? .standard
    }
    func load() -> LunarAppearance {
        guard let data = defaults.data(forKey: key), let appearance = try? JSONDecoder().decode(LunarAppearance.self, from: data) else { return LunarAppearance() }
        return appearance
    }
    func save(_ appearance: LunarAppearance) {
        if let data = try? JSONEncoder().encode(appearance) { defaults.set(data, forKey: key) }
    }
}
