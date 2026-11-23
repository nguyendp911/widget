# ViePN Widget+ — iOS 17+ · Living Canvas + Life OS + Thiên Niên Việt

SwiftUI iPhone app with WidgetKit, App Intents, App Groups, a visual widget editor, daily utility widgets and a **Vietnamese lunar family calendar**.

## Where to find Lịch Âm

Open the bottom tab **Lịch Âm** (moon icon), next to Today. Browse solar/lunar dates in day, week, month and year modes; add recurring lunar anniversaries/memorials under **Những ngày không quên**, and enable notifications.

### Vietnamese Heritage assets (v2.2.4)

The attached Vietnamese art sheet has been separated into **17 actual raster resources** under `Shared/Lunar/Assets.xcassets/`: six illustrated calendar backgrounds, four lunar badges (Mùng 1, Rằm, Ngày Giỗ, Nhuận), and seven ornaments (lotus, bamboo, peach blossom, lantern, cloud, village gate, Đông Sơn drum). A matching 1024px ViePN app icon is included.

In-app: **Lịch Âm → Cá nhân hóa → TRANH NỀN TỪ BỘ ASSET VIỆT**. Choose Tự động, Không ảnh or one of six illustrations. Use the theme picker for Minimal Zen, Vietnamese Heritage, Luxury Dark, Tết and Mid-Autumn. Existing saved settings remain compatible.

The same appearance is used in in-app previews and Widget Extension. The illustrated backgrounds receive a translucent overlay to keep dates and family events readable. Minimal Zen stays restrained by default.

## WidgetKit

Lunar widgets: Hôm nay âm lịch, Ngày đẹp – việc nhớ, Mùng 1 / Rằm, Ngày giỗ sắp tới, Lịch tháng âm dương, Ngày truyền thống. Additional utilities: budget/expense, tasks, bills, notes, focus timer, Life Command; and custom Living Canvas widgets.

To add a lunar widget: long-press iPhone Home Screen → **Edit → Add Widget → ViePN Widget+** → choose a lunar widget. Size support varies by widget.

## Source and unsigned IPA builds

This is the source repository, including XcodeGen `project.yml` and GitHub Actions workflow `.github/workflows/ios-unsigned-ipa.yml`.

Windows (edit / validate):

```powershell
python scripts/validate_source.py
code .
```

macOS (generate / build):

```bash
brew install xcodegen
xcodegen generate
bash scripts/build_unsigned_ipa_macos.sh
```

GitHub Actions builds on macOS and uploads `ViePN-WidgetPlus-unsigned-IPA` in the run's **Artifacts** section. An unsigned IPA **cannot be installed** on a normal iPhone without valid signing for the app, Widget Extension and matching App Groups entitlements.

## Accuracy and assets

The lunar algorithm uses Vietnam timezone UTC+7 and supports leap lunar months. Recurring memorial dates are recalculated from lunar dates for each year. Local notifications are scheduled in a rolling queue and require app refresh because of iOS pending notification limits; a multi-year ICS export is available.

The 17 art resources are cropped from a **user-provided JPG collage**, not native vector artwork. Transparent PNG edges may retain minor JPEG artifacts. Check artwork distribution rights before App Store release.

More details: `docs/HERITAGE_ASSETS.md`, `docs/TECHNICAL_SPEC.md` and `docs/ROADMAP.md`.


## Thiên Niên Việt — Heritage UI v2.2.7
The user's original Vietnamese asset sheet is now represented by 17 original illustrated assets plus 33 additional cropped assets, in both the iOS app and Widget Extension. Assets include 6 background panels, 4 status badges, 7 ornamental motifs, 10 function icons, 10 festival pictograms, 3 title ribbons, 6 navigation images and 4 decorative patterns. These are dynamic UI components, not only backgrounds.

Run `python3 scripts/validate_heritage_kit.py` to verify all 33 new imagesets. GitHub Actions also verifies representative names in the built App and Widget Extension Assets.car before packaging the unsigned IPA.
