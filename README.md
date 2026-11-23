# THIÊN NIÊN VIỆT — Lịch Âm iOS

Ứng dụng iPhone độc lập, chỉ tập trung vào **Lịch Âm Việt Nam**. Tái cấu trúc từ ViePN Widget+ ngày 24/11/2026.

## Tính năng hiện có
- Lịch âm–dương theo Việt Nam (UTC+7), tháng nhuận, lịch tháng có ngày âm trong từng ô.
- Can Chi ngày/tháng/năm, 24 tiết khí, giờ hoàng đạo, sao–trực, quan niệm ngày tốt–xấu (mang tính tham khảo).
- Tử vi dân gian ở mức con giáp của ngày/năm và tuổi xung; không phải lá số cá nhân.
- Ngày giỗ và sự kiện gia đình: lưu theo lịch âm, lặp lại từng năm, kiểm soát tháng nhuận, chính sách tháng thiếu, nhắc trước/đúng ngày.
- Xuất lịch giỗ nhiều năm thành file iCalendar (.ics); xem lễ Việt, mùng 1 và Rằm.
- Màn hình chính dạng bảng dọc cuộn được; chạm từng mục mở sheet chi tiết trong app.
- Giao diện Việt: giấy dó, đỏ son, vàng đồng và tranh minh họa Việt.

## Không còn trong ứng dụng
Widget Extension, Widget Studio, Today dashboard, Life OS, chi tiêu, checklist, gallery, canvas, và các App Intents dành riêng cho Home Screen widget.

## Xây dựng trên Windows + GitHub/macOS
```sh
brew install xcodegen
xcodegen generate
xcodebuild -project ThienNienViet.xcodeproj -scheme ViePNWidgetPlus \
  -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' \
  CODE_SIGNING_ALLOWED=NO build
```
GitHub Actions có thể tạo IPA **chưa ký** trên macOS; IPA cần ký trước khi cài lên iPhone.

## Giữ dữ liệu từ bản trước
- Bundle ID vẫn là `com.viepn.widgetplus`, và App Group `group.com.viepn.widgetplus` được giữ để dữ liệu lịch giỗ không bị chuyển sang kho dữ liệu khác.
- **Không gỡ ứng dụng cũ** nếu cần giữ lịch giỗ; cập nhật bằng bản đã ký với cùng Team ID và entitlements phù hợp.
- Có nhánh sao lưu `archive/widget-plus-before-lunar-only-2026-11-24` chứa bản ViePN Widget+ đầy đủ. Git history vẫn còn.
- Khi cập nhật lên app không có widget extension, các widget cũ trên Home Screen sẽ không còn hoạt động.

## Mục tiêu tiếp theo
Kiểm chứng thông báo lịch giỗ qua các năm, nâng cấp danh sách sự kiện gia đình, xây dựng lịch tuần/năm, tra cứu thuận tiện và hoàn thiện tính khả dụng theo Accessibility.
