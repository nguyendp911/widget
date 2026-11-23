import SwiftUI
import AppIntents

/// Thiên Niên Việt — one long, touchable Vietnamese almanac board.
/// In an iPhone widget the board must fit Apple's systemLarge size (it cannot
/// scroll or stretch down the Home Screen). In the app it expands vertically.
struct ThienNienVietBoard: View {
    let civil: SolarCivilDate
    let appearance: LunarAppearance
    let upcomingEvents: [LunarEventOccurrence]
    var compact: Bool = false
    var useWidgetLinks: Bool = false
    var widgetSelectedSection: ThienNienSection? = nil
    var drawsOwnBackground: Bool = true
    var onOpen: ((ThienNienSection) -> Void)? = nil

    private var lunar: VietnameseLunarDate? { VietnameseLunarCalendar.solarToLunar(civil) }
    private var facts: LunarAlmanacFacts { LunarAlmanacFacts(civil) }
    private let ink = Color(hex: "#532C24")
    private let accent = Color(hex: "#8F2421")
    private let muted = Color(hex: "#79614C")
    private let gold = Color(hex: "#C18A39")

    var body: some View {
        ZStack {
            if drawsOwnBackground { background }
            if useWidgetLinks, let focused = widgetSelectedSection {
                ThienNienWidgetDetailView(
                    section: focused, civil: civil, upcomingEvents: upcomingEvents
                )
            } else {
                VStack(alignment: .leading, spacing: compact ? 3 : 9) {
                linked(.date) { titleBanner }
                linked(.date) { dateSummary }
                Rectangle().fill(gold.opacity(0.55)).frame(height: 1)
                linked(.canChi) {
                    factRow("THIÊN CAN · ĐỊA CHI",
                            "Ngày \(facts.canChiDay) · Tháng \(facts.canChiMonth) · Năm \(facts.canChiYear)",
                            icon: "ViePNIconCanChi")
                }
                linked(.zodiac) {
                    factRow("TỬ VI DÂN GIAN",
                            "Con \(facts.dayAnimalName) · Xung \(facts.opposingAnimalName)",
                            icon: "ViePNIconZodiac")
                }
                linked(.auspicious) {
                    factRow("SAO · TRỰC · NGÀY",
                            "\(facts.dayKind) · \(facts.spirit) · Trực \(facts.officer)",
                            icon: "ViePNIconSpirit")
                }
                linked(.hours) {
                    factRow("GIỜ HOÀNG ĐẠO", facts.goodHoursLabel,
                            icon: "ViePNIconGoodHours")
                }
                linked(.solarTerms) {
                    factRow("TIẾT KHÍ", facts.solarTerm, icon: "ViePNIconSolarTerm")
                }
                linked(.memorials) {
                    factRow("NGÀY GIỖ · GIA ĐÌNH", nextFamilyLabel,
                            icon: "ViePNIconMemorial")
                }
                linked(.observances) {
                    factRow("MÙNG 1 · RẰM · LỄ", observanceLabel,
                            icon: "ViePNIconMoon")
                }
                linked(.month) {
                    VStack(alignment: .leading, spacing: compact ? 2 : 7) {
                        HStack(spacing: 5) {
                            Image("ViePNIconCalendar")
                                .resizable().scaledToFit()
                                .frame(width: compact ? 15 : 22, height: compact ? 15 : 22)
                            Text("LỊCH THÁNG ÂM DƯƠNG")
                                .font(.system(size: compact ? 9 : 13, weight: .semibold, design: .serif))
                                .tracking(compact ? 0.15 : 0.65)
                            Spacer(minLength: 0)
                            Image(systemName: "chevron.right")
                                .font(.system(size: compact ? 8 : 11, weight: .semibold))
                        }
                        weekStrip
                        if !compact { fullMonthGrid }
                    }
                    .foregroundStyle(ink)
                    .padding(.horizontal, compact ? 5 : 11)
                    .padding(.vertical, compact ? 3 : 8)
                    .background(Color(hex: "#FFF8E8").opacity(0.83),
                                in: RoundedRectangle(cornerRadius: compact ? 7 : 13))
                }
                if !compact {
                    Text("Thiên Niên Việt · Dữ liệu âm lịch Việt Nam UTC+7 · Các luận giải dân gian chỉ để tham khảo")
                        .font(.system(size: 10))
                        .foregroundStyle(muted)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
                .padding(compact ? 12 : 18)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .accessibilityElement(children: .contain)
    }

    @ViewBuilder private func linked<Content: View>(
        _ section: ThienNienSection, @ViewBuilder content: () -> Content
    ) -> some View {
        if useWidgetLinks {
            Button(intent: ThienNienSelectSectionIntent(section: section)) {
                content().contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Xem ngay \(section.title) trên widget")
        } else {
            Button { onOpen?(section) } label: {
                content().contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Xem chi tiết \(section.title)")
        }
    }

    private var background: some View {
        GeometryReader { geo in
            ZStack {
                Color(hex: "#F3DDB7")
                if let asset = LunarWidgetSkin(kind: .almanac, appearance: appearance)
                    .artworkName(family: "Large") {
                    Image(asset).resizable().scaledToFill()
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipped()
                        .opacity(0.82)
                }
                Color(hex: "#FFFAED").opacity(0.35)
                ViePNGoldWidgetBorder()
            }
        }
        .allowsHitTesting(false)
    }

    private var titleBanner: some View {
        HStack(alignment: .center, spacing: compact ? 6 : 11) {
            Image("ViePNIconCulture")
                .resizable().scaledToFit()
                .frame(width: compact ? 28 : 45, height: compact ? 28 : 45)
            VStack(alignment: .leading, spacing: compact ? 0 : 3) {
                Text("THIÊN NIÊN VIỆT")
                    .font(.system(size: compact ? 17 : 28, weight: .bold, design: .serif))
                    .tracking(compact ? 0.2 : 1.1)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .foregroundStyle(Color(hex: "#86211F"))
                Text("LỊCH VẠN NIÊN · NHỚ NGÀY VIỆT")
                    .font(.system(size: compact ? 7 : 10, weight: .medium, design: .serif))
                    .tracking(0.35)
                    .foregroundStyle(muted)
                    .lineLimit(1)
            }
            Spacer(minLength: 0)
        }
        .padding(.bottom, compact ? 2 : 5)
    }

    private var dateSummary: some View {
        HStack(alignment: .center, spacing: compact ? 8 : 15) {
            Text("\(civil.day)")
                .font(.system(size: compact ? 46 : 73, weight: .regular, design: .serif))
                .monospacedDigit()
                .foregroundStyle(accent)
                .frame(minWidth: compact ? 48 : 78, alignment: .leading)
            VStack(alignment: .leading, spacing: compact ? 2 : 5) {
                Text("Dương lịch · \(civil.day)/\(civil.month)/\(civil.year)")
                    .font(.system(size: compact ? 10 : 15, weight: .semibold, design: .serif))
                    .foregroundStyle(ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.76)
                Text("Âm lịch · \(lunar?.day ?? 0)/\(lunar?.month ?? 0)/\(lunar?.year ?? civil.year)\(lunar?.isLeapMonth == true ? " nhuận" : "")")
                    .font(.system(size: compact ? 10 : 16, weight: .semibold, design: .serif))
                    .foregroundStyle(accent)
                    .lineLimit(1)
                    .minimumScaleFactor(0.76)
                Text("Ngày \(facts.canChiDay) · \(facts.dayKind)")
                    .font(.system(size: compact ? 9 : 12, weight: .medium))
                    .foregroundStyle(muted)
                    .lineLimit(1)
            }
            Spacer(minLength: 0)
            Image(systemName: "chevron.right")
                .font(.system(size: compact ? 9 : 13, weight: .semibold))
                .foregroundStyle(gold)
        }
        .padding(.horizontal, compact ? 3 : 9)
    }

    private func factRow(_ title: String, _ description: String, icon: String) -> some View {
        HStack(alignment: .center, spacing: compact ? 5 : 11) {
            Image(icon).resizable().scaledToFit()
                .frame(width: compact ? 19 : 31, height: compact ? 19 : 31)
            VStack(alignment: .leading, spacing: compact ? 0 : 3) {
                Text(title)
                    .font(.system(size: compact ? 8 : 12, weight: .bold, design: .serif))
                    .tracking(0.3)
                    .foregroundStyle(accent)
                    .lineLimit(1)
                Text(description)
                    .font(.system(size: compact ? 9 : 13, weight: .medium, design: .serif))
                    .foregroundStyle(ink)
                    .lineLimit(compact ? 1 : 2)
                    .minimumScaleFactor(0.73)
            }
            Spacer(minLength: 1)
            Image(systemName: "chevron.right")
                .font(.system(size: compact ? 8 : 11))
                .foregroundStyle(gold)
        }
        .padding(.horizontal, compact ? 5 : 11)
        .padding(.vertical, compact ? 2 : 8)
        .background(Color(hex: "#FFFAEF").opacity(0.84),
                    in: RoundedRectangle(cornerRadius: compact ? 7 : 12))
    }

    private var nextFamilyLabel: String {
        guard let first = upcomingEvents.first else { return "Chưa có ngày giỗ · Chạm để thêm" }
        let remaining = first.daysRemaining(from: civil)
        return "\(first.title) · \(remaining == 0 ? "Hôm nay" : "Còn \(remaining) ngày")"
    }

    private var observanceLabel: String {
        if let lunar, !LunarCulture.observances(on: lunar).isEmpty {
            return LunarCulture.observances(on: lunar).joined(separator: " · ")
        }
        let first = LunarHighlights.nextLunarDay(from: civil, day: 1)
        let full = LunarHighlights.nextLunarDay(from: civil, day: 15)
        return "Mùng 1 còn \(first?.daysUntil ?? 0) ngày · Rằm còn \(full?.daysUntil ?? 0) ngày"
    }

    private var weekStrip: some View {
        let base = VietnameseLunarCalendar.jdn(civil)
        let offset = (base % 7 + 7) % 7
        return HStack(spacing: 0) {
            ForEach(0..<7, id: \.self) { index in
                let day = VietnameseLunarCalendar.civilDate(base - offset + index)
                let l = VietnameseLunarCalendar.solarToLunar(day)
                VStack(spacing: compact ? 0 : 2) {
                    Text(["T2","T3","T4","T5","T6","T7","CN"][index])
                        .font(.system(size: compact ? 7 : 9, weight: .medium))
                        .foregroundStyle(muted)
                    Text("\(day.day)")
                        .font(.system(size: compact ? 10 : 13, weight: day == civil ? .bold : .medium))
                        .foregroundStyle(day == civil ? accent : ink)
                    Text("\(l?.day ?? 0)")
                        .font(.system(size: compact ? 7 : 9))
                        .foregroundStyle(muted)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, compact ? 1 : 3)
                .background(day == civil ? gold.opacity(0.17) : .clear,
                            in: RoundedRectangle(cornerRadius: 5))
            }
        }
    }

    private var fullMonthGrid: some View {
        let first = SolarCivilDate(year: civil.year, month: civil.month, day: 1)
        let base = VietnameseLunarCalendar.jdn(first)
        let offset = (base % 7 + 7) % 7
        return LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 2), count: 7), spacing: 3) {
            ForEach(0..<42, id: \.self) { index in
                let day = VietnameseLunarCalendar.civilDate(base - offset + index)
                let l = VietnameseLunarCalendar.solarToLunar(day)
                VStack(spacing: 2) {
                    Text("\(day.day)").font(.system(size: 11, weight: day == civil ? .bold : .medium))
                        .foregroundStyle(day.month == civil.month ? ink : muted.opacity(0.5))
                    Text(l?.day == 1 ? "1/\(l?.month ?? 0)" : "\(l?.day ?? 0)")
                        .font(.system(size: 8))
                        .foregroundStyle(l?.day == 1 || l?.day == 15 ? accent : muted)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 2)
                .background(day == civil ? gold.opacity(0.24) : .clear,
                            in: RoundedRectangle(cornerRadius: 5))
            }
        }
    }
}
