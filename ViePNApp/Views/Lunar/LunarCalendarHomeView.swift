import SwiftUI
import WidgetKit

private enum LunarViewMode: String, CaseIterable, Identifiable {
    case day = "Ngày", week = "Tuần", month = "Tháng", year = "Năm"
    var id: String { rawValue }
}

struct LunarCalendarHomeView: View {
    @Binding private var incomingURL: URL?

    init(incomingURL: Binding<URL?> = .constant(nil)) {
        _incomingURL = incomingURL
    }

    @EnvironmentObject private var family: LunarFamilyStore
    @State private var selected = SolarCivilDate(date: Date()) ?? SolarCivilDate(year: 2026, month: 11, day: 23)
    @State private var mode: LunarViewMode = .month
    @State private var addingEvent = false
    @State private var editingEvent: LunarFamilyEvent?
    @State private var exportURL: URL?
    @State private var exportError: String?
    @State private var showAdvancedAppearance = false
    @State private var showAllFestivals = false

    private var theme: LunarTheme { family.appearance.theme }
    private var ink: Color { Color(hex: theme.foreground) }
    private var muted: Color { Color(hex: theme.muted) }
    private var accent: Color { Color(hex: theme.accent) }
    private var panel: Color { Color(hex: theme.secondaryBackground) }
    private var today: SolarCivilDate { SolarCivilDate(date: Date()) ?? selected }
    private var lunar: VietnameseLunarDate? { VietnameseLunarCalendar.solarToLunar(selected) }
    private var upcoming: [LunarEventOccurrence] { LunarEventScheduler.upcoming(events: family.events, from: today, count: 8) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                hero
                heritageShortcuts
                widgetShowcase
                VStack(alignment: .leading, spacing: 12) {
                    sectionLabel("TRA CỨU LỊCH", subtitle: "Từng ngày, từng tháng âm dương")
                    Picker("Chế độ", selection: $mode) {
                        ForEach(LunarViewMode.allCases) { item in Text(item.rawValue).tag(item) }
                    }.pickerStyle(.segmented)
                    Group {
                        switch mode {
                        case .day: dayDetail
                        case .week: weekPanel
                        case .month: monthPanel
                        case .year: yearPanel
                        }
                    }
                    if mode != .day { dayDetail }
                    // Daily almanac remains visible without opening an accordion.
                    VStack(alignment: .leading, spacing: 10) {
                        sectionLabel("LỊCH VẠN NIÊN", subtitle: "Can Chi, tiết khí và giờ tốt hôm nay")
                        LunarCardView(
                            kind: .almanac, size: .large, civil: selected,
                            appearance: family.appearance,
                            upcomingEvents: LunarEventScheduler.upcoming(
                                events: family.events, from: selected, count: 3
                            )
                        )
                        .frame(height: 310)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                        Text("Tử vi dân gian và ngày tốt–xấu là quan niệm văn hóa, không phải dự đoán cá nhân.")
                            .font(.system(size: 11))
                            .foregroundStyle(muted)
                    }
                }
                familyPanel
                preferencesPanel
                remindersPanel
                culturalPanel
                Text("Lịch âm Việt UTC+7 theo thuật toán thiên văn. Can Chi, sao, trực và giờ tốt–xấu là thông tin văn hóa tham khảo; cách luận giữa các truyền thống có thể khác nhau.")
                    .font(.system(size: 11)).foregroundStyle(muted).padding(.bottom, 16)
            }
            .padding(.horizontal, 18)
            .padding(.top, 14)
            .padding(.bottom, 38)
        }
        .background(Color(hex: theme.background).ignoresSafeArea())
        .foregroundStyle(ink)
        .environment(\.colorScheme, theme.usesLightSurface ? .light : .dark)
        .tint(accent)
        .navigationTitle("Lịch Âm Tĩnh")
        .navigationBarTitleDisplayMode(.inline)

        .sheet(isPresented: $addingEvent) { NavigationStack { LunarEventEditorView() } }
        .sheet(item: $editingEvent) { item in NavigationStack { LunarEventEditorView(editing: item) } }
        .alert("Không thể xuất lịch", isPresented: Binding(get: { exportError != nil }, set: { if !$0 { exportError = nil } })) {
            Button("OK") { exportError = nil }
        } message: { Text(exportError ?? "") }
        .onAppear(perform: consumeIncomingLink)
        .onChange(of: incomingURL) { _, _ in consumeIncomingLink() }
        .task { await family.syncNotifications() }
    }

    private func consumeIncomingLink() {
        guard let url = incomingURL else { return }
        handleURL(url)
        incomingURL = nil
    }

    private func handleURL(_ url: URL) {
        guard url.scheme == "viepnwidgetplus" else { return }
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        if url.host == "lunar", let text = components?.queryItems?.first(where: { $0.name == "date" })?.value {
            let parts = text.split(separator: "-").compactMap { Int($0) }
            if parts.count == 3 {
                let value = SolarCivilDate(year: parts[0], month: parts[1], day: parts[2])
                if VietnameseLunarCalendar.isValid(value) { selected = value; mode = .day }
            }
        }
        if url.host == "family", let value = components?.queryItems?.first(where: { $0.name == "event" })?.value,
           let uuid = UUID(uuidString: value), let event = family.events.first(where: { $0.id == uuid }) {
            editingEvent = event
        }
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack {
                Label("VIEPN · LỊCH ÂM VIỆT", systemImage: "moon.stars")
                    .font(.system(size: 10, weight: .semibold)).tracking(1.7).foregroundStyle(accent)
                Spacer()
                Text("UTC+7").font(.system(size: 10, weight: .medium)).foregroundStyle(muted)
            }
            Text("Nhớ ngày. Giữ tình thân.")
                .font(.system(size: 27, weight: .medium, design: .serif)).tracking(-0.5)
            Text("Một chút bình yên, một ngày không quên.")
                .font(.system(size: 13)).foregroundStyle(muted)
            if let imageName = LunarHeritageArt.ornament(for: theme), family.appearance.showOrnament {
                HStack(spacing: 9) {
                    Image(imageName)
                        .resizable().scaledToFit().frame(width: 32, height: 25)
                        .accessibilityHidden(true)
                    Text("Bộ tranh Việt · \(theme.title)")
                        .font(.system(size: 10)).foregroundStyle(muted)
                }.padding(.top, 2)
            }
        }
    }

    private var heritageShortcuts: some View {
        HStack(alignment: .top, spacing: 8) {
            heritageShortcut("Hôm nay", icon: "HeritageActionCalendar") {
                selected = today
                mode = .day
            }
            heritageShortcut("Ngày giỗ", icon: "HeritageActionFamily") {
                addingEvent = true
            }
            heritageShortcut("Nhắc việc", icon: "HeritageActionBell") {
                Task { await family.enableNotifications() }
            }
            heritageShortcut("Xem năm", icon: "HeritageActionCulture") {
                mode = .year
            }
        }
        .padding(.vertical, 8)
        .background(panel.opacity(0.7), in: RoundedRectangle(cornerRadius: 16))
    }

    private func heritageShortcut(_ label: String, icon: String, action: @escaping () -> Void) -> some View {
        VStack(spacing: 2) {
            LunarHeritageActionButton(assetName: icon, accessibilityTitle: label, action: action)
            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(muted)
                .lineLimit(1)
                .minimumScaleFactor(0.85)
        }
        .frame(maxWidth: .infinity)
    }

    private var widgetShowcase: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("LỊCH ÂM TĨNH", subtitle: "Widget trang nhã cho màn hình iPhone")
            ScrollView(.horizontal) {
                HStack(alignment: .top, spacing: 12) {
                    showcase(kind: .today, size: .small, width: 164, height: 164)
                    showcase(kind: .nextEvent, size: .medium, width: 286, height: 164)
                    showcase(kind: .moonDays, size: .small, width: 164, height: 164)
                    showcase(kind: .memorial, size: .medium, width: 286, height: 164)
                    showcase(kind: .month, size: .large, width: 280, height: 310)
                    showcase(kind: .tradition, size: .medium, width: 286, height: 164)
                    showcase(kind: .almanac, size: .large, width: 280, height: 310)
                }
            }.scrollIndicators(.hidden)
            Text("Nhấn giữ màn hình chính → Sửa → Thêm widget → ViePN Widget+.")
                .font(.system(size: 11)).foregroundStyle(muted)
        }
    }

    private func showcase(kind: LunarCardKind, size: LunarCardSize, width: CGFloat, height: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            LunarCardView(kind: kind, size: size, civil: today,
                          appearance: family.appearance, upcomingEvents: upcoming)
                .frame(width: width, height: height)
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(accent.opacity(0.16), lineWidth: 1))
            Text(kind.title).font(.system(size: 11, weight: .medium)).foregroundStyle(muted)
        }.frame(width: width)
    }

    private var dayDetail: some View {
        VStack(alignment: .leading, spacing: 13) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(selected.day)").font(.system(size: 62, weight: .light, design: .serif))
                    Text("\(selected.month)/\(selected.year) DƯƠNG LỊCH")
                        .font(.system(size: 9, weight: .semibold)).tracking(0.7).foregroundStyle(muted)
                }
                Spacer(minLength: 10)
                VStack(alignment: .trailing, spacing: 5) {
                    Text("ÂM LỊCH").font(.system(size: 10, weight: .semibold)).tracking(1).foregroundStyle(muted)
                    Text("\(lunar?.day ?? 0) / \(lunar?.month ?? 0)")
                        .font(.system(size: 30, weight: .regular, design: .serif)).foregroundStyle(accent)
                    if lunar?.isLeapMonth == true { Text("Tháng nhuận").font(.caption).foregroundStyle(accent) }
                }
            }
            if let lunar {
                let special = LunarCulture.observances(on: lunar)
                if !special.isEmpty {
                    HStack(spacing: 8) {
                        if let festival = LunarCulture.on(lunar).first {
                            LunarHeritageFestivalIllustration(festivalTitle: festival.title, size: 34)
                        }
                        Text(special.joined(separator: " · "))
                            .font(.system(size: 11, weight: .medium)).foregroundStyle(accent)
                    }
                }
            }
            DisclosureGroup("Can Chi · tiết khí · giờ hoàng đạo") {
                VStack(alignment: .leading, spacing: 9) {
                    if let can = VietnameseLunarCalendar.canChi(selected) {
                        Text("Ngày \(can.day) · Tháng \(can.month) · Năm \(can.year)")
                    }
                    Text("Tiết khí: \(VietnameseLunarCalendar.solarTerm(on: selected).name)")
                    let info = VietnameseLunarCalendar.traditionalDayInfo(selected)
                    Text("\(info.spirit) · Trực \(info.officer) (tham khảo)")
                    Text("Giờ hoàng đạo: \(VietnameseLunarCalendar.luckyHours(selected).joined(separator: ", "))")
                }.font(.system(size: 12)).foregroundStyle(muted).padding(.top, 8)
            }.font(.system(size: 12, weight: .medium))
        }.padding(18).background(panel, in: RoundedRectangle(cornerRadius: 20))
    }

    private var weekPanel: some View {
        VStack(spacing: 14) {
            navigationHeader(title: "Tuần chứa \(selected.label)", back: { moveDay(-7) }, forward: { moveDay(7) })
            let jd = VietnameseLunarCalendar.jdn(selected)
            let start = jd - (jd % 7 + 7) % 7
            HStack(spacing: 4) {
                ForEach(0..<7, id: \.self) { index in
                    let day = VietnameseLunarCalendar.civilDate(start + index)
                    let l = VietnameseLunarCalendar.solarToLunar(day)
                    Button { selected = day } label: {
                        VStack(spacing: 6) {
                            Text(["T2", "T3", "T4", "T5", "T6", "T7", "CN"][index]).font(.system(size: 9))
                            Text("\(day.day)").font(.system(size: 17, weight: .semibold))
                            Text("\(l?.day ?? 0)/\(l?.month ?? 0)").font(.system(size: 9))
                        }.frame(maxWidth: .infinity).padding(.vertical, 9)
                            .foregroundStyle(selected == day ? Color(hex: theme.background) : ink)
                            .background(selected == day ? accent : Color.clear, in: RoundedRectangle(cornerRadius: 10))
                    }.buttonStyle(.plain)
                }
            }
        }.padding(15).background(panel, in: RoundedRectangle(cornerRadius: 20))
    }

    private var monthPanel: some View {
        VStack(spacing: 12) {
            navigationHeader(title: "Tháng \(selected.month) / \(selected.year)", back: { moveMonth(-1) }, forward: { moveMonth(1) })
            LunarMonthGridView(year: selected.year, month: selected.month, selected: $selected,
                               events: family.events, accent: accent, ink: ink, muted: muted)
        }.padding(15).background(panel, in: RoundedRectangle(cornerRadius: 20))
    }

    private var yearPanel: some View {
        VStack(spacing: 12) {
            navigationHeader(title: "Năm \(selected.year)", back: { moveYear(-1) }, forward: { moveYear(1) })
            if let leap = VietnameseLunarCalendar.leapMonth(in: selected.year) {
                Text("Có tháng \(leap) nhuận âm lịch").font(.caption).foregroundStyle(accent)
            }
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 8) {
                ForEach(1...12, id: \.self) { month in
                    Button { selected = SolarCivilDate(year: selected.year, month: month, day: 1); mode = .month } label: {
                        VStack(spacing: 7) {
                            Text("Tháng \(month)").font(.system(size: 12, weight: .semibold))
                            Text(VietnameseLunarCalendar.solarToLunar(SolarCivilDate(year: selected.year, month: month, day: 1))?.label ?? "")
                                .font(.system(size: 9)).lineLimit(1).foregroundStyle(muted)
                        }.frame(maxWidth: .infinity).padding(10)
                            .background(Color(hex: theme.background), in: RoundedRectangle(cornerRadius: 12))
                    }.buttonStyle(.plain)
                }
            }
        }.padding(15).background(panel, in: RoundedRectangle(cornerRadius: 20))
    }

    private var familyPanel: some View {
        VStack(alignment: .leading, spacing: 13) {
            HStack {
                sectionLabel("NHỮNG NGÀY KHÔNG QUÊN", subtitle: "Giỗ, kỷ niệm và những người thân yêu")
                Spacer()
                LunarHeritageActionButton(assetName: "HeritageNavAdd", accessibilityTitle: "Thêm ngày giỗ") {
                    addingEvent = true
                }
            }
            if family.events.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    Image(LunarHeritageComponents.imageOrFallback("HeritageActionFamily")).resizable().scaledToFit().frame(width: 44, height: 44)
                    Text("Giữ một ngày, nhớ cả một đời.")
                        .font(.system(size: 20, weight: .regular, design: .serif))
                    Text("Thêm ngày giỗ hoặc kỷ niệm âm lịch để được nhắc đúng mỗi năm.")
                        .font(.system(size: 12)).foregroundStyle(muted)
                    Button("Thêm ngày quan trọng") { addingEvent = true }.buttonStyle(.bordered)
                }.frame(maxWidth: .infinity, alignment: .leading).padding(18)
                    .background(panel, in: RoundedRectangle(cornerRadius: 20))
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(upcoming.prefix(5))) { item in
                        Button {
                            editingEvent = family.events.first(where: { $0.id == item.eventID })
                        } label: {
                            HStack(spacing: 12) {
                                Image(LunarHeritageComponents.imageOrFallback(item.kind == .memorial ? "HeritageFestivalGioChap" : "HeritageActionFamily"))
                                    .resizable().scaledToFit().frame(width: 30, height: 30)
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(item.title).font(.system(size: 13, weight: .semibold)).foregroundStyle(ink).lineLimit(1)
                                    Text("Âm \(item.lunar.day)/\(item.lunar.month) · \(item.solar.label)")
                                        .font(.system(size: 11)).foregroundStyle(muted)
                                }
                                Spacer()
                                Text(item.daysRemaining(from: today) == 0 ? "Hôm nay" : "\(item.daysRemaining(from: today)) ngày")
                                    .font(.system(size: 11, weight: .semibold)).foregroundStyle(accent)
                            }.padding(.vertical, 12).padding(.horizontal, 13)
                        }.buttonStyle(.plain)
                        if item.id != upcoming.prefix(5).last?.id { Divider().opacity(0.2) }
                    }
                }.background(panel, in: RoundedRectangle(cornerRadius: 20))
            }
        }
    }

    private var preferencesPanel: some View {
        VStack(alignment: .leading, spacing: 11) {
            sectionLabel("CÁ NHÂN HÓA", subtitle: "Một nét Việt, vừa đủ tinh tế")
            ScrollView(.horizontal) {
                HStack(spacing: 9) {
                    ForEach(LunarTheme.featured) { value in
                        Button {
                            updateAppearance { $0.theme = value }
                        } label: {
                            VStack(alignment: .leading, spacing: 9) {
                                HStack {
                                    Circle().fill(Color(hex: value.accent)).frame(width: 16, height: 16)
                                    Spacer()
                                    if theme == value { Image(systemName: "checkmark.circle.fill").foregroundStyle(accent) }
                                }
                                Text(value.title).font(.system(size: 10, weight: .medium))
                                    .lineLimit(2).foregroundStyle(Color(hex: value.foreground))
                            }
                            .frame(width: 100, height: 74).padding(10)
                            .background(Color(hex: value.background), in: RoundedRectangle(cornerRadius: 13))
                            .overlay(RoundedRectangle(cornerRadius: 13).stroke(theme == value ? accent : .clear, lineWidth: 2))
                        }.buttonStyle(.plain)
                    }
                }
            }.scrollIndicators(.hidden)
            Text("TRANH NỀN TỪ BỘ ASSET VIỆT")
                .font(.system(size: 10, weight: .semibold))
                .tracking(1.0).foregroundStyle(muted)
            ScrollView(.horizontal) {
                HStack(spacing: 10) {
                    ForEach(LunarArtwork.allCases) { art in
                        Button { updateAppearance { $0.artwork = art } } label: {
                            VStack(alignment: .leading, spacing: 6) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 11)
                                        .fill(Color(hex: theme.background))
                                    if let imageName = art.resolvedResource(theme: theme) {
                                        GeometryReader { proxy in
                                            Image(imageName).resizable().scaledToFill()
                                                .frame(width: proxy.size.width, height: proxy.size.height)
                                                .clipped()
                                        }
                                    } else {
                                        Image(systemName: art == .none ? "circle.slash" : "moon.stars")
                                            .foregroundStyle(accent)
                                    }
                                }
                                .frame(width: 111, height: 72)
                                .clipShape(RoundedRectangle(cornerRadius: 11))
                                .overlay(RoundedRectangle(cornerRadius: 11)
                                    .stroke(family.appearance.artwork == art ? accent : accent.opacity(0.16),
                                            lineWidth: family.appearance.artwork == art ? 2 : 1))
                                Text(art.title)
                                    .font(.system(size: 10, weight: family.appearance.artwork == art ? .semibold : .regular))
                                    .foregroundStyle(ink).lineLimit(1)
                            }
                            .frame(width: 111)
                        }.buttonStyle(.plain)
                        .accessibilityLabel("Tranh nền: \(art.title)")
                    }
                }
            }.scrollIndicators(.hidden)

            DisclosureGroup(isExpanded: $showAdvancedAppearance) {
                VStack(alignment: .leading, spacing: 12) {
                    Picker("Mật độ thông tin", selection: Binding(
                        get: { family.appearance.density },
                        set: { value in updateAppearance { $0.density = value } }
                    )) {
                        ForEach(LunarInformationDensity.allCases) { item in Text(item.label).tag(item) }
                    }
                    Toggle("Kiểu số thanh lịch", isOn: appearanceBinding(\.useSerif))
                    Toggle("Hiện Can Chi", isOn: appearanceBinding(\.showCanChi))
                    Toggle("Hiện sự kiện gia đình", isOn: appearanceBinding(\.showFamilyEvents))
                    Toggle("Họa tiết điểm nhấn", isOn: appearanceBinding(\.showOrnament))
                }
                .padding(.top, 8)
            } label: {
                Label("Tùy chỉnh nâng cao", systemImage: "slider.horizontal.3")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(ink)
            }
        }.font(.system(size: 12)).padding(16).background(panel, in: RoundedRectangle(cornerRadius: 20))
    }

    private var remindersPanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("NHẮC NGÀY ÂM", subtitle: "Không để lỡ những ngày quan trọng")
            Toggle("Nhắc mùng 1 và ngày Rằm (08:00)", isOn: appearanceBinding(\.remindMoonDays))
                .font(.system(size: 12))
            if family.notificationsAuthorized {
                Label("Thông báo đã được cấp quyền", systemImage: "checkmark.circle")
                    .font(.system(size: 12)).foregroundStyle(accent)
            } else {
                Button { Task { await family.enableNotifications() } } label: {
                    Label("Bật thông báo gia đình", systemImage: "bell")
                }.buttonStyle(.bordered)
            }
            Button {
                do { exportURL = try LunarICSExporter.saveToTemporaryFile(events: family.events, fromYear: today.year) }
                catch { exportError = error.localizedDescription }
            } label: { Label("Tạo lịch giỗ 10 năm (.ics)", systemImage: "calendar.badge.clock") }
                .font(.system(size: 12))
            if let exportURL { ShareLink(item: exportURL) { Label("Chia sẻ lịch đã xuất", systemImage: "square.and.arrow.up") } }
            Text("Lịch giỗ được tính lại theo từng năm âm. iOS có giới hạn thông báo chờ; ứng dụng làm mới lịch nhắc khi mở lại. Xuất lịch 10 năm để dự phòng.")
                .font(.system(size: 11)).foregroundStyle(muted)
        }.padding(16).background(panel, in: RoundedRectangle(cornerRadius: 20))
    }

    private var culturalPanel: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionLabel("VĂN HÓA VIỆT", subtitle: "Phong tục và ý nghĩa ngày lễ")
            ForEach(Array(LunarCulture.festivals.prefix(showAllFestivals ? LunarCulture.festivals.count : 3))) { festival in
                HStack(alignment: .top, spacing: 12) {
                    LunarHeritageFestivalIllustration(festivalTitle: festival.title, size: 36)
                        .frame(width: 42)
                    DisclosureGroup {
                        Text(festival.description)
                            .font(.system(size: 12))
                            .foregroundStyle(muted)
                            .padding(.top, 6)
                    } label: {
                        VStack(alignment: .leading, spacing: 3) {
                            Text(festival.title)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(ink)
                            Text("\(festival.day)/\(festival.month) âm lịch")
                                .font(.system(size: 11))
                                .foregroundStyle(muted)
                        }
                    }
                }
                .padding(.vertical, 2)
                if festival.id != LunarCulture.festivals.last?.id {
                    Rectangle()
                        .fill(accent.opacity(0.10))
                        .frame(height: 1)
                }
            }
            Button {
                withAnimation(.easeInOut(duration: 0.2)) { showAllFestivals.toggle() }
            } label: {
                HStack {
                    Text(showAllFestivals ? "Thu gọn ngày lễ" : "Xem tất cả \(LunarCulture.festivals.count) ngày lễ")
                    Spacer()
                    Image(systemName: showAllFestivals ? "chevron.up" : "chevron.down")
                }
                .font(.system(size: 12, weight: .medium))
            }
            .buttonStyle(.plain)
            .foregroundStyle(accent)
        }
        .padding(18)
        .background(panel, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private func sectionLabel(_ overline: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            LunarHeritageSectionTitle(title: overline, theme: theme)
            Text(subtitle)
                .font(.system(size: 17, weight: .semibold, design: .serif))
                .foregroundStyle(ink)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    private func navigationHeader(title: String, back: @escaping () -> Void, forward: @escaping () -> Void) -> some View {
        HStack {
            LunarHeritageActionButton(assetName: "HeritageNavPrev", accessibilityTitle: "Ngày trước", action: back)
            Spacer(minLength: 5)
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            Spacer(minLength: 5)
            LunarHeritageActionButton(assetName: "HeritageNavNext", accessibilityTitle: "Ngày sau", action: forward)
        }
    }
    private func appearanceBinding(_ keyPath: WritableKeyPath<LunarAppearance, Bool>) -> Binding<Bool> {
        Binding(get: { family.appearance[keyPath: keyPath] }, set: { value in updateAppearance { $0[keyPath: keyPath] = value } })
    }
    private func updateAppearance(_ mutate: (inout LunarAppearance) -> Void) {
        var settings = family.appearance
        mutate(&settings)
        family.setAppearance(settings)
    }
    private func moveDay(_ delta: Int) {
        let next = VietnameseLunarCalendar.civilDate(VietnameseLunarCalendar.jdn(selected) + delta)
        if VietnameseLunarCalendar.isValid(next) { selected = next }
    }
    private func moveMonth(_ delta: Int) {
        let value = selected.year * 12 + selected.month - 1 + delta
        let next = SolarCivilDate(year: value / 12, month: value % 12 + 1, day: 1)
        if VietnameseLunarCalendar.isValid(next) { selected = next }
    }
    private func moveYear(_ delta: Int) {
        let next = SolarCivilDate(year: selected.year + delta, month: selected.month, day: min(selected.day, 28))
        if VietnameseLunarCalendar.isValid(next) { selected = next }
    }
}

private struct LunarMonthGridView: View {
    let year: Int
    let month: Int
    @Binding var selected: SolarCivilDate
    let events: [LunarFamilyEvent]
    let accent: Color
    let ink: Color
    let muted: Color

    private var marks: Set<SolarCivilDate> {
        let first = SolarCivilDate(year: year, month: month, day: 1)
        return Set(LunarEventScheduler.upcoming(events: events, from: first, count: 200, years: 2)
            .map(\.solar).filter { $0.year == year && $0.month == month })
    }
    var body: some View {
        let base = VietnameseLunarCalendar.jdn(SolarCivilDate(year: year, month: month, day: 1))
        let offset = (base % 7 + 7) % 7
        let marked = marks
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 3), count: 7), spacing: 5) {
            ForEach(["T2", "T3", "T4", "T5", "T6", "T7", "CN"], id: \.self) { day in
                Text(day).font(.system(size: 9, weight: .medium)).foregroundStyle(muted)
            }
            ForEach(0..<42, id: \.self) { index in
                let cell = VietnameseLunarCalendar.civilDate(base - offset + index)
                let lunar = VietnameseLunarCalendar.solarToLunar(cell)
                Button { if VietnameseLunarCalendar.isValid(cell) { selected = cell } } label: {
                    VStack(spacing: 3) {
                        Text("\(cell.day)").font(.system(size: 12, weight: cell == selected ? .bold : .medium))
                            .foregroundStyle(cell == selected ? accent : cell.month == month ? ink : muted.opacity(0.4))
                        Text(lunar?.day == 1 ? "1/\(lunar?.month ?? 0)" : "\(lunar?.day ?? 0)")
                            .font(.system(size: 9))
                            .foregroundStyle(lunar?.day == 1 || lunar?.day == 15 ? accent : muted)
                        Circle().fill(marked.contains(cell) ? accent : .clear).frame(width: 3, height: 3)
                    }
                    .frame(maxWidth: .infinity).padding(.vertical, 5)
                    .background(cell == selected ? accent.opacity(0.12) : Color.clear, in: RoundedRectangle(cornerRadius: 8))
                }.buttonStyle(.plain)
            }
        }
    }
}
