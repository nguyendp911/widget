import SwiftUI

struct LunarEventEditorView: View {
    @EnvironmentObject private var family: LunarFamilyStore
    @Environment(\.dismiss) private var dismiss
    @State private var event: LunarFamilyEvent
    @State private var reminders: Set<Int>
    @State private var confirmedDelete = false

    private let editingExisting: Bool

    init(editing: LunarFamilyEvent? = nil) {
        let initial = editing ?? LunarFamilyEvent(title: "", kind: .memorial, lunarDay: 1, lunarMonth: 1)
        _event = State(initialValue: initial)
        _reminders = State(initialValue: Set(initial.reminderDaysBefore))
        editingExisting = editing != nil
    }

    var body: some View {
        Form {
            Section("Sự kiện gia đình") {
                TextField("Tên người thân / sự kiện", text: $event.title)
                Picker("Loại", selection: $event.kind) {
                    ForEach(FamilyEventKind.allCases) { item in Text(item.label).tag(item) }
                }
                TextField("Ghi chú", text: $event.note, axis: .vertical).lineLimit(2...4)
            }
            Section("Ngày âm lịch gốc") {
                Picker("Ngày", selection: $event.lunarDay) {
                    ForEach(1...30, id: \.self) { Text("\($0)").tag($0) }
                }
                Picker("Tháng", selection: $event.lunarMonth) {
                    ForEach(1...12, id: \.self) { Text("Tháng \($0)").tag($0) }
                }
                Picker("Tháng nhuận", selection: $event.leapRule) {
                    ForEach(LunarLeapRule.allCases) { Text($0.label).tag($0) }
                }
                if event.lunarDay == 30 {
                    Picker("Năm không có ngày 30", selection: $event.missingDayRule) {
                        ForEach(MissingLunarDayRule.allCases) { Text($0.label).tag($0) }
                    }
                }
                Text("Ngày giỗ được quy đổi riêng từng năm. Mặc định dùng tháng thường; không chuyển giỗ sang tháng nhuận nếu bạn không chọn.")
                    .font(.caption).foregroundStyle(.secondary)
            }
            Section("Nhắc trước ngày giỗ") {
                ForEach([30, 7, 3, 1, 0], id: \.self) { days in
                    Toggle(days == 0 ? "Nhắc đúng ngày" : "Nhắc trước \(days) ngày", isOn: Binding(
                        get: { reminders.contains(days) },
                        set: { if $0 { reminders.insert(days) } else { reminders.remove(days) } }
                    ))
                }
                Picker("Giờ nhắc", selection: $event.reminderHour) {
                    ForEach(0..<24, id: \.self) { Text(String(format: "%02d:00", $0)).tag($0) }
                }
                Text("Nhắc theo giờ Việt Nam (UTC+7), kể cả khi đang ở nước ngoài.")
                    .font(.caption).foregroundStyle(.secondary)
            }
            Section("Kiểm tra các năm sắp tới") {
                let fromYear = SolarCivilDate(date: Date())?.year ?? 2026
                ForEach(fromYear...(fromYear + 5), id: \.self) { year in
                    let dates = LunarEventScheduler.inLunarYear(event, year: year)
                    HStack {
                        Text("\(year)")
                        Spacer()
                        if dates.isEmpty {
                            Text("Không có lần lặp").foregroundStyle(.secondary)
                        } else {
                            VStack(alignment: .trailing) {
                                ForEach(dates) { o in
                                    Text(o.solar.label + (o.isAdjustedForShortMonth ? " (tháng thiếu)" : ""))
                                }
                            }.foregroundStyle(.secondary)
                        }
                    }.font(.caption)
                }
            }
            Section {
                Button {
                    event.reminderDaysBefore = Array(reminders).sorted(by: >)
                    if family.save(event) { dismiss() }
                } label: {
                    Label(editingExisting ? "Lưu thay đổi" : "Lưu sự kiện", systemImage: "checkmark.circle.fill")
                        .frame(maxWidth: .infinity)
                }
                .disabled(event.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                if editingExisting {
                    Button("Xóa sự kiện", role: .destructive) { confirmedDelete = true }
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .navigationTitle(editingExisting ? "Sửa lịch giỗ" : "Thêm ngày giỗ")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { ToolbarItem(placement: .topBarLeading) { Button("Đóng") { dismiss() } } }
        .confirmationDialog("Xóa sự kiện và các lời nhắc?", isPresented: $confirmedDelete) {
            Button("Xóa", role: .destructive) { family.delete(event.id); dismiss() }
        }
    }
}
