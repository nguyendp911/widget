import Foundation

struct VietnameseLunarFestival: Identifiable, Codable, Equatable {
    let title: String
    let description: String
    let day: Int
    let month: Int
    var id: String { "\(day)-\(month)-\(title)" }
}

enum LunarCulture {
    static let festivals: [VietnameseLunarFestival] = [
        .init(title: "Tết Nguyên Đán", description: "Ngày đầu năm âm lịch, sum họp, chúc Tết và tưởng nhớ tổ tiên.", day: 1, month: 1),
        .init(title: "Tết Nguyên Tiêu", description: "Rằm tháng Giêng, dịp cầu bình an và đoàn viên.", day: 15, month: 1),
        .init(title: "Tết Hàn Thực", description: "Mùng 3 tháng Ba, nhiều gia đình làm bánh trôi, bánh chay.", day: 3, month: 3),
        .init(title: "Giỗ Tổ Hùng Vương", description: "Mùng 10 tháng Ba, tưởng nhớ công dựng nước của các Vua Hùng.", day: 10, month: 3),
        .init(title: "Lễ Phật Đản (theo một truyền thống)", description: "Nhiều cộng đồng Phật giáo tại Việt Nam kỷ niệm vào rằm tháng Tư.", day: 15, month: 4),
        .init(title: "Tết Đoan Ngọ", description: "Mùng 5 tháng Năm, còn gọi là Tết diệt sâu bọ.", day: 5, month: 5),
        .init(title: "Lễ Vu Lan", description: "Rằm tháng Bảy, dịp tưởng nhớ và báo hiếu cha mẹ, tổ tiên.", day: 15, month: 7),
        .init(title: "Tết Trung Thu", description: "Rằm tháng Tám, lễ hội trăng, gia đình và trẻ em.", day: 15, month: 8),
        .init(title: "Tết Trùng Cửu", description: "Mùng 9 tháng Chín âm lịch, ngày lễ mang ý nghĩa kính lão theo một số phong tục.", day: 9, month: 9),
        .init(title: "Tết Hạ Nguyên", description: "Rằm tháng Mười âm lịch, trong một số truyền thống gắn với mùa thu hoạch và tri ân.", day: 15, month: 10),
        .init(title: "Tết Ông Công Ông Táo", description: "Ngày 23 tháng Chạp, tục tiễn Táo quân về trời.", day: 23, month: 12)
    ]

    static func on(_ lunar: VietnameseLunarDate) -> [VietnameseLunarFestival] {
        guard !lunar.isLeapMonth else { return [] }
        return festivals.filter { $0.day == lunar.day && $0.month == lunar.month }
    }

    static func observances(on lunar: VietnameseLunarDate) -> [String] {
        var result = [String]()
        if lunar.day == 1 { result.append("Mùng 1 âm lịch") }
        if lunar.day == 15 { result.append("Ngày Rằm") }
        return result + on(lunar).map(\.title)
    }

    static func context(on solar: SolarCivilDate) -> String {
        guard let lunar = VietnameseLunarCalendar.solarToLunar(solar) else { return "Ngoài phạm vi lịch" }
        let labels = observances(on: lunar)
        if !labels.isEmpty { return labels.joined(separator: " • ") }
        let info = VietnameseLunarCalendar.traditionalDayInfo(solar)
        return "\(info.spirit) • Trực \(info.officer)"
    }
}
