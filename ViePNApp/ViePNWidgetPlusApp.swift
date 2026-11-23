import SwiftUI

@main
struct ViePNWidgetPlusApp: App {
    @StateObject private var studio = WidgetStudioStore()
    @StateObject private var utilities = UtilityStore()

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environmentObject(studio)
                .environmentObject(utilities)
                .tint(Color(hex: "#5DE9D8"))
        }
    }
}
