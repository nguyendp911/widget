import SwiftUI

/// The approved ViePN boards are a *family of distinct compositions*, not
/// one wallpaper repeated on every widget. The user can still override the
/// artwork; curated artwork is only selected for Heritage + Automatic.
struct LunarWidgetSkin {
    enum Tone { case lacquer, jade, night, parchment, custom }
    let tone: Tone
    let appearance: LunarAppearance
    let kind: LunarCardKind

    init(kind: LunarCardKind, appearance: LunarAppearance) {
        self.kind = kind
        self.appearance = appearance
        if appearance.theme == .heritage && appearance.artwork == .automatic {
            switch kind {
            case .today: tone = .lacquer
            case .moonDays: tone = .night
            case .memorial, .nextEvent: tone = .jade
            case .month, .tradition, .almanac: tone = .parchment
            }
        } else {
            tone = .custom
        }
    }

    var dark: Bool {
        switch tone {
        case .lacquer, .jade, .night: return true
        case .parchment: return false
        case .custom: return !appearance.theme.usesLightSurface
        }
    }

    var text: Color {
        switch tone {
        case .lacquer, .jade, .night: return Color(hex: "#FFF2D8")
        case .parchment: return Color(hex: "#582B24")
        case .custom: return Color(hex: appearance.theme.foreground)
        }
    }
    var softText: Color {
        switch tone {
        case .lacquer, .jade, .night: return Color(hex: "#F3D8B1")
        case .parchment: return Color(hex: "#85654E")
        case .custom: return Color(hex: appearance.theme.muted)
        }
    }
    var accent: Color {
        switch tone {
        case .lacquer, .jade, .night: return Color(hex: "#F7CD7B")
        case .parchment: return Color(hex: "#A12B25")
        case .custom: return Color(hex: appearance.theme.accent)
        }
    }
    var gold: Color { Color(hex: "#D8A34D") }

    func artworkName(family: String) -> String? {
        if appearance.artwork == .none { return nil }
        if appearance.theme == .heritage && appearance.artwork == .automatic {
            let scene: LunarArtwork
            switch kind {
            case .today: scene = .drum
            case .moonDays: scene = .moon
            case .memorial: scene = .gioNha
            case .nextEvent: scene = .lotus
            case .month: scene = .temple
            case .tradition: scene = .chrysanthemum
            case .almanac: scene = .vanNien
            }
            return scene.resolvedResource(theme: appearance.theme, family: family)
        }
        return appearance.artwork.resolvedResource(theme: appearance.theme, family: family)
    }
}

/// Crisp border drawn as strokes, never stretched from a tiny frame crop.
/// Matches the double gold line and softly rounded corners of the approved art.
struct ViePNGoldWidgetBorder: View {
    var inner: Bool = true
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(Color(hex: "#B47628").opacity(0.9), lineWidth: 1.9)
                .padding(2)
            if inner {
                RoundedRectangle(cornerRadius: 17, style: .continuous)
                    .strokeBorder(Color(hex: "#F5D88F").opacity(0.8), lineWidth: 0.65)
                    .padding(5)
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}
