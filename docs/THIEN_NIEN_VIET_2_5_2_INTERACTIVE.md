# Thiên Niên Việt 2.5.2 — Trải nghiệm widget tương tác tại chỗ

## Giới hạn nền tảng
iPhone Home Screen WidgetKit chỉ cho phép các kích thước cố định (Small, Medium, Large). Không thể kéo widget dài xuyên suốt màn hình hoặc mở một modal nổi phía trên SpringBoard.

## Hai hình thức sử dụng

### Widget Large trên Home Screen — không mở ứng dụng
- Ấn **Can Chi, Tử vi dân gian, Sao–Trực, Giờ tốt, Tiết khí, Ngày giỗ, Mùng 1/Rằm, Lịch tháng** để chuyển sang **trang chi tiết bên trong chính widget**.
- Hành động chạy bằng `Button(intent: ThienNienSelectSectionIntent)`, `openAppWhenRun=false`.
- App Group lưu mục đang xem, WidgetKit được yêu cầu làm mới timeline; nút **Quay lại** qua `ThienNienBackIntent` khôi phục bảng tổng hợp.
- Không dùng `widgetURL` trên widget tổng hợp để tránh việc nhấp mục lại mở ứng dụng.
- Thời gian thay đổi nội dung có thể bị hệ thống điều phối; kiểm tra thực tế trên iPhone thật.

### Ứng dụng Thiên Niên Việt — sheet giàu nội dung
- Bảng lịch dạng dọc và có thể cuộn.
- Mỗi mục mở `ThienNienDetailSheet` bằng `.sheet(item:)`.
- Khi mở qua URL `viepnwidgetplus://lunar?detail=...`, `RootTabView` xử lý URL trực tiếp và hiện sheet, tránh tình trạng tab con chưa kịp nhận liên kết.
- Các mục sâu như thêm ngày giỗ vẫn cần ứng dụng, do WidgetKit không thể nhập văn bản tự do trong widget.

## QA
- Xcode build iOS Simulator và iphoneos.
- XCTest lưu/chuyển mục đang xem trong App Group.
- Screenshot hai trạng thái trong ứng dụng: trang chủ và modal Can Chi.
- Nghiệm thu iPhone thật: kích thước cố định Large, các nút App Intent không mở app, trả lại widget tổng hợp và cập nhật khi ngày âm đổi.
