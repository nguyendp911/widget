# Codex project instructions (ViePN Widget+ Living Canvas 2.0)

Goal: maintain and extend the existing SwiftUI / WidgetKit project. Keep it local-first. Never assume iPhone apps compile on Windows; check on macOS Actions after changes.

1. `python scripts/validate_source.py` and optional `swiftc -frontend -parse` for syntax.
2. Preserve `WidgetDesign` Codable backwards compatibility: V1 designs in `viepn.designs.v1` must survive updates.
3. Keep `WidgetDesignView` as the single widget renderer for both app and widget extension.
4. Prefer extracted small views to prevent SwiftUI type-check explosions.
5. Never implement fake smooth animations in WidgetKit. Living scenes are snapshot-based.
6. Widget actions use App Intents and update App Groups; don't call unavailable extension APIs.
7. Test under GitHub Actions, inspect logs, repair build failures before reporting success.
8. Keep unsigned IPA (`CODE_SIGNING_ALLOWED=NO`) separate from distributable signed releases.
9. Verify all export/import paths, including security-scoped URLs. Avoid bundled remote assets.
10. Update `docs/TECHNICAL_SPEC.md` and this checklist for material changes.
