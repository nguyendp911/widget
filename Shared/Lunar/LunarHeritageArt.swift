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

/// High-detail Vietnamese scenes, pre-rasterized to each widget family
/// instead of stretching low-resolution tiles from a sprite sheet.
struct LunarHeritageBackground: View {
    let appearance: LunarAppearance
    var family: String = "Medium"

    var body: some View {
        GeometryReader { proxy in
            let light = appearance.theme.usesLightSurface
            let surface = Color(hex: appearance.theme.secondaryBackground)
            ZStack {
                Color(hex: appearance.theme.background)
                if let name = appearance.artwork.resolvedResource(theme: appearance.theme, family: family) {
                    Image(name)
                        .resizable()
                        .interpolation(.high)
                        .scaledToFill()
                        .frame(width: proxy.size.width, height: proxy.size.height)
                        .clipped()
                        // Legibility only where text tends to sit; artwork
                        // remains visible at the far edge.
                        .overlay {
                            LinearGradient(
                                stops: [
                                    .init(color: surface.opacity(light ? 0.77 : 0.79), location: 0.0),
                                    .init(color: surface.opacity(light ? 0.64 : 0.67), location: 0.54),
                                    .init(color: surface.opacity(light ? 0.11 : 0.18), location: 1.0)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        }
                } else {
                    LinearGradient(
                        colors: [surface, Color(hex: appearance.theme.background)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
        .allowsHitTesting(false)
    }
}
