import Foundation
import SwiftUI
import WidgetKit

@MainActor
final class UtilityStore: ObservableObject {
    @Published private(set) var snapshot: UtilitySnapshot
    private let repository = UtilityRepository()

    init() { snapshot = repository.load() }

    func refresh() { snapshot = repository.load() }

    private func update() {
        refresh()
        WidgetCenter.shared.reloadAllTimelines()
    }

    func addExpense(amount: Int, category: ExpenseCategory, note: String = "") {
        guard repository.addExpense(amount: amount, category: category, note: note) else { return }
        update()
    }
    func deleteExpense(_ id: UUID) { repository.deleteExpense(id); update() }
    func setBudget(_ amount: Int) { repository.setBudget(amount); update() }
    func addTask(_ title: String) { guard repository.addTask(title) else { return }; update() }
    func toggleTask(_ id: UUID) { repository.toggleTask(id); update() }
    func addBill(name: String, amount: Int, dueDay: Int) {
        guard repository.addBill(name: name, amount: amount, dueDay: dueDay) else { return }
        update()
    }
    func toggleBillPaid(_ id: UUID) { repository.toggleBillPaid(id); update() }
    func addNote(_ text: String) { guard repository.addNote(text) else { return }; update() }
    func toggleFocus(_ minutes: Int = 25) { repository.toggleFocus(minutes: minutes); update() }
    func setRevealOnWidgets(_ value: Bool) { repository.setRevealOnWidgets(value); update() }
}
