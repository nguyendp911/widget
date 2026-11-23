import SwiftUI

struct SettingsView: View {
    var body: some View {
        List {
            Section("Thông tin") {
                LabeledContent("Ứng dụng", value: "ViePN Widget+")
                LabeledContent("Phiên bản", value: "0.1.0 Starter")
                LabeledContent("iOS tối thiểu", value: "17.0")
            }
            Section("Thêm widget lên iPhone") {
                Text("1. Lưu một thiết kế trong Widget Studio.")
                Text("2. Nhấn giữ vùng trống trên Home Screen, chọn Thêm Widget.")
                Text("3. Tìm ViePN Widget+, chọn kích thước và thêm.")
                Text("4. Nhấn giữ widget, chọn Sửa Widget, rồi chọn thiết kế đã lưu.")
            }
            Section("Dữ liệu") {
                Text("Bản starter lưu dữ liệu cục bộ qua App Groups; chưa gửi dữ liệu tới máy chủ.")
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Settings")
    }
}
