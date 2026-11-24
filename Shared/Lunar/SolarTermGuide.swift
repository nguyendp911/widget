import Foundation

/// Cultural descriptions are distinct from calculated astronomical dates.
/// Seasonal names describe traditional northern East Asian conditions, not a
/// weather forecast for every region of Viet Nam.
struct SolarTermGuide: Identifiable {
    let name: String
    let season: String
    let usualDate: String
    let meaning: String
    let nature: String
    let culture: String
    var id: String { name }
    var longitude: Int { (VietnameseLunarCalendar.terms.firstIndex(of: name) ?? 0) * 15 }
    var symbol: String {
        switch season {
        case "Xuân": return "leaf"
        case "Hạ": return "sun.max"
        case "Thu": return "wind"
        default: return "snowflake"
        }
    }

    static let all: [Self] = [
        .init(name: "Lập xuân", season: "Xuân", usualDate: "3–5/2", meaning: "Bắt đầu mùa xuân theo cách phân mùa của lịch truyền thống.", nature: "Nhiệt độ ở nhiều nơi thuộc Bắc bán cầu dần tăng; cây cối có thể bắt đầu đâm chồi.", culture: "Gợi nhớ việc chuẩn bị vụ xuân, chăm vườn và đón một chu kỳ mới. Không nhất thiết trùng Tết Nguyên đán."),
        .init(name: "Vũ thủy", season: "Xuân", usualDate: "18–20/2", meaning: "Mưa nước, thời kỳ mùa xuân dần ẩm hơn theo cách gọi cổ.", nature: "Ở miền Bắc Việt Nam có thể gặp mưa phùn, độ ẩm cao; miền Nam có thể vẫn trong mùa khô.", culture: "Gợi nhắc theo dõi nguồn nước, độ ẩm đất và lịch gieo trồng địa phương."),
        .init(name: "Kinh trập", season: "Xuân", usualDate: "5–7/3", meaning: "Côn trùng thức dậy sau thời kỳ ẩn náu trong mùa lạnh.", nature: "Trời ấm dần, nhiều sinh vật hoạt động trở lại; có nơi bắt đầu xuất hiện dông xuân.", culture: "Trong lịch nông nghiệp, đây là dấu mốc quan sát cây trồng và sâu bệnh."),
        .init(name: "Xuân phân", season: "Xuân", usualDate: "20–21/3", meaning: "Mặt Trời đi qua điểm xuân phân, kinh độ hoàng đạo 0°.", nature: "Ngày và đêm gần bằng nhau, không hoàn toàn bằng nhau do khúc xạ khí quyển và cách xác định bình minh.", culture: "Mốc thiên văn quan trọng, thể hiện sự chuyển tiếp giữa nửa năm lạnh và ấm ở Bắc bán cầu."),
        .init(name: "Thanh minh", season: "Xuân", usualDate: "4–6/4", meaning: "Trong sáng, gợi hình ảnh tiết trời quang đãng của mùa xuân.", nature: "Cây cối phát triển; điều kiện thời tiết thay đổi tùy vùng.", culture: "Ở Việt Nam, nhiều gia đình tảo mộ, sửa sang phần mộ và tưởng nhớ tổ tiên trong dịp Thanh minh. Ngày thực hiện tùy tập quán."),
        .init(name: "Cốc vũ", season: "Xuân", usualDate: "19–21/4", meaning: "Mưa nuôi dưỡng ngũ cốc và cây trồng.", nature: "Giai đoạn chuyển dần sang mùa nóng; mưa có thể tăng ở một số khu vực.", culture: "Gợi nhắc chăm sóc ruộng vườn và theo dõi lượng nước theo mùa vụ."),
        .init(name: "Lập hạ", season: "Hạ", usualDate: "5–7/5", meaning: "Bắt đầu mùa hạ theo lịch tiết khí.", nature: "Nhiều vùng nóng hơn; tại Việt Nam thời điểm mưa và nóng khác nhau giữa các miền.", culture: "Mốc tham khảo trong việc sắp xếp sinh hoạt và công việc ngoài trời."),
        .init(name: "Tiểu mãn", season: "Hạ", usualDate: "20–22/5", meaning: "Hạt ngũ cốc bắt đầu đầy nhưng chưa chín hoàn toàn.", nature: "Cây trồng ở vùng ôn đới có thể bước vào thời kỳ tích lũy hạt.", culture: "Tên gọi phản ánh kinh nghiệm theo dõi sự phát triển của cây lương thực."),
        .init(name: "Mang chủng", season: "Hạ", usualDate: "5–7/6", meaning: "Liên quan đến cây có râu hạt và thời kỳ gieo trồng, thu hoạch.", nature: "Thời tiết nóng, nhiều nơi có mưa theo mùa.", culture: "Tượng trưng cho thời vụ bận rộn; lịch gieo cấy thực tế cần căn cứ giống và khí hậu địa phương."),
        .init(name: "Hạ chí", season: "Hạ", usualDate: "20–22/6", meaning: "Mặt Trời đạt kinh độ 90°, mốc hạ chí.", nature: "Bắc bán cầu có thời gian ban ngày dài nhất hoặc gần dài nhất trong năm.", culture: "Dấu mốc thiên văn dùng để nhận biết chu kỳ năm, không nhất thiết là ngày nóng nhất."),
        .init(name: "Tiểu thử", season: "Hạ", usualDate: "6–8/7", meaning: "Nóng nhẹ theo tên gọi truyền thống.", nature: "Giai đoạn nóng mùa hạ có thể kéo dài; mức nóng tùy vùng.", culture: "Gợi nhắc bố trí thời gian lao động ngoài trời phù hợp điều kiện thực tế."),
        .init(name: "Đại thử", season: "Hạ", usualDate: "22–24/7", meaning: "Nóng lớn, tên gọi của giai đoạn giữa mùa hạ.", nature: "Nhiều vùng Bắc bán cầu có nền nhiệt cao, nhưng không bảo đảm là thời kỳ nóng nhất ở Việt Nam.", culture: "Trong kinh nghiệm mùa vụ, cần quan sát nhiệt, mưa và nước tưới."),
        .init(name: "Lập thu", season: "Thu", usualDate: "7–9/8", meaning: "Bắt đầu mùa thu theo lịch truyền thống.", nature: "Ngày dần ngắn hơn ở Bắc bán cầu; nhiều nơi vẫn còn nóng.", culture: "Gợi hình ảnh chuyển mùa và chuẩn bị thu hoạch tùy từng loại cây."),
        .init(name: "Xử thử", season: "Thu", usualDate: "22–24/8", meaning: "Giai đoạn cái nóng dần lui theo quan niệm cổ.", nature: "Một số vùng bắt đầu dịu nhiệt; Việt Nam vẫn có thể nắng nóng hoặc mưa bão.", culture: "Mốc quan sát thời tiết chuyển tiếp, không thay thế dự báo khí tượng."),
        .init(name: "Bạch lộ", season: "Thu", usualDate: "7–9/9", meaning: "Móc trắng, gợi giọt sương đọng khi trời dịu mát.", nature: "Đêm mát ở một số nơi có thể tạo điều kiện ngưng tụ hơi nước.", culture: "Gợi hình ảnh mùa thu trong thơ ca và kinh nghiệm quan sát đồng ruộng."),
        .init(name: "Thu phân", season: "Thu", usualDate: "22–24/9", meaning: "Mặt Trời đạt kinh độ 180°, mốc thu phân.", nature: "Ngày đêm gần bằng nhau; sau đó ban ngày ở Bắc bán cầu tiếp tục ngắn dần.", culture: "Một trong bốn mốc phân, chí quan trọng của chu kỳ thiên văn năm."),
        .init(name: "Hàn lộ", season: "Thu", usualDate: "8–9/10", meaning: "Sương lạnh, gợi không khí thu muộn.", nature: "Nhiệt độ có thể giảm về đêm tại các vùng phía Bắc; không đồng nhất trên cả nước.", culture: "Gợi nhắc theo dõi độ ẩm, gió lạnh và tình trạng cây trồng."),
        .init(name: "Sương giáng", season: "Thu", usualDate: "23–24/10", meaning: "Sương sa, liên hệ với sương giá ở các vùng khí hậu lạnh.", nature: "Sương giá chỉ xuất hiện khi điều kiện nhiệt độ và độ ẩm thích hợp; không phải hiện tượng toàn quốc.", culture: "Tên gọi cổ nhắc về sự chuyển tiếp từ thu sang đông."),
        .init(name: "Lập đông", season: "Đông", usualDate: "7–8/11", meaning: "Bắt đầu mùa đông theo lịch truyền thống.", nature: "Ở miền Bắc Việt Nam có thể có không khí lạnh; miền Nam có chu kỳ thời tiết khác.", culture: "Gợi nhắc chuẩn bị sinh hoạt, vật nuôi và cây trồng cho điều kiện mùa lạnh tại địa phương."),
        .init(name: "Tiểu tuyết", season: "Đông", usualDate: "22–23/11", meaning: "Tuyết nhẹ, tên gọi phản ánh sự lạnh lên ở vùng khí hậu ôn đới.", nature: "Không có nghĩa Việt Nam sẽ có tuyết. Miền Bắc có thể lạnh hơn, trong khi nhiều nơi miền Nam vẫn ấm.", culture: "Mốc giữa Lập đông và Đại tuyết, gợi nhắc theo dõi sự chuyển mùa và điều kiện thực tế."),
        .init(name: "Đại tuyết", season: "Đông", usualDate: "6–8/12", meaning: "Tuyết lớn theo cách gọi truyền thống ở vùng lạnh.", nature: "Tuyết phụ thuộc nhiệt độ và độ ẩm; rất hiếm ở phần lớn Việt Nam.", culture: "Gợi hình ảnh mùa đông sâu hơn trong hệ thống tên tiết khí cổ."),
        .init(name: "Đông chí", season: "Đông", usualDate: "21–23/12", meaning: "Mặt Trời đạt kinh độ 270°, mốc đông chí.", nature: "Bắc bán cầu có ban ngày ngắn nhất hoặc gần ngắn nhất; sau đó ngày dài dần.", culture: "Là mốc quan trọng trong lịch pháp âm dương; tháng âm chứa đông chí được quy ước là tháng 11."),
        .init(name: "Tiểu hàn", season: "Đông", usualDate: "5–7/1", meaning: "Lạnh nhẹ theo tên gọi cổ.", nature: "Giai đoạn mùa đông ở Bắc bán cầu; mức rét phụ thuộc từng đợt không khí lạnh.", culture: "Gợi nhắc chuẩn bị công việc phù hợp mùa lạnh, nhất là ở vùng cao và miền Bắc."),
        .init(name: "Đại hàn", season: "Đông", usualDate: "20–21/1", meaning: "Lạnh lớn, tiết cuối trước Lập xuân.", nature: "Một số vùng còn rét; không phải nơi nào cũng có ngày lạnh nhất trong tiết này.", culture: "Khép lại vòng 24 tiết khí theo thứ tự truyền thống, chuẩn bị bước sang mùa xuân.")
    ]
    static func named(_ name: String) -> Self? { all.first { $0.name == name } }

    /// Uses the existing solar-longitude approximation and UTC+7 civil day.
    static func starts(in year: Int) -> [(guide: Self, date: SolarCivilDate)] {
        guard (1900...2100).contains(year) else { return [] }
        let first = VietnameseLunarCalendar.jdn(SolarCivilDate(year: year, month: 1, day: 1))
        let last = VietnameseLunarCalendar.jdn(SolarCivilDate(year: year, month: 12, day: 31))
        return (first...last).compactMap { j in
            let date = VietnameseLunarCalendar.civilDate(j)
            let term = VietnameseLunarCalendar.solarTerm(on: date)
            guard term.startsToday, let guide = named(term.name) else { return nil }
            return (guide, date)
        }
    }

    static func period(on date: SolarCivilDate) -> (start: SolarCivilDate?, next: SolarCivilDate?) {
        let j = VietnameseLunarCalendar.jdn(date)
        var start: SolarCivilDate?
        var next: SolarCivilDate?
        for offset in 0...20 {
            let candidate = VietnameseLunarCalendar.civilDate(j - offset)
            if VietnameseLunarCalendar.isValid(candidate), VietnameseLunarCalendar.solarTerm(on: candidate).startsToday {
                start = candidate; break
            }
        }
        for offset in 1...20 {
            let candidate = VietnameseLunarCalendar.civilDate(j + offset)
            if VietnameseLunarCalendar.isValid(candidate), VietnameseLunarCalendar.solarTerm(on: candidate).startsToday {
                next = candidate; break
            }
        }
        return (start, next)
    }
}
