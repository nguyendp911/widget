import XCTest
@testable import ViePNWidgetPlus

final class UtilityFeaturesTests: XCTestCase {
    private func makeRepository() -> (UtilityRepository, UserDefaults) {
        let defaults = UserDefaults(suiteName: "viepn.tests.\(UUID().uuidString)")!
        return (UtilityRepository(defaults: defaults), defaults)
    }

    func testExpenseIsWholeDongAndMonthlyBudgetIsCorrect() {
        let (repository, _) = makeRepository()
        repository.setBudget(500_000)
        XCTAssertTrue(repository.addExpense(amount: 20_000, category: .food))
        XCTAssertTrue(repository.addExpense(amount: 55_000, category: .travel))
        XCTAssertFalse(repository.addExpense(amount: -5, category: .other))
        XCTAssertEqual(repository.load().spentThisMonth(), 75_000)
        XCTAssertEqual(repository.load().remainingBudget(), 425_000)
    }

    func testTasksCanToggleAndUndo() {
        let (repository, _) = makeRepository()
        XCTAssertTrue(repository.addTask("Gửi báo cáo"))
        let taskID = try! XCTUnwrap(repository.load().tasks.first?.id)
        repository.toggleTask(taskID)
        XCTAssertTrue(repository.load().pendingTasks.isEmpty)
        repository.toggleTask(taskID)
        XCTAssertEqual(repository.load().pendingTasks.count, 1)
    }

    func testBillUsesCalendarMonthAndRepeats() {
        let (repository, _) = makeRepository()
        XCTAssertTrue(repository.addBill(name: "Internet", amount: 250_000, dueDay: 25))
        XCTAssertFalse(repository.addBill(name: "Invalid", amount: 100, dueDay: 31))
        let id = try! XCTUnwrap(repository.load().bills.first?.id)
        XCTAssertNotNil(repository.load().nextUnpaidBill())
        repository.toggleBillPaid(id)
        XCTAssertNil(repository.load().nextUnpaidBill())
        repository.toggleBillPaid(id)
        XCTAssertNotNil(repository.load().nextUnpaidBill())
    }

    func testFocusStartsAndStops() {
        let (repository, _) = makeRepository()
        let reference = Date(timeIntervalSince1970: 1_800_000_000)
        repository.toggleFocus(minutes: 25, now: reference)
        XCTAssertNotNil(repository.load().activeFocus(at: reference.addingTimeInterval(200)))
        XCTAssertNil(repository.load().activeFocus(at: reference.addingTimeInterval(26 * 60)))
        repository.toggleFocus(minutes: 25, now: reference.addingTimeInterval(200))
        XCTAssertNil(repository.load().focusSession)
    }

    func testNoteIsPrivateWhenConfiguredAndPersists() {
        let (repository, _) = makeRepository()
        repository.addNote("Nhớ mua sữa")
        repository.setRevealOnWidgets(false)
        XCTAssertEqual(repository.load().latestNote?.text, "Nhớ mua sữa")
        XCTAssertFalse(repository.load().revealOnWidgets)
    }
}
