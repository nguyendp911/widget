import Foundation

/// Export a concrete 10-year schedule of *Gregorian* events to Apple Calendar.
/// RFC 5545 DATE-TIME events use UTC. No yearly RRULE is used: it would drift
/// because lunar anniversaries move relative to the Gregorian calendar.
enum LunarICSExporter {
    static func text(events: [LunarFamilyEvent], fromYear: Int, years: Int = 10) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyyMMdd'T'HHmmss'Z'"
        let stamp = formatter.string(from: Date())
        var output = ["BEGIN:VCALENDAR", "VERSION:2.0", "PRODID:-//ViePN//Vietnamese Lunar Memorials//VI", "CALSCALE:GREGORIAN", "METHOD:PUBLISH", "X-WR-CALNAME:ViePN - Giỗ & sự kiện âm lịch"]
        for event in events where event.isValid {
            for year in max(1900, fromYear)...min(2100, fromYear + max(1, years) - 1) {
                for item in LunarEventScheduler.inLunarYear(event, year: year) {
                    guard let start = item.solar.asDate(hour: 8), let end = item.solar.asDate(hour: 9) else { continue }
                    output += ["BEGIN:VEVENT",
                               "UID:\(event.id.uuidString)-\(year)-\(item.lunar.isLeapMonth ? "L" : "R")@viepn.widgetplus",
                               "DTSTAMP:\(stamp)",
                               "DTSTART:\(formatter.string(from: start))",
                               "DTEND:\(formatter.string(from: end))",
                               "SUMMARY:\(escape(event.title))",
                               "DESCRIPTION:\(escape("\(event.kind.label) • Âm lịch \(item.lunar.label)\(item.isAdjustedForShortMonth ? " • Dời sang ngày cuối tháng thiếu" : "")\n\(event.note)"))"]
                    for days in Set(event.reminderDaysBefore).sorted() {
                        output += ["BEGIN:VALARM", "ACTION:DISPLAY", "DESCRIPTION:\(escape(event.title))", "TRIGGER:-P\(days)D", "END:VALARM"]
                    }
                    output.append("END:VEVENT")
                }
            }
        }
        output.append("END:VCALENDAR")
        return output.joined(separator: "\r\n") + "\r\n"
    }

    static func saveToTemporaryFile(events: [LunarFamilyEvent], fromYear: Int) throws -> URL {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("ViePN-LichGio-10nam.ics")
        try text(events: events, fromYear: fromYear).write(to: url, atomically: true, encoding: .utf8)
        return url
    }

    private static func escape(_ text: String) -> String {
        text.replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: ";", with: "\\;")
            .replacingOccurrences(of: ",", with: "\\,")
            .replacingOccurrences(of: "\n", with: "\\n")
            .replacingOccurrences(of: "\r", with: "")
    }
}
