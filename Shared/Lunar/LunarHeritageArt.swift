import SwiftUI

/// Real cropped artworks from the user's provided Vietnamese calendar asset sheet.
/// Shared between the main app and Widget Extension through Shared/.
enum LunarHeritageArt {
    static func ornament(for theme: LunarTheme) -> String? {
        switch theme {
        case .zen: return nil
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

/// Texture + translucent surface: calm typography stays readable on illustrated backgrounds.
struct LunarHeritageBackground: View {
    let appearance: LunarAppearance
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Color(hex: appearance.theme.background)
                if let name = appearance.artwork.resolvedResource(theme: appearance.theme) {
                    Image(name)
                        .resizable()
                        .scaledToFill()
                        .frame(width: proxy.size.width, height: proxy.size.height)
                        .clipped()
                        .overlay(Color(hex: appearance.theme.background)
                            .opacity(appearance.theme.usesLightSurface ? 0.70 : 0.76))
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
        .allowsHitTesting(false)
    }
}
