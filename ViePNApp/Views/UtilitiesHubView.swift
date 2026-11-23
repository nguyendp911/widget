import SwiftUI

/// Useful actions, all available without accounts, subscriptions or network access.
enum UtilitySection: String, CaseIterable, Identifiable {
    case money, tasks, bills, notes, focus
    var id: String { rawValue }
    var title: String {
        switch self {
        case .money: return "Chi tiêu"
        case .tasks: return "Công việc"
        case .bills: return "Hóa đơn"
        case .notes: return "Ghi chú"
        case .focus: return "Tập trung"
        }
    }
    var icon: String {
        switch self {
        case .money: return "creditcard"
        case .tasks: return "checkmark.circle"
        case .bills: return "calendar.badge.exclamationmark"
        case .notes: return "note.text"
        case .focus: return "timer"
        }
    }
}

struct UtilitiesHubView: View {
    @EnvironmentObject private var tools: UtilityStore
    @Binding var selection: UtilitySection
    @State private var showingExpense = false
    @State private var showingTask = false
    @State private var showingBill = false
    @State private var showingNote = false
    @State private var showingBudget = false

    var body: some View {
        StudioPage {
            VStack(alignment: .leading, spacing: 20) {
                StudioHeader(overline: "ViePN / Life OS", title: "Một chạm. Hữu ích.",
                             subtitle: "Ghi chi tiêu, hoàn thành việc, theo dõi hóa đơn và tập trung — không cần đăng nhập.")
                ScrollView(.horizontal) {
                    HStack(spacing: 8) {
                        ForEach(UtilitySection.allCases) { section in
                            Button { selection = section } label: {
                                AccentChip(text: section.title, icon: section.icon, active: section == selection)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .scrollIndicators(.hidden)
                HStack {
                    Text("THAO TÁC NHANH").font(.system(size: 11, weight: .heavy))
                        .tracking(1.6).foregroundStyle(.white.opacity(0.7))
                    Spacer()
                    Text("LOCAL-FIRST").font(.system(size: 10, weight: .bold))
                        .foregroundStyle(StudioPalette.mint)
                }
                switch selection {
                case .money: moneyContent
                case .tasks: tasksContent
                case .bills: billsContent
                case .notes: notesContent
                case .focus: focusContent
                }
                StudioPanel {
                    VStack(alignment: .leading, spacing: 11) {
                        Label("Đưa tiện ích lên màn hình chính", systemImage: "square.grid.2x2")
                            .font(.headline).foregroundStyle(.white)
                        Text("Nhấn giữ màn hình chính > Chỉnh sửa > Thêm tiện ích > ViePN Widget+. Chọn Sổ chi tiêu, Việc cần làm, Hóa đơn, Ghi chú hoặc Focus.")
                            .font(.caption).foregroundStyle(StudioPalette.muted)
                        Toggle("Hiện nội dung riêng tư trên widget", isOn: Binding(
                            get: { tools.snapshot.revealOnWidgets },
                            set: { tools.setRevealOnWidgets($0) }
                        ))
                        .font(.caption).tint(StudioPalette.mint)
                        .foregroundStyle(.white)
                        NavigationLink("Mở bộ sưu tập widget đã thiết kế") { MyWidgetsView() }
                            .font(.caption.bold()).foregroundStyle(StudioPalette.mint)
                    }
                }
            }
        }
        .navigationTitle("Life OS")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { tools.refresh() }
        .sheet(isPresented: $showingExpense) { NewExpenseSheet() }
        .sheet(isPresented: $showingTask) { QuickTextSheet(title: "Thêm công việc", placeholder: "Việc cần hoàn thành", save: tools.addTask) }
        .sheet(isPresented: $showingBill) { NewBillSheet() }
        .sheet(isPresented: $showingNote) { QuickTextSheet(title: "Ghi chú nhanh", placeholder: "Nhập ý tưởng hoặc điều cần nhớ", save: tools.addNote, multiline: true) }
        .sheet(isPresented: $showingBudget) { BudgetSheet() }
    }

    private var moneyContent: some View {
        VStack(spacing: 13) {
            StudioPanel {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Label("NGÂN SÁCH THÁNG", systemImage: "chart.pie.fill")
                            .font(.caption.bold()).foregroundStyle(StudioPalette.mint)
                        Spacer()
                        Button("Chỉnh sửa") { showingBudget = true }.font(.caption)
                    }
                    Text(tools.snapshot.remainingBudget().viepnVND)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(tools.snapshot.remainingBudget() >= 0 ? .white : .orange)
                        .minimumScaleFactor(0.5).lineLimit(1)
                    Text("Còn lại / \(tools.snapshot.monthlyBudget.viepnVND)")
                        .font(.caption).foregroundStyle(StudioPalette.muted)
                    ProgressView(value: Double(tools.snapshot.spentThisMonth()),
                                 total: Double(max(1, tools.snapshot.monthlyBudget)))
                        .tint(StudioPalette.mint)
                    Text("Đã chi: \(tools.snapshot.spentThisMonth().viepnVND)")
                        .font(.caption).foregroundStyle(.white.opacity(0.8))
                }
            }
            StudioPanel {
                VStack(alignment: .leading, spacing: 12) {
                    Text("GHI CHI TIÊU MỘT CHẠM").font(.caption.bold()).foregroundStyle(.white)
                    HStack(spacing: 9) {
                        ForEach([20_000, 50_000, 100_000], id: \.self) { amount in
                            Button { tools.addExpense(amount: amount, category: .food, note: "Ghi nhanh") } label: {
                                Text("+\(amount / 1000)k")
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                                    .frame(maxWidth: .infinity).padding(.vertical, 13)
                                    .background(StudioPalette.mint.opacity(0.15), in: RoundedRectangle(cornerRadius: 12))
                            }
                        }
                    }
                    .foregroundStyle(StudioPalette.mint)
                    Button { showingExpense = true } label: {
                        Label("Nhập khoản chi khác", systemImage: "plus.circle.fill")
                            .frame(maxWidth: .infinity).padding(.vertical, 10)
                    }
                    .buttonStyle(.borderedProminent).tint(StudioPalette.mint)
                }
            }
            sectionTitle("GIAO DỊCH GẦN ĐÂY")
            ForEach(Array(tools.snapshot.expenses.prefix(7))) { expense in
                StudioPanel {
                    HStack {
                        Image(systemName: expense.category.symbol).foregroundStyle(StudioPalette.mint)
                        VStack(alignment: .leading) {
                            Text(expense.note.isEmpty ? expense.category.title : expense.note)
                                .foregroundStyle(.white).lineLimit(1)
                            Text(expense.date.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption2).foregroundStyle(StudioPalette.muted)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("−" + expense.amount.viepnVND)
                                .font(.subheadline.bold()).foregroundStyle(.white)
                            Button { tools.deleteExpense(expense.id) } label: {
                                Label("Xóa", systemImage: "arrow.uturn.backward")
                                    .font(.caption2).foregroundStyle(StudioPalette.mint)
                            }
                        }
                    }
                }
            }
        }
    }

    private var tasksContent: some View {
        VStack(spacing: 12) {
            StudioPanel {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("VIỆC CHỜ HOÀN THÀNH").font(.caption.bold()).foregroundStyle(StudioPalette.mint)
                        Text("\(tools.snapshot.pendingTasks.count) việc")
                            .font(.system(size: 30, weight: .bold)).foregroundStyle(.white)
                    }
                    Spacer()
                    Button { showingTask = true } label: { Image(systemName: "plus").font(.title2.bold()) }
                        .buttonStyle(.borderedProminent).tint(StudioPalette.mint)
                }
            }
            ForEach(Array(tools.snapshot.tasks.prefix(30))) { task in
                StudioPanel {
                    Button { tools.toggleTask(task.id) } label: {
                        HStack(spacing: 13) {
                            Image(systemName: task.isComplete ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(StudioPalette.mint).font(.title3)
                            Text(task.title).strikethrough(task.isComplete)
                                .foregroundStyle(task.isComplete ? StudioPalette.muted : .white)
                            Spacer()
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            if tools.snapshot.tasks.isEmpty { emptyState("Chưa có công việc", "Tạo việc đầu tiên rồi đánh dấu hoàn thành ngay trên widget.") }
        }
    }

    private var billsContent: some View {
        VStack(spacing: 12) {
            StudioPanel {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("THEO DÕI THANH TOÁN HẰNG THÁNG").font(.caption.bold()).foregroundStyle(StudioPalette.mint)
                        Text("Không quên hóa đơn")
                            .font(.title2.bold()).foregroundStyle(.white)
                    }
                    Spacer()
                    Button { showingBill = true } label: { Image(systemName: "plus").font(.title2.bold()) }
                        .buttonStyle(.borderedProminent).tint(StudioPalette.mint)
                }
            }
            ForEach(tools.snapshot.bills) { bill in
                StudioPanel {
                    HStack(spacing: 12) {
                        Image(systemName: bill.isPaid(in: .now) ? "checkmark.seal.fill" : "exclamationmark.circle")
                            .foregroundStyle(bill.isPaid(in: .now) ? StudioPalette.mint : .orange)
                        VStack(alignment: .leading, spacing: 3) {
                            Text(bill.name).font(.headline).foregroundStyle(.white)
                            Text(bill.isPaid(in: .now) ? "Đã trả tháng này" : "Ngày \(bill.dueDay) · còn \(bill.daysUntilDue(from: .now)) ngày")
                                .font(.caption).foregroundStyle(StudioPalette.muted)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 3) {
                            Text(bill.amount.viepnVND).font(.caption.bold()).foregroundStyle(.white)
                            Button(bill.isPaid(in: .now) ? "Hoàn tác" : "Đã trả") { tools.toggleBillPaid(bill.id) }
                                .font(.caption.bold()).foregroundStyle(StudioPalette.mint)
                        }
                    }
                }
            }
            if tools.snapshot.bills.isEmpty { emptyState("Chưa có hóa đơn", "Thêm tiền điện, mạng hoặc thuê nhà để theo dõi hạn thanh toán.") }
        }
    }

    private var notesContent: some View {
        VStack(spacing: 12) {
            StudioPanel {
                HStack {
                    Text("Ý TƯỞNG CỦA BẠN").font(.caption.bold()).foregroundStyle(StudioPalette.mint)
                    Spacer()
                    Button { showingNote = true } label: {
                        Label("Viết nhanh", systemImage: "square.and.pencil")
                    }
                    .buttonStyle(.borderedProminent).tint(StudioPalette.mint)
                }
            }
            ForEach(Array(tools.snapshot.notes.prefix(20))) { note in
                StudioPanel {
                    VStack(alignment: .leading, spacing: 7) {
                        Text(note.text).foregroundStyle(.white).frame(maxWidth: .infinity, alignment: .leading)
                        Text(note.createdAt.formatted(date: .abbreviated, time: .shortened))
                            .font(.caption2).foregroundStyle(StudioPalette.muted)
                    }
                }
            }
            if tools.snapshot.notes.isEmpty { emptyState("Chưa có ghi chú", "Lưu những ý tưởng bất chợt trước khi quên.") }
        }
    }

    private var focusContent: some View {
        VStack(spacing: 12) {
            StudioPanel {
                VStack(alignment: .leading, spacing: 18) {
                    Text("DEEP FOCUS").font(.caption.bold()).tracking(2).foregroundStyle(StudioPalette.mint)
                    if let focus = tools.snapshot.activeFocus() {
                        Text(focus.endsAt, style: .timer)
                            .font(.system(size: 48, weight: .light, design: .rounded))
                            .monospacedDigit().foregroundStyle(.white)
                        Text("Đang tập trung — kết thúc lúc \(focus.endsAt.formatted(date: .omitted, time: .shortened))")
                            .font(.caption).foregroundStyle(StudioPalette.muted)
                        Button("Dừng phiên tập trung") { tools.toggleFocus() }
                            .buttonStyle(.borderedProminent).tint(.orange)
                    } else {
                        Text("25:00").font(.system(size: 48, weight: .light, design: .rounded)).foregroundStyle(.white)
                        Text("Tắt xao nhãng. Hoàn thành việc quan trọng nhất.")
                            .font(.caption).foregroundStyle(StudioPalette.muted)
                        HStack {
                            Button("Bắt đầu 25 phút") { tools.toggleFocus(25) }
                            Button("50 phút") { tools.toggleFocus(50) }
                        }
                        .buttonStyle(.borderedProminent).tint(StudioPalette.mint)
                    }
                }
            }
            emptyState("Focus Widget", "Hiển thị thời gian đếm ngược và nút bắt đầu/dừng; không cần kết nối máy chủ.")
        }
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title).font(.caption.bold()).tracking(1.5).foregroundStyle(StudioPalette.muted)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func emptyState(_ title: String, _ description: String) -> some View {
        StudioPanel {
            VStack(alignment: .leading, spacing: 7) {
                Text(title).font(.headline).foregroundStyle(.white)
                Text(description).font(.subheadline).foregroundStyle(StudioPalette.muted)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

private struct QuickTextSheet: View {
    @Environment(\.dismiss) private var dismiss
    let title: String
    let placeholder: String
    let save: (String) -> Void
    var multiline: Bool = false
    @State private var text = ""

    var body: some View {
        NavigationStack {
            Form {
                if multiline {
                    TextEditor(text: $text).frame(minHeight: 140)
                } else {
                    TextField(placeholder, text: $text)
                }
            }
            .navigationTitle(title)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Hủy") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Lưu") { save(text); dismiss() }
                        .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

private struct NewExpenseSheet: View {
    @EnvironmentObject private var tools: UtilityStore
    @Environment(\.dismiss) private var dismiss
    @State private var amount = ""
    @State private var note = ""
    @State private var category: ExpenseCategory = .food

    var body: some View {
        NavigationStack {
            Form {
                TextField("Số tiền VND", text: $amount).keyboardType(.numberPad)
                Picker("Danh mục", selection: $category) {
                    ForEach(ExpenseCategory.allCases) { kind in
                        Text(kind.title).tag(kind)
                    }
                }
                TextField("Ghi chú (không bắt buộc)", text: $note)
            }
            .navigationTitle("Thêm khoản chi")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Hủy") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Lưu") { tools.addExpense(amount: Int(amount) ?? 0, category: category, note: note); dismiss() }
                        .disabled((Int(amount) ?? 0) <= 0 || (Int(amount) ?? 0) > 1_000_000_000)
                }
            }
        }
    }
}

private struct BudgetSheet: View {
    @EnvironmentObject private var tools: UtilityStore
    @Environment(\.dismiss) private var dismiss
    @State private var amount = ""

    var body: some View {
        NavigationStack {
            Form { TextField("Ngân sách tháng (VND)", text: $amount).keyboardType(.numberPad) }
                .navigationTitle("Ngân sách tháng")
                .onAppear { amount = String(tools.snapshot.monthlyBudget) }
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) { Button("Hủy") { dismiss() } }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Lưu") { tools.setBudget(Int(amount) ?? 0); dismiss() }
                            .disabled(Int(amount) == nil || (Int(amount) ?? -1) < 0)
                    }
                }
        }
    }
}

private struct NewBillSheet: View {
    @EnvironmentObject private var tools: UtilityStore
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var amount = ""
    @State private var day = 15

    var body: some View {
        NavigationStack {
            Form {
                TextField("Tên hóa đơn", text: $name)
                TextField("Số tiền (VND)", text: $amount).keyboardType(.numberPad)
                Stepper("Ngày thanh toán: \(day)", value: $day, in: 1...28)
                Text("Chọn ngày 1–28 để hóa đơn lặp đúng mỗi tháng.")
                    .font(.caption).foregroundStyle(.secondary)
            }
            .navigationTitle("Thêm hóa đơn")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Hủy") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Lưu") { tools.addBill(name: name, amount: Int(amount) ?? 0, dueDay: day); dismiss() }
                        .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || (Int(amount) ?? 0) <= 0)
                }
            }
        }
    }
}
