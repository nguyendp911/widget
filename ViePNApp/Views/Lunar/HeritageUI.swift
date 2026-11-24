import SwiftUI

enum HeritagePalette {
    static let paper = Color(hex: "#F7E9D2")
    static let ink = Color(hex: "#512D22")
    static let red = Color(hex: "#9D181C")
    static let gold = Color(hex: "#C89438")
    static let soft = Color(hex: "#80664C")
}

struct HeritageFrame: ViewModifier {
    var radius: CGFloat = 18
    func body(content: Content) -> some View {
        content
            .background(Color(hex: "#FFFAEC"), in: RoundedRectangle(cornerRadius: radius))
            .overlay(RoundedRectangle(cornerRadius: radius).strokeBorder(HeritagePalette.gold, lineWidth: 1.2))
            .overlay(RoundedRectangle(cornerRadius: max(1, radius - 3)).strokeBorder(HeritagePalette.gold.opacity(0.35), lineWidth: 0.6).padding(3))
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

struct HeritageDayHero: View {
    let day: SolarCivilDate
    let lunar: VietnameseLunarDate?
    let facts: LunarAlmanacFacts
    let appearance: LunarAppearance
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(hex: "#6F0C12"), Color(hex: "#B62123"), Color(hex: "#7E1114")], startPoint: .topLeading, endPoint: .bottomTrailing)
            if appearance.showOrnament {
                HeritageDrumMark(tint: Color(hex: "#EAC67A")).frame(width: 215, height: 215).opacity(0.22).accessibilityHidden(true)
                VStack {
                    HStack {
                        Image("TNVBlossom").resizable().scaledToFit().frame(width: 100)
                        Spacer()
                        Image("TNVCloud").resizable().scaledToFit().frame(width: 66)
                    }
                    Spacer()
                    HStack(alignment: .bottom) {
                        Image("TNVMountain").resizable().scaledToFit().frame(width: 115)
                        Spacer()
                        Image("TNVLotus").resizable().scaledToFit().frame(width: 88)
                    }
                }.accessibilityHidden(true)
            }
            VStack(spacing: 9) {
                HStack(spacing: 0) {
                    dateColumn("DƯƠNG LỊCH", String(day.day), "Tháng \(day.month), \(String(day.year))")
                    Rectangle().fill(Color(hex: "#EAC67A").opacity(0.75)).frame(width: 1, height: 91)
                    dateColumn("ÂM LỊCH", lunar.map { String($0.day) } ?? "—", lunar.map { "Tháng \($0.month)\($0.isLeapMonth ? " nhuận" : "")" } ?? "Ngoài phạm vi")
                }
                Text("\(facts.canChiDay) · \(facts.dayKind)")
                    .font(.system(size: 13, weight: .medium, design: .serif))
                    .padding(.horizontal, 11).padding(.vertical, 6)
                    .background(Color(hex: "#630D13").opacity(0.9), in: Capsule())
            }.padding(.vertical, 17).padding(.horizontal, 16)
        }
        .frame(minHeight: 178)
        .foregroundStyle(Color(hex: "#FFF0C7"))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).strokeBorder(Color(hex: "#DCA94B"), lineWidth: 2))
        .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(Color(hex: "#FFE3A0"), lineWidth: 0.7).padding(5))
    }

    private func dateColumn(_ title: String, _ number: String, _ footer: String) -> some View {
        VStack(spacing: 3) {
            Text(title).font(.system(size: 10, weight: .semibold)).tracking(1)
            Text(number).font(.system(size: 57, weight: .medium, design: .serif)).monospacedDigit()
            Text(footer).font(.system(size: 12, weight: .medium, design: .serif)).lineLimit(2)
        }.frame(maxWidth: .infinity)
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
            Image(jade ? "TNVJadePlaque" : "TNVLacquerPlaque")
                .resizable().scaledToFit()
            Text(title)
                .font(.system(size: 16, weight: .semibold, design: .serif))
                .foregroundStyle(Color(hex: "#FFF1C9"))
                .lineLimit(1)
                .minimumScaleFactor(0.75)
                .padding(.horizontal, 47)
        }
        .frame(maxWidth: .infinity)
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
