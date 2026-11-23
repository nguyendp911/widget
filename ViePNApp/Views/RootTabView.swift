import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            NavigationStack { DashboardView() }
                .tabItem { Label("Today", systemImage: "house.fill") }
            NavigationStack { GalleryView() }
                .tabItem { Label("Discover", systemImage: "square.grid.2x2.fill") }
            NavigationStack { StudioHomeView() }
                .tabItem { Label("Canvas", systemImage: "square.3.layers.3d") }
            NavigationStack { ThemeFusionView() }
                .tabItem { Label("Themes", systemImage: "paintpalette.fill") }
            NavigationStack { MyWidgetsView() }
                .tabItem { Label("Library", systemImage: "square.stack.fill") }
        }
        .tint(StudioPalette.mint)
        .toolbarColorScheme(.dark, for: .tabBar)
        .preferredColorScheme(.dark)
    }
}
