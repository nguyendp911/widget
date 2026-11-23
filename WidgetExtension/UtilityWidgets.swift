import SwiftUI
import WidgetKit
import AppIntents

// Unlike a static template, these widgets perform useful local-first actions.
struct QuickExpenseIntent: AppIntent {
    static var title: LocalizedStringResource = "Ghi chi tiêu"
    static var openAppWhenRun = false
    @Parameter(title: "Số tiền VND") var amount: Int
    init() {}
    init(amount: Int) { self.amount = amount }
    func perform() async throws -> some IntentResult {
        _ = UtilityRepository().addExpense(amount: amount, category: .food, note: "Từ widget")
        WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }
}

struct CompleteQuickTaskIntent: AppIntent {
    static var title: LocalizedStringResource = "Hoàn thành công việc"
    static var openAppWhenRun = false
    @Parameter(title: "Mã công việc") var taskID: String
    init() {}
    init(taskID: String) { self.taskID = taskID }
    func perform() async throws -> some IntentResult {
        if let id = UUID(uuidString: taskID) { UtilityRepository().toggleTask(id) }
        WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }
}

struct ToggleBillPaymentIntent: AppIntent {
    static var title: LocalizedStringResource = "Đánh dấu đã trả hóa đơn"
    static var openAppWhenRun = false
    @Parameter(title: "Mã hóa đơn") var billID: String
    init() {}
    init(billID: String) { self.billID = billID }
    func perform() async throws -> some IntentResult {
        if let id = UUID(uuidString: billID) { UtilityRepository().toggleBillPaid(id) }
        WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }
}

struct ToggleFocusSessionIntent: AppIntent {
    static var title: LocalizedStringResource = "Bắt đầu hoặc dừng tập trung"
    static var openAppWhenRun = false
    @Parameter(title: "Thời lượng phút") var minutes: Int
    init() {}
    init(minutes: Int) { self.minutes = minutes }
    func perform() async throws -> some IntentResult {
        UtilityRepository().toggleFocus(minutes: minutes)
        WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }
}

struct UtilityEntry: TimelineEntry {
    let date: Date
    let snapshot: UtilitySnapshot
}

struct UtilityProvider: TimelineProvider {
    func placeholder(in context: Context) -> UtilityEntry {
        UtilityEntry(date: .now, snapshot: UtilitySnapshot())
    }

    func getSnapshot(in context: Context, completion: @escaping (UtilityEntry) -> Void) {
        completion(UtilityEntry(date: .now, snapshot: UtilityRepository().load()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<UtilityEntry>) -> Void) {
        let now = Date()
        let snapshot = UtilityRepository().load()
        let nextUpdate = now.addingTimeInterval(30 * 60)
        var dates = [now, nextUpdate]
        if let end = snapshot.activeFocus(at: now)?.endsAt, end < nextUpdate {
            dates.append(end)
        }
        let entries = dates.sorted().map { UtilityEntry(date: $0, snapshot: snapshot) }
        completion(Timeline(entries: entries, policy: .after(nextUpdate)))
    }
}

private enum UtilityWidgetType {
    case money, tasks, bills, notes, focus
}

private struct UtilityWidgetView: View {
    let entry: UtilityEntry
    let type: UtilityWidgetType
    @Environment(\.widgetFamily) private var family

    private var compact: Bool { family == .systemSmall }
    private var snap: UtilitySnapshot { entry.snapshot }
    private var mint: Color { Color(hex: "#F2D28B") }
    private var muted: Color { Color(hex: "#F1D6BA") }

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack(spacing: 6) {
                Image("ViePNIcon" + heritageIconName)
                    .resizable().scaledToFit()
                    .frame(width: compact ? 25 : 29, height: compact ? 25 : 29)
                Text(title.uppercased())
                    .font(.system(size: compact ? 10 : 12, weight: .semibold, design: .serif))
                    .tracking(0.5)
                    .lineLimit(1)
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 4)
            .background(Color(hex: "#6A1B19").opacity(0.80), in: Capsule())
            .overlay(Capsule().stroke(Color(hex: "#DBAF5A").opacity(0.7), lineWidth: 0.8))
            Spacer(minLength: 0)
            switch type {
            case .money: money
            case .tasks: tasks
            case .bills: bills
            case .notes: notes
            case .focus: focus
            }
            Spacer(minLength: 0)
            HStack {
                Text("VIEPN · TIỆN ÍCH VIỆT")
                    .font(.system(size: 8, weight: .semibold, design: .serif))
                    .tracking(0.7).foregroundStyle(muted)
                Spacer(minLength: 0)
            }
        }
        .padding(compact ? 13 : 17)
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .containerBackground(for: .widget) {
            GeometryReader { geo in
                ZStack {
                    Color(hex: "#123E34")
                    Image(heritageBackground)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipped()
                    LinearGradient(
                        colors: [Color(hex: "#123F36").opacity(0.97),
                                 Color(hex: "#153C36").opacity(0.86),
                                 Color(hex: "#12302C").opacity(0.42)],
                        startPoint: .leading, endPoint: .trailing
                    )
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(Color(hex: "#E6B766").opacity(0.63), lineWidth: 1.2)
                        .padding(3)
                }
            }
        }
        .widgetURL(type == .notes ? URL(string: "viepnwidgetplus://notes") : nil)
    }

    private var heritageBackground: String {
        let suffix = compact ? "Small" : "Medium"
        switch type {
        case .money: return "ViePNTrongDong" + suffix
        case .tasks: return "ViePNSenNgoc" + suffix
        case .bills: return "ViePNXuanViet" + suffix
        case .notes: return "ViePNSenNgoc" + suffix
        case .focus: return "ViePNTrangTre" + suffix
        }
    }
    private var heritageIconName: String {
        switch type {
        case .money: return "GoodDay"
        case .tasks: return "GoodHours"
        case .bills: return "Calendar"
        case .notes: return "Books"
        case .focus: return "SolarTerm"
        }
    }

    private var title: String {
        switch type {
        case .money: return "Sổ chi tiêu"
        case .tasks: return "Việc cần làm"
        case .bills: return "Hóa đơn"
        case .notes: return "Ghi chú nhanh"
        case .focus: return "Deep Focus"
        }
    }
    private var icon: String {
        switch type {
        case .money: return "creditcard.fill"
        case .tasks: return "checkmark.circle.fill"
        case .bills: return "calendar.badge.clock"
        case .notes: return "note.text"
        case .focus: return "timer"
        }
    }

    private var money: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Còn lại tháng này").font(.system(size: 10)).foregroundStyle(muted)
            Text(snap.revealOnWidgets ? snap.remainingBudget(at: entry.date).viepnVND : "••••••")
                .font(.system(size: compact ? 23 : 31, weight: .bold, design: .rounded))
                .minimumScaleFactor(0.5).lineLimit(1)
            HStack(spacing: 5) {
                ForEach([20_000, 50_000, 100_000], id: \.self) { amount in
                    Button(intent: QuickExpenseIntent(amount: amount)) {
                        Text("+\(amount / 1000)k")
                            .font(.system(size: compact ? 10 : 12, weight: .bold, design: .rounded))
                            .frame(maxWidth: .infinity).padding(.vertical, 8)
                            .background(mint.opacity(0.2), in: RoundedRectangle(cornerRadius: 8))
                    }
                    .buttonStyle(.plain)
                }
            }
            .foregroundStyle(mint)
        }
    }

    private var tasks: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text("\(snap.pendingTasks.count) việc đang chờ")
                .font(.system(size: compact ? 16 : 22, weight: .bold, design: .rounded))
            if snap.pendingTasks.isEmpty {
                Text("Tất cả đã hoàn thành 🎉")
                    .font(.caption).foregroundStyle(muted)
            } else {
                ForEach(Array(snap.pendingTasks.prefix(compact ? 2 : 4))) { task in
                    Button(intent: CompleteQuickTaskIntent(taskID: task.id.uuidString)) {
                        HStack(spacing: 6) {
                            Image(systemName: "circle").foregroundStyle(mint)
                            Text(task.title).lineLimit(1)
                            Spacer(minLength: 0)
                        }
                        .font(.system(size: compact ? 10 : 12, weight: .medium))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var bills: some View {
        VStack(alignment: .leading, spacing: 7) {
            if let bill = snap.nextUnpaidBill(at: entry.date) {
                Text(bill.name).font(.system(size: compact ? 19 : 26, weight: .bold, design: .rounded))
                    .lineLimit(1).minimumScaleFactor(0.65)
                Text(snap.revealOnWidgets ? bill.amount.viepnVND : "••••••")
                    .font(.subheadline).foregroundStyle(muted)
                Text(bill.daysUntilDue(from: entry.date) < 0
                     ? "Quá hạn \(-bill.daysUntilDue(from: entry.date)) ngày"
                     : "Còn \(bill.daysUntilDue(from: entry.date)) ngày")
                    .font(.caption.bold()).foregroundStyle(bill.daysUntilDue(from: entry.date) < 0 ? .orange : mint)
                Button(intent: ToggleBillPaymentIntent(billID: bill.id.uuidString)) {
                    Label("Đã thanh toán", systemImage: "checkmark.circle")
                        .font(.system(size: 10, weight: .bold)).foregroundStyle(mint)
                }
                .buttonStyle(.plain)
            } else {
                Text("Không có hóa đơn chờ")
                    .font(.headline).foregroundStyle(mint)
                Text("Thêm hóa đơn từ ViePN Life OS")
                    .font(.caption).foregroundStyle(muted)
            }
        }
    }

    private var notes: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let latest = snap.latestNote {
                Text(snap.revealOnWidgets ? latest.text : "Nội dung đang ẩn để bảo vệ riêng tư")
                    .font(.system(size: compact ? 14 : 19, weight: .medium, design: .rounded))
                    .lineLimit(compact ? 4 : 5)
            } else {
                Text("Ghi lại ý tưởng trước khi quên.")
                    .font(.headline).lineLimit(3)
            }
            Label("Chạm để viết ghi chú", systemImage: "square.and.pencil")
                .font(.system(size: 10, weight: .medium)).foregroundStyle(mint)
        }
    }

    private var focus: some View {
        VStack(alignment: .leading, spacing: 9) {
            if let session = snap.activeFocus(at: entry.date) {
                Text(session.endsAt, style: .timer)
                    .font(.system(size: compact ? 32 : 40, weight: .light, design: .rounded))
                    .monospacedDigit().minimumScaleFactor(0.5).lineLimit(1)
                Button(intent: ToggleFocusSessionIntent(minutes: 25)) {
                    Label("Dừng", systemImage: "stop.fill")
                        .font(.caption.bold()).foregroundStyle(mint)
                }
                .buttonStyle(.plain)
            } else {
                Text("25:00")
                    .font(.system(size: compact ? 34 : 42, weight: .light, design: .rounded))
                    .monospacedDigit()
                Button(intent: ToggleFocusSessionIntent(minutes: 25)) {
                    Label("Tập trung 25 phút", systemImage: "play.fill")
                        .font(.caption.bold()).foregroundStyle(mint)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// Each widget has a separate kind so users can find and pin it immediately.
struct ViePNMoneyWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "ViePNMoney", provider: UtilityProvider()) { entry in
            UtilityWidgetView(entry: entry, type: .money)
        }
        .configurationDisplayName("Sổ chi tiêu một chạm")
        .description("Ngân sách và nút ghi chi tiêu 20k/50k/100k ngay từ màn hình chính.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct ViePNTasksWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "ViePNTasks", provider: UtilityProvider()) { entry in
            UtilityWidgetView(entry: entry, type: .tasks)
        }
        .configurationDisplayName("Việc cần làm")
        .description("Đánh dấu công việc đã hoàn thành trực tiếp trên widget.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct ViePNBillsWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "ViePNBills", provider: UtilityProvider()) { entry in
            UtilityWidgetView(entry: entry, type: .bills)
        }
        .configurationDisplayName("Hóa đơn đến hạn")
        .description("Theo dõi hóa đơn tháng và đánh dấu đã thanh toán.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct ViePNNotesWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "ViePNNotes", provider: UtilityProvider()) { entry in
            UtilityWidgetView(entry: entry, type: .notes)
        }
        .configurationDisplayName("Ghi chú nhanh")
        .description("Xem ghi chú gần nhất và mở app để ghi thêm.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct ViePNFocusWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "ViePNFocus", provider: UtilityProvider()) { entry in
            UtilityWidgetView(entry: entry, type: .focus)
        }
        .configurationDisplayName("Deep Focus 25 phút")
        .description("Bắt đầu, đếm ngược và dừng phiên tập trung từ màn hình chính.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
