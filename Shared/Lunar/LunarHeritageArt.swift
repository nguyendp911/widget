import SwiftUI

/// Real cropped artworks from the user's provided Vietnamese calendar asset sheet.
/// Shared between the main app and Widget Extension through Shared/.
enum LunarHeritageArt {
    static func ornament(for theme: LunarTheme) -> String? {
        switch theme {
        case .zen: return "HeritageLotus"
        case .heritage: return "HeritageLotus"
        case .tet: return "HeritagePeach"
        case .midAutumn: return "HeritageLantern"
        case .luxury: return "HeritageDongSon"
        case .jade: return "HeritageBamboo"
        case .gold: return "HeritageGate"
        case .ink: return "HeritageCloud"
        case .lotus: return "HeritageLotus"
        }
    }

    /// Original labels remain baked into the PNG; do not modify or place them over unrelated dates.
    static func statusBadge(kind: LunarCardKind, lunar: VietnameseLunarDate?, hasFamilyEvent: Bool) -> String? {
        if kind == .memorial && hasFamilyEvent { return "HeritageBadgeMemorial" }
        if lunar?.isLeapMonth == true { return "HeritageBadgeLeap" }
        switch lunar?.day {
        case 1: return "HeritageBadgeNewMoon"
        case 15: return "HeritageBadgeFullMoon"
        default: return nil
        }
    }
}

/// Full-bleed family art stays visible; only the text side gets a veil.
/// The chosen illustration now follows the approved layout for each widget kind.
struct LunarHeritageBackground: View {
    let appearance: LunarAppearance
    var family: String = "Medium"
    var kind: LunarCardKind = .today

    var body: some View {
        GeometryReader { proxy in
            let skin = LunarWidgetSkin(kind: kind, appearance: appearance)
            ZStack {
                Color(hex: appearance.theme.background)
                if let name = skin.artworkName(family: family) {
                    Image(name)
                        .resizable()
                        .interpolation(.high)
                        .scaledToFill()
                        .frame(width: proxy.size.width, height: proxy.size.height)
                        .clipped()
                        .overlay(alignment: .leading) {
                            // Approved compositions show the flower, moon, temple and
                            // Dong Son motifs. Do not bleach the whole illustration.
                            LinearGradient(
                                stops: [
                                    .init(color: (skin.dark ? Color.black : Color.white)
                                        .opacity(skin.dark ? 0.32 : 0.34), location: 0),
                                    .init(color: (skin.dark ? Color.black : Color.white)
                                        .opacity(skin.dark ? 0.18 : 0.23), location: 0.52),
                                    .init(color: .clear, location: 0.88)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        }
                } else {
                    LinearGradient(
                        colors: [
                            Color(hex: appearance.theme.secondaryBackground),
                            Color(hex: appearance.theme.background)
                        ],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                }
                ViePNGoldWidgetBorder()
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
        .allowsHitTesting(false)
    }
}
