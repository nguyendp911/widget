import SwiftUI
import WidgetKit

/// The flagship widget: tasks, spending, bills and focus in one interactive view.
/// No fake AI and no background data scraping; context comes from the person's own records.
struct DailyBriefWidgetView: View {
    let entry: UtilityEntry
    @Environment(\.widgetFamily) private var family
    private var snapshot: UtilitySnapshot { entry.snapshot }
    private var mint: Color { Color(hex: "#E8C478") }
    private var muted: Color { Color(hex: "#F3E1C9") }
    private var isLarge: Bool { family == .systemLarge }

    private var greeting: String {
        switch Calendar.current.component(.hour, from: entry.date) {
        case 5..<12: return "Chào buổi sáng"
        case 12..<18: return "Cùng hoàn thành hôm nay"
        default: return "Tổng kết hôm nay"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: isLarge ? 13 : 8) {
            HStack(spacing: 7) {
                Image("ViePNIconCanChi")
                    .resizable().scaledToFit().frame(width: 25, height: 25)
                Text("VIEPN · TỔNG QUAN NGÀY")
                    .font(.system(size: 10, weight: .semibold, design: .serif))
                    .tracking(0.55)
                Spacer()
                Text(entry.date, format: .dateTime.day().month(.abbreviated))
                    .font(.caption2).foregroundStyle(muted)
            }
            Text(greeting)
                .font(.system(size: isLarge ? 25 : 20, weight: .bold, design: .rounded))
                .lineLimit(1).minimumScaleFactor(0.75)

            HStack(spacing: 8) {
                metric(title: "NGÂN SÁCH CÒN", symbol: "banknote.fill",
                       value: snapshot.revealOnWidgets ? snapshot.remainingBudget(at: entry.date).viepnVND : "••••••")
                metric(title: "VIỆC ĐANG CHỜ", symbol: "checkmark.circle",
                       value: "\(snapshot.pendingTasks.count) việc")
            }

            if let task = snapshot.pendingTasks.first {
                Button(intent: CompleteQuickTaskIntent(taskID: task.id.uuidString)) {
                    HStack(spacing: 8) {
                        Image(systemName: "circle").foregroundStyle(mint)
                        Text(task.title).lineLimit(1)
                        Spacer(minLength: 0)
                        Text("Xong").font(.caption2.bold()).foregroundStyle(mint)
                    }
                    .font(.caption).padding(.vertical, 4)
                }
                .buttonStyle(.plain)
            } else {
                Label("Không có việc tồn", systemImage: "checkmark.circle.fill")
                    .font(.caption).foregroundStyle(mint)
            }

            if let bill = snapshot.nextUnpaidBill(at: entry.date) {
                HStack(spacing: 6) {
                    Image(systemName: "calendar.badge.exclamationmark").foregroundStyle(.orange)
                    Text("\(bill.name): \(bill.daysUntilDue(from: entry.date)) ngày")
                        .lineLimit(1)
                }
                .font(.caption).foregroundStyle(muted)
            }

            if isLarge {
                Divider().overlay(mint.opacity(0.3))
                Text("CHẾ ĐỘ TẬP TRUNG").font(.system(size: 10, weight: .heavy)).tracking(1)
                    .foregroundStyle(muted)
            }
            HStack {
                if let session = snapshot.activeFocus(at: entry.date) {
                    Image(systemName: "timer").foregroundStyle(mint)
                    Text(session.endsAt, style: .timer)
                        .monospacedDigit().font(.caption.bold())
                } else {
                    Image(systemName: "bolt.fill").foregroundStyle(mint)
                    Text("Sẵn sàng tập trung 25 phút").font(.caption)
                }
                Spacer(minLength: 0)
                Button(intent: ToggleFocusSessionIntent(minutes: 25)) {
                    Text(snapshot.activeFocus(at: entry.date) == nil ? "Bắt đầu" : "Dừng")
                        .font(.caption.bold()).foregroundStyle(mint)
                        .padding(.horizontal, 11).padding(.vertical, 6)
                        .background(mint.opacity(0.15), in: Capsule())
                }
                .buttonStyle(.plain)
            }
            Spacer(minLength: 0)
            Text("VIEPN · NGÀY VIỆT").font(.system(size: 8, weight: .heavy)).tracking(1)
                .foregroundStyle(muted)
        }
        .padding(isLarge ? 18 : 15)
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .containerBackground(for: .widget) {
            GeometryReader { geo in
                ZStack {
                    Color(hex: "#431C1A")
                    Image(isLarge ? "ViePNTrongDongLarge" : "ViePNTrongDongMedium")
                        .resizable().scaledToFill()
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipped()
                    LinearGradient(
                        stops: [
                            .init(color: Color(hex: "#421516").opacity(0.50), location: 0),
                            .init(color: Color(hex: "#421516").opacity(0.22), location: 0.58),
                            .init(color: .clear, location: 0.9)
                        ],
                        startPoint: .leading, endPoint: .trailing
                    )
                    ViePNGoldWidgetBorder()
                }
            }
        }
    }

    private func metric(title: String, symbol: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(title, systemImage: symbol).font(.system(size: 9, weight: .bold))
                .lineLimit(1).foregroundStyle(muted)
            Text(value).font(.system(size: isLarge ? 23 : 19, weight: .bold, design: .rounded))
                .minimumScaleFactor(0.55).lineLimit(1)
        }
        .padding(9)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white.opacity(0.07), in: RoundedRectangle(cornerRadius: 11))
    }
}

struct ViePNDailyBriefWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "ViePNDailyBrief", provider: UtilityProvider()) { entry in
            DailyBriefWidgetView(entry: entry)
        }
        .configurationDisplayName("Life Command — tổng quan")
        .description("Ngân sách, công việc, hóa đơn và Focus trong một widget tương tác.")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}
