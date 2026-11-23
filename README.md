# ViePN Widget+ — iOS 17+ SwiftUI Starter

A real source-code starter for **ViePN Widget+** with an iOS app, WidgetKit extension,
App Intents, shared storage, theme gallery and editable widget designs.

> Status: **Starter / not yet compiled on Xcode**. All Swift files are source files,
> not an already-built `.ipa`. macOS + Xcode is required for the first actual iOS build.

## Included

- SwiftUI app with five tabs: Home, Explore, Studio, My Widgets, Settings.
- Template gallery: 12 templates across six categories.
- Editor: title, message, font, color, border, photo selection and countdown date.
- Widget Extension: configurable per-instance design, small / medium / large.
- Interactive habit button via App Intent.
- App Groups + shared UserDefaults, image files in the shared container.
- Privacy manifests and a GitHub Actions workflow that builds an unsigned iPhone-device IPA.
- `docs/TECHNICAL_SPEC.md` and `docs/ROADMAP.md`.

## On Windows

```powershell
cd ViePN-WidgetPlus-Starter
python scripts/validate_source.py
# optionally: pip install pyyaml to enable YAML verification
code .
```

### Publish to GitHub

```powershell
git init
git add .
git commit -m "feat: ViePN Widget+ iOS starter"
git branch -M main
git remote add origin https://github.com/YOUR-ACCOUNT/ViePN-WidgetPlus.git
git push -u origin main
```

Create the **empty repository** first and replace `YOUR-ACCOUNT` above.
The included GitHub Action will attempt to build an unsigned iphoneos IPA on a macOS runner;
check its logs to discover compiler issues.

## On macOS

Install Xcode from Apple, launch it once and accept its license. Install XcodeGen:

```bash
brew install xcodegen
xcodegen generate
open ViePNWidgetPlus.xcodeproj
```

Select **ViePNWidgetPlus** scheme, configure Signing & Capabilities on *both*
app and widget targets, and enable the **same App Groups identifier**:
`group.com.viepn.widgetplus`. Set your own unique Bundle IDs and group in
`project.yml`, `Shared/Storage/SharedRepository.swift`, and generated entitlements.
Re-run `xcodegen generate` after changing the project spec.

Unsigned device IPA from Terminal (macOS):

```bash
bash scripts/build_unsigned_ipa_macos.sh
```

Unsigned Simulator build from Terminal:

```bash
xcodebuild -project ViePNWidgetPlus.xcodeproj \
  -scheme ViePNWidgetPlus -sdk iphonesimulator \
  -destination 'generic/platform=iOS Simulator' \
  CODE_SIGNING_ALLOWED=NO build
```

For a physical iPhone or App Store, use a valid Apple Developer team/signing profile.

## Using the app

1. Open **Explore** and tap a template (or create from **Studio**).
2. Edit and **save** the widget.
3. On iPhone Home Screen, long-press and use **Add Widget**.
4. Find **ViePN Widget+**, add a size, long-press it and select **Edit Widget**.
5. Choose your saved design. Each installed instance can pick its own design.

## Architecture warning

The project includes functional source paths, but no claim is made that it has been
compiled in Xcode in this Windows/Linux environment. WeatherKit, lunar calendar,
AI generation, StoreKit subscriptions, iCloud and Lock Screen widgets are **future
milestones**, not functioning features of this starter. Photo data is stored in
App Group local storage; current code does not clean orphaned photo files.

The real iOS experience may require minor API and signing adjustments against your
selected Xcode / iOS SDK. See `docs/TECHNICAL_SPEC.md` for requirements and QA.

## GitHub Actions unsigned IPA

The workflow `.github/workflows/ios-unsigned-ipa.yml` builds for `iphoneos`, disables
Xcode code signing, bundles the `.app` and widget `.appex` under `Payload/`, and uploads
`ViePN-WidgetPlus-unsigned.ipa` as an Actions artifact. Go to **Actions → ViePN
Widget+ - Unsigned IPA → latest successful run → Artifacts** to download it.

**An unsigned IPA is NOT directly installable on a standard iPhone.** You must sign
it with an appropriate development or distribution identity and compatible
provisioning entitlements before installation. This workflow does not publish to
the App Store and uses no Apple Developer certificates or private keys.


## Life OS: widgets hữu ích (2026-11)

Ngoài Living Canvas, phiên bản này có **6 widget độc lập + 1 Life Command tổng hợp** trong Widget Gallery của iOS:

| Widget | Chức năng trực tiếp | Dữ liệu |
| --- | --- | --- |
| Sổ chi tiêu | Ghi khoản chi 20k/50k/100k qua App Intents | VND, ngân sách tháng, các khoản ghi tay |
| Việc cần làm | Đánh dấu hoàn thành ngay trên widget | Danh sách công việc riêng tư |
| Hóa đơn | Xem ngày đến hạn, đánh dấu đã thanh toán | Hóa đơn lặp theo tháng (ngày 1–28) |
| Ghi chú nhanh | Xem ghi chú gần nhất, chạm mở ViePN | Ghi chú cục bộ, có tùy chọn che nội dung |
| Deep Focus | Bắt đầu/dừng phiên 25 phút, đếm ngược | Phiên tập trung cục bộ |
| Life Command | Một widget chứa ngân sách, việc, hạn hóa đơn và phiên tập trung | Tổng hợp dữ liệu đã nhập |

Trong ứng dụng, mở tab **Tiện ích (Life OS)** để nhập dữ liệu, quản lý ngân sách và tạo các mục. Widget Extension truy cập bản sao dữ liệu cục bộ bằng **App Groups**. Không có kết nối ngân hàng, không truy cập SMS, không đọc tin nhắn hay thực hiện thanh toán. Việc cập nhật widget phụ thuộc cơ chế điều phối của iOS; bộ đếm giờ dùng hiển thị thời gian của hệ thống.

### Lưu ý về dữ liệu và quyền riêng tư

- Dữ liệu được nhập thủ công và lưu trên thiết bị bằng UserDefaults trong App Group; bản prototype chưa có Cloud Sync hay mã hóa riêng cho từng bản ghi.
- Mặc định số tiền và ghi chú có thể hiển thị trên màn hình chính. Tắt **Hiện nội dung riêng tư trên widget** trong Life OS để che các thông tin này.
- Tính năng hóa đơn chỉ **theo dõi**, không trừ tiền tự động hay gửi thông báo nhắc hạn trong bản này.
- Các nút ghi chi tiêu được thiết kế một chạm. Chỉ sử dụng dữ liệu thử nghiệm trước khi lưu thông tin thật.

### Hướng dẫn build

- Windows: chạy `python scripts/validate_source.py` và chỉnh sửa code trong VS Code/Codex.
- macOS/Xcode: `brew install xcodegen`, `xcodegen generate`, chạy scheme `ViePNWidgetPlus`.
- GitHub Actions: workflow `ios-unsigned-ipa.yml` compile Simulator và thiết bị, sau đó đóng gói IPA chưa ký. Unsigned IPA không cài được bằng cách thông thường nếu chưa ký lại cả app và widget extension.
