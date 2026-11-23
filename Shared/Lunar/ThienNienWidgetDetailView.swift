import SwiftUI
import AppIntents

/// Focused page rendered INSIDE the systemLarge Home Screen widget.
/// Not a sheet or a new app scene — App Intents replace the widget snapshot.
struct ThienNienWidgetDetailView: View {
    let section: ThienNienSection
    let civil: SolarCivilDate
    let upcomingEvents: [LunarEventOccurrence]

    private var facts: LunarAlmanacFacts { LunarAlmanacFacts(civil) }
    private var lunar: VietnameseLunarDate? { VietnameseLunarCalendar.solarToLunar(civil) }
    private let ink = Color(hex: "#502D26")
    private let accent = Color(hex: "#982823")
    private let muted = Color(hex: "#7C624F")
    private let gold = Color(hex: "#C28C42")

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack(spacing: 6) {
                Button(intent: ThienNienBackIntent()) {
                    Label("Quay lại", systemImage: "chevron.left")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(accent)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 6)
                        .background(Color(hex: "#F7E1B7"), in: Capsule())
                }
                .buttonStyle(.plain)
                Spacer(minLength: 2)
                Text("THIÊN NIÊN VIỆT")
                    .font(.system(size: 12, weight: .bold, design: .serif))
                    .tracking(0.6)
                    .foregroundStyle(accent)
                    .lineLimit(1)
            }
            HStack(spacing: 8) {
                Image("ViePNIconCulture")
                    .resizable().scaledToFit()
                    .frame(width: 26, height: 26)
                Text(section.title.uppercased())
                    .font(.system(size: 16, weight: .semibold, design: .serif))
                    .foregroundStyle(ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            Rectangle().fill(gold.opacity(0.7)).frame(height: 1)
            content
            Spacer(minLength: 0)
            Text("Phong tục Việt · Thông tin tham khảo")
                .font(.system(size: 9))
                .foregroundStyle(muted)
                .lineLimit(1)
        }
        .padding(13)
    }

    @ViewBuilder private var content: some View {
        switch section {
        case .date:
            fact("Dương lịch", civil.label)
            fact("Âm lịch", lunar?.label ?? "—")
            fact("Ngày Can Chi", facts.canChiDay)
            fact("Năm Can Chi", facts.canChiYear)
            fact("Tiết khí", facts.solarTerm)
        case .canChi:
            fact("Can Chi ngày", facts.canChiDay)
            fact("Can Chi tháng", facts.canChiMonth)
            fact("Can Chi năm", facts.canChiYear)
            fact("Con giáp năm", facts.yearAnimalName)
            note("10 Thiên Can · 12 Địa Chi tạo thành chu kỳ 60.")
        case .zodiac:
            fact("Con giáp của ngày", facts.dayAnimalName)
            fact("Con giáp của năm", facts.yearAnimalName)
            fact("Tuổi xung theo Địa Chi", facts.opposingAnimalName)
            fact("Can Chi ngày", facts.canChiDay)
            note("Tử vi dân gian, không phải lá số cá nhân.")
        case .auspicious:
            fact("Phân loại ngày", facts.dayKind)
            fact("Thần trực", facts.spirit)
            fact("Thập nhị trực", facts.officer)
            fact("Tiết khí", facts.solarTerm)
            note("Ngày tốt – xấu thay đổi tùy truyền thống.")
        case .hours:
            let good = Set(facts.goodHours)
            let labels = VietnameseLunarCalendar.chi
            let intervals = [
                "23–01", "01–03", "03–05", "05–07", "07–09", "09–11",
                "11–13", "13–15", "15–17", "17–19", "19–21", "21–23"
            ]
            HStack(spacing: 8) {
                hourColumn(0..<6, labels: labels, intervals: intervals, good: good)
                hourColumn(6..<12, labels: labels, intervals: intervals, good: good)
            }
            note("Dấu son: giờ hoàng đạo trong ngày.")
        case .solarTerms:
            fact("Tiết khí hiện tại", facts.solarTerm)
            fact("Can Chi ngày", facts.canChiDay)
            note("Một năm có 24 tiết khí, mỗi tiết khoảng 15° trên đường hoàng đạo.")
            note("Chạm 'Xem đầy đủ' ở trong ứng dụng để tra cứu toàn bộ 24 tiết khí.")
        case .memorials:
            if upcomingEvents.isEmpty {
                VStack(alignment: .leading, spacing: 9) {
                    Text("Chưa có ngày giỗ được lưu.")
                        .font(.system(size: 15, weight: .medium, design: .serif))
                        .foregroundStyle(ink)
                    Text("Mở Thiên Niên Việt để thêm ngày giỗ; lịch sẽ tự tính lại theo từng năm âm.")
                        .font(.system(size: 12))
                        .foregroundStyle(muted)
                }
            } else {
                ForEach(Array(upcomingEvents.prefix(4))) { event in
                    fact(event.title,
                         "Âm \(event.lunar.day)/\(event.lunar.month) · \(event.daysRemaining(from: civil)) ngày")
                }
            }
        case .observances:
            let first = LunarHighlights.nextLunarDay(from: civil, day: 1)
            let full = LunarHighlights.nextLunarDay(from: civil, day: 15)
            fact("Mùng 1", "Còn \(first?.daysUntil ?? 0) ngày")
            fact("Ngày Rằm", "Còn \(full?.daysUntil ?? 0) ngày")
            if let lunar, !LunarCulture.on(lunar).isEmpty {
                ForEach(LunarCulture.on(lunar)) { holiday in
                    fact("Ngày lễ hôm nay", holiday.title)
                }
            } else {
                note("Xem danh sách ngày lễ Việt Nam trong ứng dụng.")
            }
        case .month:
            monthGrid
        }
    }

    private func fact(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title.uppercased())
                .font(.system(size: 9, weight: .semibold, design: .serif))
                .tracking(0.25)
                .foregroundStyle(accent)
            Text(value)
                .font(.system(size: 14, weight: .medium, design: .serif))
                .foregroundStyle(ink)
                .lineLimit(2)
                .minimumScaleFactor(0.75)
        }
        .padding(.horizontal, 9)
        .padding(.vertical, 6)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: "#FFF8EA").opacity(0.9),
                    in: RoundedRectangle(cornerRadius: 9))
    }

    private func note(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 11, weight: .regular, design: .serif))
            .foregroundStyle(muted)
            .fixedSize(horizontal: false, vertical: true)
    }

    private func hourColumn(_ indices: Range<Int>, labels: [String],
                            intervals: [String], good: Set<String>) -> some View {
        VStack(spacing: 3) {
            ForEach(indices, id: \.self) { i in
                HStack(spacing: 4) {
                    Circle()
                        .fill(good.contains(labels[i]) ? accent : muted.opacity(0.3))
                        .frame(width: 5, height: 5)
                    Text(labels[i])
                        .font(.system(size: 11, weight: .semibold, design: .serif))
                    Spacer(minLength: 0)
                    Text(intervals[i])
                        .font(.system(size: 9))
                        .foregroundStyle(muted)
                }
                .foregroundStyle(ink)
                .padding(5)
                .background(Color(hex: "#FFF8EA").opacity(0.88),
                            in: RoundedRectangle(cornerRadius: 5))
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var monthGrid: some View {
        let first = SolarCivilDate(year: civil.year, month: civil.month, day: 1)
        let jdn = VietnameseLunarCalendar.jdn(first)
        let offset = (jdn % 7 + 7) % 7
        return VStack(spacing: 3) {
            HStack {
                ForEach(["T2","T3","T4","T5","T6","T7","CN"], id: \.self) { label in
                    Text(label).font(.system(size: 9, weight: .semibold))
                        .frame(maxWidth: .infinity).foregroundStyle(muted)
                }
            }
            ForEach(0..<6, id: \.self) { row in
                HStack(spacing: 2) {
                    ForEach(0..<7, id: \.self) { column in
                        let day = VietnameseLunarCalendar.civilDate(jdn - offset + row * 7 + column)
                        let moon = VietnameseLunarCalendar.solarToLunar(day)
                        VStack(spacing: 1) {
                            Text("\(day.day)")
                                .font(.system(size: 11, weight: day == civil ? .bold : .medium))
                                .foregroundStyle(day.month == civil.month ? ink : muted.opacity(0.5))
                            Text("\(moon?.day ?? 0)")
                                .font(.system(size: 8))
                                .foregroundStyle(muted)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 3)
                        .background(day == civil ? gold.opacity(0.28) : .clear,
                                    in: RoundedRectangle(cornerRadius: 4))
                    }
                }
            }
        }
    }
}
