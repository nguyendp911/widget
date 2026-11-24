import SwiftUI

struct HeritageCalendarView: View {
    @EnvironmentObject private var family: LunarFamilyStore
    @State private var day = SolarCivilDate(date: Date()) ?? SolarCivilDate(year: 2026, month: 11, day: 24)
    @State private var comparison = Date()
    @State private var search = ""
    @State private var message = ""
    @State private var section: ThienNienSection?
    @State private var mode = 1
    @State private var compare = false
    @State private var auspiciousOnly = false
    private var facts: LunarAlmanacFacts { LunarAlmanacFacts(day) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HeritageBanner(title: "Lịch vạn niên", subtitle: "Tra cứu ngày Việt từ 1900–2100", image: "ViePNCongLangLarge")
                VStack(alignment: .leading, spacing: 9) {
                    Text("TÌM NGÀY ÂM – DƯƠNG").font(.system(.subheadline, design: .serif).weight(.semibold))
                    HStack {
                        TextField("Rằm tháng 7 năm 2028", text: $search).textFieldStyle(.roundedBorder).submitLabel(.search).onSubmit(runSearch)
                        Button("Tìm", action: runSearch).buttonStyle(.borderedProminent)
                    }
                    Text("Ví dụ: 24/11/2026, 15/7/2028 âm, mùng 1 tháng 1 năm 2028.").font(.caption).foregroundStyle(HeritagePalette.soft)
                    if !message.isEmpty { Text(message).font(.caption).foregroundStyle(HeritagePalette.red) }
                    DatePicker("Ngày đang xem", selection: Binding(get: { day.asDate() ?? Date() }, set: {
                        if let value = SolarCivilDate(date: $0), VietnameseLunarCalendar.isValid(value) { day = value }
                    }), in: dateRange, displayedComponents: .date)
                        .environment(\.timeZone, VietnameseLunarCalendar.vietnamTimeZone)
                        .environment(\.locale, Locale(identifier: "vi_VN"))
                }.padding(14).heritageFrame()
                Picker("Chế độ", selection: $mode) {
                    Text("Tuần").tag(0); Text("Tháng").tag(1); Text("Năm").tag(2)
                }.pickerStyle(.segmented)
                HStack {
                    Button { move(-1) } label: { Image(systemName: "chevron.left").padding(10) }
                    Spacer()
                    Text(mode == 2 ? "Năm \(String(day.year))" : "Tháng \(day.month) · \(String(day.year))").font(.system(.headline, design: .serif))
                    Spacer()
                    Button { move(1) } label: { Image(systemName: "chevron.right").padding(10) }
                    Button("Nay") { if let now = SolarCivilDate(date: Date()) { day = now } }
                }
                if mode == 2 {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                        ForEach(1...12, id: \.self) { month in
                            Button {
                                day = SolarCivilDate(year: day.year, month: month, day: 1)
                                mode = 1
                            } label: {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Tháng \(month)").font(.system(.headline, design: .serif))
                                    let start = SolarCivilDate(year: day.year, month: month, day: 1)
                                    Text(VietnameseLunarCalendar.solarToLunar(start).map { "Âm đầu tháng: \($0.day)/\($0.month)" } ?? "—").font(.caption)
                                    Image("TNVCloud").resizable().scaledToFit().frame(height: 27).accessibilityHidden(true)
                                }.frame(maxWidth: .infinity, alignment: .leading).padding(12).heritageFrame()
                            }.buttonStyle(.plain)
                        }
                    }
                } else {
                    dateGrid
                }
                HeritageDayHero(day: day, lunar: VietnameseLunarCalendar.solarToLunar(day), facts: facts, appearance: family.appearance)
                VStack(alignment: .leading, spacing: 12) {
                    Text("Tra cứu chuyên sâu").font(.headline)
                    ForEach([ThienNienSection.canChi, .zodiac, .auspicious, .hours, .solarTerms, .observances]) { item in
                        Button { section = item } label: {
                            HStack { Text(item.title); Spacer(); Image(systemName: "chevron.right") }
                        }
                        Divider()
                    }
                    Toggle("Tham khảo ngày hoàng đạo tháng này", isOn: $auspiciousOnly)
                    if auspiciousOnly {
                        let dates = monthDays.filter { $0.month == day.month && LunarAlmanacFacts($0).dayKind == "Hoàng đạo" }
                        ForEach(dates, id: \.self) { candidate in
                            Button { day = candidate; section = .auspicious } label: {
                                HStack { Text(candidate.label); Spacer(); Text(LunarAlmanacFacts(candidate).canChiDay).foregroundStyle(HeritagePalette.soft) }
                            }
                        }
                        Text("Chỉ lọc theo quy ước hoàng đạo; không bảo đảm phù hợp cưới hỏi, khai trương hoặc các quyết định thực tế.").font(.caption)
                    }
                    Toggle("So sánh hai ngày", isOn: $compare)
                    if compare {
                        DatePicker("Ngày thứ hai", selection: $comparison, in: dateRange, displayedComponents: .date)
                        if let second = SolarCivilDate(date: comparison) {
                            comparisonRow(day); comparisonRow(second)
                        }
                    }
                }.padding(15).heritageFrame()
            }.padding(16)
        }
        .background(HeritagePalette.paper.ignoresSafeArea())
        .foregroundStyle(HeritagePalette.ink)
        .navigationTitle("Lịch âm")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $section) { item in ThienNienDetailSheet(section: item, civil: day, familyEvents: family.events) }
    }

    private var dateRange: ClosedRange<Date> {
        SolarCivilDate(year: 1900, month: 1, day: 1).asDate()!...SolarCivilDate(year: 2100, month: 12, day: 31).asDate()!
    }

    private var monthDays: [SolarCivilDate] {
        let first = SolarCivilDate(year: day.year, month: day.month, day: 1)
        let j = VietnameseLunarCalendar.jdn(first)
        return (0..<42).map { VietnameseLunarCalendar.civilDate(j - (j % 7 + 7) % 7 + $0) }.filter { VietnameseLunarCalendar.isValid($0) }
    }

    private var dateGrid: some View {
        let j = VietnameseLunarCalendar.jdn(day)
        let days = mode == 0 ? (0..<7).map { VietnameseLunarCalendar.civilDate(j - (j % 7 + 7) % 7 + $0) } : monthDays
        let events = LunarEventScheduler.upcoming(events: family.events, from: days.first ?? day, count: 500, years: 2)
        return VStack(spacing: 5) {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 2), count: 7), spacing: 5) {
                ForEach(["T2","T3","T4","T5","T6","T7","CN"], id: \.self) { Text($0).font(.caption.weight(.medium)) }
                ForEach(days, id: \.self) { candidate in
                    let l = VietnameseLunarCalendar.solarToLunar(candidate)
                    let special = events.contains { $0.solar == candidate } || l.map { !LunarCulture.on($0).isEmpty } == true
                    Button {
                        if VietnameseLunarCalendar.isValid(candidate) { day = candidate }
                    } label: {
                        VStack(spacing: 2) {
                            Text(String(candidate.day)).font(.system(size: 15, weight: candidate == day ? .bold : .medium))
                            Text(l.map { $0.day == 1 ? "1/\($0.month)" : String($0.day) } ?? "—").font(.system(size: 10))
                            Circle().fill(special ? HeritagePalette.red : .clear).frame(width: 4, height: 4)
                        }.frame(maxWidth: .infinity, minHeight: 43)
                            .foregroundStyle(candidate == day ? Color.white : (candidate.month == day.month ? HeritagePalette.ink : HeritagePalette.soft.opacity(0.6)))
                            .background(candidate == day ? HeritagePalette.red : .clear, in: RoundedRectangle(cornerRadius: 8))
                    }.buttonStyle(.plain)
                }
            }
        }.padding(10).heritageFrame()
    }

    private func comparisonRow(_ value: SolarCivilDate) -> some View {
        let f = LunarAlmanacFacts(value)
        return VStack(alignment: .leading, spacing: 5) {
            Text(value.label).font(.headline)
            Text("Âm \(VietnameseLunarCalendar.solarToLunar(value)?.label ?? "—") · \(f.canChiDay)")
            Text("\(f.dayKind) · Trực \(f.officer) · \(f.solarTerm)")
        }.font(.subheadline).frame(maxWidth: .infinity, alignment: .leading).padding(10).background(HeritagePalette.paper, in: RoundedRectangle(cornerRadius: 8))
    }

    private func runSearch() {
        if let result = HeritageSearch.date(search, year: day.year) { day = result; mode = 1; message = "Đã tìm thấy \(result.label)." }
        else { message = "Không tìm được ngày hợp lệ. Kiểm tra ngày, tháng, năm hoặc chữ “âm”, “nhuận”." }
    }

    private func move(_ delta: Int) {
        if mode == 0 {
            let next = VietnameseLunarCalendar.civilDate(VietnameseLunarCalendar.jdn(day) + delta * 7)
            if VietnameseLunarCalendar.isValid(next) { day = next }
        } else {
            var calendar = Calendar(identifier: .gregorian)
            calendar.timeZone = VietnameseLunarCalendar.vietnamTimeZone
            let first = SolarCivilDate(year: day.year, month: day.month, day: 1)
            guard let date = first.asDate(), let next = calendar.date(byAdding: mode == 2 ? .year : .month, value: delta, to: date),
                  let civil = SolarCivilDate(date: next), VietnameseLunarCalendar.isValid(civil) else { return }
            day = civil
        }
    }
}

struct HeritageCultureView: View {
    @State private var query = ""
    @State private var selected: VietnameseLunarFestival?
    @State private var topic: ThienNienSection?
    private var today: SolarCivilDate { SolarCivilDate(date: Date()) ?? SolarCivilDate(year: 2026, month: 11, day: 24) }
    private var festivals: [VietnameseLunarFestival] {
        let normalized = HeritageSearch.normalized(query)
        if normalized.isEmpty { return LunarCulture.festivals }
        return LunarCulture.festivals.filter { HeritageSearch.normalized($0.title + " " + $0.description).contains(normalized) }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HeritageBanner(title: "Di sản Việt", subtitle: "Phong tục · Lễ Tết · Tri thức lịch Việt", image: "ViePNSenNgocLarge")
                TextField("Tìm lễ hội, phong tục…", text: $query).textFieldStyle(.roundedBorder)
                Text("Bách khoa lịch Việt").font(.headline)
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    ForEach([ThienNienSection.canChi, .zodiac, .hours, .solarTerms]) { item in
                        Button { topic = item } label: {
                            VStack(spacing: 5) {
                                Image(item == .solarTerms ? "TNVMountain" : item == .hours ? "TNVCloud" : "TNVDrum").resizable().scaledToFit().frame(height: 54)
                                Text(item.title).font(.system(.subheadline, design: .serif).weight(.semibold))
                            }.frame(maxWidth: .infinity).padding(12).heritageFrame()
                        }.buttonStyle(.plain)
                    }
                }
                Text("Lễ Việt trong năm").font(.headline)
                ForEach(festivals) { festival in
                    Button { selected = festival } label: {
                        HStack(spacing: 12) {
                            Image(art(festival)).resizable().scaledToFill().frame(width: 82, height: 65).clipped().clipShape(RoundedRectangle(cornerRadius: 9))
                            VStack(alignment: .leading, spacing: 5) {
                                Text(festival.title).font(.system(.headline, design: .serif))
                                Text("\(festival.day)/\(festival.month) âm lịch").font(.caption).foregroundStyle(HeritagePalette.red)
                                Text(festival.description).font(.caption).lineLimit(2)
                            }
                            Spacer(minLength: 0)
                            Image(systemName: "chevron.right").font(.caption)
                        }.padding(10).heritageFrame()
                    }.buttonStyle(.plain)
                }
                if festivals.isEmpty { Text("Chưa tìm thấy trong thư viện nội dung hiện có.").font(.caption) }
                Text("Nội dung tra cứu cục bộ, chưa có trợ lý AI hoặc tài liệu trích dẫn đầy đủ. Tập quán có thể khác giữa gia đình và vùng miền.").font(.caption).foregroundStyle(HeritagePalette.soft)
            }.padding(16)
        }
        .background(HeritagePalette.paper.ignoresSafeArea())
        .foregroundStyle(HeritagePalette.ink)
        .navigationTitle("Văn hóa Việt")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $topic) { item in ThienNienDetailSheet(section: item, civil: today, familyEvents: []) }
        .sheet(item: $selected) { festival in
            NavigationStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        HeritageBanner(title: festival.title, subtitle: "\(festival.day)/\(festival.month) âm lịch", image: art(festival))
                        Text("Ý nghĩa").font(.headline)
                        Text(festival.description)
                        let year = today.year
                        let date = VietnameseLunarCalendar.lunarToSolar(VietnameseLunarDate(day: festival.day, month: festival.month, year: year, isLeapMonth: false))
                        Text("Năm \(String(year)): \(date?.label ?? "—") dương lịch").font(.headline)
                        Text("Có thể chuẩn bị một bữa cơm sum họp, tìm hiểu ý nghĩa ngày lễ và trao đổi với người thân về phong tục gia đình.").font(.subheadline)
                    }.padding(16)
                }.background(HeritagePalette.paper.ignoresSafeArea())
                    .navigationTitle("Lễ Việt").navigationBarTitleDisplayMode(.inline)
            }.presentationDragIndicator(.visible)
        }
    }

    private func art(_ festival: VietnameseLunarFestival) -> String {
        switch festival.month {
        case 1: return "ViePNXuanVietLarge"
        case 4, 7: return "ViePNSenNgocLarge"
        case 8: return "ViePNTrangTreLarge"
        case 3: return "ViePNCongLangLarge"
        case 10, 12: return "ViePNGioNhaLarge"
        default: return "ViePNCucVangLarge"
        }
    }
}
