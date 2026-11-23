import Foundation

/// Normal lunar month is the default for anniversaries. A leap-month anniversary
/// must opt into a leap policy explicitly; never silently shift to a regular month.
enum LunarLeapRule: String, Codable, CaseIterable, Identifiable {
    case regular = "regular"
    case leapOnly = "leapOnly"
    case both = "both"
    var id: String { rawValue }
    var label: String {
        switch self {
        case .regular: return "Tháng thường (mặc định)"
        case .leapOnly: return "Chỉ tháng nhuận (năm có tháng đó)"
        case .both: return "Cả tháng thường và tháng nhuận"
        }
    }
}

enum MissingLunarDayRule: String, Codable, CaseIterable, Identifiable {
    case lastDay = "lastDay"
    case skip = "skip"
    var id: String { rawValue }
    var label: String { self == .lastDay ? "Chuyển sang ngày cuối tháng" : "Bỏ qua năm có tháng thiếu" }
}

enum FamilyEventKind: String, Codable, CaseIterable, Identifiable {
    case memorial, birthday, anniversary, other
    var id: String { rawValue }
    var label: String {
        switch self {
        case .memorial: return "Ngày giỗ"
        case .birthday: return "Sinh nhật âm lịch"
        case .anniversary: return "Kỷ niệm gia đình"
        case .other: return "Sự kiện khác"
        }
    }
    var icon: String {
        switch self {
        case .memorial: return "leaf.fill"
        case .birthday: return "gift.fill"
        case .anniversary: return "heart.fill"
        case .other: return "bell.fill"
        }
    }
}

struct LunarFamilyEvent: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var title: String
    var kind: FamilyEventKind = .memorial
    var lunarDay: Int
    var lunarMonth: Int
    var firstLunarYear: Int? = nil
    var leapRule: LunarLeapRule = .regular
    var missingDayRule: MissingLunarDayRule = .lastDay
    var reminderDaysBefore: [Int] = [7, 1, 0]
    var reminderHour: Int = 8
    var reminderMinute: Int = 0
    var note: String = ""

    var isValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        (1...30).contains(lunarDay) && (1...12).contains(lunarMonth) &&
        (0...23).contains(reminderHour) && (0...59).contains(reminderMinute) &&
        reminderDaysBefore.allSatisfy { (0...30).contains($0) }
    }
}

struct LunarEventOccurrence: Identifiable, Equatable {
    let eventID: UUID
    let title: String
    let kind: FamilyEventKind
    let solar: SolarCivilDate
    let lunar: VietnameseLunarDate
    let isAdjustedForShortMonth: Bool
    var id: String { "\(eventID.uuidString):\(solar.label):\(lunar.isLeapMonth)" }

    func daysRemaining(from civil: SolarCivilDate) -> Int {
        VietnameseLunarCalendar.jdn(solar) - VietnameseLunarCalendar.jdn(civil)
    }
}

enum LunarEventScheduler {
    static func inLunarYear(_ event: LunarFamilyEvent, year: Int) -> [LunarEventOccurrence] {
        guard event.isValid, (1900...2100).contains(year), year >= (event.firstLunarYear ?? 1900) else { return [] }
        let variants: [Bool]
        switch event.leapRule {
        case .regular: variants = [false]
        case .leapOnly: variants = [true]
        case .both: variants = [false, true]
        }
        return variants.compactMap { leap -> LunarEventOccurrence? in
            guard let length = VietnameseLunarCalendar.monthLength(month: event.lunarMonth, year: year, leap: leap) else { return nil }
            if event.lunarDay > length && event.missingDayRule == .skip { return nil }
            let day = min(length, event.lunarDay)
            let lunar = VietnameseLunarDate(day: day, month: event.lunarMonth, year: year, isLeapMonth: leap)
            guard let solar = VietnameseLunarCalendar.lunarToSolar(lunar) else { return nil }
            return LunarEventOccurrence(eventID: event.id, title: event.title, kind: event.kind, solar: solar, lunar: lunar,
                                        isAdjustedForShortMonth: day != event.lunarDay)
        }.sorted { $0.solar < $1.solar }
    }

    static func upcoming(events: [LunarFamilyEvent], from civil: SolarCivilDate, count: Int = 20, years: Int = 8) -> [LunarEventOccurrence] {
        let lowYear = max(1900, civil.year - 1)
        let highYear = min(2100, civil.year + max(2, years))
        guard lowYear <= highYear else { return [] }
        var collected: [LunarEventOccurrence] = []
        for event in events {
            for year in lowYear...highYear {
                collected.append(contentsOf: inLunarYear(event, year: year))
            }
        }
        collected = collected.filter { $0.solar >= civil }
        collected.sort {
            if $0.solar == $1.solar { return $0.title < $1.title }
            return $0.solar < $1.solar
        }
        return Array(collected.prefix(max(0, count)))
    }

    /// A generated projection, never a yearly solar recurrence that drifts.
    static func reminders(events: [LunarFamilyEvent], now: Date = Date(), maxCount: Int = 48) -> [(event: LunarFamilyEvent, occurrence: LunarEventOccurrence, on: Date)] {
        guard let civil = SolarCivilDate(date: now) else { return [] }
        let byID = Dictionary(uniqueKeysWithValues: events.map { ($0.id, $0) })
        let occurrences = upcoming(events: events, from: VietnameseLunarCalendar.civilDate(VietnameseLunarCalendar.jdn(civil) - 30), count: 200, years: 6)
        let results = occurrences.flatMap { occurrence -> [(event: LunarFamilyEvent, occurrence: LunarEventOccurrence, on: Date)] in
            guard let event = byID[occurrence.eventID] else { return [] }
            return Array(Set(event.reminderDaysBefore)).sorted(by: >).compactMap { before in
                let civil = VietnameseLunarCalendar.civilDate(VietnameseLunarCalendar.jdn(occurrence.solar) - before)
                guard let fire = civil.asDate(hour: event.reminderHour)?.addingTimeInterval(TimeInterval(event.reminderMinute * 60)), fire > now else { return nil }
                return (event: event, occurrence: occurrence, on: fire)
            }
        }
        return results.sorted { $0.on < $1.on }.prefix(maxCount).map { $0 }
    }
}

/// Pure-data App Group repository. Notifications are re-projected after edits or
/// app activation by the host app (extensions cannot request notification access).
final class LunarFamilyRepository {
    private let key = "viepn.lunar.family.v1"
    private let defaults: UserDefaults

    init(defaults: UserDefaults? = nil) {
        self.defaults = defaults ?? UserDefaults(suiteName: "group.com.viepn.widgetplus") ?? .standard
    }

    func load() -> [LunarFamilyEvent] {
        guard let data = defaults.data(forKey: key),
              let result = try? JSONDecoder().decode([LunarFamilyEvent].self, from: data) else { return [] }
        return result
    }

    @discardableResult
    func upsert(_ event: LunarFamilyEvent) -> Bool {
        guard event.isValid else { return false }
        var items = load()
        if let index = items.firstIndex(where: { $0.id == event.id }) { items[index] = event }
        else { items.append(event) }
        guard let data = try? JSONEncoder().encode(items) else { return false }
        defaults.set(data, forKey: key)
        return true
    }

    func delete(_ id: UUID) {
        let items = load().filter { $0.id != id }
        if let data = try? JSONEncoder().encode(items) { defaults.set(data, forKey: key) }
    }
}
