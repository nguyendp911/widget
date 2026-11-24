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
        VStack(alignment: .leading, spacing: 19) {
            Button { onOpen(.date) } label: {
                HeritageDayHero(day: civil, lunar: lunar, facts: facts, appearance: appearance)
            }.buttonStyle(.plain)
            EditorialSectionTitle(eyebrow: "Tra cứu trong ngày", title: "Nhịp sống & lịch pháp")
            termCard
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 11), GridItem(.flexible(), spacing: 11)], spacing: 11) {
                tile(.canChi, title: "Thiên Can · Địa Chi", value: facts.canChiDay, note: "Tháng " + facts.canChiMonth + " · Năm " + facts.canChiYear, symbol: "circle.hexagongrid")
                tile(.auspicious, title: "Sao & Trực", value: "Trực " + facts.officer, note: facts.dayKind + " · " + facts.spirit, symbol: "sparkle")
                tile(.zodiac, title: "Con giáp", value: facts.dayAnimalName, note: "Tuổi xung: " + facts.opposingAnimalName, symbol: "seal")
                tile(.hours, title: "Giờ hoàng đạo", value: String(facts.goodHours.count) + " khung giờ", note: facts.goodHoursLabel, symbol: "clock")
            }
            VStack(alignment: .leading, spacing: 13) {
                Button { onOpen(.month) } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("ÂM DƯƠNG LỊCH").font(.caption2.weight(.semibold)).tracking(1.5).foregroundStyle(soft)
                            Text("Tháng " + String(civil.month) + " · " + String(civil.year)).font(.system(.title2, design: .serif).weight(.semibold))
                        }
                        Spacer()
                        Image(systemName: "arrow.up.right").font(.subheadline.weight(.semibold)).foregroundStyle(wine)
                    }.frame(maxWidth: .infinity, alignment: .leading)
                }.buttonStyle(.plain)
                monthGrid
                HStack(spacing: 7) {
                    Circle().fill(gold).frame(width: 6,height: 6)
                    Text("Mùng 1, Rằm").font(.caption).foregroundStyle(soft)
                    Spacer()
                    Text("Chạm ngày để tra cứu").font(.caption).foregroundStyle(soft)
                }
            }.padding(16).editorialSurface()
            EditorialSectionTitle(eyebrow: "Nếp nhà Việt", title: "Ngày đáng nhớ")
            tile(.observances, title: "Mùng 1 · Rằm · Ngày lễ", value: "Lịch lễ Việt", note: observanceSummary, symbol: "moon.stars")
            tile(.memorials, title: "Gia đình", value: "Ngày giỗ & ngày nhớ", note: familySummary, symbol: "heart")
            Text("Lịch tính theo UTC+7; quan niệm giờ, ngày tốt xấu và tử vi là thông tin văn hóa tham khảo.").font(.caption).foregroundStyle(soft)
        }.foregroundStyle(ink)
    }

    private var termCard: some View {
        let guide = SolarTermGuide.named(facts.solarTerm)
        let period = SolarTermGuide.period(on: civil)
        return Button { onOpen(.solarTerms) } label: {
            HStack(alignment: .center, spacing: 15) {
                VStack(alignment: .leading, spacing: 7) {
                    Text("24 TIẾT KHÍ  /  " + (guide?.season.uppercased() ?? ""))
                        .font(.caption2.weight(.semibold)).tracking(1.4).foregroundStyle(Color(hex: "#E6C17B"))
                    Text(facts.solarTerm).font(.system(size: 29,weight:.semibold,design:.serif))
                    Text(guide?.meaning ?? "Tra cứu tiết khí").font(.subheadline).fixedSize(horizontal:false,vertical:true)
                    if let next = period.next {
                        let days = VietnameseLunarCalendar.jdn(next) - VietnameseLunarCalendar.jdn(civil)
                        Text("Còn " + String(days) + " ngày đến " + VietnameseLunarCalendar.solarTerm(on: next).name)
                            .font(.caption.weight(.medium)).foregroundStyle(Color(hex: "#E6C17B"))
                    }
                }.frame(maxWidth: .infinity,alignment:.leading)
                VStack(spacing: 11) {
                    Image(systemName: guide?.symbol ?? "sun.max").font(.system(size: 39, weight: .light))
                    Image(systemName: "arrow.up.right").font(.caption.weight(.semibold))
                }.foregroundStyle(Color(hex: "#E6C17B"))
            }.padding(19).foregroundStyle(Color(hex: "#FFF1D3"))
            .background(LinearGradient(colors:[Color(hex:"#173D36"),Color(hex:"#285B4D")],startPoint:.topLeading,endPoint:.bottomTrailing),in:RoundedRectangle(cornerRadius:22))
        }.buttonStyle(.plain)
    }

    private func tile(_ section: ThienNienSection, title: String, value: String, note: String, symbol: String) -> some View {
        Button { onOpen(section) } label: {
            VStack(alignment:.leading,spacing:8) {
                HStack {
                    if section == .zodiac {
                        HeritageAnimalArtwork(branch: facts.dayAnimal).frame(width:42,height:42)
                    } else {
                        Image(systemName:symbol).font(.system(size:21,weight:.medium)).foregroundStyle(wine)
                            .frame(width:42,height:42)
                            .background(Color(hex:"#F3E8D5"),in:RoundedRectangle(cornerRadius:13))
                    }
                    Spacer(minLength:0)
                    Image(systemName:"arrow.up.right").font(.caption.weight(.semibold)).foregroundStyle(soft)
                }
                Text(title).font(.caption.weight(.medium)).foregroundStyle(soft)
                Text(value).font(.system(.headline,design:.serif)).foregroundStyle(ink).fixedSize(horizontal:false,vertical:true)
                Text(note).font(.caption).foregroundStyle(soft).fixedSize(horizontal:false,vertical:true)
            }.padding(13).frame(maxWidth:.infinity,minHeight:145,alignment:.topLeading).editorialSurface()
        }.buttonStyle(.plain).accessibilityLabel("Xem " + title + ": " + value + ". " + note)
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
                    Button { if VietnameseLunarCalendar.isValid(day) { onSelect(day) } } label: {
                        VStack(spacing: 3) {
                            Text("\(day.day)")
                                .font(.system(size: 13, weight: day == civil ? .bold : .medium))
                                .foregroundStyle(day == civil ? Color.white : day.month == civil.month ? ink : soft.opacity(0.48))
                            Text(moon?.day == 1 ? "1/\(moon?.month ?? 0)" : "\(moon?.day ?? 0)")
                                .font(.system(size: 10))
                                .foregroundStyle(day == civil ? Color(hex: "#FFE5AE") : moon?.day == 1 || moon?.day == 15 ? wine : soft)
                        }
                        .frame(maxWidth: .infinity, minHeight: 39)
                        .background(day == civil ? wine : .clear,
                                    in: RoundedRectangle(cornerRadius: 7))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Ngày \(day.label), âm \(moon?.label ?? "")")
                }
            }
        }
    }
}
