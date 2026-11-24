import SwiftUI

/// Standalone iPhone home screen: one comprehensive almanac rather than tabs
/// or a miniature Home Screen widget.
struct ThienNienHomeView: View {
    @EnvironmentObject private var family: LunarFamilyStore
    @State private var selected = SolarCivilDate(date: .now)
        ?? SolarCivilDate(year: 2026, month: 11, day: 24)
    @State private var showingEventEditor = false
    @State private var editingEvent: LunarFamilyEvent?
    @State private var detail: ThienNienSection?
    @State private var showingSettings = false
    @State private var exportFile: URL?
    @State private var notice: String?

    private let wine = Color(hex: "#8D2F25")
    private let ink = Color(hex: "#4D332A")
    private let soft = Color(hex: "#776453")
    private let gold = Color(hex: "#C59C55")

    private var upcoming: [LunarEventOccurrence] {
        LunarEventScheduler.upcoming(events: family.events, from: selected, count: 6)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header
                dateNavigator
                ThienNienLunarBoard(
                    civil: selected, appearance: family.appearance, upcoming: upcoming,
                    onOpen: { detail = $0 },
                    onSelect: { selected = $0 }
                )
                familySection
                quickActions
                Text("Thiên Niên Việt · Giữ ngày Việt – Trọn tình thân")
                    .font(.system(size: 12, weight: .medium, design: .serif))
                    .foregroundStyle(soft)
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 16)
            }
            .padding(.horizontal, 16)
            .padding(.top, 15)
        }
        .background(Color(hex: "#F1E5CE").ignoresSafeArea())
        .foregroundStyle(ink)
        .navigationTitle("Thiên Niên Việt")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { showingSettings = true } label: {
                    Image(systemName: "gearshape")
                        .foregroundStyle(wine)
                }
                .accessibilityLabel("Cài đặt lịch âm")
            }
        }
        .fullScreenCover(item: $detail) { section in
            ThienNienDetailSheet(section: section, civil: selected, familyEvents: family.events)
        }
        .fullScreenCover(isPresented: $showingEventEditor) {
            NavigationStack { LunarEventEditorView() }
        }
        .fullScreenCover(item: $editingEvent) { event in
            NavigationStack { LunarEventEditorView(editing: event) }
        }
        .fullScreenCover(isPresented: $showingSettings) {
            NavigationStack { ThienNienSettingsView() }
        }
        .alert("Thiên Niên Việt", isPresented: Binding(
            get: { notice != nil },
            set: { if !$0 { notice = nil } }
        )) {
            Button("Đóng") { notice = nil }
        } message: { Text(notice ?? "") }
        .task { await family.syncNotifications() }
    }

    private var header: some View {
        HeritageBanner(title: "Thiên Niên Việt", subtitle: "Lịch âm & Văn hóa Việt")
    }

    private var dateNavigator: some View {
        HStack(spacing: 13) {
            Button { moveDay(-1) } label: {
                Image(systemName: "chevron.left")
                    .frame(width: 33, height: 36)
            }
            DatePicker(
                "Ngày đang xem",
                selection: Binding(
                    get: { selected.asDate(hour: 12) ?? Date() },
                    set: { if let day = SolarCivilDate(date: $0) { selected = day } }
                ),
                displayedComponents: .date
            )
            .environment(\.timeZone, VietnameseLunarCalendar.vietnamTimeZone)
            .datePickerStyle(.compact)
            .labelsHidden()
            .frame(maxWidth: .infinity)
            Button { moveDay(1) } label: {
                Image(systemName: "chevron.right")
                    .frame(width: 33, height: 36)
            }
            Button {
                selected = SolarCivilDate(date: Date()) ?? selected
            } label: {
                Text("Hôm nay")
                    .font(.system(size: 12, weight: .semibold))
                    .padding(.horizontal, 10)
                    .frame(height: 36)
            }
        }
        .foregroundStyle(wine)
        .padding(9)
        .background(Color(hex: "#FFFAED"),
                    in: RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16)
            .stroke(gold.opacity(0.35), lineWidth: 1))
    }

    private var familySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("GIA ĐÌNH · NHỮNG NGÀY KHÔNG QUÊN")
                    .font(.system(size: 13, weight: .semibold, design: .serif))
                    .foregroundStyle(wine)
                Spacer(minLength: 0)
                Button {
                    showingEventEditor = true
                } label: {
                    Label("Thêm", systemImage: "plus")
                        .font(.system(size: 12, weight: .semibold))
                }
            }
            if upcoming.isEmpty {
                HStack(spacing: 12) {
                    Image("ViePNIconMemorial")
                        .resizable().scaledToFit().frame(width: 42, height: 42)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Chưa có ngày giỗ nào")
                            .font(.system(size: 15, weight: .semibold, design: .serif))
                        Text("Thêm ngày âm để tự nhắc lại đúng mỗi năm.")
                            .font(.system(size: 12))
                            .foregroundStyle(soft)
                    }
                }
            } else {
                ForEach(upcoming.prefix(4)) { item in
                    HStack(spacing: 10) {
                        Image("ViePNIconMemorial")
                            .resizable().scaledToFit().frame(width: 34, height: 34)
                        VStack(alignment: .leading, spacing: 3) {
                            Text(item.title)
                                .font(.system(size: 15, weight: .semibold, design: .serif))
                            Text("Âm \(item.lunar.label) · Dương \(item.solar.label)")
                                .font(.system(size: 11)).foregroundStyle(soft)
                        }
                        Spacer()
                        Text(item.daysRemaining(from: selected) == 0
                             ? "Hôm nay" : "Còn \(item.daysRemaining(from: selected)) ngày")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(wine)
                    }
                    .padding(.vertical, 4)
                }
            }
            Button {
                detail = .memorials
            } label: {
                HStack {
                    Text("Xem tất cả ngày giỗ")
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .font(.system(size: 12, weight: .medium))
            }
        }
        .padding(16)
        .background(Color(hex: "#FFFAED"),
                    in: RoundedRectangle(cornerRadius: 18))
        .overlay(RoundedRectangle(cornerRadius: 18)
            .stroke(gold.opacity(0.45), lineWidth: 1))
    }

    private var quickActions: some View {
        VStack(alignment: .leading, spacing: 11) {
            Text("TIỆN ÍCH LỊCH ÂM")
                .font(.system(size: 13, weight: .semibold, design: .serif))
                .foregroundStyle(wine)
            HStack(spacing: 10) {
                action("Thêm ngày giỗ", icon: "plus.circle") {
                    showingEventEditor = true
                }
                action("Bật nhắc việc", icon: "bell.badge") {
                    Task {
                        await family.enableNotifications()
                        if let error = family.errorMessage {
                            notice = error
                        } else {
                            notice = family.notificationsAuthorized
                                ? "Đã bật quyền thông báo cho ngày giỗ và lịch âm."
                                : "Hãy cho phép thông báo trong Cài đặt iPhone."
                        }
                    }
                }
            }
            HStack(spacing: 10) {
                action("Ngày lễ Việt", icon: "calendar") { detail = .observances }
                action("Xuất lịch 10 năm", icon: "square.and.arrow.up") {
                    do {
                        exportFile = try LunarICSExporter.saveToTemporaryFile(
                            events: family.events, fromYear: selected.year
                        )
                    } catch {
                        notice = "Không thể tạo lịch: \(error.localizedDescription)"
                    }
                }
            }
            if let exportFile {
                ShareLink(item: exportFile) {
                    Label("Chia sẻ tệp lịch giỗ 10 năm (.ics)", systemImage: "square.and.arrow.up")
                        .font(.system(size: 13, weight: .semibold))
                }
            }
        }
    }

    private func action(_ title: String, icon: String,
                        action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: icon)
                .font(.system(size: 12, weight: .semibold, design: .serif))
                .frame(maxWidth: .infinity, minHeight: 47)
                .background(Color(hex: "#FFFAED"),
                            in: RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12)
                    .stroke(gold.opacity(0.43), lineWidth: 1))
        }
    }

    private func moveDay(_ offset: Int) {
        let jdn = VietnameseLunarCalendar.jdn(selected)
        let next = VietnameseLunarCalendar.civilDate(jdn + offset)
        if VietnameseLunarCalendar.isValid(next) { selected = next }
    }
}
