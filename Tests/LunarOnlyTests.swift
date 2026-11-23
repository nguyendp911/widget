import Foundation
import XCTest
@testable import ViePNWidgetPlus

final class LunarOnlyTests: XCTestCase {
    func testStandaloneLunarConversions() {
        let tet = SolarCivilDate(year: 2026, month: 2, day: 17)
        XCTAssertEqual(
            VietnameseLunarCalendar.solarToLunar(tet),
            VietnameseLunarDate(day: 1, month: 1, year: 2026, isLeapMonth: false)
        )
        XCTAssertEqual(VietnameseLunarCalendar.leapMonth(in: 2025), 6)
        XCTAssertNil(VietnameseLunarCalendar.leapMonth(in: 2026))
    }

    func testVietnameseZodiacAndAlmanac() {
        let facts = LunarAlmanacFacts(SolarCivilDate(year: 2026, month: 11, day: 23))
        XCTAssertEqual(facts.goodHours.count, 6)
        XCTAssertFalse(facts.solarTerm.isEmpty)
        XCTAssertEqual(LunarAlmanacFacts.animal("Mão"), "Mèo")
        XCTAssertTrue(facts.canChiDay.contains(" "))
    }

    func testMemorialRepeatsOnTheLunarDate() {
        let memorial = LunarFamilyEvent(title: "Giỗ bà", kind: .memorial, lunarDay: 15, lunarMonth: 8)
        for year in 2025...2036 {
            let occurrences = LunarEventScheduler.inLunarYear(memorial, year: year)
            XCTAssertEqual(occurrences.count, 1)
            XCTAssertEqual(occurrences.first?.lunar.day, 15)
            XCTAssertEqual(occurrences.first?.lunar.month, 8)
        }
    }

    func testAppContentCategories() {
        XCTAssertEqual(ThienNienSection.allCases.count, 9)
        XCTAssertNotNil(ThienNienSection.allCases.first(where: { $0 == .memorials }))
    }

    func testOldAppearanceStorageCompatible() {
        let stored = LunarAppearance()
        XCTAssertEqual(stored.theme, .heritage)
        XCTAssertNotNil(stored.artwork.resolvedResource(theme: stored.theme, family: "Large"))
    }

    func testFiveYearICSUsesConcreteDates() {
        let memorial = LunarFamilyEvent(title: "Giỗ cha", kind: .memorial, lunarDay: 12, lunarMonth: 4)
        let content = LunarICSExporter.text(events: [memorial], fromYear: 2026, years: 5)
        XCTAssertEqual(content.components(separatedBy: "BEGIN:VEVENT").count, 6)
        XCTAssertFalse(content.contains("RRULE"))
    }
}
