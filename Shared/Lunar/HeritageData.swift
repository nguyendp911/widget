import Foundation

struct HeritageTask: Identifiable, Codable, Equatable {
    var id = UUID()
    var title: String
    var done = false
    var assignee = ""
    var cost: Double = 0
}

struct HeritagePerson: Identifiable, Codable, Equatable {
    var id = UUID()
    var name: String
    var relationship: String
    var parentID: UUID? = nil
    var note = ""
}

struct HeritageMemory: Identifiable, Codable, Equatable {
    var id = UUID()
    var title: String
    var text: String
    var date = Date()
    var image: Data? = nil
}

struct HeritageArchive: Codable {
    var version = 1
    var events: [LunarFamilyEvent]
    var tasks: [String: [HeritageTask]]
    var people: [HeritagePerson]
    var memories: [HeritageMemory]
}

enum HeritageSearch {
    static func normalized(_ text: String) -> String {
        text.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: Locale(identifier: "vi_VN"))
            .replacingOccurrences(of: "đ", with: "d")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Accepts a full lunar expression (e.g. Rằm tháng 7 năm 2028)
    /// or a civil date dd/mm/yyyy. Missing years use the supplied current year.
    static func date(_ text: String, year: Int) -> SolarCivilDate? {
        let q = normalized(text)
        let nums = q.split(whereSeparator: { !$0.isNumber }).compactMap { Int($0) }
        let isLunar = q.contains("ram") || q.contains("mung") || q.contains("am") || q.contains("nhuan")
        if isLunar {
            let day: Int
            let month: Int
            let y: Int
            if q.contains("ram") {
                guard let m = nums.first else { return nil }
                day = 15; month = m; y = nums.count > 1 ? nums[1] : year
            } else {
                guard nums.count >= 2 else { return nil }
                day = nums[0]; month = nums[1]; y = nums.count > 2 ? nums[2] : year
            }
            guard (1...30).contains(day), (1...12).contains(month), (1900...2100).contains(y) else { return nil }
            return VietnameseLunarCalendar.lunarToSolar(
                VietnameseLunarDate(day: day, month: month, year: y, isLeapMonth: q.contains("nhuan")))
        }
        guard nums.count == 3 else { return nil }
        let result = SolarCivilDate(year: nums[2], month: nums[1], day: nums[0])
        return VietnameseLunarCalendar.isValid(result) ? result : nil
    }
}

enum HeritageRitual {
    static func preparation(for kind: FamilyEventKind) -> [HeritageTask] {
        let titles: [String]
        switch kind {
        case .memorial: titles = ["Thống nhất thời gian với gia đình", "Dọn dẹp bàn thờ theo phong tục gia đình", "Chuẩn bị hoa, lễ vật hoặc bữa cơm", "Nhắc người thân tham dự", "Kiểm tra chi phí và việc còn lại"]
        case .birthday: titles = ["Nhắc người thân", "Chuẩn bị lời chúc hoặc quà", "Sắp xếp thời gian sum họp"]
        case .anniversary: titles = ["Thống nhất thời gian", "Chuẩn bị lời chúc", "Lưu lại kỷ niệm"]
        case .other: titles = ["Xác nhận lịch", "Chuẩn bị những việc cần thiết", "Thông báo người tham dự"]
        }
        return titles.map { HeritageTask(title: $0) }
    }
}
