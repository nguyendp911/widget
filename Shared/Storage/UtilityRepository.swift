import Foundation

/// Shared UserDefaults in an App Group, readable by the host and widget extension.
/// Each transaction is kept in one JSON snapshot; extend with actor/file locking if
/// multi-device syncing or high-frequency concurrent writers are introduced.
final class UtilityRepository {
    private let key = "viepn.utilities.v1"
    private let defaults: UserDefaults

    init(defaults: UserDefaults? = nil) {
        self.defaults = defaults ?? UserDefaults(suiteName: "group.com.viepn.widgetplus") ?? .standard
    }

    func load() -> UtilitySnapshot {
        guard let data = defaults.data(forKey: key),
              let result = try? JSONDecoder().decode(UtilitySnapshot.self, from: data)
        else { return UtilitySnapshot() }
        return result
    }

    private func save(_ snapshot: UtilitySnapshot) {
        if let data = try? JSONEncoder().encode(snapshot) {
            defaults.set(data, forKey: key)
        }
    }

    @discardableResult
    func addExpense(amount: Int, category: ExpenseCategory = .other, note: String = "") -> Bool {
        guard amount > 0, amount <= 1_000_000_000 else { return false }
        var snapshot = load()
        snapshot.expenses.insert(ExpenseRecord(amount: amount, category: category, note: String(note.prefix(140))), at: 0)
        save(snapshot)
        return true
    }

    @discardableResult
    func addTask(_ title: String) -> Bool {
        let cleaned = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleaned.isEmpty else { return false }
        var snapshot = load()
        snapshot.tasks.insert(QuickTask(title: String(cleaned.prefix(140))), at: 0)
        save(snapshot)
        return true
    }

    func toggleTask(_ id: UUID) {
        var snapshot = load()
        guard let i = snapshot.tasks.firstIndex(where: { $0.id == id }) else { return }
        snapshot.tasks[i].completedAt = snapshot.tasks[i].completedAt == nil ? Date() : nil
        save(snapshot)
    }

    @discardableResult
    func addBill(name: String, amount: Int, dueDay: Int) -> Bool {
        let cleaned = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleaned.isEmpty, amount > 0, (1...28).contains(dueDay) else { return false }
        var snapshot = load()
        snapshot.bills.append(RecurringBill(name: String(cleaned.prefix(80)), amount: amount, dueDay: dueDay))
        save(snapshot)
        return true
    }

    func toggleBillPaid(_ id: UUID, at date: Date = Date()) {
        var snapshot = load()
        guard let i = snapshot.bills.firstIndex(where: { $0.id == id }) else { return }
        let key = UtilitySnapshot.monthKey(date)
        snapshot.bills[i].paidMonthKey = snapshot.bills[i].paidMonthKey == key ? nil : key
        save(snapshot)
    }

    @discardableResult
    func addNote(_ text: String) -> Bool {
        let cleaned = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleaned.isEmpty else { return false }
        var snapshot = load()
        snapshot.notes.insert(QuickNote(text: String(cleaned.prefix(2000))), at: 0)
        save(snapshot)
        return true
    }

    func deleteExpense(_ id: UUID) {
        var snapshot = load()
        snapshot.expenses.removeAll { $0.id == id }
        save(snapshot)
    }

    func setBudget(_ amount: Int) {
        guard amount >= 0 else { return }
        var snapshot = load()
        snapshot.monthlyBudget = amount
        save(snapshot)
    }

    func setRevealOnWidgets(_ value: Bool) {
        var snapshot = load()
        snapshot.revealOnWidgets = value
        save(snapshot)
    }

    func toggleFocus(minutes: Int = 25, now: Date = Date()) {
        var snapshot = load()
        if snapshot.activeFocus(at: now) != nil {
            snapshot.focusSession = nil
        } else {
            snapshot.focusSession = FocusSession(startedAt: now, durationMinutes: max(1, min(180, minutes)))
        }
        save(snapshot)
    }
}
