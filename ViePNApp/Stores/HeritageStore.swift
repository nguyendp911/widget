import Foundation
import Combine

/// Additional local family information. Kept separate from the legacy event
/// schema, so an update cannot erase a user's existing anniversaries.
@MainActor
final class HeritageStore: ObservableObject {
    @Published var tasks: [String: [HeritageTask]] = [:] { didSet { persist() } }
    @Published var people: [HeritagePerson] = [] { didSet { persist() } }
    @Published var memories: [HeritageMemory] = [] { didSet { persist() } }
    @Published var storageError: String?
    private var loading = true
    private let url: URL

    init() {
        let root = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        url = root.appendingPathComponent("thien-nien-family-v1.json")
        if let data = try? Data(contentsOf: url) {
            do {
                let a = try JSONDecoder().decode(HeritageArchive.self, from: data)
                tasks = a.tasks; people = a.people; memories = a.memories
            } catch { storageError = "Không đọc được sổ gia đình. Tệp gốc vẫn được giữ."; return }
        }
        loading = false
    }

    private func persist() {
        guard !loading else { return }
        do {
            try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
            let data = try JSONEncoder().encode(archive(events: []))
            try data.write(to: url, options: [.atomic, .completeFileProtectionUntilFirstUserAuthentication])
            storageError = nil
        } catch { storageError = "Không lưu được dữ liệu: \(error.localizedDescription)" }
    }

    func archive(events: [LunarFamilyEvent]) -> HeritageArchive {
        HeritageArchive(events: events, tasks: tasks, people: people, memories: memories)
    }

    func merge(_ a: HeritageArchive) {
        for (key, value) in a.tasks where tasks[key] == nil { tasks[key] = value }
        for person in a.people where !people.contains(where: { $0.id == person.id }) { people.append(person) }
        for memory in a.memories where !memories.contains(where: { $0.id == memory.id }) { memories.append(memory) }
    }
}
