import SwiftUI
import UIKit

/// Reusable, accessible controls extracted from the user's original Vietnamese
/// heritage asset board. Functional text and dates remain native SwiftUI views.
enum LunarHeritageComponents {
    static func available(_ name: String) -> Bool { UIImage(named: name) != nil }

    /// Fallbacks keep the GitHub app functional until the entire separately
    /// cropped PNG pack is copied to the Xcode asset catalog.
    static func imageOrFallback(_ name: String) -> String {
        if available(name) { return name }
        if name.contains("FestivalTet") { return "HeritagePeach" }
        if name.contains("FestivalTao") || name.contains("FestivalGioChap") { return "HeritageGate" }
        if name.contains("FestivalVuLan") || name.contains("FestivalHaNguyen") { return "HeritageLotus" }
        if name.contains("FestivalMidAutumn") { return "HeritageLantern" }
        if name.contains("FestivalDuanNgo") { return "HeritageBamboo" }
        if name.contains("FestivalHungKings") { return "HeritageGate" }
        if name.contains("FestivalTrungCuu") { return "HeritagePeach" }
        if name.contains("FestivalHanThuc") { return "HeritageCloud" }
        if name.contains("ActionHeart") || name.contains("ActionFamily") { return "HeritageLotus" }
        if name.contains("ActionCalendar") { return "HeritageDongSon" }
        return "HeritageCloud"
    }

    static func symbol(for name: String) -> String {
        if name.contains("NavPrev") { return "chevron.left" }
        if name.contains("NavNext") { return "chevron.right" }
        if name.contains("NavAdd") { return "plus" }
        if name.contains("Calendar") { return "calendar" }
        if name.contains("Bell") { return "bell" }
        if name.contains("Family") { return "person.2" }
        if name.contains("Culture") { return "book.closed" }
        if name.contains("Settings") { return "gearshape" }
        if name.contains("Heart") { return "heart" }
        return "circle" 
    }

    static func festivalImage(for title: String) -> String? {
        if title.contains("Nguyên Đán") { return "HeritageFestivalTet" }
        if title.contains("Táo") { return "HeritageFestivalTao" }
        if title.contains("Vu Lan") { return "HeritageFestivalVuLan" }
        if title.contains("Trung Thu") { return "HeritageFestivalMidAutumn" }
        if title.contains("Giỗ Tổ") { return "HeritageFestivalHungKings" }
        if title.contains("Đoan Ngọ") { return "HeritageFestivalDuanNgo" }
        if title.contains("Hạ Nguyên") { return "HeritageFestivalHaNguyen" }
        if title.contains("Trùng Cửu") { return "HeritageFestivalTrungCuu" }
        if title.contains("Hàn Thực") { return "HeritageFestivalHanThuc" }
        if title.contains("giỗ") || title.contains("Giỗ") { return "HeritageFestivalGioChap" }
        return nil
    }

    static func ribbonImage(for theme: LunarTheme) -> String {
        switch theme {
        case .zen, .heritage, .tet: return "HeritageTitleCream"
        case .luxury, .gold, .ink: return "HeritageTitleRed"
        case .jade, .lotus, .midAutumn: return "HeritageTitleGreen"
        }
    }

    static func patternImage(for theme: LunarTheme) -> String {
        switch theme {
        case .zen, .heritage: return "HeritagePatternPaper"
        case .tet, .luxury, .lotus: return "HeritagePatternRed"
        case .jade, .ink, .midAutumn: return "HeritagePatternJade"
        case .gold: return "HeritagePatternGold"
        }
    }
}

struct LunarHeritageSectionTitle: View {
    let title: String
    let theme: LunarTheme
    var body: some View {
        if theme == .zen {
            Text(title)
                .font(.system(size: 11, weight: .semibold))
                .tracking(1.1)
                .foregroundStyle(Color(hex: theme.accent))
        } else {
            ZStack {
                if LunarHeritageComponents.available(LunarHeritageComponents.ribbonImage(for: theme)) {
                    Image(LunarHeritageComponents.ribbonImage(for: theme))
                        .resizable(capInsets: EdgeInsets(top: 14, leading: 43, bottom: 14, trailing: 43), resizingMode: .stretch)
                        .frame(height: 39)
                } else {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color(hex: theme.secondaryBackground))
                        .overlay(RoundedRectangle(cornerRadius: 14)
                            .stroke(Color(hex: theme.accent).opacity(0.35), lineWidth: 1))
                }
                Text(title)
                    .font(.system(size: 11, weight: .semibold, design: .serif))
                    .foregroundStyle(theme == .heritage || theme == .tet ? Color(hex: "#6D3426") : .white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .padding(.horizontal, 20)
            }
            .frame(height: 39)
        }
    }
}

struct LunarHeritageActionButton: View {
    let assetName: String
    let accessibilityTitle: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                if LunarHeritageComponents.available(assetName) {
                    Image(assetName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 37, height: 37)
                } else {
                    Image(systemName: LunarHeritageComponents.symbol(for: assetName))
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(Color(hex: "#9E2922"))
                        .frame(width: 36, height: 36)
                        .background(Color(hex: "#F8EACB"), in: Circle())
                        .overlay(Circle().stroke(Color(hex: "#D9A545"), lineWidth: 1.4))
                }
            }
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityTitle)
    }
}

struct LunarHeritageFestivalIllustration: View {
    let festivalTitle: String
    var size: CGFloat = 38

    @ViewBuilder
    var body: some View {
        if let resource = LunarHeritageComponents.festivalImage(for: festivalTitle) {
            Image(LunarHeritageComponents.imageOrFallback(resource))
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
                .accessibilityHidden(true)
        }
    }
}

struct LunarHeritagePatternDivider: View {
    let theme: LunarTheme
    var body: some View {
        Group {
            if LunarHeritageComponents.available(LunarHeritageComponents.patternImage(for: theme)) {
                Image(LunarHeritageComponents.patternImage(for: theme))
                    .resizable(resizingMode: .tile)
                    .frame(height: 4)
                    .opacity(0.25)
            } else {
                Rectangle()
                    .fill(Color(hex: theme.accent).opacity(0.12))
                    .frame(height: 1)
            }
        }
        .accessibilityHidden(true)
    }
}
