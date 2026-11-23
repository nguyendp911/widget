import Foundation

/// Traditional Vietnamese almanac metadata. These are deterministic calendar
/// conventions, NOT a personal horoscope or a prediction about someone's life.
struct LunarAlmanacFacts {
    let canChiDay: String
    let canChiMonth: String
    let canChiYear: String
    let solarTerm: String
    let spirit: String
    let officer: String
    let auspicious: Bool
    let goodHours: [String]
    let opposingZodiac: String

    init(_ civil: SolarCivilDate) {
        let cycle = VietnameseLunarCalendar.canChi(civil)
        canChiDay = cycle?.day ?? "—"
        canChiMonth = cycle?.month ?? "—"
        canChiYear = cycle?.year ?? "—"
        solarTerm = VietnameseLunarCalendar.solarTerm(on: civil).name
        let tradition = VietnameseLunarCalendar.traditionalDayInfo(civil)
        spirit = tradition.spirit
        officer = tradition.officer
        auspicious = tradition.auspicious
        goodHours = VietnameseLunarCalendar.luckyHours(civil)
        let chi = cycle?.day.split(separator: " ").last.map(String.init) ?? ""
        if let index = VietnameseLunarCalendar.chi.firstIndex(of: chi) {
            opposingZodiac = VietnameseLunarCalendar.chi[(index + 6) % 12]
        } else {
            opposingZodiac = "—"
        }
    }

    var dayKind: String { auspicious ? "Hoàng đạo" : "Hắc đạo" }
    var goodHoursLabel: String { goodHours.joined(separator: " · ") }
    var culturalLabel: String {
        dayKind + " · " + spirit + " · Trực " + officer
    }
}
