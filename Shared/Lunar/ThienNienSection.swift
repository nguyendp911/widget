import Foundation

/// A sheet for each category of the standalone Vietnamese lunar app.
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
}
