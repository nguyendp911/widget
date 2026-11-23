import SwiftUI

/// Entirely local vector art. No remote images, API keys or runtime downloads.
/// WidgetKit renders snapshots; this is not a continuously animated widget.
struct LivingSceneView: View {
    let scene: LivingScene
    let date: Date
    var saturation: Double = 1

    private var evening: Bool {
        let hour = Calendar.current.component(.hour, from: date)
        return hour >= 18 || hour < 6
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                LinearGradient(colors: palette,
                               startPoint: .topLeading, endPoint: .bottomTrailing)
                switch scene {
                case .aurora: aurora
                case .cosmos: cosmos
                case .zen: zen
                case .neon: neon
                case .dream: dream
                case .noir: noir
                }
                LinearGradient(colors: [.black.opacity(0.13), .clear, .black.opacity(0.22)],
                               startPoint: .top, endPoint: .bottom)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .clipped()
        }
        .drawingGroup(opaque: false)
        .accessibilityHidden(true)
    }

    private var palette: [Color] {
        switch scene {
        case .aurora: return evening ? [.init(hex: "#03152D"), .init(hex: "#15436C"), .init(hex: "#082439")] : [.init(hex: "#123F5F"), .init(hex: "#258F91"), .init(hex: "#5DB5AA")]
        case .cosmos: return [.init(hex: "#150B31"), .init(hex: "#452273"), .init(hex: "#0D1D43")]
        case .zen: return evening ? [.init(hex: "#142C3A"), .init(hex: "#986C75"), .init(hex: "#2C514B")] : [.init(hex: "#426D73"), .init(hex: "#F5A879"), .init(hex: "#8DC6B3")]
        case .neon: return [.init(hex: "#100C25"), .init(hex: "#46275F"), .init(hex: "#191B43")]
        case .dream: return [.init(hex: "#54467A"), .init(hex: "#B68CAC"), .init(hex: "#F2AFB9")]
        case .noir: return [.init(hex: "#070911"), .init(hex: "#263045"), .init(hex: "#10131B")]
        }
    }

    private var stars: some View {
        Canvas { context, size in
            for index in 0..<75 {
                let x = CGFloat((index * 73 + 17) % 101) / 101 * size.width
                let y = CGFloat((index * 47 + 11) % 103) / 103 * size.height
                let r: CGFloat = index.isMultiple(of: 9) ? 1.65 : 0.65
                let rect = CGRect(x: x, y: y, width: r * 2, height: r * 2)
                context.fill(Path(ellipseIn: rect), with: .color(.white.opacity(index.isMultiple(of: 4) ? 0.85 : 0.42)))
            }
        }
    }

    private var aurora: some View {
        GeometryReader { proxy in
            ZStack {
                stars.opacity(evening ? 1 : 0.36)
                Ellipse().fill(Color(hex: "#3BE8D6").opacity(0.40))
                    .frame(width: proxy.size.width * 1.25, height: proxy.size.height * 0.45)
                    .blur(radius: 38).rotationEffect(.degrees(-28))
                    .offset(x: proxy.size.width * 0.24, y: -proxy.size.height * 0.21)
                Ellipse().fill(Color(hex: "#BA85FF").opacity(0.47))
                    .frame(width: proxy.size.width, height: proxy.size.height * 0.30)
                    .blur(radius: 34).rotationEffect(.degrees(32))
                    .offset(x: -proxy.size.width * 0.2, y: proxy.size.height * 0.12)
                Circle().stroke(.white.opacity(0.22), lineWidth: 1)
                    .frame(width: proxy.size.width * 0.80)
                    .offset(x: proxy.size.width * 0.43, y: proxy.size.height * 0.44)
            }
        }
    }

    private var cosmos: some View {
        GeometryReader { proxy in
            ZStack {
                stars
                Circle().fill(Color(hex: "#AE7EFF").opacity(0.48))
                    .frame(width: proxy.size.width * 0.60).blur(radius: 46)
                    .offset(x: proxy.size.width * 0.32, y: -proxy.size.height * 0.20)
                Circle().fill(LinearGradient(colors: [Color(hex: "#FBBCE6"), Color(hex: "#8D66D6"), Color(hex: "#3E296D")], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: proxy.size.width * 0.42)
                    .overlay(Circle().stroke(.white.opacity(0.34), lineWidth: 1))
                    .shadow(color: Color(hex: "#BD8BFF").opacity(0.65), radius: 32)
                    .offset(x: proxy.size.width * 0.26, y: -proxy.size.height * 0.24)
                Ellipse().stroke(Color(hex: "#FFCAF5").opacity(0.34), lineWidth: 2)
                    .frame(width: proxy.size.width * 0.87, height: proxy.size.width * 0.19)
                    .rotationEffect(.degrees(-28))
                    .offset(x: proxy.size.width * 0.24, y: -proxy.size.height * 0.22)
            }
        }
    }

    private var zen: some View {
        GeometryReader { proxy in
            ZStack {
                Circle().fill(Color(hex: "#FFF0B7").opacity(0.82))
                    .frame(width: proxy.size.width * 0.46)
                    .blur(radius: 2)
                    .shadow(color: Color(hex: "#FFC697").opacity(0.70), radius: 28)
                    .offset(x: proxy.size.width * 0.27, y: -proxy.size.height * 0.16)
                Canvas { context, size in
                    for ridge in 0..<3 {
                        var path = Path()
                        let baseY = size.height * (0.61 + Double(ridge) * 0.13)
                        path.move(to: CGPoint(x: 0, y: baseY + 28))
                        path.addCurve(to: CGPoint(x: size.width, y: baseY + 9),
                                      control1: CGPoint(x: size.width * 0.30, y: baseY - 40),
                                      control2: CGPoint(x: size.width * 0.67, y: baseY + 55))
                        path.addLine(to: CGPoint(x: size.width, y: size.height))
                        path.addLine(to: CGPoint(x: 0, y: size.height))
                        path.closeSubpath()
                        context.fill(path, with: .color([Color(hex: "#8FAAA0"), Color(hex: "#577E76"), Color(hex: "#234C4B")][ridge].opacity(0.96)))
                    }
                }
            }
        }
    }

    private var neon: some View {
        GeometryReader { proxy in
            ZStack {
                Circle().fill(Color(hex: "#F44CBE").opacity(0.53))
                    .frame(width: proxy.size.width * 0.54).blur(radius: 45)
                    .offset(x: proxy.size.width * 0.25, y: -proxy.size.height * 0.2)
                Canvas { context, size in
                    for index in 0..<19 {
                        let x = CGFloat(index) * size.width / 19
                        let width = size.width / 17
                        let height = size.height * CGFloat(0.17 + Double((index * 17) % 13) / 45)
                        let rect = CGRect(x: x, y: size.height - height, width: width, height: height)
                        context.fill(Path(rect), with: .color(Color(hex: index.isMultiple(of: 3) ? "#353666" : "#25234C")))
                        for j in 0..<4 {
                            let dot = CGRect(x: x + 4, y: size.height - height + 9 + CGFloat(j) * 13, width: 2.2, height: 3.2)
                            context.fill(Path(roundedRect: dot, cornerRadius: 1), with: .color(Color(hex: index.isMultiple(of: 2) ? "#FF7ED2" : "#62F2FA").opacity(0.85)))
                        }
                    }
                }
            }
        }
    }

    private var dream: some View {
        GeometryReader { proxy in
            ZStack {
                ForEach(0..<5, id: \.self) { index in
                    Circle()
                        .fill(Color.white.opacity(index.isMultiple(of: 2) ? 0.10 : 0.18))
                        .frame(width: proxy.size.width * (0.28 + Double(index) * 0.14))
                        .blur(radius: CGFloat(index * 6 + 4))
                        .offset(x: proxy.size.width * CGFloat(Double((index * 7) % 5) - 2) * 0.14,
                                y: proxy.size.height * CGFloat(Double((index * 11) % 7) - 3) * 0.12)
                }
                Circle().stroke(.white.opacity(0.30), lineWidth: 1)
                    .frame(width: proxy.size.width * 0.65)
                    .offset(x: proxy.size.width * 0.22, y: proxy.size.height * 0.1)
                stars.opacity(0.55)
            }
        }
    }

    private var noir: some View {
        GeometryReader { proxy in
            ZStack {
                Circle()
                    .stroke(LinearGradient(colors: [.white.opacity(0.42), .clear], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)
                    .frame(width: proxy.size.width * 0.96)
                    .offset(x: proxy.size.width * 0.43, y: -proxy.size.height * 0.2)
                RoundedRectangle(cornerRadius: 38)
                    .fill(.white.opacity(0.06))
                    .frame(width: proxy.size.width * 0.85, height: proxy.size.height * 0.74)
                    .rotationEffect(.degrees(22))
                    .offset(x: proxy.size.width * 0.3, y: proxy.size.height * 0.23)
            }
        }
    }
}
