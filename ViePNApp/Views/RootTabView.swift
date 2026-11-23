import SwiftUI

private enum ViePNTab: Hashable {
    case today, tools, gallery, studio, themes
}

struct RootTabView: View {
    @State private var tab: ViePNTab = .today
    @State private var selectedTool: UtilitySection = .money

    var body: some View {
        TabView(selection: $tab) {
            NavigationStack { DashboardView() }
                .tabItem { Label("Today", systemImage: "house.fill") }.tag(ViePNTab.today)
            NavigationStack { UtilitiesHubView(selection: $selectedTool) }
                .tabItem { Label("Tiện ích", systemImage: "bolt.square.fill") }.tag(ViePNTab.tools)
            NavigationStack { GalleryView() }
                .tabItem { Label("Gallery", systemImage: "square.grid.2x2.fill") }.tag(ViePNTab.gallery)
            NavigationStack { StudioHomeView() }
                .tabItem { Label("Canvas", systemImage: "square.3.layers.3d") }.tag(ViePNTab.studio)
            NavigationStack { ThemeFusionView() }
                .tabItem { Label("Themes", systemImage: "paintpalette.fill") }.tag(ViePNTab.themes)
        }
        .tint(StudioPalette.mint)
        .toolbarColorScheme(.dark, for: .tabBar)
        .preferredColorScheme(.dark)
        .onOpenURL { url in
            guard url.scheme == "viepnwidgetplus" else { return }
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
