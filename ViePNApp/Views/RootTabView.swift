import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            NavigationStack { DashboardView() }
                .tabItem { Label("Home", systemImage: "house") }
            NavigationStack { GalleryView() }
                .tabItem { Label("Explore", systemImage: "square.grid.2x2") }
            NavigationStack { StudioHomeView() }
                .tabItem { Label("Studio", systemImage: "paintbrush.pointed") }
            NavigationStack { MyWidgetsView() }
                .tabItem { Label("My Widgets", systemImage: "square.stack") }
            NavigationStack { SettingsView() }
                .tabItem { Label("Settings", systemImage: "gearshape") }
        }
    }
}
