import SwiftUI

// ViePN Heritage: visual assets are SVG rendered by Xcode. Dates, Can Chi,
// zodiac references and memorial names stay real SwiftUI text.
enum LunarGlyph {
    case calendar, canChi, zodiac, solarTerm, goodHours, spirit
    case family, moon, books, memorial, reminder, festival, goodDay, badDay

    var asset: String {
        switch self {
        case .calendar: return "ViePNIconCalendar"
        case .canChi: return "ViePNIconCanChi"
        case .zodiac: return "ViePNIconZodiac"
        case .solarTerm: return "ViePNIconSolarTerm"
        case .goodHours: return "ViePNIconGoodHours"
        case .spirit: return "ViePNIconSpirit"
        case .family: return "ViePNIconFamily"
        case .moon: return "ViePNIconMoon"
        case .books: return "ViePNIconBooks"
        case .memorial: return "ViePNIconMemorial"
        case .reminder: return "ViePNIconReminder"
        case .festival: return "ViePNIconFestival"
        case .goodDay: return "ViePNIconGoodDay"
        case .badDay: return "ViePNIconBadDay"
        }
    }
}

// Delicate lacquer/gold rather than the generic iOS symbol circle.
struct LunarVectorIcon: View {
    let glyph: LunarGlyph
    let theme: LunarTheme
    var size: CGFloat = 20

    var body: some View {
        Image(glyph.asset)
            .resizable()
            .interpolation(.high)
            .scaledToFit()
            .frame(width: size, height: size)
            .accessibilityHidden(true)
    }
}

struct LunarVectorHeader: View {
    let title: String
    let theme: LunarTheme
    var compact: Bool = false
    var glyph: LunarGlyph = .calendar

    private var dark: Bool { !theme.usesLightSurface }

    var body: some View {
        HStack(spacing: compact ? 5 : 8) {
            LunarVectorIcon(glyph: glyph, theme: theme, size: compact ? 19 : 23)
            Text(title)
                .font(.system(size: compact ? 9 : 11, weight: .semibold, design: .serif))
                .tracking(compact ? 0.35 : 0.65)
                .foregroundStyle(dark ? Color(hex: "#FFF1D6") : Color(hex: "#7D2624"))
                .lineLimit(1)
                .minimumScaleFactor(0.82)
            Spacer(minLength: 0)
            if !compact {
                Image("ViePNIconCanChi")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18, height: 18)
                    .opacity(0.84)
            }
        }
        .padding(.horizontal, compact ? 1 : 8)
        .frame(height: compact ? 20 : 29)
        .background {
            if !compact {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: dark ? "#651B1F" : "#F6E4C1").opacity(0.93),
                                Color(hex: dark ? "#3C2624" : "#FBF2DF").opacity(0.85)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(hex: "#CA9A47").opacity(0.68), lineWidth: 0.8))
            }
        }
        .accessibilityAddTraits(.isHeader)
    }
}

struct LunarVectorFact: View {
    let glyph: LunarGlyph
    let title: String
    let value: String
    let theme: LunarTheme

    var body: some View {
        HStack(alignment: .top, spacing: 6) {
            LunarVectorIcon(glyph: glyph, theme: theme, size: 21)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 9, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color(hex: theme.muted))
                    .lineLimit(1)
                    .minimumScaleFactor(0.83)
                Text(value)
                    .font(.system(size: 11, weight: .medium, design: .serif))
                    .foregroundStyle(Color(hex: theme.foreground))
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 5)
        .padding(.vertical, 5)
        .background(
            Color(hex: theme.secondaryBackground).opacity(theme.usesLightSurface ? 0.70 : 0.42),
            in: RoundedRectangle(cornerRadius: 9)
        )
    }
}

struct LunarVectorInline: View {
    let glyph: LunarGlyph
    let value: String
    let theme: LunarTheme

    var body: some View {
        HStack(spacing: 5) {
            LunarVectorIcon(glyph: glyph, theme: theme, size: 18)
            Text(value)
                .font(.system(size: 10, weight: .medium, design: .serif))
                .foregroundStyle(Color(hex: theme.foreground))
                .lineLimit(1)
                .minimumScaleFactor(0.82)
            Spacer(minLength: 0)
        }
    }
}

/// Native title plaques for the app. The vector SVG background is always
/// shown at its intended aspect ratio; the text is not baked into an image.
struct ViePNHeritageRibbon: View {
    let title: String
    var color: String = "Red"

    private var textColor: Color {
        color == "Cream" ? Color(hex: "#742F28") : Color(hex: "#FBEACA")
    }

    var body: some View {
        ZStack {
            Image("ViePNTitle" + color)
                .resizable()
                .scaledToFit()
            Text(title)
                .font(.system(size: 13, weight: .semibold, design: .serif))
                .foregroundStyle(textColor)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
    }
}
