import Foundation

@main struct LunarSmoke {
    static func assert(_ condition: @autoclosure () -> Bool, _ message: String) {
        if !condition() { fputs("FAIL: \(message)\n", stderr); exit(1) }
    }
    static func main() {
        let tet = [(2023, 1, 22), (2024, 2, 10), (2025, 1, 29), (2026, 2, 17),
                   (2027, 2, 6), (2028, 1, 26), (2029, 2, 13), (2030, 2, 2),
                   (2031, 1, 23), (2033, 1, 31), (2034, 2, 19)]
        for (year, month, day) in tet {
            let d = SolarCivilDate(year: year, month: month, day: day)
            assert(VietnameseLunarCalendar.solarToLunar(d) == VietnameseLunarDate(day: 1, month: 1, year: year, isLeapMonth: false), "Tet \(year)")
            assert(VietnameseLunarCalendar.lunarToSolar(VietnameseLunarDate(day: 1, month: 1, year: year, isLeapMonth: false)) == d, "Tet inverse \(year)")
        }
        let leap = [2023:2, 2025:6, 2028:5, 2031:3, 2033:11]
        for (y, m) in leap { assert(VietnameseLunarCalendar.leapMonth(in: y) == m, "leap \(y)") }
        assert(VietnameseLunarCalendar.leapMonth(in: 2026) == nil, "no leap 2026")
        let source = LunarFamilyEvent(title: "Giỗ bà", kind: .memorial, lunarDay: 15, lunarMonth: 8)
        for y in 2023...2035 {
            let items = LunarEventScheduler.inLunarYear(source, year: y)
            assert(items.count == 1, "memorial yearly count \(y)")
            assert(items[0].lunar.day == 15 && items[0].lunar.month == 8 && !items[0].lunar.isLeapMonth, "memorial lunar date \(y)")
            assert(VietnameseLunarCalendar.solarToLunar(items[0].solar) == items[0].lunar, "memorial inverse \(y)")
        }
        var leapOnly = source
        leapOnly.lunarMonth = 6
        leapOnly.leapRule = .leapOnly
        assert(LunarEventScheduler.inLunarYear(leapOnly, year: 2025).count == 1, "leap only in leap year")
        assert(LunarEventScheduler.inLunarYear(leapOnly, year: 2026).isEmpty, "leap only missing year")
        var both = leapOnly; both.leapRule = .both
        assert(LunarEventScheduler.inLunarYear(both, year: 2025).count == 2, "regular and leap")
        var thirty = source
        thirty.lunarDay = 30
        thirty.lunarMonth = 2
        thirty.missingDayRule = .lastDay
        var hit = false
        for year in 2020...2040 {
            if VietnameseLunarCalendar.monthLength(month: 2, year: year) == 29 {
                let items = LunarEventScheduler.inLunarYear(thirty, year: year)
                assert(items.count == 1 && items[0].lunar.day == 29 && items[0].isAdjustedForShortMonth, "missing day fallback")
                thirty.missingDayRule = .skip
                assert(LunarEventScheduler.inLunarYear(thirty, year: year).isEmpty, "missing day skip")
                hit = true; break
            }
        }
        assert(hit, "find a short month")
        let civil = SolarCivilDate(year: 2026, month: 11, day: 23)
        assert(VietnameseLunarCalendar.solarToLunar(civil)?.label == "15/10/2026", "23 Nov 2026 lunar")
        assert(LunarHighlights.nextLunarDay(from: civil, day: 15)?.daysUntil == 0, "today full moon")
        let ics = LunarICSExporter.text(events: [source], fromYear: 2026, years: 5)
        assert(ics.contains("BEGIN:VCALENDAR") && ics.contains("END:VCALENDAR"), "ICS markers")
        assert(ics.components(separatedBy: "BEGIN:VEVENT").count == 6, "exact 5 occurrences")
        assert(!ics.contains("RRULE"), "no solar yearly RRULE")
        // Check one day every ten days through 2022–2036, including leap-month years.
        var days = 0
        for year in 2022...2036 {
            let first = VietnameseLunarCalendar.jdn(SolarCivilDate(year: year, month: 1, day: 1))
            let last = VietnameseLunarCalendar.jdn(SolarCivilDate(year: year, month: 12, day: 31))
            for jd in stride(from: first, through: last, by: 10) {
                let day = VietnameseLunarCalendar.civilDate(jd)
                guard let lunar = VietnameseLunarCalendar.solarToLunar(day) else { continue }
                assert(VietnameseLunarCalendar.lunarToSolar(lunar) == day, "solar-lunar roundtrip \(day.label)")
                days += 1
            }
        }
        print("PASS: \(tet.count) Tet dates; leap month rules; 13 annual memorials; ICS; \(days) round-trips; mùng 1 / Rằm")
    }
}
