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
        // Mùng 1 / Rằm also occur in a leap lunar month; these are NOT holidays that get skipped.
        let leapStart = VietnameseLunarCalendar.lunarToSolar(VietnameseLunarDate(day: 1, month: 6, year: 2025, isLeapMonth: true))!
        assert(LunarHighlights.nextLunarDay(from: leapStart, day: 1)?.daysUntil == 0, "moon observance in leap month")
        assert(LunarHighlights.nextLunarDay(from: leapStart, day: 1)?.name.contains("nhuận") == true, "leap label")
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
        // Exhaustive civil-day roundtrip across 1900–2099, including edge cases
        // 07 May 2054 / 09 April 2062 that exposed a naive new-moon bracket bug.
        var days = 0
        let first = VietnameseLunarCalendar.jdn(SolarCivilDate(year: 1900, month: 1, day: 1))
        let last = VietnameseLunarCalendar.jdn(SolarCivilDate(year: 2099, month: 12, day: 31))
        for jd in first...last {
            let day = VietnameseLunarCalendar.civilDate(jd)
            guard let lunar = VietnameseLunarCalendar.solarToLunar(day) else {
                assert(false, "missing conversion \(day.label)")
                continue
            }
            assert(lunar.day >= 1 && lunar.day <= 30, "valid lunar day \(day.label)")
            assert(VietnameseLunarCalendar.lunarToSolar(lunar) == day, "solar-lunar roundtrip \(day.label)")
            days += 1
        }
        let ram = VietnameseLunarCalendar.lunarToSolar(VietnameseLunarDate(day: 15, month: 7, year: 2028, isLeapMonth: false))
        assert(HeritageSearch.date("Rằm tháng 7 năm 2028", year: 2026) == ram, "Vietnamese lunar query")
        assert(HeritageSearch.date("31/2/2026", year: 2026) == nil, "invalid civil query")
        assert(HeritageSearch.date("24/11/2026", year: 2026) == SolarCivilDate(year: 2026, month: 11, day: 24), "civil query")
        let archive = HeritageArchive(events: [source], tasks: ["test": HeritageRitual.preparation(for: .memorial)], people: [HeritagePerson(name: "Ông", relationship: "Ông nội")], memories: [])
        let encoded = try! JSONEncoder().encode(archive)
        let decoded = try! JSONDecoder().decode(HeritageArchive.self, from: encoded)
        assert(decoded.events == archive.events && decoded.tasks == archive.tasks && decoded.people == archive.people, "family backup roundtrip")
        print("PASS: heritage search and backup")
        print("PASS: \(tet.count) Tet dates; leap month rules; 13 annual memorials; ICS; \(days) round-trips; mùng 1 / Rằm")
    }
}
