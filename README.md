# ViePN Widget+ 2.0 — Living Canvas

**SwiftUI + WidgetKit + App Intents · iOS 17+ · Windows/Codex development · macOS/Xcode build**

> A local-first personalisation studio, not a remote wallpaper service. Source included, independent of external APIs. This repository can build an **unsigned device IPA** using GitHub Actions. The IPA must be properly signed before installation.

## What's new in 2.0

- **Premium Home / Gallery** — dedicated dark editorial UI and curated 12 designs covering eight widget types.
- **6 Living Scenes** — Aurora Drift, Cosmic Dust, Zen Horizon, Neon City, Dreamscape, Noir Glass. All scenes are deterministic vector graphics; Aurora/Zen respond to time of day.
- **Magic Canvas** — overlay-based direct manipulation of layers; editable text, clock, date, SF Symbols, photo and geometric elements; drag to position, scale, rotation, opacity, colour, hide/remove, front/back ordering, undo/redo (up to 35 edits).
- **Contextual smart widgets** — Daily Command content changes by morning/afternoon/evening and shows user-defined priorities; Memory Timeline counts dates and can display a selected picture.
- **Theme Fusion** — coordinated widget palettes + wallpaper PNG (1170×2532), icon sheet PNG, theme JSON export and JSON import. Theme packs can be shared through iOS Share Sheet.
- **Safe v0.1 upgrade** — saved designs decode with defaults for newly added fields. The shared App Groups storage key is unchanged.
- **Widget extension** — choose a stored design from the widget editing menu; interactive habit button; hourly timeline entries.

## Project map

```text
ViePNApp/Views/              Premium screens, Magic Canvas and Theme Fusion
ViePNApp/Stores/             Local design management
Shared/Models/               Backwards-compatible design/layer/scene models
Shared/Views/                One renderer used by the app and the Widget Extension
WidgetExtension/             WidgetKit + App Intents
Tests/                       Model migration and layer unit tests
scripts/                     Validation and unsigned IPA build
.github/workflows/           macOS CI and IPA artifacts
project.yml                  XcodeGen input
```

## Develop on Windows

```powershell
git clone https://github.com/nguyendp911/widget.git
cd widget
python .\scripts\validate_source.py
code .
```

Visual Studio Code and Codex can edit source on Windows. **They cannot build/test against Apple's iOS SDK there.** Check a pull request by running the GitHub Actions workflow on macOS.

## Build in GitHub Actions

Open **Actions → ViePN Widget+ - Unsigned IPA → Run workflow**. The runner installs XcodeGen and builds a device target with `CODE_SIGNING_ALLOWED=NO`, then packages `Payload/ViePNWidgetPlus.app` as `ViePN-WidgetPlus-unsigned.ipa`. Download the workflow's artifact. It is not a signed, ready-to-install application.

## Build on Mac

```bash
brew install xcodegen
bash scripts/build_unsigned_ipa_macos.sh
```

## Setup before signed distribution

1. Register the bundle IDs `com.viepn.widgetplus` and `com.viepn.widgetplus.widgets` in Apple Developer.
2. Register App Group `group.com.viepn.widgetplus` and enable it for both targets.
3. Configure app and extension signing/provisioning profiles and build normally with Xcode.
4. Test on iPhone: photos, widget editing, App Intents, all three widget families, Smart and Memory.
5. Review App Store requirements, artwork/privacy manifests, accessibility and translations.

## Platform and implementation caveats

- WidgetKit is snapshot/timeline based, **not an always-running animated surface**. `LivingSceneView` renders a frame for a given time. WidgetKit decides actual refresh timing.
- iOS does not permit direct installation of wallpaper, custom app icons or complete Home Screen layout by third-party apps. Theme Fusion exports the assets and leaves application of them to the user.
- SF Symbols in the icon sheet are illustrative previews and the sheet is not a directly installable iOS icon pack. Use Shortcuts or compatible launcher flows where appropriate.
- Smart Daily Command uses user-configured priorities and the device clock, **not AI predictions or automatically imported Apple Calendar events**.
- Theme JSON import accepts v2 packages and caps templates at 150. Shared file origins must be trusted; image files are not embedded in JSON.
- Premium account sync, server-backed AI designer, advanced timeline planning, lock-screen accessories and full icon-package automation are not included and would require additional design/permissions.

## Status

The code is source-complete for the documented v2 scope, but this README does not claim passing an Xcode build unless confirmed by the GitHub Actions run. Linux `swiftc -frontend -parse` and model type-check can be used for preliminary checks only.
