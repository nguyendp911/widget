# Codex instruction & first tickets

Repository source of truth: `project.yml`, `Shared/`, `ViePNApp/`, `WidgetExtension/`, `docs/`.

## First Codex request

> Inspect this SwiftUI + WidgetKit source. Do not rewrite it into Flutter/React Native.
> Keep minimum iOS 17. First, improve compile reliability against current Xcode SDK.
> Check AppIntents, WidgetKit, XcodeGen targets, code signing, SharedRepository and
> WidgetDesignView. Make the smallest fixes needed. Add tests. Do not claim an iOS
> build passed unless a macOS Xcode runner actually built it. Maintain the Vietnamese UI.

## Tickets

1. P0 Generate Xcode project on macOS and fix any build errors.
2. P0 Set up shared App Group capability for real device (both targets).
3. P1 Refactor image file naming / compression / cleanup / corruption handling.
4. P1 Improve widget preview layouts in small/medium/large.
5. P1 Add real onboarding: add widget → edit widget → choose saved design.
6. P1 Extend tests / snapshots and release checklist.
7. P2 Layer-based Studio editor with undo/redo and template import/export.
8. P2 WeatherKit, EventKit, Lock Screen after MVP verified.
