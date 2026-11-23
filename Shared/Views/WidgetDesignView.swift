import SwiftUI

/// One renderer reused by in-app previews and the actual Widget Extension.
/// Interaction overlays are added by the Widget Extension.
struct WidgetDesignView: View {
    let design: WidgetDesign
    let date: Date
    let habitCompleted: Bool

    private var titleFont: Font {
        let size = 23.0 * design.fontScale
        switch design.fontPreset {
        case .rounded: return .system(size: size, weight: .bold, design: .rounded)
        case .system: return .system(size: size, weight: .bold)
        case .serif: return .system(size: size, weight: .semibold, design: .serif)
        case .monospaced: return .system(size: size, weight: .semibold, design: .monospaced)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack(spacing: 7) {
                Image(systemName: design.kind.symbol)
                    .foregroundStyle(design.accentColor)
                Text(design.title)
                    .font(.caption.weight(.semibold))
                    .lineLimit(1)
                Spacer(minLength: 0)
            }

            Spacer(minLength: 2)
            mainContent
            Spacer(minLength: 2)

            Text(design.name.uppercased())
                .font(.system(size: 9, weight: .bold, design: .rounded))
                .tracking(1.3)
                .opacity(0.66)
                .lineLimit(1)
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .foregroundStyle(design.foregroundColor)
        .background(design.backgroundColor)
        .overlay {
            if design.showBorder {
                RoundedRectangle(cornerRadius: 18)
                    .strokeBorder(design.accentColor.opacity(0.6), lineWidth: 2)
                    .padding(5)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    @ViewBuilder
    private var mainContent: some View {
        switch design.kind {
        case .clock:
            VStack(alignment: .leading, spacing: 6) {
                Text(date, style: .time)
                    .font(.system(size: 35 * design.fontScale, weight: .bold, design: .rounded))
                    .minimumScaleFactor(0.55)
                    .lineLimit(1)
                Text(date, format: .dateTime.weekday(.wide).day().month(.wide))
                    .font(.caption)
                    .lineLimit(2)
            }
        case .calendar:
            VStack(alignment: .leading, spacing: 2) {
                Text(date, format: .dateTime.day())
                    .font(.system(size: 47 * design.fontScale, weight: .bold, design: .rounded))
                    .minimumScaleFactor(0.6)
                Text(date, format: .dateTime.weekday(.wide).month(.wide).year())
                    .font(.caption)
                    .lineLimit(2)
            }
        case .photo:
            if let photo = SharedRepository().image(named: design.imageFileName) {
                GeometryReader { geometry in
                    Image(uiImage: photo)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            } else {
                VStack(alignment: .leading, spacing: 6) {
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.largeTitle)
                        .foregroundStyle(design.accentColor)
                    Text(design.message).font(.caption).lineLimit(2)
                }
            }
        case .quote:
            Text("“\(design.message)”")
                .font(titleFont)
                .minimumScaleFactor(0.6)
                .lineLimit(5)
        case .countdown:
            VStack(alignment: .leading, spacing: 5) {
                if let target = design.targetDate {
                    Text(target, style: .relative)
                        .font(titleFont)
                        .minimumScaleFactor(0.6)
                        .lineLimit(2)
                } else {
                    Text("Chưa chọn ngày").font(titleFont)
                }
                Text(design.message).font(.caption).lineLimit(2)
            }
        case .habit:
            VStack(alignment: .leading, spacing: 6) {
                Text(design.message).font(titleFont).lineLimit(2)
                HStack(spacing: 5) {
                    Image(systemName: habitCompleted ? "checkmark.circle.fill" : "circle")
                    Text(habitCompleted ? "Đã hoàn thành" : "Chưa hoàn thành")
                }
                .font(.caption.weight(.medium))
                .foregroundStyle(design.accentColor)
            }
        }
    }
}
