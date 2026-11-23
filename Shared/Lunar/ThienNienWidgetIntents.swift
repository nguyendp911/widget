import Foundation
import AppIntents
import WidgetKit

/// Shared focus between an App Intent interaction and WidgetKit's next snapshot.
/// No app launch is required to change which section the Large widget displays.
enum ThienNienWidgetFocusStore {
    private static let key = "viepn.thiennien.widget.focus.v1"
    private static var defaults: UserDefaults {
        UserDefaults(suiteName: "group.com.viepn.widgetplus") ?? .standard
    }

    static func load() -> ThienNienSection? {
        guard let value = defaults.string(forKey: key) else { return nil }
        return ThienNienSection(rawValue: value)
    }

    static func save(_ section: ThienNienSection?) {
        if let section { defaults.set(section.rawValue, forKey: key) }
        else { defaults.removeObject(forKey: key) }
    }
}

/// iOS 17+ interactive widget action. Unlike a Link, this does NOT launch the app.
struct ThienNienSelectSectionIntent: AppIntent {
    static var title: LocalizedStringResource = "Xem mục Thiên Niên Việt"
    static var description = IntentDescription("Hiện chi tiết ngay trên widget, không mở ứng dụng.")
    static var openAppWhenRun: Bool = false

    @Parameter(title: "Mục")
    var sectionID: String

    init() {}
    init(section: ThienNienSection) {
        sectionID = section.rawValue
    }

    func perform() async throws -> some IntentResult {
        guard let section = ThienNienSection(rawValue: sectionID) else { return .result() }
        ThienNienWidgetFocusStore.save(section)
        WidgetCenter.shared.reloadTimelines(ofKind: "ViePNThienNienViet")
        return .result()
    }
}

/// Back to the full calendar without leaving the Home Screen.
struct ThienNienBackIntent: AppIntent {
    static var title: LocalizedStringResource = "Quay lại Thiên Niên Việt"
    static var openAppWhenRun: Bool = false

    init() {}

    func perform() async throws -> some IntentResult {
        ThienNienWidgetFocusStore.save(nil)
        WidgetCenter.shared.reloadTimelines(ofKind: "ViePNThienNienViet")
        return .result()
    }
}
