import Foundation
import UIKit

/// Shared between the host application and Widget Extension via App Groups.
/// Configure the same group in both capabilities and provisioning profiles.
final class SharedRepository {
    static let appGroupID = "group.com.viepn.widgetplus"
    private let designsKey = "viepn.designs.v1"
    private let habitsKey = "viepn.habits.v1"

    private var defaults: UserDefaults {
        // Fallback helps simulator previews, but does NOT synchronize between app/extension.
        UserDefaults(suiteName: Self.appGroupID) ?? .standard
    }

    func loadDesigns() -> [WidgetDesign] {
        guard let data = defaults.data(forKey: designsKey),
              let result = try? JSONDecoder().decode([WidgetDesign].self, from: data)
        else { return [] }
        return result
    }

    func saveDesigns(_ designs: [WidgetDesign]) throws {
        let data = try JSONEncoder().encode(designs)
        defaults.set(data, forKey: designsKey)
    }

    func design(id: String?) -> WidgetDesign {
        if let id, let selected = loadDesigns().first(where: { $0.id.uuidString == id }) {
            return selected
        }
        return loadDesigns().first ?? SampleTemplates.catalog[0]
    }

    private func todayKey() -> String {
        let calendar = Calendar.current
        let parts = calendar.dateComponents([.year, .month, .day], from: Date())
        return "\(parts.year ?? 0)-\(parts.month ?? 0)-\(parts.day ?? 0)"
    }

    func isHabitComplete(id: String) -> Bool {
        let records = defaults.dictionary(forKey: habitsKey) as? [String: String] ?? [:]
        return records[id] == todayKey()
    }

    func toggleHabit(id: String) {
        var records = defaults.dictionary(forKey: habitsKey) as? [String: String] ?? [:]
        records[id] = records[id] == todayKey() ? nil : todayKey()
        defaults.set(records, forKey: habitsKey)
    }

    func saveImage(_ data: Data) throws -> String {
        guard let folder = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: Self.appGroupID
        ) else {
            throw NSError(domain: "ViePN", code: 1001, userInfo: [
                NSLocalizedDescriptionKey: "App Group chưa được cấu hình hoặc ký đúng."
            ])
        }
        let name = UUID().uuidString + ".img"
        try data.write(to: folder.appendingPathComponent(name), options: .atomic)
        return name
    }

    func image(named name: String?) -> UIImage? {
        guard let name, !name.contains("/"), !name.contains(".."),
              let folder = FileManager.default.containerURL(
                  forSecurityApplicationGroupIdentifier: Self.appGroupID
              ) else { return nil }
        return UIImage(contentsOfFile: folder.appendingPathComponent(name).path)
    }
}
