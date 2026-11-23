import SwiftUI

/// Small reusable UI toolkit for the premium dark appearance.
enum StudioPalette {
    // Vietnamese heritage rather than the old generic blue/purple studio.
    static let background = Color(hex: "#0D2721")
    static let surface = Color(hex: "#224339")
    static let muted = Color(hex: "#D8C4A6")
    static let highlight = Color(hex: "#B8382D")
    static let mint = Color(hex: "#E8C271")
}

struct StudioHeader: View {
    let overline: String
    let title: String
    let subtitle: String
    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(overline.uppercased())
                .font(.system(size: 11, weight: .black, design: .rounded))
                .tracking(2.4).foregroundStyle(StudioPalette.mint)
            Text(title)
                .font(.system(size: 33, weight: .bold, design: .rounded))
                .tracking(-1.2)
                .foregroundStyle(.white)
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(StudioPalette.muted)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct AccentChip: View {
    let text: String
    let icon: String
    var active: Bool = false
    var body: some View {
        Label(text, systemImage: icon)
            .font(.system(size: 12, weight: .semibold, design: .rounded))
            .padding(.horizontal, 14).padding(.vertical, 10)
            .foregroundStyle(active ? .black : .white.opacity(0.78))
            .background(active ? StudioPalette.mint : StudioPalette.surface,
                        in: Capsule())
    }
}

struct StudioPanel<Content: View>: View {
    let content: Content
    init(@ViewBuilder content: () -> Content) { self.content = content() }
    var body: some View {
        content
            .padding(16)
            .background(StudioPalette.surface, in: RoundedRectangle(cornerRadius: 22))
            .overlay(RoundedRectangle(cornerRadius: 22).stroke(Color(hex: "#C79A51").opacity(0.46), lineWidth: 1))
    }
}

struct SceneShowcaseCard: View {
    let design: WidgetDesign
    var height: CGFloat = 180
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            WidgetDesignView(design: design, date: .now, habitCompleted: false)
            LinearGradient(colors: [.clear, .black.opacity(0.45)],
                           startPoint: .center, endPoint: .bottom)
            VStack(alignment: .leading, spacing: 4) {
                Text(design.name.uppercased())
                    .font(.system(size: 10, weight: .black, design: .rounded))
                    .tracking(1.5)
                Text(design.scene?.subtitle ?? design.kind.title)
                    .font(.system(size: 10)).opacity(0.84)
            }
            .padding(12)
            .foregroundStyle(.white)
        }
        .frame(height: height)
        .clipShape(RoundedRectangle(cornerRadius: 19))
        .overlay(RoundedRectangle(cornerRadius: 19).stroke(.white.opacity(0.12), lineWidth: 1))
    }
}

struct StudioPage<Content: View>: View {
    let content: Content
    init(@ViewBuilder content: () -> Content) { self.content = content() }
    var body: some View {
        ScrollView {
            content.padding(.horizontal, 20).padding(.top, 18).padding(.bottom, 28)
        }
        .background(StudioPalette.background.ignoresSafeArea())
        .toolbarBackground(StudioPalette.background, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .preferredColorScheme(.dark)
    }
}
