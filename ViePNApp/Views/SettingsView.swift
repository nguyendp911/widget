import SwiftUI

struct SettingsView: View {
    var body: some View {
        List {
            Section("ViePN Widget+") {
                LabeledContent("Edition", value: "Living Canvas 2.0")
                LabeledContent("Minimum iOS", value: "17.0")
                LabeledContent("Privacy", value: "Local-first, App Groups")
            }
            Section("How to use") {
                Text("Create a widget in Canvas, save it, then open the Home Screen widget gallery.")
                Text("Long-press your installed widget, choose Edit Widget, and select your saved design.")
                Text("Use Theme Fusion to share a wallpaper image or export the current scene as JSON.")
            }
            Section("Platform limitations") {
                Text("Widgets update on the system timeline. Continuous animation and installing wallpaper or app icons programmatically are not supported.")
            }
        }
        .navigationTitle("Settings")
    }
}
