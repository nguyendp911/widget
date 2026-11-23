import SwiftUI

@main
struct ViePNWidgetPlusApp: App {
    @StateObject private var studio = WidgetStudioStore()
    @StateObject private var utilities = UtilityStore()
    @StateObject private var lunarFamily = LunarFamilyStore()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environmentObject(studio)
                .environmentObject(utilities)
                .environmentObject(lunarFamily)
                .tint(Color(hex: "#5DE9D8"))
                .onChange(of: scenePhase) { _, newPhase in
                    if newPhase == .active {
                        lunarFamily.reload()
                        Task { await lunarFamily.syncNotifications() }
                    }
                }
        }
    }
}
