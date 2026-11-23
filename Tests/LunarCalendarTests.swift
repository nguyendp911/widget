import Foundation
import XCTest
@testable import ViePNWidgetPlus

final class LunarCalendarTests: XCTestCase {
    func testLunarArtworkDefaultsToIllustratedBackground() {
        let appearance = LunarAppearance()
        XCTAssertEqual(appearance.theme, .heritage)
        XCTAssertNotNil(appearance.artwork.resolvedResource(theme: appearance.theme))
        XCTAssertNotNil(LunarArtwork.automatic.resolvedResource(theme: .zen))
        XCTAssertNil(LunarArtwork.none.resolvedResource(theme: .heritage))
    }

    func testApprovedHeritageHasUniqueArtworkForEachWidgetKind() {
        let appearance = LunarAppearance()
        let expected: [(LunarCardKind, String)] = [
            (.today, "ViePNTrongDongMedium"),
            (.nextEvent, "ViePNGioNhaMedium"),
            (.moonDays, "ViePNTrangTreMedium"),
            (.memorial, "ViePNSenNgocMedium"),
            (.month, "ViePNCongLangMedium"),
            (.tradition, "ViePNCucVangMedium"),
            (.almanac, "ViePNVanNienMedium")
        ]
        for (kind, asset) in expected {
            let skin = LunarWidgetSkin(kind: kind, appearance: appearance)
            XCTAssertEqual(skin.artworkName(family: "Medium"), asset)
        }
        XCTAssertTrue(LunarWidgetSkin(kind: .today, appearance: appearance).dark)
        XCTAssertTrue(LunarWidgetSkin(kind: .memorial, appearance: appearance).dark)
        XCTAssertFalse(LunarWidgetSkin(kind: .almanac, appearance: appearance).dark)
        XCTAssertFalse(LunarWidgetSkin(kind: .nextEvent, appearance: appearance).dark)
        var jade = appearance
        jade.artwork = .lotus
        XCTAssertTrue(LunarWidgetSkin(kind: .month, appearance: jade).dark)
        jade.artwork = .gioNha
        XCTAssertFalse(LunarWidgetSkin(kind: .memorial, appearance: jade).dark)

        var custom = appearance
        custom.artwork = .spring
        XCTAssertEqual(LunarWidgetSkin(kind: .memorial, appearance: custom)
            .artworkName(family: "Large"), "ViePNXuanVietLarge")
    }

    func testAlmanacFactsHaveConsistentTraditionalData() {
        let civil = SolarCivilDate(year: 2026, month: 11, day: 23)
        let facts = LunarAlmanacFacts(civil)
        XCTAssertFalse(facts.canChiDay.isEmpty)
        XCTAssertFalse(facts.canChiMonth.isEmpty)
        XCTAssertFalse(facts.canChiYear.isEmpty)
        XCTAssertEqual(facts.goodHours.count, 6)
        XCTAssertTrue(VietnameseLunarCalendar.chi.contains(facts.opposingZodiac))
        XCTAssertFalse(facts.solarTerm.isEmpty)
    }

    func testRetinaHeritageArtworkHasDedicatedWidgetFamilies() {
        let art = LunarArtwork.vanNien
        XCTAssertEqual(art.resolvedResource(theme: .heritage, family: "Small"), "ViePNVanNienSmall")
        XCTAssertEqual(art.resolvedResource(theme: .heritage, family: "Medium"), "ViePNVanNienMedium")
        XCTAssertEqual(art.resolvedResource(theme: .heritage, family: "Large"), "ViePNVanNienLarge")
        XCTAssertEqual(LunarArtwork.gioNha.resolvedResource(theme: .heritage), "ViePNGioNhaMedium")
        XCTAssertNil(LunarArtwork.none.resolvedResource(theme: .heritage, family: "Large"))
    }

    func testZodiacVietnameseAnimalLabels() {
        XCTAssertEqual(LunarAlmanacFacts.animal("Mão"), "Mèo")
        XCTAssertEqual(LunarAlmanacFacts.animal("Sửu"), "Trâu")
        XCTAssertEqual(LunarAlmanacFacts.animal("Thìn"), "Rồng")
        let facts = LunarAlmanacFacts(SolarCivilDate(year: 2026, month: 11, day: 23))
        XCTAssertFalse(facts.dayAnimalName.isEmpty)
        XCTAssertFalse(facts.opposingAnimalName.isEmpty)
        XCTAssertEqual(facts.goodHours.count, 6)
    }

    func testThienNienVietModalLinksRoundTrip() {
        let day = SolarCivilDate(year: 2026, month: 11, day: 23)
        for section in ThienNienSection.allCases {
            let link = section.url(for: day)
            let parsed = ThienNienSection.destination(from: link)
            XCTAssertEqual(parsed?.section, section)
            XCTAssertEqual(parsed?.date, day)
            XCTAssertEqual(link.host, "lunar")
        }
        XCTAssertNil(ThienNienSection.destination(
            from: URL(string: "https://one.google.com/ai")!
        ))
        XCTAssertNil(ThienNienSection.destination(
            from: URL(string: "viepnwidgetplus://lunar?detail=unknown")!
        ))
    }

    func testTetAndLeapMonths() {
        let tet = SolarCivilDate(year: 2026, month: 2, day: 17)
        XCTAssertEqual(VietnameseLunarCalendar.solarToLunar(tet),
                       VietnameseLunarDate(day: 1, month: 1, year: 2026, isLeapMonth: false))
        XCTAssertEqual(VietnameseLunarCalendar.leapMonth(in: 2025), 6)
        XCTAssertEqual(VietnameseLunarCalendar.leapMonth(in: 2033), 11)
    }
    func testMemorialRecurrence() {
        let e = LunarFamilyEvent(title: "Giỗ ông", lunarDay: 12, lunarMonth: 4)
        let dates = (2025...2035).flatMap { LunarEventScheduler.inLunarYear(e, year: $0) }
        XCTAssertEqual(dates.count, 11)
        for date in dates { XCTAssertEqual(date.lunar.day, 12); XCTAssertEqual(date.lunar.month, 4) }
    }
    func testOnlyLeapMonth() {
        let e = LunarFamilyEvent(title: "Nhớ ngày nhuận", lunarDay: 10, lunarMonth: 6, leapRule: .leapOnly)
        XCTAssertEqual(LunarEventScheduler.inLunarYear(e, year: 2025).count, 1)
        XCTAssertTrue(LunarEventScheduler.inLunarYear(e, year: 2026).isEmpty)
    }
    func testNewMoonEdgeCasesAndStartOf1900() {
        for (year, month, day) in [(1900, 1, 1), (2054, 5, 7), (2062, 4, 9)] {
            let solar = SolarCivilDate(year: year, month: month, day: day)
            let lunar = VietnameseLunarCalendar.solarToLunar(solar)
            XCTAssertNotNil(lunar)
            XCTAssertGreaterThanOrEqual(lunar?.day ?? 0, 1)
            XCTAssertEqual(lunar.flatMap(VietnameseLunarCalendar.lunarToSolar), solar)
        }
    }
    func testLeapMonthStillHasFirstAndFullMoon() {
        let leap = VietnameseLunarCalendar.lunarToSolar(VietnameseLunarDate(day: 1, month: 6, year: 2025, isLeapMonth: true))!
        XCTAssertEqual(LunarHighlights.nextLunarDay(from: leap, day: 1)?.daysUntil, 0)
        XCTAssertTrue(LunarHighlights.nextLunarDay(from: leap, day: 1)?.name.contains("nhuận") == true)
    }
    func testMoonCountdownAndCalendarExport() {
        let day = SolarCivilDate(year: 2026, month: 11, day: 23)
        XCTAssertEqual(LunarHighlights.nextLunarDay(from: day, day: 15)?.daysUntil, 0)
        let ics = LunarICSExporter.text(events: [LunarFamilyEvent(title: "Ngày giỗ", lunarDay: 9, lunarMonth: 7)], fromYear: 2026, years: 5)
        XCTAssertFalse(ics.contains("RRULE"))
        XCTAssertEqual(ics.components(separatedBy: "BEGIN:VEVENT").count, 6)
    }
}
