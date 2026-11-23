import SwiftUI

/// Shared rendering core: this exact view renders in the preview and WidgetKit.
/// The widget always gets a static SwiftUI snapshot rather than continuous motion.
struct WidgetDesignView: View {
    let design: WidgetDesign
    let date: Date
    let habitCompleted: Bool

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                if let scene = design.scene {
                    LivingSceneView(scene: scene, date: date)
                } else {
                    design.backgroundColor
                }
                if design.layers.isEmpty {
                    classicContent
                        .padding(17)
                } else {
                    ForEach(design.layers) { layer in
                        if !layer.hidden {
                            CanvasLayerContent(layer: layer, design: design, date: date)
                                .frame(maxWidth: proxy.size.width * 0.86)
                                .scaleEffect(layer.scale)
                                .rotationEffect(.degrees(layer.rotation))
                                .opacity(layer.opacity)
                                .position(x: proxy.size.width * layer.x,
                                          y: proxy.size.height * layer.y)
                                .allowsHitTesting(false)
                        }
                    }
                }
                if design.showBorder {
                    RoundedRectangle(cornerRadius: 18)
                        .strokeBorder(design.accentColor.opacity(0.68), lineWidth: 1.4)
                        .padding(6)
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
        .accessibilityLabel("\(design.name), \(design.kind.title)")
    }

    private var mainFont: Font {
        switch design.fontPreset {
        case .rounded: return .system(size: 26 * design.fontScale, weight: .bold, design: .rounded)
        case .system: return .system(size: 26 * design.fontScale, weight: .bold)
        case .serif: return .system(size: 26 * design.fontScale, weight: .semibold, design: .serif)
        case .monospaced: return .system(size: 26 * design.fontScale, weight: .semibold, design: .monospaced)
        }
    }

    private var classicContent: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 7) {
                Image(systemName: design.kind.symbol)
                    .foregroundStyle(design.accentColor)
                Text(design.title)
                    .font(.system(size: 10, weight: .heavy, design: .rounded))
                    .tracking(1.4).lineLimit(1)
                Spacer(minLength: 0)
                Circle().fill(design.accentColor).frame(width: 5, height: 5)
            }
            Spacer(minLength: 0)
            contentByKind
            Spacer(minLength: 0)
            HStack {
                Text("VIEPN / LIVING CANVAS")
                    .font(.system(size: 8, weight: .heavy, design: .rounded))
                    .tracking(1.4)
                Spacer(minLength: 0)
                Image(systemName: "sparkle").foregroundStyle(design.accentColor)
            }
            .opacity(0.78)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .foregroundStyle(design.foregroundColor)
    }

    @ViewBuilder
    private var contentByKind: some View {
        switch design.kind {
        case .clock:
            VStack(alignment: .leading, spacing: 6) {
                Text(date, style: .time)
                    .font(.system(size: 39 * design.fontScale, weight: .light, design: .rounded))
                    .monospacedDigit().minimumScaleFactor(0.5).lineLimit(1)
                Text(date, format: .dateTime.weekday(.wide).day().month(.wide))
                    .font(.caption).opacity(0.8).lineLimit(2)
            }
        case .calendar:
            VStack(alignment: .leading, spacing: 1) {
                Text(date, format: .dateTime.day())
                    .font(.system(size: 56 * design.fontScale, weight: .thin, design: .rounded))
                Text(date, format: .dateTime.weekday(.wide).month(.wide).year())
                    .font(.caption).lineLimit(2)
            }
        case .photo:
            if let photo = SharedRepository().image(named: design.imageFileName) {
                GeometryReader { geo in
                    Image(uiImage: photo).resizable().scaledToFill()
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipped().clipShape(RoundedRectangle(cornerRadius: 12))
                }
            } else {
                Label("Thêm ảnh trong Magic Canvas", systemImage: "photo.artframe")
                    .font(.subheadline).lineLimit(3)
            }
        case .quote:
            Text("“\(design.message)”")
                .font(mainFont).minimumScaleFactor(0.55).lineLimit(5)
        case .countdown:
            VStack(alignment: .leading, spacing: 6) {
                if let target = design.targetDate {
                    Text(target, style: .relative)
                        .font(mainFont).minimumScaleFactor(0.55).lineLimit(2)
                } else { Text("Chọn ngày sự kiện").font(mainFont) }
                Text(design.message).font(.caption).opacity(0.85)
            }
        case .habit:
            VStack(alignment: .leading, spacing: 9) {
                Text(design.message).font(mainFont).lineLimit(2).minimumScaleFactor(0.6)
                Label(habitCompleted ? "Đã hoàn thành" : "Chưa hoàn thành",
                      systemImage: habitCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.caption.bold()).foregroundStyle(design.accentColor)
            }
        case .smart:
            SmartDailyContent(date: date, title: design.title, message: design.message, goals: design.smartGoals, accent: design.accentColor)
        case .memory:
            VStack(alignment: .leading, spacing: 5) {
                if let photo = SharedRepository().image(named: design.imageFileName) {
                    Image(uiImage: photo).resizable().scaledToFill()
                        .frame(width: 39, height: 39)
                        .clipShape(Circle())
                } else {
                    Image(systemName: "heart.fill")
                        .font(.title2).foregroundStyle(design.accentColor)
                }
                if let target = design.targetDate {
                    Text("\(abs(Calendar.current.dateComponents([.day], from: target, to: date).day ?? 0))")
                        .font(.system(size: 49 * design.fontScale, weight: .ultraLight, design: .rounded))
                    Text(target <= date ? "NGÀY KỶ NIỆM" : "NGÀY ĐẾN KỶ NIỆM")
                        .font(.system(size: 9, weight: .heavy)).tracking(1.6)
                }
                Text(design.message).font(.caption).lineLimit(2)
            }
        }
    }
}

struct SmartDailyContent: View {
    let date: Date
    let title: String
    let message: String
    let goals: [String]
    let accent: Color

    private var phase: (String, String, String) {
        switch Calendar.current.component(.hour, from: date) {
        case 5..<12: return ("GOOD MORNING", "sunrise.fill", "Bắt đầu với điều quan trọng nhất")
        case 12..<18: return ("KEEP MOVING", "sun.max.fill", "Một bước nhỏ cũng là tiến bộ")
        default: return ("SLOW DOWN", "moon.stars.fill", "Nhìn lại những điều tốt đẹp")
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack(spacing: 6) {
                Image(systemName: phase.1).foregroundStyle(accent)
                Text(phase.0).tracking(1.4)
            }
            .font(.system(size: 9, weight: .bold, design: .rounded))
            Text(date, style: .time)
                .font(.system(size: 34, weight: .light, design: .rounded))
                .minimumScaleFactor(0.5).lineLimit(1)
            Text(message.isEmpty ? phase.2 : message)
                .font(.caption).lineLimit(2)
            VStack(alignment: .leading, spacing: 3) {
                ForEach(Array(goals.prefix(2).enumerated()), id: \.offset) { _, goal in
                    Label(goal, systemImage: "circle")
                        .font(.system(size: 9)).lineLimit(1)
                }
            }
            HStack(spacing: 5) {
                Circle().fill(accent).frame(width: 5, height: 5)
                Text(phase.2).lineLimit(1)
            }
            .font(.system(size: 9, weight: .medium)).opacity(0.88)
        }
    }
}

struct CanvasLayerContent: View {
    let layer: CanvasLayer
    let design: WidgetDesign
    let date: Date

    var body: some View {
        Group {
            switch layer.kind {
            case .text:
                Text(layer.text.isEmpty ? "Your story" : layer.text)
                    .font(.system(size: 19 * design.fontScale, weight: .bold, design: design.fontPreset == .serif ? .serif : .rounded))
                    .multilineTextAlignment(.center).lineLimit(4)
            case .clock:
                Text(date, style: .time)
                    .font(.system(size: 34 * design.fontScale, weight: .light, design: .rounded))
                    .monospacedDigit().lineLimit(1).minimumScaleFactor(0.45)
            case .date:
                Text(date, format: .dateTime.weekday(.wide).day().month(.wide))
                    .font(.system(size: 13 * design.fontScale, weight: .medium, design: .rounded))
                    .lineLimit(2).multilineTextAlignment(.center)
            case .icon:
                Image(systemName: layer.symbol.isEmpty ? "sparkles" : layer.symbol)
                    .font(.system(size: 33, weight: .thin))
            case .image:
                if let photo = SharedRepository().image(named: design.imageFileName) {
                    Image(uiImage: photo).resizable().scaledToFit()
                        .frame(maxWidth: 145, maxHeight: 140)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    Image(systemName: "photo.on.rectangle")
                        .font(.system(size: 34)).opacity(0.75)
                }
            case .shape:
                Circle().strokeBorder(Color(hex: layer.colorHex).opacity(0.68), lineWidth: 2)
                    .frame(width: 65, height: 65)
                    .overlay(Circle().fill(Color(hex: layer.colorHex).opacity(0.12)).padding(5))
            }
        }
        .foregroundStyle(Color(hex: layer.colorHex))
        .shadow(color: .black.opacity(0.16), radius: 4, y: 2)
    }
}
