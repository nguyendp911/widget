import SwiftUI

private enum ViePNTab: Hashable {
    case today, lunar, tools, gallery, studio
}

struct RootTabView: View {
    @EnvironmentObject private var lunarFamily: LunarFamilyStore
    @State private var tab: ViePNTab = .today
    @State private var selectedTool: UtilitySection = .money
    @State private var pendingLunarURL: URL?

    var body: some View {
        TabView(selection: $tab) {
            NavigationStack { DashboardView() }
                .tabItem { Label("Today", systemImage: "house.fill") }.tag(ViePNTab.today)
            NavigationStack { LunarCalendarHomeView(incomingURL: $pendingLunarURL) }
                .tabItem { Label("Lịch Âm", systemImage: "moon.stars.fill") }.tag(ViePNTab.lunar)
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
    }
}
