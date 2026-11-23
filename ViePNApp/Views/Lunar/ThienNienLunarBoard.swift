import SwiftUI

/// Full-length, scrollable almanac for the actual iOS application.
/// All numbers, Can Chi, observances and memorial dates are native dynamic text.
struct ThienNienLunarBoard: View {
    let civil: SolarCivilDate
    let appearance: LunarAppearance
    let upcoming: [LunarEventOccurrence]
    let onOpen: (ThienNienSection) -> Void
    let onSelect: (SolarCivilDate) -> Void

    private var lunar: VietnameseLunarDate? { VietnameseLunarCalendar.solarToLunar(civil) }
    private var facts: LunarAlmanacFacts { LunarAlmanacFacts(civil) }
    private let wine = Color(hex: "#8C2923")
    private let ink = Color(hex: "#4E3228")
    private let soft = Color(hex: "#79634F")
    private let gold = Color(hex: "#C39B54")

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            banner
            Button { onOpen(.date) } label: {
                HStack(alignment: .center, spacing: 14) {
                    Text("\(civil.day)")
                        .font(.system(size: 70, weight: .regular, design: .serif))
                        .monospacedDigit()
                        .foregroundStyle(wine)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("DƯƠNG LỊCH")
                            .font(.system(size: 10, weight: .semibold))
                            .tracking(1)
                            .foregroundStyle(soft)
                        Text("\(civil.day) tháng \(civil.month), \(civil.year)")
                            .font(.system(size: 15, weight: .semibold, design: .serif))
                            .foregroundStyle(ink)
                        Text("Âm \(lunar?.day ?? 0)/\(lunar?.month ?? 0)/\(lunar?.year ?? civil.year)\(lunar?.isLeapMonth == true ? " nhuận" : "")")
                            .font(.system(size: 16, weight: .semibold, design: .serif))
                            .foregroundStyle(wine)
                        Text("Ngày \(facts.canChiDay) · \(facts.dayKind)")
                            .font(.system(size: 12))
                            .foregroundStyle(soft)
                    }
                    Spacer(minLength: 2)
                    Image(systemName: "chevron.right").font(.caption).foregroundStyle(gold)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 9)
                .background(Color(hex: "#FFFAEC").opacity(0.96), in: RoundedRectangle(cornerRadius: 15))
            }
            .buttonStyle(.plain)

            Divider().overlay(gold.opacity(0.7))

            detailButton(.canChi, title: "THIÊN CAN · ĐỊA CHI",
                         value: "Ngày \(facts.canChiDay) · Tháng \(facts.canChiMonth) · Năm \(facts.canChiYear)",
                         icon: "ViePNIconCanChi")
            detailButton(.zodiac, title: "TỬ VI DÂN GIAN",
                         value: "Con \(facts.dayAnimalName) · Xung \(facts.opposingAnimalName)",
                         icon: "ViePNIconZodiac")
            detailButton(.auspicious, title: "SAO · TRỰC · NGÀY TỐT XẤU",
                         value: "\(facts.dayKind) · \(facts.spirit) · Trực \(facts.officer)",
                         icon: "ViePNIconSpirit")
            detailButton(.hours, title: "GIỜ HOÀNG ĐẠO",
                         value: facts.goodHoursLabel, icon: "ViePNIconGoodHours")
            detailButton(.solarTerms, title: "24 TIẾT KHÍ",
                         value: facts.solarTerm, icon: "ViePNIconSolarTerm")
            detailButton(.memorials, title: "NGÀY GIỖ · GIA ĐÌNH",
                         value: familySummary, icon: "ViePNIconMemorial")
            detailButton(.observances, title: "MÙNG 1 · RẰM · NGÀY LỄ",
                         value: observanceSummary, icon: "ViePNIconMoon")

            VStack(alignment: .leading, spacing: 13) {
                Button { onOpen(.month) } label: {
                    HStack(spacing: 9) {
                        Image("ViePNIconCalendar").resizable().scaledToFit().frame(width: 30, height: 30)
                        Text("LỊCH THÁNG ÂM DƯƠNG")
                            .font(.system(size: 16, weight: .semibold, design: .serif))
                            .foregroundStyle(wine)
                        Spacer()
                        Image(systemName: "arrow.up.left.and.arrow.down.right")
                            .font(.caption).foregroundStyle(gold)
                    }
                }
                .buttonStyle(.plain)
                monthGrid
            }
            .padding(14)
            .background(Color(hex: "#FFF9E9").opacity(0.96), in: RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(gold.opacity(0.42), lineWidth: 0.8))
            Text("Âm lịch Việt Nam (UTC+7) · Can Chi, ngày tốt–xấu và tử vi dân gian là thông tin văn hóa tham khảo.")
                .font(.system(size: 11))
                .foregroundStyle(soft)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .background {
            GeometryReader { geometry in
                ZStack {
                    Color(hex: "#F3E2C4")
                    Image(appearance.artwork.resolvedResource(theme: appearance.theme, family: "Large") ?? "ViePNVanNienLarge")
                        .resizable()
                        .scaledToFill()
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipped()
                        .opacity(0.30)
                    Color(hex: "#FFF5DF").opacity(0.26)
                }
            }
        }
        .overlay {
            RoundedRectangle(cornerRadius: 24)
                .strokeBorder(gold, lineWidth: 2)
                .padding(2)
        }
        .overlay {
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(Color(hex: "#F6DCA5"), lineWidth: 1)
                .padding(6)
        }
        .clipShape(RoundedRectangle(cornerRadius: 25))
    }

    private var banner: some View {
        HStack(spacing: 11) {
            Image("ViePNIconCulture")
                .resizable().scaledToFit().frame(width: 45, height: 45)
            VStack(alignment: .leading, spacing: 3) {
                Text("THIÊN NIÊN VIỆT")
                    .font(.system(size: 25, weight: .bold, design: .serif))
                    .tracking(0.6)
                    .foregroundStyle(wine)
                    .minimumScaleFactor(0.8)
                    .lineLimit(1)
                Text("LỊCH VẠN NIÊN · GIỮ NGÀY VIỆT")
                    .font(.system(size: 10, weight: .medium, design: .serif))
                    .tracking(0.5)
                    .foregroundStyle(soft)
            }
            Spacer(minLength: 0)
        }
        .padding(.bottom, 3)
    }

    private func detailButton(_ section: ThienNienSection, title: String,
                              value: String, icon: String) -> some View {
        Button { onOpen(section) } label: {
            HStack(alignment: .center, spacing: 10) {
                Image(icon).resizable().scaledToFit().frame(width: 37, height: 37)
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 13, weight: .bold, design: .serif))
                        .foregroundStyle(wine)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(value)
                        .font(.system(size: 14, weight: .medium, design: .serif))
                        .foregroundStyle(ink)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 2)
                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(gold)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 11)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(hex: "#FFFBF0").opacity(0.96),
                        in: RoundedRectangle(cornerRadius: 13))
            .overlay(RoundedRectangle(cornerRadius: 13)
                .stroke(gold.opacity(0.15), lineWidth: 0.7))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Xem chi tiết \(section.title)")
    }

    private var familySummary: String {
        guard let first = upcoming.first else { return "Chưa có ngày giỗ · Chạm để thêm" }
        let days = first.daysRemaining(from: civil)
        return "\(first.title) · \(days == 0 ? "Hôm nay" : "Còn \(days) ngày")"
    }

    private var observanceSummary: String {
        if let lunar {
            let special = LunarCulture.observances(on: lunar)
            if !special.isEmpty { return special.joined(separator: " · ") }
        }
        let first = LunarHighlights.nextLunarDay(from: civil, day: 1)
        let full = LunarHighlights.nextLunarDay(from: civil, day: 15)
        return "Mùng 1 còn \(first?.daysUntil ?? 0) ngày · Rằm còn \(full?.daysUntil ?? 0) ngày"
    }

    private var monthGrid: some View {
        let first = SolarCivilDate(year: civil.year, month: civil.month, day: 1)
        let start = VietnameseLunarCalendar.jdn(first)
        let offset = (start % 7 + 7) % 7
        return VStack(spacing: 5) {
            HStack {
                ForEach(["T2", "T3", "T4", "T5", "T6", "T7", "CN"], id: \.self) { title in
                    Text(title).font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(soft).frame(maxWidth: .infinity)
                }
            }
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 2), count: 7),
                      spacing: 5) {
                ForEach(0..<42, id: \.self) { index in
                    let day = VietnameseLunarCalendar.civilDate(start - offset + index)
                    let moon = VietnameseLunarCalendar.solarToLunar(day)
                    Button { onSelect(day) } label: {
                        VStack(spacing: 3) {
                            Text("\(day.day)")
                                .font(.system(size: 13, weight: day == civil ? .bold : .medium))
                                .foregroundStyle(day.month == civil.month ? ink : soft.opacity(0.48))
                            Text(moon?.day == 1 ? "1/\(moon?.month ?? 0)" : "\(moon?.day ?? 0)")
                                .font(.system(size: 10))
                                .foregroundStyle(moon?.day == 1 || moon?.day == 15 ? wine : soft)
                        }
                        .frame(maxWidth: .infinity, minHeight: 39)
                        .background(day == civil ? gold.opacity(0.22) : .clear,
                                    in: RoundedRectangle(cornerRadius: 7))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Ngày \(day.label), âm \(moon?.label ?? "")")
                }
            }
        }
    }
}
