import SwiftUI

@main
struct ViePNWidgetPlusApp: App {
    @StateObject private var studio = WidgetStudioStore()

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environmentObject(studio)
                .tint(Color(hex: "#6777E8"))
        }
    }
}
