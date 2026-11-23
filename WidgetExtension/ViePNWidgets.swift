import SwiftUI
import WidgetKit
import AppIntents

/// A dynamic entity lets each installed widget choose a different saved design.
struct DesignEntity: AppEntity {
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Thiết kế Widget"
    static var defaultQuery = DesignEntityQuery()

    let id: String
    let name: String

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)")
    }
}

struct DesignEntityQuery: EntityQuery {
    func entities(for identifiers: [DesignEntity.ID]) async throws -> [DesignEntity] {
        SharedRepository().loadDesigns()
            .filter { identifiers.contains($0.id.uuidString) }
            .map { DesignEntity(id: $0.id.uuidString, name: $0.name) }
    }

    func suggestedEntities() async throws -> [DesignEntity] {
        SharedRepository().loadDesigns().map {
            DesignEntity(id: $0.id.uuidString, name: $0.name)
        }
    }
}

struct SelectDesignIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Chọn thiết kế"
    static var description = IntentDescription("Chọn một widget đã lưu trong ViePN Studio.")

    @Parameter(title: "Thiết kế")
    var design: DesignEntity?
}

struct ToggleHabitIntent: AppIntent {
    static var title: LocalizedStringResource = "Đánh dấu thói quen"
    static var openAppWhenRun: Bool = false

    @Parameter(title: "Mã thiết kế")
    var designID: String

    init() {}
    init(designID: String) { self.designID = designID }

    func perform() async throws -> some IntentResult {
        SharedRepository().toggleHabit(id: designID)
        WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }
}

struct StudioEntry: TimelineEntry {
    let date: Date
    let design: WidgetDesign
    let habitCompleted: Bool
}

struct StudioProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> StudioEntry {
        StudioEntry(date: .now, design: SampleTemplates.catalog[0], habitCompleted: false)
    }

    func snapshot(for configuration: SelectDesignIntent, in context: Context) async -> StudioEntry {
        makeEntry(date: .now, selectedID: configuration.design?.id)
    }

    func timeline(for configuration: SelectDesignIntent, in context: Context) async -> Timeline<StudioEntry> {
        let now = Date()
        // Hourly entries let the Command Center switch between morning, focus and
        // evening states. WidgetKit may delay rendering according to its budget.
        let start = Calendar.current.dateInterval(of: .hour, for: now)?.start ?? now
        let entries = (0..<26).compactMap { offset -> StudioEntry? in
            guard let next = Calendar.current.date(byAdding: .hour, value: offset, to: start) else {
                return nil
            }
            return makeEntry(date: next, selectedID: configuration.design?.id)
        }
        return Timeline(entries: entries, policy: .atEnd)
    }

    private func makeEntry(date: Date, selectedID: String?) -> StudioEntry {
        let repo = SharedRepository()
        let design = repo.design(id: selectedID)
        return StudioEntry(date: date, design: design,
                           habitCompleted: repo.isHabitComplete(id: design.id.uuidString))
    }
}

struct StudioWidgetEntryView: View {
    let entry: StudioEntry

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            WidgetDesignView(design: entry.design, date: entry.date, habitCompleted: entry.habitCompleted)
            if entry.design.kind == .habit {
                Button(intent: ToggleHabitIntent(designID: entry.design.id.uuidString)) {
                    Image(systemName: entry.habitCompleted ? "checkmark.circle.fill" : "circle")
                        .font(.title3)
                        .foregroundStyle(entry.design.accentColor)
                        .padding(10)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Đánh dấu hoàn thành")
            }
        }
        .containerBackground(entry.design.backgroundColor, for: .widget)
    }
}

struct ViePNStudioWidget: Widget {
    let kind = "ViePNStudioWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: SelectDesignIntent.self, provider: StudioProvider()) { entry in
            StudioWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("ViePN Widget+")
        .description("Chọn widget đã thiết kế trong ViePN Studio.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

@main
struct ViePNWidgetBundle: WidgetBundle {
    var body: some Widget {
        ViePNStudioWidget()
        ViePNLunarTodayWidget()
        ViePNLunarNextWidget()
        ViePNLunarMoonWidget()
        ViePNLunarFamilyWidget()
        ViePNLunarMonthWidget()
        ViePNLunarTraditionWidget()
        ViePNLunarAlmanacWidget()
        ViePNThienNienVietWidget()
        ViePNMoneyWidget()
        ViePNTasksWidget()
        ViePNBillsWidget()
        ViePNNotesWidget()
        ViePNFocusWidget()
        ViePNDailyBriefWidget()
    }
}
