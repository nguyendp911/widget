# ViePN Widget+ 2.4.0 — Vietnamese Heritage UI integration

## Source of truth
- 8 independently authored scene families (Xuân Việt, Trống Đồng, Sen Ngọc, Trăng Tre, Cổng Làng, Cúc Vàng, Vạn Niên, Giỗ Nhà), each with a **Small / Medium / Large** JPEG exported for WidgetKit from a 7680×4320 master. The optimized JPEG files are committed in `Shared/Lunar/Assets.xcassets/`.
- 16 separate Vietnamese medallion icon SVGs and 3 title ribbon SVGs in the same asset catalog, with `preserves-vector-representation=true`.
- All numbers, Can Chi, sao–trực, giờ hoàng đạo, gia đình events and cultural/zodiac notes are SwiftUI text driven from local calendar algorithms, **never part of a composite screenshot**.

## Screens actually updated
- **Lịch Âm:** main hero lacquer ribbon, 4 crisp shortcut icons, widget preview; almanac medium/large shows real dynamic data and distinct vector fact icons.
- **Tiện ích:** new red lacquer navigation banner and gold-rimmed SVG category controls; existing local-first tools remain actionable.
- **Home Screen widgets:** money, tasks, bills, notes, focus each have a matching heritage artwork variant and SVG icon. Life Command uses a standalone Trống Đồng background, native text and unchanged interactive App Intents.
- **WidgetKit:** existing `containerBackground(for: .widget)` respects iOS widget layout and uses dedicated art by family; Lock Screen accessories stay monochrome per iOS conventions.

## QA gates
1. `python3 scripts/validate_source.py`.
2. `python3 scripts/validate_heritage_kit.py`.
3. `bash scripts/run_lunar_smoke.sh` (lunar dates, leap, recurrence).
4. Generate and build app + WidgetKit on macOS using `xcodegen generate` then `xcodebuild`; GitHub Action checks optimized scene names and vector asset names in **both** app and appex `Assets.car`.
5. On an actual iPhone: compare Small/Medium/Large in normal and tinted icon modes, test family events after day rollover, check 3× text sharpness.

## Notes
- A generated 8K JPEG's pixel size does not prove native 8K scene detail; for iPhone the family-specific assets and vector UI are the sharpness-critical resources.
- "Tử vi dân gian" here means customary day-zodiac and opposing-branch notes, not a personal horoscope or guaranteed prediction.
- Don't delete the installed app just to refresh visuals: existing local events may be lost. Update with the same bundle ID after signing.
