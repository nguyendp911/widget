import SwiftUI

/// Separate, resolution-independent visual elements for lunar widgets.
/// Icons and titles remain real SwiftUI vectors/text, never resized JPG crops.
enum LunarGlyph {
    case calendar, canChi, zodiac, solarTerm, goodHours, spirit, family, moon, books

    var symbol: String {
        switch self {
        case .calendar: return "calendar"
        case .canChi: return "circle.hexagongrid.fill"
        case .zodiac: return "pawprint.fill"
        case .solarTerm: return "sun.max"
        case .goodHours: return "clock"
        case .spirit: return "sparkles"
        case .family: return "heart.fill"
        case .moon: return "moon.stars.fill"
        case .books: return "book.closed.fill"
        }
    }
}

struct LunarVectorIcon: View {
    let glyph: LunarGlyph
    let theme: LunarTheme
    var size: CGFloat = 19

    var body: some View {
        Image(systemName: glyph.symbol)
            .font(.system(size: max(9, size * 0.52), weight: .medium))
            .foregroundStyle(Color(hex: theme.accent))
            .frame(width: size, height: size)
            .background(
                Circle().fill(Color(hex: theme.secondaryBackground).opacity(0.9))
            )
            .overlay(
                Circle().stroke(Color(hex: theme.accent).opacity(0.40), lineWidth: 0.8)
            )
            .accessibilityHidden(true)
    }
}

struct LunarVectorHeader: View {
    let title: String
    let theme: LunarTheme
    var compact: Bool = false
    var glyph: LunarGlyph = .calendar

    var body: some View {
        HStack(spacing: 7) {
            LunarVectorIcon(glyph: glyph, theme: theme, size: compact ? 17 : 20)
            Text(title)
                .font(.system(size: compact ? 9 : 11, weight: .bold, design: .rounded))
                .tracking(compact ? 0.55 : 0.9)
                .foregroundStyle(Color(hex: theme.foreground))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            Spacer(minLength: 1)
            if !compact {
                Image(systemName: "circle.grid.2x2")
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(Color(hex: theme.accent).opacity(0.8))
            }
        }
        .frame(height: compact ? 19 : 23)
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
            LunarVectorIcon(glyph: glyph, theme: theme, size: 20)
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 9, weight: .semibold))
                    .tracking(0.2)
                    .foregroundStyle(Color(hex: theme.muted))
                    .lineLimit(1)
                Text(value)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Color(hex: theme.foreground))
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 3)
    }
}

struct LunarVectorInline: View {
    let glyph: LunarGlyph
    let value: String
    let theme: LunarTheme

    var body: some View {
        HStack(spacing: 5) {
            LunarVectorIcon(glyph: glyph, theme: theme, size: 17)
            Text(value)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(Color(hex: theme.foreground))
                .lineLimit(1)
                .minimumScaleFactor(0.78)
        }
    }
}
