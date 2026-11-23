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
    let dayAnimal: String
    let yearAnimal: String

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
        dayAnimal = chi
        yearAnimal = cycle?.year.split(separator: " ").last.map(String.init) ?? "—"
        if let index = VietnameseLunarCalendar.chi.firstIndex(of: chi) {
            opposingZodiac = VietnameseLunarCalendar.chi[(index + 6) % 12]
        } else {
            opposingZodiac = "—"
        }
    }

    /// The Vietnamese zodiac includes Mèo (cat) for Mão, not rabbit.
    static func animal(_ branch: String) -> String {
        let map = [
            "Tý": "Chuột", "Sửu": "Trâu", "Dần": "Hổ", "Mão": "Mèo",
            "Thìn": "Rồng", "Tỵ": "Rắn", "Ngọ": "Ngựa", "Mùi": "Dê",
            "Thân": "Khỉ", "Dậu": "Gà", "Tuất": "Chó", "Hợi": "Lợn"
        ]
        return map[branch] ?? branch
    }

    var dayAnimalName: String { Self.animal(dayAnimal) }
    var yearAnimalName: String { Self.animal(yearAnimal) }
    var opposingAnimalName: String { Self.animal(opposingZodiac) }
    var dayKind: String { auspicious ? "Hoàng đạo" : "Hắc đạo" }
    var goodHoursLabel: String { goodHours.joined(separator: " · ") }
    var culturalLabel: String {
        dayKind + " · " + spirit + " · Trực " + officer
    }
}
