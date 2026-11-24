import SwiftUI
import UIKit

enum WesternSign: String, CaseIterable, Identifiable {
    case aries, taurus, gemini, cancer, leo, virgo, libra, scorpio, sagittarius, capricorn, aquarius, pisces
    var id: String { rawValue }
    var name: String {
        ["Bạch Dương","Kim Ngưu","Song Tử","Cự Giải","Sư Tử","Xử Nữ","Thiên Bình","Bọ Cạp","Nhân Mã","Ma Kết","Bảo Bình","Song Ngư"][Self.allCases.firstIndex(of: self)!]
    }
    var symbol: String { ["♈","♉","♊","♋","♌","♍","♎","♏","♐","♑","♒","♓"][Self.allCases.firstIndex(of: self)!] }
    var element: String { ["Lửa","Đất","Khí","Nước"][Self.allCases.firstIndex(of: self)! % 4] }
    var asset: String { "TNVWestern" + rawValue.prefix(1).uppercased() + String(rawValue.dropFirst()) }
    var period: String { ["21/3 – 19/4","20/4 – 20/5","21/5 – 20/6","21/6 – 22/7","23/7 – 22/8","23/8 – 22/9","23/9 – 22/10","23/10 – 21/11","22/11 – 21/12","22/12 – 19/1","20/1 – 18/2","19/2 – 20/3"][Self.allCases.firstIndex(of: self)!] }
    static func approximate(_ date: SolarCivilDate) -> Self {
        switch date.month * 100 + date.day {
        case 321...419: return .aries
        case 420...520: return .taurus
        case 521...620: return .gemini
        case 621...722: return .cancer
        case 723...822: return .leo
        case 823...922: return .virgo
        case 923...1022: return .libra
        case 1023...1121: return .scorpio
        case 1122...1221: return .sagittarius
        case 120...218: return .aquarius
        case 219...320: return .pisces
        default: return .capricorn
        }
    }
}

enum HeritageArtCatalog {
    static func animal(_ branch: String) -> String {
        let names = ["Ty","Suu","Dan","Mao","Thin","TySnake","Ngo","Mui","Than","Dau","Tuat","Hoi"]
        guard let index = VietnameseLunarCalendar.chi.firstIndex(of: branch) else { return "" }
        return "TNVAnimal" + names[index]
    }

    static var missingAssets: [String] {
        let required = VietnameseLunarCalendar.chi.map { animal($0) } + WesternSign.allCases.map(\.asset)
        return required.filter { UIImage(named: $0) == nil }
    }
}

struct HeritageAnimalArtwork: View {
    let branch: String
    var body: some View {
        if let image = UIImage(named: HeritageArtCatalog.animal(branch)) {
            Image(uiImage: image).resizable().scaledToFit()
        } else {
            MissingZodiacArtwork(name: HeritageArtCatalog.animal(branch))
        }
    }
}

struct WesternArtwork: View {
    let sign: WesternSign
    var body: some View {
        if let image = UIImage(named: sign.asset) {
            Image(uiImage: image).resizable().scaledToFit()
        } else {
            MissingZodiacArtwork(name: sign.asset)
        }
    }
}

private struct MissingZodiacArtwork: View {
    let name: String
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: "photo.badge.exclamationmark").font(.title2)
            Text("Thiếu ảnh").font(.caption.weight(.semibold))
        }
        .foregroundStyle(HeritagePalette.red)
        .accessibilityLabel("Thiếu tài nguyên " + name)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct HeritageAstrologyView: View {
    @State private var date = Date()
    @State private var selectedSign: WesternSign?
    @State private var selectedAnimal: AnimalGuide?
    private var civil: SolarCivilDate { SolarCivilDate(date: date) ?? SolarCivilDate(year: 2026, month: 11, day: 24) }
    private var facts: LunarAlmanacFacts { LunarAlmanacFacts(civil) }
    private var sign: WesternSign { WesternSign.approximate(civil) }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                HeritageBanner(title: "Thiên mệnh", subtitle: "Can Chi · Con giáp · Hoàng đạo")
                if !HeritageArtCatalog.missingAssets.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        Label("Bản cài đặt thiếu ảnh", systemImage: "exclamationmark.triangle.fill").font(.headline)
                        Text("Thiếu " + String(HeritageArtCatalog.missingAssets.count) + "/24 asset. Hãy cập nhật IPA mới; ứng dụng không dùng hình cũ để thay thế.").font(.caption)
                    }.padding(12).frame(maxWidth: .infinity, alignment: .leading).heritageFrame()
                }
                DatePicker("Ngày sinh / ngày tra cứu", selection: $date, in: (SolarCivilDate(year: 1900, month: 1, day: 1).asDate()!)...(SolarCivilDate(year: 2100, month: 12, day: 31).asDate()!), displayedComponents: .date)
                    .environment(\.timeZone, VietnameseLunarCalendar.vietnamTimeZone)
                    .environment(\.locale, Locale(identifier: "vi_VN"))
                    .padding(12).heritageFrame()
                HStack(spacing: 12) {
                    Button { selectedAnimal = AnimalGuide.named(facts.yearAnimal) } label: {
                        VStack(spacing: 6) {
                            HeritageAnimalArtwork(branch: facts.yearAnimal).frame(height: 124)
                            Text(facts.canChiYear).font(.system(.headline, design: .serif))
                            Text(NapAmGuide.lookup(facts.canChiYear)?.name ?? facts.yearAnimalName).font(.caption)
                            Text("Xem hồ sơ tuổi").font(.caption2).foregroundStyle(HeritagePalette.red)
                        }.frame(maxWidth: .infinity).padding(10).heritageFrame()
                    }.buttonStyle(.plain)
                    Button { selectedSign = sign } label: {
                        VStack(spacing: 6) {
                            WesternArtwork(sign: sign).frame(height: 124)
                            Text(sign.name).font(.system(.headline, design: .serif))
                            Text(sign.element).font(.caption)
                            Text("Xem hồ sơ cung").font(.caption2).foregroundStyle(HeritagePalette.red)
                        }.frame(maxWidth: .infinity).padding(10).heritageFrame()
                    }.buttonStyle(.plain)
                }
                HeritagePlaque(title: "Mười hai con giáp Việt")
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 10) {
                    ForEach(AnimalGuide.all) { guide in
                        Button { selectedAnimal = guide } label: {
                            VStack(spacing: 7) {
                                HeritageAnimalArtwork(branch: guide.branch).frame(height: 98)
                                Text(guide.branch + " · " + guide.animal).font(.subheadline.weight(.semibold))
                                Text(guide.yinYang + " " + guide.element).font(.caption).foregroundStyle(HeritagePalette.soft)
                                Text("Xem hồ sơ").font(.caption2).foregroundStyle(HeritagePalette.red)
                            }.frame(maxWidth: .infinity).padding(7).heritageFrame()
                        }.buttonStyle(.plain)
                    }
                }
                HeritagePlaque(title: "Mười hai cung hoàng đạo", jade: true)
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 10) {
                    ForEach(WesternSign.allCases) { item in
                        Button { selectedSign = item } label: {
                            VStack(spacing: 5) {
                                WesternArtwork(sign: item).frame(height: 98)
                                Text(item.name).font(.caption.weight(.semibold))
                                Text(item.element).font(.caption2).foregroundStyle(HeritagePalette.soft)
                                Text("Xem hồ sơ").font(.caption2).foregroundStyle(HeritagePalette.red)
                            }.frame(maxWidth: .infinity).padding(6).heritageFrame()
                        }.buttonStyle(.plain)
                    }
                }
                Text("Bộ minh họa · 3.8").font(.caption2).foregroundStyle(HeritagePalette.soft)
                Text("Cung Mặt Trời được ước tính bằng mốc ngày phổ biến. Ngày sát ranh giới cần giờ, nơi sinh và thiên văn chính xác. Tử vi, chiêm tinh là nội dung văn hóa, không có khả năng dự báo chắc chắn.").font(.caption).foregroundStyle(HeritagePalette.soft)
            }.padding(16)
        }
        .background(HeritagePalette.paper.ignoresSafeArea())
        .foregroundStyle(HeritagePalette.ink)
        .navigationTitle("Thiên mệnh")
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(item: $selectedSign) { item in
            WesternSignArticleView(sign: item)
        }
        .fullScreenCover(item: $selectedAnimal) { item in
            ZodiacArticleView(guide: item, referenceYear: civil.year)
        }
    }
}
