import Foundation
import XCTest
import UIKit
@testable import ViePNWidgetPlus

final class LunarOnlyTests: XCTestCase {
    func testAllZodiacAssetsAreBundled() {
        for branch in VietnameseLunarCalendar.chi {
            let name = HeritageArtCatalog.animal(branch)
            XCTAssertNotNil(UIImage(named: name, in: Bundle.main, compatibleWith: nil), "Missing asset: " + name)
        }
        for sign in WesternSign.allCases {
            XCTAssertNotNil(UIImage(named: sign.asset, in: Bundle.main, compatibleWith: nil), "Missing asset: " + sign.asset)
        }
    }

    func testZodiacKnowledgeCoverageAndCycle() {
        XCTAssertEqual(AnimalGuide.all.map(\.branch), VietnameseLunarCalendar.chi)
        XCTAssertEqual(WesternGuide.all.count, 12)
        XCTAssertEqual(AnimalGuide.named("Mão")?.animal, "Mèo")
        XCTAssertEqual(AnimalGuide.named("Tý")?.hour, "23:00 – 01:00")
        XCTAssertEqual(AnimalGuide.named("Tý")?.harmony, "Sửu")
        XCTAssertEqual(AnimalGuide.named("Mão")?.harmony, "Tuất")
        XCTAssertEqual(AnimalGuide.named("Ngọ")?.opposing, "Tý")
        XCTAssertEqual(AnimalGuide.named("Thân")?.trine, "Tý · Thìn · Thân")
        XCTAssertEqual(NapAmGuide.lookup("Giáp Tý")?.name, "Hải Trung Kim")
        XCTAssertEqual(NapAmGuide.lookup("Bính Ngọ")?.name, "Thiên Hà Thủy")
        XCTAssertEqual(NapAmGuide.lookup("Quý Hợi")?.name, "Đại Hải Thủy")
        XCTAssertNil(NapAmGuide.lookup("Giáp Sửu"))
        for index in 0..<60 {
            let cycle = VietnameseLunarCalendar.can[index%10] + " " + VietnameseLunarCalendar.chi[index%12]
            XCTAssertNotNil(NapAmGuide.lookup(cycle))
        }
        for guide in AnimalGuide.all {
            XCTAssertGreaterThan(guide.heritage.count, 100)
            XCTAssertEqual(AnimalGuide.named(guide.harmony)?.harmony, guide.branch)
            XCTAssertEqual(AnimalGuide.named(guide.opposing)?.opposing, guide.branch)
        }
    }

    func testWesternSignApproximateBoundaries() {
        XCTAssertEqual(WesternSign.approximate(SolarCivilDate(year: 2026, month: 3, day: 20)), .pisces)
        XCTAssertEqual(WesternSign.approximate(SolarCivilDate(year: 2026, month: 3, day: 21)), .aries)
        XCTAssertEqual(WesternSign.approximate(SolarCivilDate(year: 2026, month: 12, day: 22)), .capricorn)
        XCTAssertEqual(WesternSign.approximate(SolarCivilDate(year: 2026, month: 1, day: 19)), .capricorn)
        XCTAssertEqual(WesternSign.allCases.count, 12)
        XCTAssertEqual(Set(VietnameseLunarCalendar.chi.map { HeritageArtCatalog.animal($0) }).count, 12)
    }

    func testSolarTermLibraryCoverage() {
        XCTAssertEqual(SolarTermGuide.all.count, 24)
        XCTAssertEqual(Set(SolarTermGuide.all.map(\.name)), Set(VietnameseLunarCalendar.terms))
        XCTAssertEqual(SolarTermGuide.named("Xuân phân")?.longitude, 0)
        XCTAssertEqual(SolarTermGuide.named("Đông chí")?.longitude, 270)
        for year in [1900, 2026, 2028, 2100] {
            let starts = SolarTermGuide.starts(in: year)
            XCTAssertEqual(starts.count, 24)
            XCTAssertEqual(Set(starts.map { $0.guide.name }).count, 24)
            XCTAssertTrue(starts.allSatisfy { VietnameseLunarCalendar.solarTerm(on: $0.date).startsToday })
        }
    }

    func testSolarTermPeriod() {
        let day = SolarCivilDate(year: 2026, month: 11, day: 24)
        let period = SolarTermGuide.period(on: day)
        XCTAssertNotNil(period.start)
        XCTAssertNotNil(period.next)
        if let start = period.start, let next = period.next {
            XCTAssertLessThanOrEqual(start, day)
            XCTAssertGreaterThan(next, day)
            XCTAssertEqual(VietnameseLunarCalendar.solarTerm(on: start).name,
                           VietnameseLunarCalendar.solarTerm(on: day).name)
        }
    }

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
