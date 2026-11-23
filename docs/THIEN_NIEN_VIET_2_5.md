# Thiên Niên Việt — v2.5.0

## Product
- The lunar module is branded **Thiên Niên Việt** in navigation, on the long card, in previews, and on the installed widget gallery.
- The in-app page contains a vertically scrolling almanac board, one section for each: solar/lunar date, Can Chi, popular zodiac notes, sao/trực/day category, auspicious hours, solar terms, family memorials, Mùng 1/Rằm/holidays and month calendar.
- Each section in the **app** uses a Button to present \`ThienNienDetailSheet\` via \`sheet(item:)\` without navigation push.
- Each row in the **Home Screen systemLarge WidgetKit extension** uses a distinct \`Link\` to \`viepnwidgetplus://lunar?detail=<section>&date=YYYY-MM-DD\`; the app routes the link directly to that section's modal. If the user taps outside a row the root \`widgetURL\` opens the selected date.
- iOS does **not** permit an arbitrary full-screen-height widget, widget scrolling, nor a modal above the SpringBoard. The tallest standard iPhone widget is **systemLarge**; this uses a compact board with abbreviated facts. The expanded, scrollable board and all modal sheets exist in the app.
- Calendar facts, Can Chi and family dates are live text and preserve existing App Group data. Popular zodiac notes are labeled cultural references, not personal horoscope analysis.
- Every live modal uses Vietnamese paper, lacquer and gold styling with detailed facts and an explicit close button.

## QA
- Unit test validates URL round trips for all nine detail sections and rejects invalid routes.
- Xcode compiles both the app and Widget Extension via GitHub Actions; inspect its IPA and Simulator screenshot artifacts.
- A real-device check remains necessary to verify tap targets and updated widget snapshots.
