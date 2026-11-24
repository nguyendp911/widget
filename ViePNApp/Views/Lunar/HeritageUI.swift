import SwiftUI

enum HeritagePalette {
    static let paper = Color(hex: "#F6F0E5")
    static let ink = Color(hex: "#332923")
    static let red = Color(hex: "#84262B")
    static let gold = Color(hex: "#B68B49")
    static let soft = Color(hex: "#80664C")
}

struct HeritageFrame: ViewModifier {
    var radius: CGFloat = 18
    func body(content: Content) -> some View {
        content
            .background(Color(hex: "#FFFAEC"), in: RoundedRectangle(cornerRadius: radius))
            .overlay(RoundedRectangle(cornerRadius: radius).strokeBorder(HeritagePalette.gold, lineWidth: 1.2))
             .overlay(RoundedRectangle(cornerRadius: max(1, radius - 3)).strokeBorder(HeritagePalette.gold.opacity(0.35), lineWidth: 0.6).padding(3))
            .overlay {
                HeritageCornerArt().padding(6).allowsHitTesting(false).accessibilityHidden(true)
            }
    }
}
extension View {
    func heritageFrame(radius: CGFloat = 18) -> some View { modifier(HeritageFrame(radius: radius)) }
}

struct HeritageBanner: View {
    let title: String
    let subtitle: String
    var image = "ViePNXuanVietLarge"
    var body: some View {
        ZStack {
            GeometryReader { g in
                Image(image).resizable().scaledToFill().frame(width: g.size.width, height: g.size.height).clipped()
            }
            LinearGradient(colors: [Color(hex: "#FFF3D9").opacity(0.98), Color(hex: "#FFF3D9").opacity(0.85), .clear], startPoint: .leading, endPoint: .trailing)
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    HeritageDrumMark(tint: HeritagePalette.gold).frame(width: 37, height: 37).accessibilityHidden(true)
                    Text(title).font(.system(size: 26, weight: .bold, design: .serif)).foregroundStyle(HeritagePalette.red).lineLimit(2).minimumScaleFactor(0.75)
                    Text(subtitle).font(.system(size: 12, weight: .medium)).foregroundStyle(HeritagePalette.ink)
                }
                Spacer(minLength: 0)
            }.padding(18)
        }
        .frame(height: 140)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .heritageFrame(radius: 20)
    }
}

/// Editorial calendar card: one dominant date, a lunar seal, and clear calendar context.
struct HeritageDayHero: View {
    let day: SolarCivilDate
    let lunar: VietnameseLunarDate?
    let facts: LunarAlmanacFacts
    let appearance: LunarAppearance
    private let cream = Color(hex: "#FFF0D2")
    private let brass = Color(hex: "#E6C17B")

    private var weekday: String {
        guard let date = day.asDate() else { return "" }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "vi_VN")
        formatter.timeZone = VietnameseLunarCalendar.vietnamTimeZone
        formatter.dateFormat = "EEEE"
        return formatter.string(from: date).capitalized
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 17) {
            HStack(alignment: .center) {
                Label("LỊCH VIỆT", systemImage: "sun.max").font(.caption.weight(.semibold)).tracking(2)
                Spacer()
                Text(weekday).font(.subheadline.weight(.medium))
            }.foregroundStyle(brass)
            HStack(alignment: .center, spacing: 18) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("DƯƠNG LỊCH").font(.caption2.weight(.semibold)).tracking(1.3).foregroundStyle(brass)
                    Text(String(day.day)).font(.system(size: 84, weight: .regular, design: .serif)).monospacedDigit()
                        .lineLimit(1).minimumScaleFactor(0.5).contentTransition(.numericText())
                    Text("Tháng " + String(day.month) + " · " + String(day.year))
                        .font(.subheadline.weight(.medium)).foregroundStyle(brass)
                }.frame(maxWidth: .infinity, alignment: .leading)
                VStack(spacing: 6) {
                    ZStack {
                        Circle().fill(Color(hex: "#F0D49A"))
                        Circle().strokeBorder(brass, lineWidth: 1.5).padding(5)
                        if appearance.showOrnament {
                            HeritageDrumMark(tint: Color(hex: "#9C6329")).padding(9).opacity(0.35)
                        }
                        VStack(spacing: 0) {
                            Text(lunar.map { String($0.day) } ?? "—")
                                .font(.system(size: 43, weight: .semibold, design: .serif)).monospacedDigit()
                            Text("ÂM LỊCH").font(.system(size: 9, weight: .semibold)).tracking(1)
                        }.foregroundStyle(Color(hex: "#621B20"))
                    }.frame(width: 111, height: 111)
                    Text(lunar.map { "Tháng " + String($0.month) + ($0.isLeapMonth ? " nhuận" : "") } ?? "Ngoài phạm vi")
                        .font(.caption.weight(.medium)).foregroundStyle(brass)
                }
            }
            Rectangle().fill(brass.opacity(0.35)).frame(height: 1)
            HStack(alignment: .center, spacing: 10) {
                HeritageAnimalArtwork(branch: facts.dayAnimal).frame(width: 43, height: 43)
                VStack(alignment: .leading, spacing: 4) {
                    Text(facts.canChiDay).font(.system(.headline, design: .serif))
                    Text("Năm " + facts.canChiYear).font(.caption).foregroundStyle(brass)
                }
                Spacer(minLength: 5)
                Text(facts.dayKind)
                    .font(.caption.weight(.semibold)).foregroundStyle(cream)
                    .padding(.horizontal, 10).padding(.vertical, 7)
                    .background(Color.white.opacity(0.10), in: Capsule())
                    .overlay(Capsule().strokeBorder(brass.opacity(0.55), lineWidth: 0.7))
            }
        }.padding(22)
        .foregroundStyle(cream)
        .background {
            ZStack(alignment: .trailing) {
                LinearGradient(colors: [Color(hex: "#381318"), Color(hex: "#70232B"), Color(hex: "#4A161F")], startPoint: .topLeading, endPoint: .bottomTrailing)
                if appearance.showOrnament {
                    HeritageDrumMark(tint: brass).frame(width: 260, height: 260).offset(x: 85, y: -62).opacity(0.13).accessibilityHidden(true)
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 26))
        .overlay(RoundedRectangle(cornerRadius: 26).strokeBorder(brass.opacity(0.7), lineWidth: 1))
    }
}

/// Quiet paper card for reading and interaction, without repeated ornamental borders.
struct EditorialSurface: ViewModifier {
    var radius: CGFloat = 20
    func body(content: Content) -> some View {
        content
            .background(Color(hex: "#FFFDF7"), in: RoundedRectangle(cornerRadius: radius))
            .overlay(RoundedRectangle(cornerRadius: radius).strokeBorder(Color(hex: "#DDCDB1"), lineWidth: 0.8))
    }
}
extension View {
    func editorialSurface(radius: CGFloat = 20) -> some View { modifier(EditorialSurface(radius: radius)) }
}

struct EditorialSectionTitle: View {
    let eyebrow: String
    let title: String
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(eyebrow.uppercased()).font(.caption2.weight(.semibold)).tracking(2).foregroundStyle(HeritagePalette.soft)
            Text(title).font(.system(size: 25, weight: .semibold, design: .serif)).foregroundStyle(HeritagePalette.ink)
        }.frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct HeritageRootView: View {
    var body: some View {
        TabView {
            NavigationStack { ThienNienHomeView() }
                .tabItem { Label("Hôm nay", systemImage: "sun.max") }
            NavigationStack { HeritageCalendarView() }
                .tabItem { Label("Lịch âm", systemImage: "calendar") }
            NavigationStack { HeritageFamilyView() }
                .tabItem { Label("Gia đình", systemImage: "person.2") }
            NavigationStack { HeritageAstrologyView() }
                .tabItem { Label("Thiên mệnh", systemImage: "sparkles") }
            NavigationStack { HeritageCultureView() }
                .tabItem { Label("Văn hóa", systemImage: "book") }
        }
        .tint(HeritagePalette.red)
        .preferredColorScheme(.light)
    }
}


struct HeritagePlaque: View {
    let title: String
    var jade = false
    var body: some View {
        ZStack {
            HeritagePlaqueArt(jade: jade)
                .accessibilityHidden(true)
            Text(title)
                .font(.system(size: 16, weight: .semibold, design: .serif))
                .foregroundStyle(Color(hex: "#FFF1C9"))
                .lineLimit(1)
                .minimumScaleFactor(0.75)
                .padding(.horizontal, 47)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 56)
        .accessibilityElement(children: .combine)
    }
}


/// Native scalable ornament inspired by concentric Đông Sơn bronze-drum
/// geometry. It is drawn at the device's resolution, never upscaled as a bitmap.
struct HeritageDrumMark: View {
    var tint: Color = HeritagePalette.gold
    var body: some View {
        GeometryReader { proxy in
            let size = min(proxy.size.width, proxy.size.height)
            ZStack {
                Circle().strokeBorder(tint, lineWidth: max(0.7, size * 0.012))
                ForEach([0.90, 0.76, 0.66, 0.48], id: \.self) { scale in
                    Circle().strokeBorder(tint, lineWidth: max(0.55, size * 0.006))
                        .frame(width: size * scale, height: size * scale)
                }
                Path { path in
                    let center = CGPoint(x: size / 2, y: size / 2)
                    for i in 0..<24 {
                        let a = Double(i) * .pi / 12
                        let b = a + .pi / 24
                        func point(_ angle: Double, _ radius: CGFloat) -> CGPoint {
                            CGPoint(x: center.x + CGFloat(cos(angle)) * radius * size,
                                    y: center.y + CGFloat(sin(angle)) * radius * size)
                        }
                        path.move(to: point(a, 0.385))
                        path.addLine(to: point(b, 0.445))
                        path.addLine(to: point(a + .pi / 12, 0.385))
                    }
                    for i in 0..<24 {
                        let angle = Double(i) * .pi / 12 - .pi / 2
                        let radius: CGFloat = i.isMultiple(of: 2) ? 0.225 : 0.082
                        let point = CGPoint(x: center.x + CGFloat(cos(angle)) * radius * size,
                                            y: center.y + CGFloat(sin(angle)) * radius * size)
                        if i == 0 { path.move(to: point) } else { path.addLine(to: point) }
                    }
                    path.closeSubpath()
                }.stroke(tint, style: StrokeStyle(lineWidth: max(0.55, size * 0.008), lineJoin: .round))
            }
            .frame(width: size, height: size)
            .position(x: proxy.size.width / 2, y: proxy.size.height / 2)
        }
    }
}


// MARK: - Resolution-independent Vietnamese decorative assets

struct HeritageCornerArt: View {
    var body: some View {
        GeometryReader { g in
            Path { p in
                for i in 0..<4 {
                    let x: CGFloat = i % 2 == 0 ? 0 : g.size.width
                    let y: CGFloat = i < 2 ? 0 : g.size.height
                    let dx: CGFloat = i % 2 == 0 ? 1 : -1
                    let dy: CGFloat = i < 2 ? 1 : -1
                    let offsets: [(CGFloat, CGFloat)] = [(0,14),(0,6),(6,6),(6,0),(14,0),(14,3),(9,3),(9,9),(3,9),(3,14)]
                    for (n, pt) in offsets.enumerated() {
                        let v = CGPoint(x: x + pt.0 * dx, y: y + pt.1 * dy)
                        if n == 0 { p.move(to: v) } else { p.addLine(to: v) }
                    }
                }
            }.stroke(HeritagePalette.gold.opacity(0.7), style: StrokeStyle(lineWidth: 0.8, lineJoin: .round))
        }
    }
}

struct HeritagePlaqueArt: View {
    var jade: Bool
    var body: some View {
        GeometryReader { g in
            let w = g.size.width
            let h = g.size.height
            ZStack {
                RoundedRectangle(cornerRadius: 13)
                    .fill(LinearGradient(colors: jade ? [Color(hex: "#113E38"), Color(hex: "#26736A"), Color(hex: "#123D36")] : [Color(hex: "#5D1016"), Color(hex: "#A32A28"), Color(hex: "#641016")], startPoint: .topLeading, endPoint: .bottomTrailing))
                RoundedRectangle(cornerRadius: 13).strokeBorder(Color(hex: "#C89A4C"), lineWidth: 1.8)
                RoundedRectangle(cornerRadius: 9).strokeBorder(Color(hex: "#EAC67A").opacity(0.8), lineWidth: 0.7).padding(4)
                HStack {
                    HeritageDrumMark(tint: Color(hex: "#EAC67A")).frame(width: 30, height: 30)
                    Spacer()
                    HeritageLotusMark(tint: Color(hex: "#EAC67A")).frame(width: 30, height: 30)
                }.padding(.horizontal, 12)
                Path { p in
                    p.move(to: CGPoint(x: w * 0.2, y: 8))
                    p.addLine(to: CGPoint(x: w * 0.8, y: 8))
                    p.move(to: CGPoint(x: w * 0.2, y: h - 8))
                    p.addLine(to: CGPoint(x: w * 0.8, y: h - 8))
                }.stroke(Color(hex: "#EAC67A").opacity(0.4), lineWidth: 0.5)
            }
        }
    }
}

struct HeritageLotusMark: View {
    var tint: Color = HeritagePalette.gold
    var body: some View {
        GeometryReader { g in
            Path { p in
                let w = g.size.width, h = g.size.height
                func pt(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: x*w, y: y*h) }
                for sign in [CGFloat(-1), CGFloat(1)] {
                    p.move(to: pt(0.5,0.76))
                    p.addQuadCurve(to: pt(0.5+sign*0.46,0.38), control: pt(0.5+sign*0.43,0.8))
                    p.addQuadCurve(to: pt(0.5,0.76), control: pt(0.5+sign*0.10,0.36))
                    p.move(to: pt(0.5,0.76))
                    p.addQuadCurve(to: pt(0.5+sign*0.26,0.15), control: pt(0.5+sign*0.31,0.44))
                    p.addQuadCurve(to: pt(0.5,0.76), control: pt(0.5+sign*0.02,0.23))
                }
                p.move(to: pt(0.5,0.76))
                p.addQuadCurve(to: pt(0.5,0.04), control: pt(0.18,0.45))
                p.addQuadCurve(to: pt(0.5,0.76), control: pt(0.82,0.45))
                p.move(to: pt(0.17,0.84)); p.addQuadCurve(to: pt(0.83,0.84), control: pt(0.5,1))
            }.stroke(tint, style: StrokeStyle(lineWidth: max(0.8, min(g.size.width,g.size.height)*0.025), lineCap: .round, lineJoin: .round))
        }
    }
}

/// Twelve individual, original line-art glyphs in a shared 64-unit coordinate space.
/// M = move, L = line, Q = quadratic curve, Z = close. All glyphs remain sharp at any size.
struct HeritageAnimalMark: View {
    let branch: String
    var tint = Color(hex: "#F3D68D")
    private static let artwork: [String: String] = [
        "Tý": "M 8 44 Q 6 27 22 24 Q 24 12 34 18 Q 40 21 39 28 Q 53 29 57 39 L 62 41 L 53 45 Q 42 54 26 49 L 18 53 M 8 44 Q 0 42 3 32 Q 7 27 11 29 M 47 35 L 48 35 M 50 43 L 59 48 M 25 49 L 26 55",
        "Sửu": "M 18 23 Q 6 25 6 9 Q 11 19 23 17 M 46 23 Q 58 25 58 9 Q 53 19 41 17 M 18 22 Q 32 11 46 22 L 48 39 Q 49 55 32 57 Q 15 55 16 39 Z M 17 25 L 6 22 Q 5 34 16 33 M 47 25 L 58 22 Q 59 34 48 33 M 23 32 L 25 32 M 39 32 L 41 32 M 23 43 Q 32 39 41 43 L 41 49 Q 32 53 23 49 Z M 27 46 L 28 46 M 36 46 L 37 46",
        "Dần": "M 13 23 Q 4 6 20 12 L 25 17 Q 32 13 39 17 L 44 12 Q 60 6 51 23 Q 59 36 48 49 Q 32 62 16 49 Q 5 36 13 23 Z M 25 21 L 32 26 L 39 21 M 32 26 L 32 32 M 15 31 L 23 34 M 49 31 L 41 34 M 13 40 L 22 40 M 51 40 L 42 40 M 23 36 L 25 36 M 39 36 L 41 36 M 27 43 L 37 43 L 32 47 Z M 32 47 Q 26 53 22 47 M 32 47 Q 38 53 42 47",
        "Mão": "M 13 26 L 9 8 L 27 18 Q 32 16 37 18 L 55 8 L 51 26 Q 60 40 46 51 Q 32 59 18 51 Q 4 40 13 26 Z M 17 20 L 15 13 M 47 20 L 49 13 M 21 34 Q 25 31 28 34 M 36 34 Q 39 31 43 34 M 28 41 L 36 41 L 32 44 Z M 32 44 Q 27 49 23 45 M 32 44 Q 37 49 41 45 M 7 40 L 19 42 M 7 47 L 19 45 M 57 40 L 45 42 M 57 47 L 45 45",
        "Thìn": "M 12 48 Q 3 31 17 24 Q 26 18 36 25 L 44 17 L 41 8 L 50 14 L 57 10 L 54 22 L 61 29 L 52 33 L 59 38 L 44 39 Q 34 35 31 42 Q 26 55 41 53 Q 49 52 51 46 M 12 48 L 5 53 L 17 54 Q 21 60 29 55 M 22 25 L 19 15 L 27 21 M 34 25 L 34 17 M 49 27 L 50 27 M 50 35 Q 60 43 63 35 M 17 35 Q 22 31 26 35 M 16 45 L 22 43",
        "Tỵ": "M 16 51 Q 3 50 6 40 Q 9 32 23 35 L 42 40 Q 55 44 57 34 Q 59 25 45 24 L 31 24 Q 21 23 23 15 Q 26 7 40 10 Q 55 10 55 18 L 47 23 M 16 51 Q 37 58 49 49 M 33 13 L 34 13 M 53 19 L 61 21 L 64 18 M 61 21 L 64 24 M 12 40 Q 18 38 25 43 M 29 46 Q 36 49 43 46",
        "Ngọ": "M 13 53 Q 9 40 19 28 L 26 19 L 23 8 L 35 16 L 44 8 L 43 21 Q 47 26 47 32 L 59 43 Q 61 49 52 52 L 42 49 L 32 39 Q 26 45 28 56 Z M 23 23 Q 9 24 8 41 M 21 20 Q 7 19 5 29 M 39 29 L 40 29 M 53 44 L 54 44 M 18 35 L 24 32",
        "Mùi": "M 22 22 Q 9 20 10 10 Q 12 2 23 6 Q 17 13 27 19 M 42 22 Q 55 20 54 10 Q 52 2 41 6 Q 47 13 37 19 M 21 22 Q 32 17 43 22 L 44 38 Q 42 48 35 50 L 32 59 L 29 50 Q 22 48 20 38 Z M 20 25 Q 5 22 8 34 L 20 35 M 44 25 Q 59 22 56 34 L 44 35 M 25 31 L 27 31 M 37 31 L 39 31 M 29 42 L 35 42 L 32 46 Z",
        "Thân": "M 15 22 Q 6 17 4 29 Q 4 42 15 39 M 49 22 Q 58 17 60 29 Q 60 42 49 39 M 15 19 Q 20 10 32 13 Q 44 10 49 19 Q 56 34 47 47 Q 32 58 17 47 Q 8 34 15 19 Z M 32 27 Q 20 16 17 31 Q 14 39 24 41 Q 20 53 32 54 Q 44 53 40 41 Q 50 39 47 31 Q 44 16 32 27 Z M 24 32 L 25 32 M 39 32 L 40 32 M 29 40 L 35 40 M 27 46 Q 32 50 37 46",
        "Dậu": "M 19 27 Q 12 17 22 16 Q 17 6 27 10 Q 32 0 37 12 Q 48 5 45 18 Q 51 18 47 26 L 57 31 L 47 36 Q 50 43 43 45 Q 39 42 40 37 Q 36 52 22 55 L 9 55 Q 19 48 19 27 Z M 37 27 L 38 27 M 20 34 Q 30 35 29 49 M 21 20 L 29 18",
        "Tuất": "M 18 20 Q 32 12 46 20 L 55 17 Q 62 30 53 43 L 46 34 Q 50 51 32 57 Q 14 51 18 34 L 11 43 Q 2 30 9 17 Z M 23 32 L 25 32 M 39 32 L 41 32 M 27 41 Q 32 38 37 41 L 32 46 Z M 32 46 Q 26 51 22 47 M 32 46 Q 38 51 42 47 M 28 52 Q 32 57 36 52",
        "Hợi": "M 12 26 L 6 8 Q 18 8 24 18 Q 32 15 40 18 Q 46 8 58 8 L 52 26 Q 59 39 49 50 Q 32 61 15 50 Q 5 39 12 26 Z M 14 22 L 11 13 M 50 22 L 53 13 M 20 33 L 22 33 M 42 33 L 44 33 M 19 43 Q 19 36 32 36 Q 45 36 45 43 Q 45 50 32 50 Q 19 50 19 43 Z M 27 42 L 27 45 M 37 42 L 37 45"
    ]
    private var vector: Path {
        let tokens = (Self.artwork[branch] ?? "").split(separator: " ").map(String.init)
        var i = 0
        var p = Path()
        func point(_ offset: Int) -> CGPoint {
            CGPoint(x: Double(tokens[offset]) ?? 0, y: Double(tokens[offset+1]) ?? 0)
        }
        while i < tokens.count {
            switch tokens[i] {
            case "M", "L":
                guard i+2 < tokens.count else { return p }
                if tokens[i] == "M" { p.move(to: point(i+1)) } else { p.addLine(to: point(i+1)) }
                i += 3
            case "Q":
                guard i+4 < tokens.count else { return p }
                p.addQuadCurve(to: point(i+3), control: point(i+1)); i += 5
            case "Z": p.closeSubpath(); i += 1
            default: i += 1
            }
        }
        return p
    }
    var body: some View {
        GeometryReader { g in
            let scale = min(g.size.width, g.size.height) / 64
            let transform = CGAffineTransform(scaleX: scale, y: scale)
            vector.applying(transform)
                .stroke(tint, style: StrokeStyle(lineWidth: max(0.9, scale*1.7), lineCap: .round, lineJoin: .round))
                .frame(width: 64*scale, height: 64*scale)
                .position(x: g.size.width/2, y: g.size.height/2)
        }.accessibilityHidden(true)
    }
}
