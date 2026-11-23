import SwiftUI
import WidgetKit

struct LunarWidgetEntry: TimelineEntry {
    let date: Date
    let civil: SolarCivilDate
    let appearance: LunarAppearance
    let family: [LunarEventOccurrence]
}

struct LunarWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> LunarWidgetEntry { makeEntry(for: .now) }
    func getSnapshot(in context: Context, completion: @escaping (LunarWidgetEntry) -> Void) {
        completion(makeEntry(for: .now))
    }
    func getTimeline(in context: Context, completion: @escaping (Timeline<LunarWidgetEntry>) -> Void) {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = VietnameseLunarCalendar.vietnamTimeZone
        let start = calendar.startOfDay(for: Date())
        // Advance at the next Vietnam midnight. WidgetKit owns the actual refresh schedule.
        let entries: [LunarWidgetEntry] = (0..<22).compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: offset, to: start) else { return nil }
            return makeEntry(for: date)
        }
        let next = calendar.date(byAdding: .day, value: 1, to: start) ?? Date().addingTimeInterval(86400)
        completion(Timeline(entries: entries, policy: .after(next)))
    }
    private func makeEntry(for date: Date) -> LunarWidgetEntry {
        let civil = SolarCivilDate(date: date) ?? SolarCivilDate(year: 2026, month: 1, day: 1)
        let events = LunarFamilyRepository().load()
        let upcoming = LunarEventScheduler.upcoming(events: events, from: civil, count: 3, years: 2)
        return LunarWidgetEntry(date: date, civil: civil, appearance: LunarAppearanceRepository().load(), family: upcoming)
    }
}

private struct LunarWidgetContent: View {
    let entry: LunarWidgetEntry
    let kind: LunarCardKind
    @Environment(\.widgetFamily) private var family
    private var size: LunarCardSize {
        switch family {
        case .systemSmall: return .small
        case .systemLarge, .systemExtraLarge: return .large
        case .accessoryInline, .accessoryCircular, .accessoryRectangular: return .lock
        default: return .medium
        }
    }
    private var destination: URL? {
        if kind == .memorial || kind == .nextEvent, let event = entry.family.first {
            return URL(string: "viepnwidgetplus://family?event=\(event.eventID.uuidString)")
        }
        return URL(string: "viepnwidgetplus://lunar?date=\(entry.civil.year)-\(entry.civil.month)-\(entry.civil.day)")
    }
    @ViewBuilder
    var body: some View {
        if size == .lock {
            // Lock Screen accessories are intentionally monochrome and compact.
            LunarCardView(kind: kind, size: size, civil: entry.civil, appearance: entry.appearance,
                          upcomingEvents: entry.family, drawsOwnBackground: false)
                .containerBackground(.clear, for: .widget)
                .widgetURL(destination)
        } else {
            // Put the illustrated art in the actual WidgetKit background.
            // This fills the whole widget even when WidgetKit applies safe content margins.
            LunarCardView(kind: kind, size: size, civil: entry.civil, appearance: entry.appearance,
                          upcomingEvents: entry.family, drawsOwnBackground: false)
                .containerBackground(for: .widget) {
                    LunarHeritageBackground(appearance: entry.appearance, family: size.assetFamily, kind: kind)
                }
                .widgetURL(destination)
        }
    }
}

struct ViePNLunarTodayWidget: Widget {
    let kind = "ViePNLunarToday"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: LunarWidgetProvider()) { LunarWidgetContent(entry: $0, kind: .today) }
            .configurationDisplayName("Thiên Niên Việt · Hôm nay")
            .description("Ngày dương, ngày âm và Can Chi với bố cục tối giản.")
            .contentMarginsDisabled()
            .supportedFamilies([.systemSmall, .systemMedium, .accessoryInline, .accessoryRectangular])
    }
}
struct ViePNLunarNextWidget: Widget {
    let kind = "ViePNLunarNext"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: LunarWidgetProvider()) { LunarWidgetContent(entry: $0, kind: .nextEvent) }
            .configurationDisplayName("Ngày đẹp – việc nhớ")
            .description("Ngày âm và sự kiện gia đình gần nhất.")
            .contentMarginsDisabled()
            .supportedFamilies([.systemMedium])
    }
}
struct ViePNLunarMoonWidget: Widget {
    let kind = "ViePNLunarMoon"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: LunarWidgetProvider()) { LunarWidgetContent(entry: $0, kind: .moonDays) }
            .configurationDisplayName("Mùng 1 & Rằm")
            .description("Còn bao nhiêu ngày đến mùng một và ngày rằm.")
            .contentMarginsDisabled()
            .supportedFamilies([.systemSmall, .systemMedium, .accessoryRectangular, .accessoryInline])
    }
}
struct ViePNLunarFamilyWidget: Widget {
    let kind = "ViePNLunarFamily"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: LunarWidgetProvider()) { LunarWidgetContent(entry: $0, kind: .memorial) }
            .configurationDisplayName("Ngày giỗ sắp tới")
            .description("Nhớ ngày giỗ và những dịp quan trọng của gia đình.")
            .contentMarginsDisabled()
            .supportedFamilies([.systemSmall, .systemMedium, .accessoryRectangular])
    }
}
struct ViePNLunarMonthWidget: Widget {
    let kind = "ViePNLunarMonth"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: LunarWidgetProvider()) { LunarWidgetContent(entry: $0, kind: .month) }
            .configurationDisplayName("Lịch tháng âm dương")
            .description("Lịch dương và lịch âm trong từng ô ngày.")
            .contentMarginsDisabled()
            .supportedFamilies([.systemLarge])
    }
}
struct ViePNLunarTraditionWidget: Widget {
    let kind = "ViePNLunarTradition"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: LunarWidgetProvider()) { LunarWidgetContent(entry: $0, kind: .tradition) }
            .configurationDisplayName("Chi tiết ngày truyền thống")
            .description("Can Chi, tiết khí và trực theo phong tục (tham khảo).")
            .contentMarginsDisabled()
            .supportedFamilies([.systemMedium])
    }
}

 
/// The detailed widget is deliberately a separate family from the month grid.
/// Large = day, Can Chi, zodiac context, solar term, star/officer, lucky hours,
/// and the next family event. Medium keeps readable core facts.
struct ViePNLunarAlmanacWidget: Widget {
    let kind = "ViePNLunarAlmanac"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: LunarWidgetProvider()) {
            LunarWidgetContent(entry: $0, kind: .almanac)
        }
        .configurationDisplayName("Thiên Niên Việt · Can Chi")
        .description("Xem ngay âm dương, Can Chi, tiết khí, giờ tốt, ngày giỗ và tử vi dân gian.")
        .contentMarginsDisabled()
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}


/// SystemLarge is the tallest standard widget on iPhone. It cannot expand or
/// present a sheet on SpringBoard; each section opens its sheet in the host app.
struct ViePNThienNienVietWidget: Widget {
    let kind = "ViePNThienNienViet"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: LunarWidgetProvider()) { entry in
            ThienNienVietBoard(
                civil: entry.civil, appearance: entry.appearance,
                upcomingEvents: entry.family, compact: true,
                useWidgetLinks: true, drawsOwnBackground: false
            )
            .containerBackground(for: .widget) {
                LunarHeritageBackground(
                    appearance: entry.appearance, family: "Large", kind: .almanac
                )
            }
            .widgetURL(ThienNienSection.date.url(for: entry.civil))
        }
        .configurationDisplayName("Thiên Niên Việt · Toàn cảnh")
        .description("Âm dương, Can Chi, tử vi dân gian, giờ tốt, tiết khí, lễ và ngày giỗ. Chạm để xem chi tiết.")
        .contentMarginsDisabled()
        .supportedFamilies([.systemLarge])
    }
}
