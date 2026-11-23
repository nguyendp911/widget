import Foundation

struct LunarUpcomingFestival: Equatable {
    let name: String
    let solar: SolarCivilDate
    let lunar: VietnameseLunarDate
    let daysUntil: Int
}

enum LunarHighlights {
    /// A calculation from each exact lunar month, including year transitions.
    /// Ordinary holidays aren't repeated in leap months by default.
    static func nextObservance(from civil: SolarCivilDate, maxDays: Int = 60) -> LunarUpcomingFestival? {
        let start = VietnameseLunarCalendar.jdn(civil)
        for offset in 0...maxDays {
            let solar = VietnameseLunarCalendar.civilDate(start + offset)
            guard let lunar = VietnameseLunarCalendar.solarToLunar(solar) else { continue }
            if !lunar.isLeapMonth && lunar.day == 1 {
                return LunarUpcomingFestival(name: "Mùng 1 tháng \(lunar.month)", solar: solar, lunar: lunar, daysUntil: offset)
            }
            if !lunar.isLeapMonth && lunar.day == 15 {
                return LunarUpcomingFestival(name: "Rằm tháng \(lunar.month)", solar: solar, lunar: lunar, daysUntil: offset)
            }
        }
        return nil
    }

    static func nextLunarDay(from civil: SolarCivilDate, day: Int, maxDays: Int = 65) -> LunarUpcomingFestival? {
        let start = VietnameseLunarCalendar.jdn(civil)
        for offset in 0...maxDays {
            let solar = VietnameseLunarCalendar.civilDate(start + offset)
            guard let lunar = VietnameseLunarCalendar.solarToLunar(solar), lunar.day == day, !lunar.isLeapMonth else { continue }
            return LunarUpcomingFestival(name: day == 15 ? "Rằm tháng \(lunar.month)" : "Mùng 1 tháng \(lunar.month)", solar: solar, lunar: lunar, daysUntil: offset)
        }
        return nil
    }
}
