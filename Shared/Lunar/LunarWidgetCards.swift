import SwiftUI

/// A single render path is reused in the gallery preview and WidgetKit.
/// Visual principles: a large primary number, 1–2 quiet secondary facts, generous whitespace.
enum LunarCardKind: String, CaseIterable, Identifiable {
    case today, nextEvent, moonDays, memorial, month, tradition
    var id: String { rawValue }
    var title: String {
        switch self {
        case .today: return "Hôm nay âm lịch"
        case .nextEvent: return "Ngày đẹp – việc nhớ"
        case .moonDays: return "Mùng 1 / Rằm"
        case .memorial: return "Ngày giỗ sắp tới"
        case .month: return "Lịch tháng âm dương"
        case .tradition: return "Ngày truyền thống"
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
                                .frame(width: size == .small ? 72 : 118, height: size == .small ? 70 : 110)
                                .opacity(theme.usesLightSurface ? 0.18 : 0.22)
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
                            }
                        }
                        Spacer(minLength: 0)
                        if size != .small { footer }
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
        HStack(spacing: 6) {
            Image(systemName: "moon.phase.waning.crescent")
                .font(.system(size: 11, weight: .medium)).foregroundStyle(accent)
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
            HStack {
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

    private var lockContent: some View {
        Group {
            switch kind {
            case .today, .tradition, .month:
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

    private var footer: some View {
        HStack {
            if appearance.showOrnament && theme != .zen,
               let status = LunarHeritageArt.statusBadge(kind: kind, lunar: lunar,
                                                          hasFamilyEvent: nextFamily != nil && appearance.showFamilyEvents) {
                Image(status)
                    .resizable().scaledToFit().frame(width: 92, height: 25)
                    .accessibilityLabel(lunar?.isLeapMonth == true ? "Tháng nhuận" : kind == .memorial ? "Ngày giỗ" : lunar?.day == 1 ? "Mùng một" : "Ngày rằm")
            } else if lunar?.isLeapMonth == true {
                Text("THÁNG NHUẬN").font(.system(size: 9, weight: .semibold)).foregroundStyle(accent)
            } else if lunar?.day == 1 || lunar?.day == 15 {
                Text(lunar?.day == 15 ? "NGÀY RẰM" : "MÙNG MỘT")
                    .font(.system(size: 9, weight: .semibold)).foregroundStyle(accent)
            } else {
                Text("VIỆT NAM · UTC+7").font(.system(size: 9, weight: .medium)).tracking(0.8).foregroundStyle(muted)
            }
            Spacer(minLength: 0)
            Text("VIEPN").font(.system(size: 9, weight: .medium)).tracking(1.2).foregroundStyle(muted)
        }
    }

    private var separator: some View { Rectangle().fill(accent.opacity(0.22)).frame(height: 1) }
}
