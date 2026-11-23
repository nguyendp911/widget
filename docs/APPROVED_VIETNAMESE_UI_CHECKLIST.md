# ViePN 2.4.1 — Approved design parity acceptance criteria

The accepted Vietnamese design reference is a family of differentiated art styles, not a generic painted background.

- Today: lacquer red + Dong Son motif + gold border.
- Memorial / upcoming family event: emerald jade + lotus/incense art + countdown.
- Full-moon widget: moonlit bamboo, warm pale-gold text.
- Month calendar: parchment + village temple architecture with live month grid.
- Can Chi and traditional day facts: light Vietnamese paper with true data-driven typography.
- All categories use **their own artwork by default**, but manually chosen artwork overrides it everywhere.
- Iconography and text must stay crisp; Vector SVG icons; numbers, Can Chi, auspicious hours, seasonal terms and family data remain editable and calculated.
- Two gold border strokes and scene-specific text contrast, not an 80% opaque overlay.
- Home Screen WidgetKit Extension must choose **the same kind-specific artwork as the app's preview**.
- iPhone Simulator screenshot is uploaded as a build artifact for visual comparison, but real-device and Home Screen capture still require user acceptance.

Swift unit test: `testApprovedHeritageHasUniqueArtworkForEachWidgetKind`.
