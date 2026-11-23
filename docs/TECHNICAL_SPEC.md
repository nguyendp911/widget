# ViePN Widget+ — Living Canvas v2 Technical Specification

## Scope
- iOS >= 17.0; Swift 5 language mode; SwiftUI app and WidgetKit extension.
- Offline-first, without mandatory sign-in or service API keys.
- User creates, edits, shares and installs configurable Home Screen widgets.
- macOS GitHub Actions builds an unsigned IPA intended for later codesigning.

## Data architecture
`WidgetDesign` preserves v1 fields and adds `scene: LivingScene?`, `layers: [CanvasLayer]` and `smartGoals: [String]`. Custom `init(from:)` supplies migration defaults. V1 storage key `viepn.designs.v1` remains unchanged to avoid data loss. A layer's x/y are normalized percentages of widget width/height, and render identically in app and extension. `CanvasLayerContent` supports text, time, date, SF Symbol, image and shape. Layers are edited as value types; action snapshots power undo/redo.

## Render pipeline
`WidgetDesignView` composes `LivingSceneView` and either the ordered canvas layers or kind-specific classic layout. Scene visuals are vector-only. `WidgetKit` configuration uses a dynamic AppEntity of user-saved designs; AppIntentTimelineProvider creates 26 hourly entries so time-context presentation can change without fetching data. Interaction uses `ToggleHabitIntent` and reloads the timeline. Time-of-day changes are subject to WidgetKit scheduling.

## Theme Fusion
`ThemeFusionView` selects a scene and previews the wallpaper. `ImageRenderer` generates 390×844 @3x PNG. It also renders a 4×3 SF Symbol icon sheet and exports portable JSON with version, scene and designs. Imported JSON copies design UUIDs rather than overwriting the user's saved items. Theme JSON does not embed image bytes; imported image widgets may require selecting photos again.

## Editor UX
Canvas editor uses hit-target gestures on top of the shared renderer, with selected-layer highlight. Each drag records one undo snapshot and updates normalized coordinates. Style sliders and fields push history snapshots (last 35). Supported tools: add/remove layer; edit text and icon symbol; opacity, rotation, scale, color, order and visibility; select scene; change source text/photo/date, previews in small/medium/large sizes.

## Privacy and limits
- PhotosPicker accesses user-selected images only. Images save to the App Group container.
- No uploads or analytics SDK.
- No hidden background service. Export uses iOS ShareLink.
- App Group capabilities must be signed together for app and extension.
- Drag/editing is an app-only UI; WidgetKit uses static rendering.
- Apple does not offer a public API for applying home-screen layouts or bypassing code signing.

## QA gates
- Linux Swift syntax parse for every source file and model type-check.
- XcodeGen YAML validates.
- GitHub macOS `xcodebuild` builds unsigned generic iPhone target.
- Compile and run XCTest on Apple simulator where runner available.
- Hardware acceptance: add widget, select configuration, mutate habit, context changes, photos, theme export/import, restore v1 data, no lost designs after app update.

## Vietnamese lunar calendar / Lịch Âm Tĩnh (v2.2)

- `Shared/Lunar/VietnameseLunarCalendar.swift`: UTC+7 new moon / leap month / Can Chi / solar terms / tradition algorithms, civil-day value types. This uses astronomical approximations and requires independent edge-case validation for a strict accuracy claim.
- `Shared/Lunar/LunarFamilyEvents.swift`: event model; recurring solar dates generated per lunar year; explicit leapOnly/both/regular and missing lunar day 30 policy, App Group storage.
- `Shared/Lunar/LunarAppearance.swift`: Minimal Zen core style, Heritage, Luxury, Tết, Mid-Autumn; backward decode old theme settings.
- `Shared/Lunar/LunarWidgetCards.swift`: common SwiftUI renderer shared by app preview and widgets, with six information-density-aware purposes.
- `WidgetExtension/LunarWidgets.swift`: six WidgetKit kinds, supported Home/Lock families, timeline entries for VN dates, deep links to lunar calendar and matching family event.
- `ViePNApp/Views/Lunar/LunarCalendarHomeView.swift`: four calendar modes, theme previews, family list, notification opt-in, ICS export and culture.
- `ViePNApp/Stores/LunarFamilyStore.swift`: notification permission and scheduling. Rolling local notification queue (bounded); reschedule on foreground and mutation. Do not promise indefinite background refresh since iOS imposes delivery and queue limits.
- `scripts/run_lunar_smoke.sh`: independently executable Foundation-only regression suite for 11 Vietnamese Tết dates, leap months, annual memorials, month length, `.ics` and 555 sampled roundtrips.

UI rule: Small widget → date at glance. Medium → date plus the next memorial. Large → lunar/solar month. Lock Screen → one short line. Theme highlight occupies under 10% of the visual surface, fonts use iOS system + one optional serif accent. No continuously animated widget or fabricated precise astronomical times.
