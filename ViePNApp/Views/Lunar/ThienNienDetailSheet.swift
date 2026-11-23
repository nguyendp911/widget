import SwiftUI

/// Opened as an in-app sheet, never as an intermediate navigation page.
/// Widget deep links route here on launch of the host app.
struct ThienNienDetailSheet: View {
    let section: ThienNienSection
    let civil: SolarCivilDate
    let familyEvents: [LunarFamilyEvent]

    @Environment(\.dismiss) private var dismiss
    @State private var showingAddEvent = false
    @State private var highlighted: SolarCivilDate?
    private let ink = Color(hex: "#572D24")
    private let muted = Color(hex: "#83644E")
    private let accent = Color(hex: "#982723")
    private let gold = Color(hex: "#BD893B")

    private var lunar: VietnameseLunarDate? { VietnameseLunarCalendar.solarToLunar(civil) }
    private var facts: LunarAlmanacFacts { LunarAlmanacFacts(civil) }
    private var upcoming: [LunarEventOccurrence] {
        LunarEventScheduler.upcoming(events: familyEvents, from: civil, count: 30, years: 4)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 10) {
                        Image("ViePNIconCulture")
                            .resizable().scaledToFit()
                            .frame(width: 42, height: 42)
                        VStack(alignment: .leading, spacing: 3) {
                            Text("THIÊN NIÊN VIỆT")
                                .font(.system(size: 13, weight: .semibold, design: .serif))
                                .tracking(1)
                                .foregroundStyle(accent)
                            Text(section.title)
                                .font(.system(size: 24, weight: .semibold, design: .serif))
                                .foregroundStyle(ink)
                        }
                    }
                    .padding(.bottom, 4)
                    content
                    Text("Thông tin Can Chi, giờ hoàng đạo và ngày tốt–xấu được cung cấp theo quy ước lịch dân gian để tham khảo; không phải dự đoán vận mệnh cá nhân.")
                        .font(.system(size: 11))
                        .foregroundStyle(muted)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, 5)
                }
                .padding(20)
            }
            .background(Color(hex: "#F8EED9").ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Đóng") { dismiss() }
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(accent)
                }
            }
            .tint(accent)
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .sheet(isPresented: $showingAddEvent) {
            NavigationStack { LunarEventEditorView() }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch section {
        case .date:
            group("ÂM LỊCH · DƯƠNG LỊCH") {
                detail("Dương lịch", civil.label)
                detail("Âm lịch", lunar?.label ?? "Ngoài phạm vi")
                detail("Tháng nhuận", lunar?.isLeapMonth == true ? "Có" : "Không")
                detail("Ngày Can Chi", facts.canChiDay)
                detail("Tiết khí", facts.solarTerm)
            }
        case .canChi:
            group("THIÊN CAN · ĐỊA CHI") {
                detail("Can Chi ngày", facts.canChiDay)
                detail("Can Chi tháng", facts.canChiMonth)
                detail("Can Chi năm", facts.canChiYear)
                Text("Hệ Can Chi gồm 10 Thiên Can và 12 Địa Chi, phối hợp thành chu kỳ 60. Đây là thông tin tính theo ngày đang xem.")
                    .font(.system(size: 13))
                    .foregroundStyle(muted)
            }
        case .zodiac:
            group("TỬ VI DÂN GIAN") {
                detail("Con giáp của ngày", facts.dayAnimalName)
                detail("Con giáp của năm", facts.yearAnimalName)
                detail("Tuổi xung theo Địa Chi", facts.opposingAnimalName)
                detail("Can Chi ngày", facts.canChiDay)
                Text("Đây là thông tin con giáp và xung chi của ngày. Muốn lập lá số tử vi cá nhân cần thêm ngày, giờ và dữ liệu sinh; ứng dụng chưa cung cấp lá số đó.")
                    .font(.system(size: 13))
                    .foregroundStyle(muted)
            }
        case .auspicious:
            group("SAO · TRỰC · HOÀNG ĐẠO") {
                detail("Loại ngày", facts.dayKind)
                detail("Sao / Thần trực", facts.spirit)
                detail("Thập nhị trực", facts.officer)
                detail("Tiết khí", facts.solarTerm)
                Text("Các trường phái lịch vạn niên có thể dùng cách an sao và chọn ngày khác nhau; không nên xem đây là một phán quyết chắc chắn tốt hay xấu.")
                    .font(.system(size: 13))
                    .foregroundStyle(muted)
            }
        case .hours:
            group("MƯỜI HAI GIỜ ĐỊA CHI") {
                ForEach(0..<12, id: \.self) { index in
                    let name = VietnameseLunarCalendar.chi[index]
                    let intervals = [
                        "23:00–01:00", "01:00–03:00", "03:00–05:00", "05:00–07:00",
                        "07:00–09:00", "09:00–11:00", "11:00–13:00", "13:00–15:00",
                        "15:00–17:00", "17:00–19:00", "19:00–21:00", "21:00–23:00"
                    ]
                    HStack {
                        Text("Giờ \(name)")
                            .font(.system(size: 14, weight: .medium, design: .serif))
                        Spacer()
                        Text(intervals[index])
                            .font(.system(size: 12))
                            .foregroundStyle(muted)
                        Text(facts.goodHours.contains(name) ? "Hoàng đạo" : "Khác")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(facts.goodHours.contains(name) ? accent : muted)
                            .frame(width: 72, alignment: .trailing)
                    }
                    .padding(.vertical, 5)
                    if index != 11 { Divider().overlay(gold.opacity(0.2)) }
                }
            }
        case .solarTerms:
            group("24 TIẾT KHÍ TRONG NĂM") {
                detail("Tiết khí hiện tại", facts.solarTerm)
                ForEach(Array(VietnameseLunarCalendar.terms.enumerated()), id: \.offset) { row in
                    HStack {
                        Text(String(format: "%02d", row.offset + 1))
                            .font(.system(size: 11, weight: .semibold)).foregroundStyle(accent)
                            .frame(width: 26)
                        Text(row.element)
                            .font(.system(size: 14, weight: .medium, design: .serif))
                            .foregroundStyle(ink)
                        Spacer()
                        if row.element == facts.solarTerm {
                            Text("Hiện tại")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundStyle(accent)
                        }
                    }
                    .padding(.vertical, 3)
                }
            }
        case .memorials:
            group("NGÀY GIỖ & NGÀY NHỚ") {
                if upcoming.isEmpty {
                    Text("Chưa có sự kiện gia đình. Hãy thêm ngày giỗ theo âm lịch để được nhắc đúng từng năm.")
                        .font(.system(size: 14))
                        .foregroundStyle(muted)
                } else {
                    ForEach(upcoming) { item in
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(item.title)
                                    .font(.system(size: 15, weight: .semibold, design: .serif))
                                Spacer()
                                Text(item.daysRemaining(from: civil) == 0
                                     ? "Hôm nay" : "Còn \(item.daysRemaining(from: civil)) ngày")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(accent)
                            }
                            Text("Âm \(item.lunar.label) · Dương \(item.solar.label)")
                                .font(.system(size: 12))
                                .foregroundStyle(muted)
                            if item.isAdjustedForShortMonth {
                                Text("Đã điều chỉnh về ngày cuối tháng âm thiếu")
                                    .font(.system(size: 11)).foregroundStyle(accent)
                            }
                        }
                        .padding(.vertical, 5)
                        Divider().overlay(gold.opacity(0.2))
                    }
                }
                Button { showingAddEvent = true } label: {
                    Label("Thêm ngày giỗ / sự kiện", systemImage: "plus.circle.fill")
                        .font(.system(size: 14, weight: .semibold))
                }
                .padding(.top, 7)
            }
        case .month:
            group("THÁNG \(civil.month) NĂM \(civil.year)") {
                monthGrid
                if let day = highlighted {
                    let lunarDay = VietnameseLunarCalendar.solarToLunar(day)
                    detail("Ngày đã chọn", "\(day.label) · Âm \(lunarDay?.label ?? "—")")
                }
            }
        case .observances:
            group("MÙNG MỘT · NGÀY RẰM") {
                let first = LunarHighlights.nextLunarDay(from: civil, day: 1)
                let full = LunarHighlights.nextLunarDay(from: civil, day: 15)
                detail("Mùng Một gần nhất", "\(first?.name ?? "—") · Còn \(first?.daysUntil ?? 0) ngày")
                detail("Rằm gần nhất", "\(full?.name ?? "—") · Còn \(full?.daysUntil ?? 0) ngày")
            }
            group("NGÀY LỄ TRUYỀN THỐNG") {
                ForEach(LunarCulture.festivals) { festival in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(festival.title)
                            .font(.system(size: 15, weight: .semibold, design: .serif))
                            .foregroundStyle(ink)
                        Text("\(festival.day)/\(festival.month) âm lịch")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(accent)
                        Text(festival.description)
                            .font(.system(size: 12))
                            .foregroundStyle(muted)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }

    private func detail(_ title: String, _ value: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Text(title)
                .font(.system(size: 13))
                .foregroundStyle(muted)
            Spacer(minLength: 3)
            Text(value)
                .font(.system(size: 14, weight: .semibold, design: .serif))
                .foregroundStyle(ink)
                .multilineTextAlignment(.trailing)
        }
        .padding(.vertical, 6)
    }

    private func group<Content: View>(
        _ title: String, @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 11) {
            Text(title)
                .font(.system(size: 12, weight: .semibold, design: .serif))
                .tracking(0.5)
                .foregroundStyle(accent)
            content()
        }
        .padding(15)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: "#FFFAEE"),
                    in: RoundedRectangle(cornerRadius: 15, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 15)
            .stroke(gold.opacity(0.46), lineWidth: 1))
    }

    private var monthGrid: some View {
        let first = SolarCivilDate(year: civil.year, month: civil.month, day: 1)
        let base = VietnameseLunarCalendar.jdn(first)
        let start = (base % 7 + 7) % 7
        return LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 3), count: 7), spacing: 6) {
            ForEach(["T2","T3","T4","T5","T6","T7","CN"], id: \.self) { name in
                Text(name).font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(muted)
            }
            ForEach(0..<42, id: \.self) { offset in
                let day = VietnameseLunarCalendar.civilDate(base - start + offset)
                let moon = VietnameseLunarCalendar.solarToLunar(day)
                Button { highlighted = day } label: {
                    VStack(spacing: 2) {
                        Text("\(day.day)")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(day == civil ? accent : ink)
                        Text(moon?.day == 1 ? "1/\(moon?.month ?? 0)" : "\(moon?.day ?? 0)")
                            .font(.system(size: 9))
                            .foregroundStyle(muted)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 5)
                    .background((highlighted ?? civil) == day ? gold.opacity(0.24) : .clear,
                                in: RoundedRectangle(cornerRadius: 7))
                }
                .buttonStyle(.plain)
            }
        }
    }
}
