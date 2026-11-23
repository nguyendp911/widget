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
