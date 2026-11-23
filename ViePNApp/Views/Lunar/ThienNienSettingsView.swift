import SwiftUI

struct ThienNienSettingsView: View {
    @EnvironmentObject private var family: LunarFamilyStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Form {
            Section("Giao diện Thiên Niên Việt") {
                Picker("Chủ đề", selection: appearanceBinding(\.theme)) {
                    ForEach(LunarTheme.featured) { option in
                        Text(option.title).tag(option)
                    }
                }
                Picker("Tranh nền", selection: appearanceBinding(\.artwork)) {
                    ForEach(LunarArtwork.allCases) { option in
                        Text(option.title).tag(option)
                    }
                }
            }
            Section("Lời nhắc lịch âm") {
                Toggle("Nhắc mùng 1 và ngày Rằm", isOn: appearanceBinding(\.remindMoonDays))
                Button {
                    Task { await family.enableNotifications() }
                } label: {
                    Label("Cho phép thông báo", systemImage: "bell.badge")
                }
                Text("Ngày giỗ sẽ được quy đổi lại cho từng năm âm lịch. Ứng dụng làm mới các thông báo khi bạn mở lại.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Section("Dữ liệu gia đình") {
                Text("Lịch giỗ được lưu trên thiết bị trong vùng dữ liệu ViePN hiện có. Giữ nguyên bundle ID để tránh mất dữ liệu khi cập nhật.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Section("Thông tin") {
                Text("Thiên Niên Việt — Lịch âm Việt Nam UTC+7")
                Text("Can Chi, tử vi dân gian và ngày tốt xấu mang tính tham khảo văn hóa.")
                    .font(.caption).foregroundStyle(.secondary)
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color(hex: "#F3E8D6"))
        .navigationTitle("Cài đặt")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Đóng") { dismiss() }
            }
        }
    }

    private func appearanceBinding<T>(_ keyPath: WritableKeyPath<LunarAppearance,T>) -> Binding<T> {
        Binding(
            get: { family.appearance[keyPath: keyPath] },
            set: { newValue in
                var updated = family.appearance
                updated[keyPath: keyPath] = newValue
                family.setAppearance(updated)
            }
        )
    }
}
