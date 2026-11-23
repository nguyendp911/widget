# Roadmap / delivery checklist

## Implemented in v2 source
- [x] Premium Home and Gallery with curated scene cards.
- [x] Six procedural living scenes and time-sensitive palettes.
- [x] Magic Canvas layer model, drag, scale, rotation, opacity, ordering, hide, remove, undo/redo.
- [x] Scene and content editing, three widget size previews and photo import.
- [x] Daily Command smart content (time of day and editable priorities).
- [x] Memory Timeline and optional user-selected photo.
- [x] Theme Fusion: wallpaper PNG, icon sheet PNG, theme JSON import/export, save matching widgets.
- [x] App Groups persistence and v1 migration decoder.
- [x] WidgetKit dynamic selection and interactive habit button.
- [x] Unsigned IPA GitHub Actions recipe.

## Release acceptance (requires macOS/hardware)
- [ ] Xcode build verified for current v2 commit.
- [ ] Unit tests run on iPhone Simulator.
- [ ] iPhone tests: add/edit widget, photo and permissions, Theme Fusion, app restart.
- [ ] VoiceOver labels, dynamic type and localization QA.
- [ ] Design review and App Store metadata.

## Future items not represented as complete
- [ ] Secure backend for AI-generated original scenes (needs service and costs).
- [ ] iCloud sync, subscriptions and StoreKit verification.
- [ ] Calendar/Weather permissions and integration, lock screen families.
- [ ] One-tap icon installs are not possible via public iOS APIs.
