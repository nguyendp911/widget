import SwiftUI

private enum ViePNTab: Hashable {
    case today, lunar, tools, gallery, studio
}

/// Root-level presentation survives a cold app launch from a WidgetKit Link.
/// A child sheet may miss the first URL while its tab is still being created.
private struct ThienNienModalRequest: Identifiable {
    let id = UUID()
    let section: ThienNienSection
    let civil: SolarCivilDate
}

struct RootTabView: View {
    @EnvironmentObject private var lunarFamily: LunarFamilyStore
    @State private var tab: ViePNTab = .lunar
    @State private var selectedTool: UtilitySection = .money
    @State private var pendingLunarURL: URL?
    @State private var modalRequest: ThienNienModalRequest?

    var body: some View {
        TabView(selection: $tab) {
            NavigationStack { DashboardView() }
                .tabItem { Label("Today", systemImage: "house.fill") }.tag(ViePNTab.today)
            NavigationStack { LunarCalendarHomeView(incomingURL: $pendingLunarURL) }
                .tabItem { Label("Thiên Niên", systemImage: "moon.stars.fill") }.tag(ViePNTab.lunar)
            NavigationStack { UtilitiesHubView(selection: $selectedTool) }
                .tabItem { Label("Tiện ích", systemImage: "bolt.square.fill") }.tag(ViePNTab.tools)
            NavigationStack { GalleryView() }
                .tabItem { Label("Gallery", systemImage: "square.grid.2x2.fill") }.tag(ViePNTab.gallery)
            NavigationStack { StudioHomeView() }
                .tabItem { Label("Canvas", systemImage: "square.3.layers.3d") }.tag(ViePNTab.studio)
        }
        .tint(tab == .lunar ? Color(hex: lunarFamily.appearance.theme.accent) : StudioPalette.mint)
        .toolbarBackground(
            tab == .lunar
                ? Color(hex: lunarFamily.appearance.theme.secondaryBackground)
                : Color(hex: "#1E2426"),
            for: .tabBar
        )
        .toolbarBackground(.visible, for: .tabBar)
        .toolbarColorScheme(
            tab == .lunar && lunarFamily.appearance.theme.usesLightSurface ? .light : .dark,
            for: .tabBar
        )
        .preferredColorScheme(
            tab == .lunar && lunarFamily.appearance.theme.usesLightSurface ? .light : .dark
        )
        .onOpenURL { url in
            guard url.scheme == "viepnwidgetplus" else { return }
            // Resolve the WidgetKit section URL at the root before switching tabs:
            // it reliably presents the matching sheet on cold and warm launches.
            if let route = ThienNienSection.destination(from: url) {
                tab = .lunar
                modalRequest = ThienNienModalRequest(
                    section: route.section,
                    civil: route.date ?? SolarCivilDate(date: Date())
                        ?? SolarCivilDate(year: 2026, month: 11, day: 23)
                )
                return
            }
            switch url.host {
            case "lunar", "family":
                pendingLunarURL = url
                tab = .lunar
            default:
                tab = .tools
                switch url.host {
                case "notes": selectedTool = .notes
                case "tasks": selectedTool = .tasks
                case "bills": selectedTool = .bills
                case "focus": selectedTool = .focus
                default: selectedTool = .money
                }
            }
        }
        .sheet(item: $modalRequest) { request in
            ThienNienDetailSheet(
                section: request.section,
                civil: request.civil,
                familyEvents: lunarFamily.events
            )
        }
        .onAppear {
            #if DEBUG
            // Only installed in Debug for Simulator screenshot inspection.
            if let key = ProcessInfo.processInfo.environment["VIEPN_PREVIEW_MODAL"],
               let section = ThienNienSection(rawValue: key) {
                tab = .lunar
                modalRequest = ThienNienModalRequest(
                    section: section,
                    civil: SolarCivilDate(date: Date())
                        ?? SolarCivilDate(year: 2026, month: 11, day: 23)
                )
            }
            #endif
        }
    }
}
