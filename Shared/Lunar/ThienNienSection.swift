import Foundation

/// Internal modal destinations shared by WidgetKit and the application.
/// WidgetKit cannot present a sheet over SpringBoard: it deep-links to the
/// host app, which presents the matching sheet immediately on activation.
enum ThienNienSection: String, CaseIterable, Identifiable {
    case date, canChi, zodiac, auspicious, hours, solarTerms, memorials, month, observances
    var id: String { rawValue }

    var title: String {
        switch self {
        case .date: return "Âm dương lịch"
        case .canChi: return "Thiên Can · Địa Chi"
        case .zodiac: return "Tử vi dân gian"
        case .auspicious: return "Sao · Trực · Ngày tốt xấu"
        case .hours: return "Giờ hoàng đạo"
        case .solarTerms: return "24 tiết khí"
        case .memorials: return "Ngày giỗ gia đình"
        case .month: return "Lịch tháng âm dương"
        case .observances: return "Ngày lễ · Mùng 1 · Rằm"
        }
    }

    func url(for day: SolarCivilDate) -> URL {
        var parts = URLComponents()
        parts.scheme = "viepnwidgetplus"
        parts.host = "lunar"
        parts.queryItems = [
            URLQueryItem(name: "detail", value: rawValue),
            URLQueryItem(name: "date", value: String(format: "%04d-%02d-%02d", day.year, day.month, day.day))
        ]
        // Every case is encoded from fixed, non-user-controlled tokens.
        return parts.url!
    }

    static func destination(from url: URL) -> (section: ThienNienSection, date: SolarCivilDate?)? {
        guard url.scheme == "viepnwidgetplus", url.host == "lunar",
              let parts = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let key = parts.queryItems?.first(where: { $0.name == "detail" })?.value,
              let section = ThienNienSection(rawValue: key) else { return nil }
        var date: SolarCivilDate?
        if let value = parts.queryItems?.first(where: { $0.name == "date" })?.value {
            let numbers = value.split(separator: "-").compactMap { Int($0) }
            if numbers.count == 3 {
                let candidate = SolarCivilDate(year: numbers[0], month: numbers[1], day: numbers[2])
                if VietnameseLunarCalendar.isValid(candidate) { date = candidate }
            }
        }
        return (section, date)
    }
}
