import SwiftUI

/// A single render path is reused in the gallery preview and WidgetKit.
/// Visual principles: a large primary number, 1–2 quiet secondary facts, generous whitespace.
enum LunarCardKind: String, CaseIterable, Identifiable {
    case today, nextEvent, moonDays, memorial, month, tradition, almanac
    var id: String { rawValue }
    var title: String {
        switch self {
        case .today: return "Hôm nay âm lịch"
        case .nextEvent: return "Ngày đẹp – việc nhớ"
        case .moonDays: return "Mùng 1 / Rằm"
        case .memorial: return "Ngày giỗ sắp tới"
        case .month: return "Lịch tháng âm dương"
        case .tradition: return "Ngày truyền thống"
        case .almanac: return "Vạn niên · Tử vi dân gian"
        }
    }
}

enum LunarCardSize { case small, medium, large, lock }

struct LunarCardView: View {
    let kind: LunarCardKind
    let size: LunarCardSize
    let civil: SolarCivilDate
    let appearance: LunarAppearance
    let upcomingEvents: [LunarEventOccurrence]
    var drawsOwnBackground: Bool = true

    private var theme: LunarTheme { appearance.theme }
    private var dateDesign: Font.Design { appearance.useSerif ? .serif : .rounded }
    private var ink: Color { Color(hex: theme.foreground) }
    private var muted: Color { Color(hex: theme.muted) }
    private var accent: Color { Color(hex: theme.accent) }
    private var lunar: VietnameseLunarDate? { VietnameseLunarCalendar.solarToLunar(civil) }
    private var nextFamily: LunarEventOccurrence? { upcomingEvents.first }
    private var nextMoon: LunarUpcomingFestival? { LunarHighlights.nextObservance(from: civil) }
    private var canChi: CanChi? { VietnameseLunarCalendar.canChi(civil) }
    private var isSpecial: Bool { lunar?.day == 1 || lunar?.day == 15 || !(lunar.map(LunarCulture.on) ?? []).isEmpty }

    var body: some View {
        Group {
            if size == .lock {
                lockContent
            } else {
                ZStack(alignment: .topTrailing) {
                    if drawsOwnBackground {
                        LunarHeritageBackground(appearance: appearance)
                    }
                    if appearance.showOrnament {
                        if let ornament = LunarHeritageArt.ornament(for: theme) {
                            Image(ornament)
                                .resizable()
                                .scaledToFit()
                                .frame(width: size == .small ? 38 : 56, height: size == .small ? 40 : 62)
                                .opacity(theme.usesLightSurface ? 0.74 : 0.60)
                                .padding(.top, size == .small ? 22 : 24)
                                .padding(.trailing, size == .small ? 4 : 10)
                                .accessibilityHidden(true)
                        } else {
                            Circle().stroke(accent.opacity(0.09), lineWidth: 1)
                                .frame(width: 124, height: 124).offset(x: 44, y: -50)
                            Circle().stroke(accent.opacity(0.06), lineWidth: 1)
                                .frame(width: 162, height: 162).offset(x: 42, y: -54)
                        }
                    }
                    VStack(alignment: .leading, spacing: size == .small ? 6 : 10) {
                        heading
                        Group {
                            switch kind {
                            case .today: todayBody
                            case .nextEvent: nextEventBody
                            case .moonDays: moonDaysBody
                            case .memorial: memorialBody
                            case .month: monthBody
                            case .tradition: traditionBody
                            case .almanac: almanacBody
                            }
                        }
                        Spacer(minLength: 0)
                        if size != .small && kind != .almanac { footer }
                    }
                    .padding(size == .small ? 13 : 18)
                }
                .foregroundStyle(ink)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            }
        }
        .accessibilityElement(children: .combine)
    }

    private var heading: some View {
        Group {
            if size != .small && theme != .zen {
                LunarHeritageSectionTitle(title: "LỊCH ÂM TĨNH", theme: theme)
                    .frame(height: 28)
            } else {
                HStack(spacing: 6) {
                    if theme != .zen {
                        Image(LunarHeritageComponents.imageOrFallback("HeritageActionCalendar"))
                            .resizable().scaledToFit().frame(width: 18, height: 18)
                    } else {
                        Image(systemName: "moon.phase.waning.crescent")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(accent)
                    }
                    Text("LỊCH ÂM TĨNH")
                        .font(.system(size: 9, weight: .semibold, design: .rounded))
                        .tracking(1.5).foregroundStyle(muted)
                    Spacer(minLength: 0)
                    if isSpecial {
                        Circle().fill(accent).frame(width: 5, height: 5)
                            .accessibilityLabel("Ngày âm lịch đặc biệt")
                    }
                }
            }
        }
    }

    private var todayBody: some View {
        Group {
            if size == .small {
                VStack(alignment: .leading, spacing: 2) {
                    Spacer(minLength: 2)
                    Text("\(civil.day)").font(.system(size: 56, weight: .light, design: dateDesign))
                        .minimumScaleFactor(0.7).lineLimit(1)
                    Text("\(lunar?.day ?? 0) tháng \(lunar?.month ?? 0) âm")
                        .font(.system(size: 13, weight: .semibold)).foregroundStyle(accent).lineLimit(1)
                    if appearance.showCanChi, let chi = canChi {
                        Text("Ngày \(chi.day)").font(.system(size: 10)).foregroundStyle(muted).lineLimit(1)
                    }
                }
            } else {
                HStack(alignment: .center, spacing: 18) {
                    Text("\(civil.day)").font(.system(size: 76, weight: .light, design: dateDesign))
                        .minimumScaleFactor(0.7).lineLimit(1)
                    Rectangle().fill(accent.opacity(0.25)).frame(width: 1, height: 62)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(lunar?.day ?? 0) tháng \(lunar?.month ?? 0) âm")
                            .font(.system(size: 18, weight: .semibold)).foregroundStyle(accent)
                        if appearance.showCanChi, let chi = canChi {
                            Text("Ngày \(chi.day)").font(.system(size: 12)).foregroundStyle(muted)
                        }
                        if let moon = nextMoon, appearance.density != .essential {
                            Text(moon.daysUntil == 0 ? "Hôm nay: \(moon.name)" : "\(moon.name) sau \(moon.daysUntil) ngày")
                                .font(.system(size: 11)).foregroundStyle(muted).lineLimit(1)
                        }
                    }
                }
            }
        }
    }

    private var nextEventBody: some View {
        VStack(alignment: .leading, spacing: 8) {
            todayBody
            if let event = nextFamily, appearance.showFamilyEvents {
                separator
                HStack(alignment: .firstTextBaseline) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(event.title).font(.system(size: 13, weight: .semibold)).lineLimit(1)
                        Text("Âm \(event.lunar.day)/\(event.lunar.month) · \(event.solar.label)")
                            .font(.system(size: 10)).foregroundStyle(muted).lineLimit(1)
                    }
                    Spacer()
                    Text(event.daysRemaining(from: civil) == 0 ? "Hôm nay" : "\(event.daysRemaining(from: civil)) ngày")
                        .font(.system(size: 11, weight: .bold)).foregroundStyle(accent)
                }
            } else if let moon = nextMoon {
                Text("\(moon.name) · \(moon.daysUntil == 0 ? "Hôm nay" : "còn \(moon.daysUntil) ngày")")
                    .font(.system(size: 12, weight: .medium)).foregroundStyle(accent)
            }
        }
    }

    private var moonDaysBody: some View {
        let first = LunarHighlights.nextLunarDay(from: civil, day: 1)
        let full = LunarHighlights.nextLunarDay(from: civil, day: 15)
        return VStack(alignment: .leading, spacing: 8) {
            if size != .small { Text("NHỊP TRĂNG VIỆT").font(.system(size: 10, weight: .medium)).tracking(1.4).foregroundStyle(muted) }
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Image(systemName: "moon.circle").foregroundStyle(accent)
                Text("Rằm").font(.system(size: size == .small ? 19 : 25, weight: .medium, design: .serif))
                Spacer()
                Text(full.map { "\($0.daysUntil) ngày" } ?? "—")
                    .font(.system(size: 12, weight: .semibold)).foregroundStyle(accent)
            }
            separator
            HStack(spacing: 8) {
                Image(systemName: "moon.phase.new").foregroundStyle(accent)
                Text("Mùng 1").font(.system(size: 13, weight: .medium))
                Spacer()
                Text(first.map { "\($0.daysUntil) ngày" } ?? "—")
                    .font(.system(size: 12, weight: .semibold)).foregroundStyle(accent)
            }
        }
    }

    private var memorialBody: some View {
        VStack(alignment: .leading, spacing: 7) {
            if let event = nextFamily, appearance.showFamilyEvents {
                HStack(spacing: 8) {
                    Image(LunarHeritageComponents.imageOrFallback(event.kind == .memorial ? "HeritageFestivalGioChap" : "HeritageActionFamily"))
                        .resizable().scaledToFit().frame(width: 28, height: 28)
                    Text(event.kind == .memorial ? "NGÀY GIỖ GIA ĐÌNH" : "SỰ KIỆN GIA ĐÌNH")
                        .font(.system(size: 9, weight: .semibold)).foregroundStyle(muted)
                }
                Text(event.title).font(.system(size: size == .small ? 18 : 26, weight: .medium, design: .serif))
                    .lineLimit(2).minimumScaleFactor(0.75)
                Text("\(event.daysRemaining(from: civil))")
                    .font(.system(size: size == .small ? 32 : 42, weight: .light, design: dateDesign))
                    .foregroundStyle(accent)
                    + Text(" ngày nữa").font(.system(size: 11)).foregroundStyle(muted)
                Text("Giỗ \(event.lunar.day)/\(event.lunar.month) âm · \(event.solar.label)")
                    .font(.system(size: 10)).foregroundStyle(muted).lineLimit(2)
            } else {
                Image(systemName: "heart.text.square").font(.title2).foregroundStyle(accent)
                Text("Giữ những ngày thương nhớ.")
                    .font(.system(size: 18, weight: .medium, design: .serif)).lineLimit(2)
                Text("Thêm ngày giỗ trong ứng dụng").font(.system(size: 11)).foregroundStyle(muted)
            }
        }
    }

    private var monthBody: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 7) {
                Image(LunarHeritageComponents.imageOrFallback("HeritageActionCalendar"))
                    .resizable().scaledToFit().frame(width: 24, height: 24)
                Text("THÁNG \(civil.month) / \(civil.year)")
                    .font(.system(size: 15, weight: .semibold, design: .serif))
                Spacer()
                Text("DƯƠNG · ÂM").font(.system(size: 9, weight: .medium)).tracking(1).foregroundStyle(muted)
            }
            let first = SolarCivilDate(year: civil.year, month: civil.month, day: 1)
            let jdn = VietnameseLunarCalendar.jdn(first)
            let offset = (jdn % 7 + 7) % 7
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 1), count: 7), spacing: 2) {
                ForEach(["T2", "T3", "T4", "T5", "T6", "T7", "CN"], id: \.self) { w in
                    Text(w).font(.system(size: 8, weight: .medium)).foregroundStyle(muted)
                }
                ForEach(0..<42, id: \.self) { i in
                    let day = VietnameseLunarCalendar.civilDate(jdn - offset + i)
                    let ld = VietnameseLunarCalendar.solarToLunar(day)
                    VStack(spacing: 1) {
                        Text("\(day.day)").font(.system(size: 10, weight: day == civil ? .bold : .medium))
                            .foregroundStyle(day == civil ? accent : day.month == civil.month ? ink : muted.opacity(0.45))
                        Text(ld?.day == 1 ? "1/\(ld?.month ?? 0)" : "\(ld?.day ?? 0)")
                            .font(.system(size: 7)).foregroundStyle(ld?.day == 1 || ld?.day == 15 ? accent : muted)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 2)
                    .background(day == civil ? accent.opacity(0.12) : Color.clear, in: RoundedRectangle(cornerRadius: 4))
                    .overlay(alignment: .topTrailing) {
                        if upcomingEvents.contains(where: { $0.solar == day }) {
                            Circle().fill(accent).frame(width: 3, height: 3)
                        }
                    }
                }
            }
            if appearance.density != .essential {
                let facts = LunarAlmanacFacts(civil)
                separator
                HStack(spacing: 5) {
                    Text("Can Chi: \(facts.canChiDay)")
                    Spacer(minLength: 2)
                    Text(facts.dayKind + " · Trực " + facts.officer)
                }
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(ink)
                .lineLimit(1)
                Text("Tiết khí: \(facts.solarTerm) · Giờ tốt: \(facts.goodHoursLabel)")
                    .font(.system(size: 9))
                    .foregroundStyle(muted)
                    .lineLimit(2)
            }
            if appearance.showFamilyEvents, let event = nextFamily {
                HStack(spacing: 6) {
                    Image(systemName: "heart.text.square").foregroundStyle(accent)
                    Text("Sắp tới: \(event.title)").lineLimit(1)
                    Spacer(minLength: 2)
                    Text(event.solar.label).foregroundStyle(accent)
                }
                .font(.system(size: 10, weight: .medium))
            }
        }
    }

    private var traditionBody: some View {
        VStack(alignment: .leading, spacing: 7) {
            if let lunar, let festival = LunarCulture.on(lunar).first {
                HStack(spacing: 7) {
                    LunarHeritageFestivalIllustration(festivalTitle: festival.title, size: 30)
                    Text(festival.title).font(.system(size: 10, weight: .medium))
                        .foregroundStyle(accent).lineLimit(1)
                }
            }
            Text("\(lunar?.day ?? 0) tháng \(lunar?.month ?? 0) âm")
                .font(.system(size: size == .small ? 19 : 26, weight: .medium, design: .serif))
                .foregroundStyle(accent)
            if let canChi = canChi {
                Text("Ngày \(canChi.day)").font(.system(size: 14, weight: .semibold))
                if size != .small {
                    Text("Tháng \(canChi.month) · Năm \(canChi.year)")
                        .font(.system(size: 11)).foregroundStyle(muted)
                }
            }
            if size != .small && appearance.density != .essential {
                separator
                let info = VietnameseLunarCalendar.traditionalDayInfo(civil)
                Text("\(info.spirit) · Trực \(info.officer)")
                    .font(.system(size: 11)).foregroundStyle(muted)
                Text("Tiết khí: \(VietnameseLunarCalendar.solarTerm(on: civil).name)")
                    .font(.system(size: 11)).foregroundStyle(muted)
            }
        }
    }

    /// Compact almanac for medium and an information-rich large widget.
    /// The term "tử vi" here means customary zodiac/day information, not predictions.
    @ViewBuilder
    private var almanacBody: some View {
        let facts = LunarAlmanacFacts(civil)
        if size == .large {
            VStack(alignment: .leading, spacing: 9) {
                HStack(alignment: .center, spacing: 14) {
                    Text("\(civil.day)")
                        .font(.system(size: 51, weight: .light, design: .serif))
                        .monospacedDigit()
                        .foregroundStyle(ink)
                    VStack(alignment: .leading, spacing: 3) {
                        Text("THÁNG \(civil.month) · \(civil.year)")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(muted)
                        Text("Âm \(lunar?.day ?? 0)/\(lunar?.month ?? 0)\(lunar?.isLeapMonth == true ? " nhuận" : "")")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(accent)
                        Text("Ngày \(facts.canChiDay)")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(ink)
                    }
                    Spacer(minLength: 0)
                }
                separator
                HStack(alignment: .top, spacing: 10) {
                    almanacFact("CAN CHI", "Tháng \(facts.canChiMonth)\nNăm \(facts.canChiYear)")
                    almanacFact("SAO · TRỰC", "\(facts.spirit)\nTrực \(facts.officer)")
                }
                HStack(alignment: .top, spacing: 10) {
                    almanacFact("TIẾT KHÍ", facts.solarTerm)
                    almanacFact("NGÀY", facts.dayKind)
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text("GIỜ HOÀNG ĐẠO")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundStyle(muted)
                    Text(facts.goodHoursLabel)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(ink)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
                if appearance.showFamilyEvents, let event = nextFamily {
                    HStack(spacing: 5) {
                        Image(systemName: "heart")
                        Text("Sắp tới: \(event.title)")
                            .lineLimit(1)
                        Spacer(minLength: 3)
                        Text("\(event.daysRemaining(from: civil)) ngày")
                    }
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(accent)
                }
                Text("Tử vi dân gian (tham khảo) · Tuổi xung: \(facts.opposingZodiac)")
                    .font(.system(size: 10))
                    .foregroundStyle(muted)
            }
        } else {
            VStack(alignment: .leading, spacing: 5) {
                HStack(alignment: .firstTextBaseline, spacing: 9) {
                    Text("\(civil.day)")
                        .font(.system(size: 32, weight: .light, design: .serif))
                        .foregroundStyle(ink)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Âm \(lunar?.day ?? 0)/\(lunar?.month ?? 0)")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(accent)
                        Text(facts.canChiDay)
                            .font(.system(size: 11, weight: .medium))
                    }
                    Spacer(minLength: 0)
                }
                separator
                HStack(spacing: 8) {
                    Text(facts.dayKind + " · Trực " + facts.officer)
                    Spacer(minLength: 0)
                    Text(facts.solarTerm)
                }
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(ink)
                .lineLimit(1)
                Text("Giờ tốt: " + facts.goodHoursLabel)
                    .font(.system(size: 10))
                    .foregroundStyle(muted)
                    .lineLimit(1)
                Text("Tuổi xung ngày: " + facts.opposingZodiac + " · Phong tục tham khảo")
                    .font(.system(size: 9))
                    .foregroundStyle(muted)
                    .lineLimit(1)
            }
        }
    }

    private func almanacFact(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(label)
                .font(.system(size: 9, weight: .semibold))
                .tracking(0.3)
                .foregroundStyle(muted)
            Text(value)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(ink)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var lockContent: some View {
        Group {
            switch kind {
            case .today, .tradition, .month, .almanac:
                Text("\(lunar?.day ?? 0)/\(lunar?.month ?? 0) ÂL")
            case .moonDays:
                Text(nextMoon.map { "\($0.name) · \($0.daysUntil) ngày" } ?? "Âm lịch Việt")
            case .memorial, .nextEvent:
                Text(nextFamily.map { "\($0.title): \($0.daysRemaining(from: civil)) ngày" } ?? "Chưa có sự kiện")
            }
        }
        .font(.system(size: 13, weight: .semibold))
        .lineLimit(1)
    }

    /// Native text badge instead of scaling the tiny badge cropped from the
    /// original JPG sprite sheet. Remains crisp at @2x/@3x on iPhone.
    private var crispBadgeTitle: String? {
        if lunar?.isLeapMonth == true { return "THÁNG NHUẬN" }
        if kind == .memorial, nextFamily != nil, appearance.showFamilyEvents { return "NGÀY GIỖ" }
        if lunar?.day == 1 { return "MÙNG MỘT" }
        if lunar?.day == 15 { return "NGÀY RẰM" }
        return nil
    }

    private var footer: some View {
        HStack {
            if let label = crispBadgeTitle {
                Text(label)
                    .font(.system(size: 9, weight: .semibold, design: .rounded))
                    .tracking(0.6)
                    .foregroundStyle(accent)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(accent.opacity(0.10), in: Capsule())
                    .overlay(Capsule().stroke(accent.opacity(0.36), lineWidth: 0.8))
            } else {
                Text("VIỆT NAM · UTC+7")
                    .font(.system(size: 9, weight: .medium))
                    .tracking(0.6)
                    .foregroundStyle(muted)
            }
            Spacer(minLength: 0)
            Text("VIEPN")
                .font(.system(size: 9, weight: .medium))
                .tracking(1.0)
                .foregroundStyle(muted)
        }
    }

    private var separator: some View { Rectangle().fill(accent.opacity(0.22)).frame(height: 1) }
}
