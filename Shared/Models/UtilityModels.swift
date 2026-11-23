import Foundation

// Everything in this module is local-first. No bank, shipping or health API access.
enum ExpenseCategory: String, CaseIterable, Codable, Identifiable {
    case food, travel, shopping, bills, other
    var id: String { rawValue }
    var title: String {
        switch self {
        case .food: return "Ăn uống"
        case .travel: return "Di chuyển"
        case .shopping: return "Mua sắm"
        case .bills: return "Hóa đơn"
        case .other: return "Khác"
        }
    }
    var symbol: String {
        switch self {
        case .food: return "fork.knife"
        case .travel: return "car.fill"
        case .shopping: return "bag.fill"
        case .bills: return "doc.text.fill"
        case .other: return "square.grid.2x2.fill"
        }
    }
}

struct ExpenseRecord: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var amount: Int // Whole Vietnamese dong; never use floating point for money.
    var category: ExpenseCategory
    var note: String
    var date: Date = Date()
}

struct QuickTask: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var title: String
    var createdAt: Date = Date()
    var completedAt: Date? = nil
    var isComplete: Bool { completedAt != nil }
}

struct RecurringBill: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var name: String
    var amount: Int
    var dueDay: Int // 1...28 to guarantee this day exists in every month.
    var paidMonthKey: String? = nil

    func isPaid(in date: Date, calendar: Calendar = .current) -> Bool {
        paidMonthKey == UtilitySnapshot.monthKey(date, calendar: calendar)
    }

    func daysUntilDue(from date: Date, calendar: Calendar = .current) -> Int {
        let components = calendar.dateComponents([.year, .month], from: date)
        var due = DateComponents(year: components.year, month: components.month, day: max(1, min(28, dueDay)))
        due.calendar = calendar
        guard let dueDate = calendar.date(from: due) else { return 0 }
        return calendar.dateComponents([.day], from: calendar.startOfDay(for: date), to: dueDate).day ?? 0
    }
}

struct QuickNote: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var text: String
    var createdAt: Date = Date()
}

struct FocusSession: Codable, Equatable {
    var startedAt: Date
    var durationMinutes: Int
    var endsAt: Date { startedAt.addingTimeInterval(TimeInterval(durationMinutes * 60)) }
    func isActive(at date: Date = Date()) -> Bool { date < endsAt }
}

struct UtilitySnapshot: Codable, Equatable {
    var expenses: [ExpenseRecord] = []
    var tasks: [QuickTask] = []
    var bills: [RecurringBill] = []
    var notes: [QuickNote] = []
    var monthlyBudget: Int = 3_000_000
    var focusSession: FocusSession? = nil
    var revealOnWidgets: Bool = true

    static func monthKey(_ date: Date, calendar: Calendar = .current) -> String {
        let c = calendar.dateComponents([.year, .month], from: date)
        return String(format: "%04d-%02d", c.year ?? 0, c.month ?? 0)
    }

    func spentThisMonth(at date: Date = Date(), calendar: Calendar = .current) -> Int {
        expenses.filter { calendar.isDate($0.date, equalTo: date, toGranularity: .month) }
            .reduce(0) { $0 + max(0, $1.amount) }
    }

    func remainingBudget(at date: Date = Date()) -> Int {
        monthlyBudget - spentThisMonth(at: date)
    }

    var pendingTasks: [QuickTask] {
        tasks.filter { !$0.isComplete }.sorted { $0.createdAt < $1.createdAt }
    }

    func nextUnpaidBill(at date: Date = Date()) -> RecurringBill? {
        bills.filter { !$0.isPaid(in: date) }
            .sorted { $0.daysUntilDue(from: date) < $1.daysUntilDue(from: date) }.first
    }

    var latestNote: QuickNote? {
        notes.max(by: { $0.createdAt < $1.createdAt })
    }

    func activeFocus(at date: Date = Date()) -> FocusSession? {
        guard let focusSession, focusSession.isActive(at: date) else { return nil }
        return focusSession
    }
}

extension Int {
    var viepnVND: String { self.formatted(.number.grouping(.automatic)) + " đ" }
}
