# ViePN Widget+ — Đặc tả kỹ thuật (PRD + Engineering Spec)

**Phiên bản tài liệu:** 0.1 | **Thời điểm:** 2026-11-23  
**Định hướng:** iOS 17+, SwiftUI + WidgetKit, viết nguồn trên Windows và build trên macOS.

## 1. Mục tiêu sản phẩm

Ứng dụng cá nhân hóa Home Screen iPhone. Người dùng xem thư viện mẫu (Explore),
chọn mẫu hoặc tạo trống (Studio), chỉnh sửa trực quan (Widget Editor), lưu nhiều
mẫu (My Widgets), rồi chọn mẫu riêng cho từng widget đã thêm lên Home Screen.

**Giá trị khác biệt:** ưu tiên tiếng Việt, các mẫu đẹp, sử dụng offline, quyền riêng tư.

**Không thuộc giai đoạn starter:** WeatherKit, âm lịch chuẩn, đồng bộ đám mây,
AI tạo theme, StoreKit Pro, Live Activities, Lock Screen widget, push notification.
Chúng thuộc roadmap; không giả định đã hoạt động.

## 2. Người dùng và luồng thao tác

- U1: Mở Explore → lọc loại → chọn template → mở Editor → lưu → My Widgets.
- U2: Studio → chọn loại → chỉnh font/màu/nội dung → lưu.
- U3: Home Screen iOS → Add Widget → ViePN Widget+ → Edit Widget → chọn thiết kế.
- U4: Cập nhật thiết kế trong app → `WidgetCenter.reloadAllTimelines()`.
- U5: Habit widget → bấm nút → App Intent ghi trạng thái hôm nay → reload widget.
- U6: Photo widget → PhotosPicker → ghi ảnh vào App Group container → widget đọc ảnh.

## 3. Kiến trúc thành phần

```
  SwiftUI iOS App (Home / Explore / Studio / My Widgets / Settings)
        | writes (JSON)
        v
  SharedRepository -- App Group UserDefaults / photo files
        ^
        | reads & modifies
  WidgetKit Extension -- AppIntentConfiguration / EntityQuery
        | draws
  WidgetDesignView (renderer dùng chung)
```

- `Shared/Models`: `WidgetKind`, `WidgetDesign`, `FontPreset`, `SampleTemplates`.
- `Shared/Theme`: parse hex và Color conversion.
- `Shared/Storage`: Codable JSON + trạng thái habit + file ảnh dùng chung.
- `Shared/Views`: trình render dùng chung để preview tương đương widget.
- `ViePNApp/Stores`: ObservableObject thao tác lưu thiết kế + gọi WidgetCenter.
- `ViePNApp/Views`: màn hình SwiftUI, tạo/sửa/xóa thiết kế.
- `WidgetExtension`: `AppEntity` chọn thiết kế, `AppIntentTimelineProvider`,
  `ToggleHabitIntent`, WidgetBundle.

## 4. Data model

### WidgetDesign (Codable v1)

| Trường | Kiểu | Ý nghĩa |
| --- | --- | --- |
| id | UUID | khóa định danh thiết kế |
| name | String | tên mẫu trong Gallery/My Widgets |
| kind | WidgetKind | clock, calendar, photo, quote, countdown, habit |
| title | String | tiêu đề trên widget |
| message | String | thông điệp / mô tả |
| backgroundHex / foregroundHex / accentHex | String | màu HEX RGB |
| fontPreset | FontPreset | rounded, system, serif, monospaced |
| fontScale | Double | giới hạn UI 0.70–1.30 |
| showBorder | Bool | viền trang trí |
| targetDate | Date? | ngày đếm ngược |
| imageFileName | String? | tệp ảnh trong container App Group |

**Storage:** `viepn.designs.v1` là JSON của `[WidgetDesign]` trong
`UserDefaults(suiteName: "group.com.viepn.widgetplus")`. Tệp ảnh phải nằm trong
`FileManager.containerURL(forSecurityApplicationGroupIdentifier:)`, không lưu
binary ảnh vào UserDefaults. `viepn.habits.v1` chứa dictionary `[UUID: localDay]`.

**Đồng bộ:** app/extension cần cùng App Group và cùng Apple Team provisioning.
Trường hợp thiếu entitlement, code có fallback `.standard` để preview nhưng dữ
liệu sẽ **không** chia sẻ qua ranh giới app/extension.

**Migration:** phiên bản tiếp theo cần đóng gói schemaVersion, Codable migration,
giới hạn kích thước dữ liệu và dọn file ảnh không dùng.

## 5. Widget runtime

- `AppIntentConfiguration` cấp tùy chọn *thiết kế* cho từng instance widget.
- `DesignEntityQuery` trả danh sách thiết kế đã lưu từ App Group.
- `StudioProvider` tạo 61 timeline entries theo từng phút (xấp xỉ 1 giờ).
- `WidgetDesignView` dùng SwiftUI và có background chuẩn widget.
- `ToggleHabitIntent` cho phép đánh dấu hoàn thành ngày hiện tại.
- Các update widget do iOS kiểm soát; không cam kết chạy animation, làm mới
  liên tục hoặc cập nhật từng giây. Có thể trễ so với timeline.
- Bản starter chỉ hỗ trợ Home Screen Small/Medium/Large, chưa Lock Screen.
- Khi thiết kế đã chọn bị xóa, bản đầu sử dụng mẫu đầu tiên còn tồn tại;
  phiên bản sau cần màn hình thông báo/placeholder rõ ràng.

## 6. Chỉ tiêu phi chức năng (mục tiêu kiểm thử)

- App launch nhanh, không bắt buộc đăng nhập, không cần backend.
- Tránh lưu ảnh lớn trùng nhiều bản sao; thêm nén/crop trước bản beta.
- Bảo vệ quyền riêng tư: truy cập ảnh qua PhotosPicker, không cần quyền đọc toàn thư viện.
- VoiceOver label cho nút tương tác habit.
- Không lưu dữ liệu nhạy cảm vào log.
- Tương phản màu do user chỉnh cần cảnh báo trước bản 1.0.
- Lỗi dữ liệu hỏng: không crash, hiển thị dữ liệu mặc định.

## 7. Định nghĩa hoàn thành cho Starter

- [x] Source app SwiftUI / 5 tab có mặt trong repository.
- [x] 6 loại và 12 mẫu mặc định dưới dạng code.
- [x] Editor: văn bản, font, màu, border, ảnh, countdown.
- [x] Lưu/sửa/xóa mẫu và refresh WidgetKit được viết trong source.
- [x] Widget Extension với AppIntent chọn mẫu và nút habit.
- [x] Entitlements App Group và PrivacyInfo manifests được khai báo.
- [x] XcodeGen YAML + GitHub Actions build job + static validation.
- [ ] XcodeGen generate thành công trên macOS (chưa có môi trường).
- [ ] `xcodebuild` compile trên iOS Simulator (chưa kiểm chứng).
- [ ] QA trên iPhone thật + signing + App Group capability (chưa kiểm chứng).
- [ ] Chạy được theo quy trình TestFlight (chưa kiểm chứng).

## 8. Chiến lược kiểm thử

**Unit:** Codable round-trip, clone mẫu, đủ 6 kind.  
**Integration:** tạo, sửa, xóa, chọn per-instance widget, ảnh hiển thị,
habit toggle, reload, đồng hồ và countdown.  
**Device:** iPhone kích thước nhỏ, Dynamic Type, dark mode, VoiceOver,
locale `vi_VN`, mạng offline, reboot, update app.  
**Release:** privacy manifest, HIG, screenshot, review notes, signing,
app group, bundle ID và TestFlight.

## 9. Lộ trình CI/CD

- Windows: code bằng VS Code/Codex, chạy `scripts/validate_source.py`, git push.
- GitHub macOS runner: cài XcodeGen → tạo `.xcodeproj` → `xcodebuild` unsigned simulator.
- Mac local: Xcode project → chọn Developer Team → App Groups → build thiết bị.
- Khi sẵn sàng: archive, TestFlight, App Store Connect.

**Lưu ý:** macOS GitHub Actions là giải pháp kiểm thử build tự động; có thể phát
sinh chi phí/minutes tùy GitHub plan và dung lượng sử dụng.

## 10. API decisions / tài liệu tham khảo

- WidgetKit: https://developer.apple.com/documentation/widgetkit
- Interactive widgets: https://developer.apple.com/documentation/widgetkit/adding-interactivity-to-widgets-and-live-activities
- AppIntentConfiguration: https://developer.apple.com/documentation/widgetkit/appintentconfiguration
- App Groups: https://developer.apple.com/documentation/xcode/configuring-app-groups
- UserDefaults suiteName: https://developer.apple.com/documentation/foundation/userdefaults/init(suitename:)
- Required reason APIs: https://developer.apple.com/documentation/technotes/tn3183-adding-required-reason-api-entries-to-your-privacy-manifest
- XcodeGen: https://github.com/yonaskolb/XcodeGen
