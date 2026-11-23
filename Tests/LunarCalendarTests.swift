import Foundation
import XCTest
@testable import ViePNWidgetPlus

final class LunarCalendarTests: XCTestCase {
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
    func testMoonCountdownAndCalendarExport() {
        let day = SolarCivilDate(year: 2026, month: 11, day: 23)
        XCTAssertEqual(LunarHighlights.nextLunarDay(from: day, day: 15)?.daysUntil, 0)
        let ics = LunarICSExporter.text(events: [LunarFamilyEvent(title: "Ngày giỗ", lunarDay: 9, lunarMonth: 7)], fromYear: 2026, years: 5)
        XCTAssertFalse(ics.contains("RRULE"))
        XCTAssertEqual(ics.components(separatedBy: "BEGIN:VEVENT").count, 6)
    }
}
