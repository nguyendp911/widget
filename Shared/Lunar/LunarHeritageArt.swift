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

/// Sharp native composition for Retina widgets. The original source is a
/// collage: individual panels are too small to scale as full-bleed artwork.
/// Use SwiftUI drawing for the full canvas and keep cropped art near 1:1 size.
struct LunarHeritageBackground: View {
    let appearance: LunarAppearance

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            let accent = Color(hex: appearance.theme.accent)
            ZStack {
                LinearGradient(
                    colors: [
                        Color(hex: appearance.theme.secondaryBackground),
                        Color(hex: appearance.theme.background)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                // Native vector atmosphere remains sharp on all Retina sizes.
                Circle()
                    .fill(accent.opacity(appearance.theme.usesLightSurface ? 0.10 : 0.16))
                    .frame(width: min(width * 0.48, 132), height: min(width * 0.48, 132))
                    .position(x: width * 0.85, y: height * 0.16)

                Path { path in
                    path.move(to: CGPoint(x: 0, y: height * 0.90))
                    path.addCurve(
                        to: CGPoint(x: width, y: height * 0.86),
                        control1: CGPoint(x: width * 0.33, y: height * 0.73),
                        control2: CGPoint(x: width * 0.67, y: height * 1.02)
                    )
                }
                .stroke(accent.opacity(0.19), lineWidth: 1)

                if let image = appearance.artwork.resolvedResource(theme: appearance.theme) {
                    // A small illustration, never a stretched low-resolution background.
                    Image(image)
                        .resizable()
                        .interpolation(.high)
                        .scaledToFit()
                        .frame(width: min(width * 0.40, 112),
                               height: min(height * 0.46, 66))
                        .opacity(appearance.theme.usesLightSurface ? 0.72 : 0.62)
                        .position(x: width * 0.79, y: height * 0.83)
                        .accessibilityHidden(true)
                }
            }
            .frame(width: width, height: height)
            .clipped()
        }
        .allowsHitTesting(false)
    }
}

/// Full-bleed illustration for the combined calendar widget.
struct LunarAlmanacBackground: View {
    var body: some View {
        GeometryReader { geometry in
            Image("ViePNLunarLacquer")
                .resizable()
                .scaledToFill()
                .frame(width: geometry.size.width, height: geometry.size.height)
                .clipped()
                .overlay(Color.black.opacity(0.38))
        }
        .allowsHitTesting(false)
    }
}
