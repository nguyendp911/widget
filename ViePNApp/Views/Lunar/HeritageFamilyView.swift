import SwiftUI
import UIKit
import PhotosUI
import UniformTypeIdentifiers
import EventKit

struct HeritageFamilyView: View {
    @EnvironmentObject private var family: LunarFamilyStore
    @EnvironmentObject private var heritage: HeritageStore
    @State private var horizon = 90
    @State private var addEvent = false
    @State private var editEvent: LunarFamilyEvent?
    @State private var checklist: LunarEventOccurrence?
    @State private var showPeople = false
    @State private var showMemory = false
    @State private var showImport = false
    @State private var backupURL: URL?
    @State private var message: String?
    private var today: SolarCivilDate { SolarCivilDate(date: Date()) ?? SolarCivilDate(year: 2026, month: 11, day: 24) }
    private var events: [LunarEventOccurrence] {
        LunarEventScheduler.upcoming(events: family.events, from: today, count: 500, years: 2)
            .filter { $0.daysRemaining(from: today) <= horizon }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HeritageBanner(title: "Ngày nhớ gia đình", subtitle: "Giữ trọn những ngày không quên", image: "ViePNGioNhaLarge")
                if let error = heritage.storageError { Text(error).font(.caption).foregroundStyle(.red) }
                HStack {
                    Text("Sự kiện sắp tới").font(.headline)
                    Spacer()
                    Button { addEvent = true } label: { Label("Thêm", systemImage: "plus.circle.fill") }
                }
                Picker("Khoảng thời gian", selection: $horizon) {
                    ForEach([7,30,90,365], id: \.self) { Text("\($0) ngày").tag($0) }
                }.pickerStyle(.segmented)
                if events.isEmpty { Text("Không có sự kiện trong khoảng này.").padding(16).frame(maxWidth: .infinity, alignment: .leading).heritageFrame() }
                ForEach(events) { item in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image("TNVIncense").resizable().scaledToFit().frame(width: 43, height: 40)
                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.title).font(.system(size: 17, weight: .semibold, design: .serif))
                                Text("Âm \(item.lunar.label) · Dương \(item.solar.label)").font(.caption).foregroundStyle(HeritagePalette.soft)
                            }
                            Spacer(minLength: 0)
                            Text(item.daysRemaining(from: today) == 0 ? "Hôm nay" : "Còn \(item.daysRemaining(from: today)) ngày")
                                .font(.caption.weight(.semibold)).foregroundStyle(HeritagePalette.red)
                        }
                        HStack {
                            Button("Chuẩn bị") { checklist = item }
                            Spacer()
                            Button("Chỉnh sửa") { editEvent = family.events.first { $0.id == item.eventID } }
                        }.font(.subheadline)
                    }.padding(13).heritageFrame()
                }
                HeritagePlaque(title: "Tất cả ngày nhớ")
                ForEach(family.events) { item in
                    Button { editEvent = item } label: {
                        HStack {
                            Text(item.title)
                            Spacer()
                            Text("\(item.lunarDay)/\(item.lunarMonth) ÂL").foregroundStyle(HeritagePalette.soft)
                            Image(systemName: "chevron.right")
                        }.padding(12).heritageFrame()
                    }.buttonStyle(.plain)
                }
                HStack {
                    Button { showPeople = true } label: { shortcut("Gia phả", image: "TNVLotus") }
                    Button { showMemory = true } label: { shortcut("Kỷ niệm", image: "TNVBlossom") }
                }.buttonStyle(.plain)
                VStack(alignment: .leading, spacing: 12) {
                    HeritagePlaque(title: "Sao lưu và chia sẻ", jade: true)
                    Button("Tạo bản sao lưu gia đình (.json)") { makeBackup() }
                    if let backupURL { ShareLink(item: backupURL) { Label("Chia sẻ hoặc lưu vào iCloud Drive", systemImage: "square.and.arrow.up") } }
                    Button("Nhập bản sao lưu từ Tệp") { showImport = true }
                    Button("Thêm ngày nhớ 12 tháng tới vào Apple Calendar") {
                        Task { await exportCalendar() }
                    }
                    Text("Chia sẻ bằng tệp sao lưu; chưa đồng bộ nhiều thiết bị theo thời gian thực.").font(.caption).foregroundStyle(HeritagePalette.soft)
                }.frame(maxWidth: .infinity, alignment: .leading).padding(16).heritageFrame()
            }.padding(16)
        }
        .background(HeritagePalette.paper.ignoresSafeArea())
        .foregroundStyle(HeritagePalette.ink)
        .navigationTitle("Gia đình")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $addEvent) { NavigationStack { LunarEventEditorView() } }
        .sheet(item: $editEvent) { event in NavigationStack { LunarEventEditorView(editing: event) } }
        .sheet(item: $checklist) { item in HeritageChecklistView(event: item) }
        .sheet(isPresented: $showPeople) { HeritagePeopleView() }
        .sheet(isPresented: $showMemory) { HeritageMemoryView() }
        .fileImporter(isPresented: $showImport, allowedContentTypes: [.json]) { result in
            do {
                let url = try result.get()
                let scoped = url.startAccessingSecurityScopedResource()
                defer { if scoped { url.stopAccessingSecurityScopedResource() } }
                let bytes = try Data(contentsOf: url)
                guard bytes.count <= 50_000_000 else { message = "Tệp sao lưu vượt quá 50 MB."; return }
                let a = try JSONDecoder().decode(HeritageArchive.self, from: bytes)
                guard a.version == 1, a.events.allSatisfy(\.isValid) else { message = "Bản sao lưu không hợp lệ."; return }
                var added = 0
                for event in a.events where !family.events.contains(where: { $0.id == event.id }) {
                    if family.save(event) { added += 1 }
                }
                heritage.merge(a)
                message = "Đã nhập \(added) sự kiện mới và gộp sổ gia đình. Dữ liệu hiện tại không bị ghi đè."
            } catch { message = error.localizedDescription }
        }
        .alert("Thiên Niên Việt", isPresented: Binding(get: { message != nil }, set: { if !$0 { message = nil } })) {
            Button("Đóng") { message = nil }
        } message: { Text(message ?? "") }
    }

    private func shortcut(_ title: String, image: String) -> some View {
        VStack(spacing: 7) {
            Image(image).resizable().scaledToFit().frame(height: 65)
            Text(title).font(.system(size: 17, weight: .semibold, design: .serif))
        }.frame(maxWidth: .infinity).padding(12).heritageFrame()
    }

    private func makeBackup() {
        do {
            let url = FileManager.default.temporaryDirectory.appendingPathComponent("ThienNienViet-\(UUID().uuidString).json")
            try JSONEncoder().encode(heritage.archive(events: family.events)).write(to: url, options: [.atomic, .completeFileProtection])
            backupURL = url
        } catch { message = error.localizedDescription }
    }

    @MainActor private func exportCalendar() async {
        do {
            let store = EKEventStore()
            guard try await store.requestFullAccessToEvents(), let calendar = store.defaultCalendarForNewEvents else {
                message = "Cần cho phép truy cập Lịch trong Cài đặt."; return
            }
            let end = VietnameseLunarCalendar.civilDate(VietnameseLunarCalendar.jdn(today) + 365)
            let items = LunarEventScheduler.upcoming(events: family.events, from: today, count: 1000, years: 2).filter { $0.solar <= end }
            var added = 0
            for item in items {
                guard let start = item.solar.asDate(hour: 0), let stop = VietnameseLunarCalendar.civilDate(VietnameseLunarCalendar.jdn(item.solar)+1).asDate(hour: 0) else { continue }
                let marker = "TNV:\(item.id)"
                let existing = store.events(matching: store.predicateForEvents(withStart: start, end: stop, calendars: [calendar]))
                guard !existing.contains(where: { $0.notes?.contains(marker) == true }) else { continue }
                let event = EKEvent(eventStore: store)
                event.title = item.title
                event.calendar = calendar
                event.startDate = start
                event.endDate = stop
                event.isAllDay = true
                event.timeZone = VietnameseLunarCalendar.vietnamTimeZone
                event.notes = "Âm lịch \(item.lunar.label)\n\(marker)"
                try store.save(event, span: .thisEvent, commit: false)
                added += 1
            }
            try store.commit()
            message = "Đã thêm \(added) ngày nhớ vào Apple Calendar. Các ngày này là ngày đã quy đổi, không phải lặp theo dương lịch."
        } catch { message = error.localizedDescription }
    }
}

struct HeritageChecklistView: View {
    @EnvironmentObject private var heritage: HeritageStore
    @Environment(\.dismiss) private var dismiss
    let event: LunarEventOccurrence
    @State private var items: [HeritageTask] = []
    @State private var title = ""
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    ProgressView(value: Double(items.filter(\.done).count), total: Double(max(1, items.count)))
                    Text("Dự trù: \(items.reduce(0) { $0 + $1.cost }.formatted(.currency(code: "VND")))")
                }
                Section("Việc cần chuẩn bị") {
                    ForEach($items) { $item in
                        VStack(alignment: .leading) {
                            Toggle(item.title, isOn: $item.done)
                            TextField("Người phụ trách", text: $item.assignee)
                            TextField("Chi phí dự trù", value: $item.cost, format: .number).keyboardType(.decimalPad)
                        }
                    }.onDelete { items.remove(atOffsets: $0) }
                    HStack {
                        TextField("Thêm việc", text: $title)
                        Button("Thêm") { items.append(HeritageTask(title: title)); title = "" }.disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                }
                Text("Danh sách gợi ý, có thể điều chỉnh theo tập quán của gia đình.").font(.caption)
            }
            .navigationTitle(event.title)
            .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Lưu") { heritage.tasks[event.id] = items; dismiss() } } }
            .onAppear { items = heritage.tasks[event.id] ?? HeritageRitual.preparation(for: event.kind) }
        }
    }
}

struct HeritagePeopleView: View {
    @EnvironmentObject private var heritage: HeritageStore
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var relation = ""
    @State private var parent: UUID?
    var body: some View {
        NavigationStack {
            Form {
                Section("Thành viên") {
                    ForEach(heritage.people) { person in
                        VStack(alignment: .leading) {
                            Text(person.name).font(.headline)
                            Text(person.relationship + (heritage.people.first(where: { $0.id == person.parentID }).map { " · Con của " + $0.name } ?? "")).font(.caption)
                        }
                    }.onDelete { offsets in
                        let removed = Set(offsets.map { heritage.people[$0].id })
                        heritage.people.remove(atOffsets: offsets)
                        for i in heritage.people.indices where heritage.people[i].parentID.map({ removed.contains($0) }) == true { heritage.people[i].parentID = nil }
                    }
                }
                Section("Thêm người thân") {
                    TextField("Họ tên", text: $name)
                    TextField("Vai vế (ông, bà, cha…)", text: $relation)
                    Picker("Cha/mẹ trong gia phả", selection: $parent) {
                        Text("Chưa xác định").tag(nil as UUID?)
                        ForEach(heritage.people) { person in Text(person.name).tag(Optional(person.id)) }
                    }
                    Button("Lưu thành viên") {
                        heritage.people.append(HeritagePerson(name: name, relationship: relation, parentID: parent))
                        name = ""; relation = ""; parent = nil
                    }.disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }.navigationTitle("Gia phả mini")
                .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Đóng") { dismiss() } } }
        }
    }
}

struct HeritageMemoryView: View {
    @EnvironmentObject private var heritage: HeritageStore
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var story = ""
    @State private var photo: PhotosPickerItem?
    @State private var photoData: Data?
    var body: some View {
        NavigationStack {
            Form {
                Section("Kỷ niệm đã lưu") {
                    ForEach(heritage.memories) { item in
                        VStack(alignment: .leading, spacing: 6) {
                            if let data = item.image, let image = UIImage(data: data) {
                                Image(uiImage: image).resizable().scaledToFit().frame(maxHeight: 200)
                            }
                            Text(item.title).font(.headline)
                            Text(item.date.formatted(date: .abbreviated, time: .omitted)).font(.caption)
                            Text(item.text)
                        }
                    }.onDelete { heritage.memories.remove(atOffsets: $0) }
                }
                Section("Viết kỷ niệm") {
                    TextField("Tiêu đề", text: $title)
                    TextField("Câu chuyện", text: $story, axis: .vertical).lineLimit(3...8)
                    PhotosPicker(selection: $photo, matching: .images) { Label("Chọn ảnh", systemImage: "photo") }
                    if let photoData, let image = UIImage(data: photoData) { Image(uiImage: image).resizable().scaledToFit().frame(maxHeight: 130) }
                    Button("Lưu kỷ niệm") {
                        heritage.memories.append(HeritageMemory(title: title, text: story, image: photoData))
                        title = ""; story = ""; photo = nil; photoData = nil
                    }.disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }.navigationTitle("Nhật ký gia đình")
                .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Đóng") { dismiss() } } }
                .onChange(of: photo) { _, value in
                    Task {
                        guard let data = try? await value?.loadTransferable(type: Data.self), let image = UIImage(data: data) else { photoData = nil; return }
                        let ratio = min(1, 1200 / max(image.size.width, image.size.height))
                        let size = CGSize(width: image.size.width * ratio, height: image.size.height * ratio)
                        photoData = UIGraphicsImageRenderer(size: size).jpegData(withCompressionQuality: 0.8) { _ in image.draw(in: CGRect(origin: .zero, size: size)) }
                    }
                }
        }
    }
}
