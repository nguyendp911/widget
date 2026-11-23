import Foundation
import Combine
import UserNotifications

@MainActor
final class LunarFamilyStore: ObservableObject {
    @Published private(set) var events: [LunarFamilyEvent] = []
    @Published private(set) var notificationsAuthorized = false
    @Published var errorMessage: String?
    @Published var appearance: LunarAppearance = LunarAppearance()
    private let repository = LunarFamilyRepository()

    init() {
        reload()
        appearance = LunarAppearanceRepository().load()
    }

    func reload() {
        events = repository.load()
    }

    func save(_ event: LunarFamilyEvent) -> Bool {
        guard repository.upsert(event) else {
            errorMessage = "Ngày âm hoặc thông tin nhắc việc không hợp lệ."
            return false
        }
        refreshAfterMutation()
        return true
    }

    func setAppearance(_ value: LunarAppearance) {
        appearance = value
        LunarAppearanceRepository().save(value)
        Task { await syncNotifications() }
    }

    func delete(_ id: UUID) {
        repository.delete(id)
        refreshAfterMutation()
    }

    private func refreshAfterMutation() {
        reload()
        Task { await syncNotifications() }
    }

    /// Called on foreground / edit, without triggering a surprise permission prompt.
    func syncNotifications() async {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        notificationsAuthorized = settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional
        guard notificationsAuthorized else { return }
        do {
            try await LunarNotificationScheduler.replaceLunarNotifications(events: events, appearance: appearance)
        } catch {
            errorMessage = "Không thể tạo thông báo: \(error.localizedDescription)"
        }
    }

    func enableNotifications() async {
        do {
            notificationsAuthorized = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
            if notificationsAuthorized { await syncNotifications() }
        } catch {
            errorMessage = "Quyền thông báo chưa được cấp: \(error.localizedDescription)"
        }
    }
}

enum LunarNotificationScheduler {
    static let namespace = "viepn.lunar."

    static func replaceLunarNotifications(events: [LunarFamilyEvent], appearance: LunarAppearance) async throws {
        let center = UNUserNotificationCenter.current()
        let pending = await center.pendingNotificationRequests()
        let existing = pending.map(\.identifier).filter { $0.hasPrefix(namespace) }
        center.removePendingNotificationRequests(withIdentifiers: existing)

        // Keep below the customary OS pending-notification cap so the rest of
        // the application has room. Queue a rolling multi-year projection.
        let reminders = LunarEventScheduler.reminders(events: events, maxCount: appearance.remindMoonDays ? 32 : 40)
        let vn = VietnameseLunarCalendar.vietnamTimeZone
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = vn
        for reminder in reminders {
            let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: reminder.on)
            var localComponents = components
            localComponents.timeZone = vn
            let content = UNMutableNotificationContent()
            content.title = reminder.occurrence.daysRemaining(from: SolarCivilDate(date: reminder.on) ?? reminder.occurrence.solar) == 0
                ? "Hôm nay: \(reminder.event.title)" : "Sắp đến: \(reminder.event.title)"
            content.body = "Ngày \(reminder.occurrence.solar.label) (\(reminder.occurrence.lunar.label) âm lịch)" +
                (reminder.occurrence.isAdjustedForShortMonth ? " • Tháng thiếu, dùng ngày cuối tháng" : "")
            content.sound = .default
            content.userInfo = ["eventID": reminder.event.id.uuidString]
            let identifier = namespace + reminder.event.id.uuidString + "." + reminder.occurrence.solar.label + "." + String(Int(reminder.on.timeIntervalSince1970))
            let trigger = UNCalendarNotificationTrigger(dateMatching: localComponents, repeats: false)
            try await center.add(UNNotificationRequest(identifier: identifier, content: content, trigger: trigger))
        }
        if appearance.remindMoonDays, let civil = SolarCivilDate(date: Date()) {
            var added = 0
            let todayJDN = VietnameseLunarCalendar.jdn(civil)
            // Opt-in reminders for the next lunar first/fifteenth; never use a solar yearly RRULE.
            for offset in 0..<125 where added < 8 {
                let date = VietnameseLunarCalendar.civilDate(todayJDN + offset)
                guard let lunar = VietnameseLunarCalendar.solarToLunar(date),
                      lunar.day == 1 || lunar.day == 15,
                      let fire = date.asDate(hour: 8), fire > Date() else { continue }
                let body = UNMutableNotificationContent()
                body.title = lunar.day == 1 ? "Hôm nay là mùng 1 âm lịch" : "Hôm nay là ngày Rằm"
                body.body = "\(date.label) dương lịch · \(lunar.label) âm lịch"
                body.sound = .default
                var moonComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: fire)
                moonComponents.timeZone = vn
                let trigger = UNCalendarNotificationTrigger(dateMatching: moonComponents, repeats: false)
                try await center.add(UNNotificationRequest(identifier: namespace + "moon.\(date.label)", content: body, trigger: trigger))
                added += 1
            }
        }
    }
}
