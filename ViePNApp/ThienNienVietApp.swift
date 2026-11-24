import SwiftUI

/// Standalone Thiên Niên Việt application. No WidgetKit extension, studio,
/// gallery, utility dashboard, or SpringBoard widget routing.
@main
struct ThienNienVietApp: App {
    @StateObject private var family = LunarFamilyStore()
    @StateObject private var heritage = HeritageStore()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            HeritageRootView()
            .environmentObject(heritage)
            .environmentObject(family)
            .tint(Color(hex: "#9A3226"))
            .onChange(of: scenePhase) { _, phase in
                if phase == .active {
                    family.reload()
                    Task { await family.syncNotifications() }
                }
            }
        }
    }
}
