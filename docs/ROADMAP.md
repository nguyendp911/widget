# Roadmap và kế hoạch viết mã — ViePN Widget+

## Sprint 0 — Khởi tạo (đã dựng source, chờ build Mac)
- Chuẩn hóa `project.yml`, App Groups, repo, CI, code review.
- Dựng 5 tab, 6 loại widget và 12 template.
- Viết editor dùng chung, JSON persistence, ảnh, AppIntent selection / habit.
- **Exit criteria:** Xcode generate và build trên Simulator thành công; fix compiler errors.

## Sprint 1 — Độ tin cậy + UX (1–2 tuần)
- Bổ sung migration dữ liệu, unit/integration tests, trạng thái lỗi rõ ràng.
- Nén ảnh với giới hạn độ phân giải, dọn ảnh orphaned, xử lý ảnh định dạng đặc biệt.
- Hỗ trợ các kích thước widget, Dynamic Type, accessibility, localization Việt/Anh.
- Cải thiện đồng hồ / countdown theo hướng hệ thống tự render thời gian.

## Sprint 2 — Studio nâng cao (2 tuần)
- Layer model: text, icon, shape, image, clock, group.
- Undo/redo, alignment/snap, lock, copy/paste layer, layout responsive size.
- Export/import theme JSON, kiểm tra độ tương phản, thêm 30–50 template.
- **Exit criteria:** cùng một design render đúng ở App Preview và WidgetKit.

## Sprint 3 — Smart Widgets (2 tuần)
- EventKit: lịch, nhắc việc (permission & empty-state).
- WeatherKit: thời tiết (Apple entitlement + caching, no real-time guarantees).
- Lunar calendar Việt Nam: nguồn thuật toán + đối chiếu lịch chính thức.
- Lock Screen widget với UI khác theo accessory families.
- **Exit criteria:** permission denial, offline, lỗi provider được xử lý.

## Sprint 4 — Pro + Cloud (1–2 tuần)
- StoreKit 2: free/pro, restore purchases, TestFlight sandbox.
- CloudKit/iCloud sync có opt-in, xử lý merge conflicts.
- Analytics tối thiểu theo hướng bảo vệ dữ liệu, privacy review.

## Sprint 5 — Release (1–2 tuần)
- Kiểm tra HIG, App Store screenshots, legal & Privacy Policy.
- TestFlight → feedback → crash triage → App Store Review.

## Backlog không cam kết
- AI sinh theme, Live Activities, theme marketplace, trợ năng mở rộng.

## Quy tắc kỹ thuật cho Codex
1. Không thêm dependency bên ngoài nếu không có lý do rõ ràng.
2. Thay đổi project target/entitlements chỉ trong `project.yml`; regenerate bằng XcodeGen.
3. Renderer SwiftUI dùng chung, giữ logic lưu trữ tách khỏi view.
4. Không thêm tính năng khiến Widget Extension yêu cầu mở app để render.
5. Mỗi PR: mô tả, ảnh/snapshot nếu UI thay đổi, kiểm thử Simulator khi có Mac.
6. Tất cả nội dung tính năng chưa có phải ghi rõ là roadmap, không giả lập dữ liệu realtime.
