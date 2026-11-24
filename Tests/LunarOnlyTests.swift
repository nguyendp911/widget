import Foundation
import XCTest
@testable import ViePNWidgetPlus

final class LunarOnlyTests: XCTestCase {
    func testNaturalDateSearch() {
        let expected = VietnameseLunarCalendar.lunarToSolar(
            VietnameseLunarDate(day: 15, month: 7, year: 2028, isLeapMonth: false))
        XCTAssertEqual(HeritageSearch.date("Rằm tháng 7 năm 2028", year: 2026), expected)
        XCTAssertEqual(HeritageSearch.date("24/11/2026", year: 2026), SolarCivilDate(year: 2026, month: 11, day: 24))
        XCTAssertNil(HeritageSearch.date("31/2/2026", year: 2026))
    }

    func testCivilSearchWithVietnameseYearWords() {
        let expected = SolarCivilDate(year: 2026, month: 11, day: 24)
        XCTAssertEqual(HeritageSearch.date("Ngày 24 tháng 11 năm 2026", year: 2025), expected)
        XCTAssertEqual(HeritageSearch.date("24/11 dương", year: 2026), expected)
        XCTAssertNil(HeritageSearch.date("15/7/2028 âm dương", year: 2026))
        XCTAssertEqual(HeritageSearch.date("15/7/2028 âm", year: 2026),
                       VietnameseLunarCalendar.lunarToSolar(
                         VietnameseLunarDate(day: 15, month: 7, year: 2028, isLeapMonth: false)))
    }

    func testHeritageArchiveRoundTrip() throws {
        let archive = HeritageArchive(events: [], tasks: ["test": HeritageRitual.preparation(for: .memorial)], people: [HeritagePerson(name: "Ông", relationship: "Ông nội")], memories: [HeritageMemory(title: "Ngày nhớ", text: "Gia đình")])
        let restored = try JSONDecoder().decode(HeritageArchive.self, from: JSONEncoder().encode(archive))
        XCTAssertEqual(restored.people, archive.people)
        XCTAssertEqual(restored.tasks, archive.tasks)
        XCTAssertEqual(restored.memories, archive.memories)
    }

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
