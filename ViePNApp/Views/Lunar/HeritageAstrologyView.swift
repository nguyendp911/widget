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
}

struct HeritageAnimalArtwork: View {
    let branch: String
    var body: some View {
        if let image = UIImage(named: HeritageArtCatalog.animal(branch)) {
            Image(uiImage: image).resizable().scaledToFit()
        } else {
            ZStack {
                Circle().fill(HeritagePalette.red)
                Circle().strokeBorder(HeritagePalette.gold, lineWidth: 2)
                HeritageAnimalMark(branch: branch).padding(14)
            }
        }
    }
}

private struct WesternArtwork: View {
    let sign: WesternSign
    var body: some View {
        if let image = UIImage(named: sign.asset) {
            Image(uiImage: image).resizable().scaledToFit()
        } else {
            ZStack {
                Circle().fill(HeritagePalette.red)
                Circle().strokeBorder(HeritagePalette.gold, lineWidth: 2)
                Text(sign.symbol).font(.system(size: 42)).foregroundStyle(Color(hex: "#F3D68D"))
            }
        }
    }
}

enum HeritageOracleTopic: String, CaseIterable, Identifiable {
    case canChi, lunar, zodiac, western, elements, hours, terms, memorial, tuVi
    var id: String { rawValue }
    var title: String {
        switch self {
        case .canChi: return "Thiên Can · Địa Chi"
        case .lunar: return "Âm dương lịch"
        case .zodiac: return "12 con giáp"
        case .western: return "12 cung hoàng đạo"
        case .elements: return "Ngũ hành · Nạp âm"
        case .hours: return "Giờ hoàng đạo"
        case .terms: return "24 tiết khí"
        case .memorial: return "Ngày giỗ · Phong tục"
        case .tuVi: return "Tử Vi Đẩu Số"
        }
    }
}

struct HeritageAstrologyView: View {
    @State private var date = Date()
    @State private var showOracle = false
    @State private var selectedSign: WesternSign?
    private var civil: SolarCivilDate { SolarCivilDate(date: date) ?? SolarCivilDate(year: 2026, month: 11, day: 24) }
    private var facts: LunarAlmanacFacts { LunarAlmanacFacts(civil) }
    private var sign: WesternSign { WesternSign.approximate(civil) }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                HeritageBanner(title: "Thiên mệnh", subtitle: "Can Chi · Con giáp · Hoàng đạo")
                DatePicker("Ngày sinh / ngày tra cứu", selection: $date, in: (SolarCivilDate(year: 1900, month: 1, day: 1).asDate()!)...(SolarCivilDate(year: 2100, month: 12, day: 31).asDate()!), displayedComponents: .date)
                    .environment(\.timeZone, VietnameseLunarCalendar.vietnamTimeZone)
                    .environment(\.locale, Locale(identifier: "vi_VN"))
                    .padding(12).heritageFrame()
                HStack(spacing: 12) {
                    VStack(spacing: 6) {
                        HeritageAnimalArtwork(branch: facts.yearAnimal).frame(height: 110)
                        Text(facts.canChiYear).font(.system(.headline, design: .serif))
                        Text(facts.yearAnimalName).font(.caption)
                    }.frame(maxWidth: .infinity).padding(12).heritageFrame()
                    VStack(spacing: 6) {
                        WesternArtwork(sign: sign).frame(height: 110)
                        Text(sign.name).font(.system(.headline, design: .serif))
                        Text(sign.element).font(.caption)
                    }.frame(maxWidth: .infinity).padding(12).heritageFrame()
                }
                Button { showOracle = true } label: {
                    HeritagePlaque(title: "Hỏi Thiên Niên AI", jade: true)
                }.buttonStyle(.plain)
                HeritagePlaque(title: "Mười hai con giáp Việt")
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 10) {
                    ForEach(VietnameseLunarCalendar.chi, id: \.self) { branch in
                        VStack(spacing: 5) {
                            HeritageAnimalArtwork(branch: branch).frame(height: 86)
                            Text(branch + " · " + LunarAlmanacFacts.animal(branch)).font(.caption.weight(.medium))
                        }.frame(maxWidth: .infinity).padding(6).heritageFrame()
                    }
                }
                HeritagePlaque(title: "Mười hai cung hoàng đạo", jade: true)
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 10) {
                    ForEach(WesternSign.allCases) { item in
                        Button { selectedSign = item } label: {
                            VStack(spacing: 5) {
                                WesternArtwork(sign: item).frame(height: 86)
                                Text(item.name).font(.caption.weight(.medium))
                            }.frame(maxWidth: .infinity).padding(6).heritageFrame()
                        }.buttonStyle(.plain)
                    }
                }
                Text("Cung Mặt Trời được ước tính bằng mốc ngày phổ biến. Ngày sát ranh giới cần giờ, nơi sinh và thiên văn chính xác. Tử vi, chiêm tinh là nội dung văn hóa, không có khả năng dự báo chắc chắn.").font(.caption).foregroundStyle(HeritagePalette.soft)
            }.padding(16)
        }
        .background(HeritagePalette.paper.ignoresSafeArea())
        .foregroundStyle(HeritagePalette.ink)
        .navigationTitle("Thiên mệnh")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showOracle) { HeritageOracleView(civil: civil) }
        .sheet(item: $selectedSign) { item in
            VStack(spacing: 15) {
                WesternArtwork(sign: item).frame(height: 180)
                Text(item.symbol + " " + item.name).font(.system(.title, design: .serif).bold())
                Text(item.period)
                Text("Nguyên tố truyền thống: " + item.element)
                Text("Mốc ngày chỉ mang tính ước tính.").font(.caption)
            }.padding(24).presentationDetents([.medium,.large]).presentationDragIndicator(.visible)
        }
    }
}

private struct OracleRequest: Encodable {
    let topic: String
    let date: String
    let lunar: String
    let dayCanChi: String
    let monthCanChi: String
    let yearCanChi: String
    let term: String
    let goodHours: [String]
    let western: String
}
private struct OracleResponse: Decodable { let answer: String }

struct HeritageOracleView: View {
    let civil: SolarCivilDate
    @Environment(\.dismiss) private var dismiss
    @AppStorage("tnv.oracle.endpoint") private var endpoint = ""
    @State private var accessToken = ""
    @State private var topic = HeritageOracleTopic.canChi
    @State private var answer = ""
    @State private var busy = false
    @State private var allowShare = false
    private var facts: LunarAlmanacFacts { LunarAlmanacFacts(civil) }
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    HeritageBanner(title: "Thiên Niên AI", subtitle: "Trợ lý chuyên tri thức lịch Việt")
                    Text("Ngày tra cứu: " + civil.label).font(.headline)
                    Picker("Chủ đề", selection: $topic) {
                        ForEach(HeritageOracleTopic.allCases) { item in Text(item.title).tag(item) }
                    }.pickerStyle(.menu)
                    Text("Chỉ hỗ trợ các chủ đề được liệt kê, không có ô nhập lệnh tự do.").font(.caption)
                    DisclosureGroup("Kết nối máy chủ AI") {
                        TextField("https://máy-chủ.example/oracle", text: $endpoint)
                            .textInputAutocapitalization(.never).autocorrectionDisabled().keyboardType(.URL).textFieldStyle(.roundedBorder)
                        SecureField("Mã truy cập máy chủ", text: $accessToken).textFieldStyle(.roundedBorder)
                        Text("Mã truy cập chỉ lưu trong phiên này. Khóa nhà cung cấp AI phải đặt trên máy chủ.").font(.caption)
                    }
                    Toggle("Đồng ý gửi ngày tra cứu và dữ liệu lịch đã tính đến máy chủ", isOn: $allowShare)
                        .font(.subheadline)
                    Button {
                        Task { await ask() }
                    } label: {
                        if busy { ProgressView().frame(maxWidth: .infinity) }
                        else { Label("Tra cứu cùng AI", systemImage: "sparkles").frame(maxWidth: .infinity) }
                    }.buttonStyle(.borderedProminent).disabled(busy || !allowShare || endpoint.isEmpty || accessToken.isEmpty)
                    if !answer.isEmpty { Text(answer).textSelection(.enabled).padding(14).frame(maxWidth: .infinity, alignment: .leading).heritageFrame() }
                    Text("AI có thể sai. Không dùng tử vi thay cho tư vấn y tế, pháp lý, tài chính hoặc quyết định quan trọng.").font(.caption).foregroundStyle(HeritagePalette.soft)
                }.padding(16)
            }.background(HeritagePalette.paper.ignoresSafeArea())
            .navigationTitle("Thiên Niên AI").navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Đóng") { dismiss() } } }
        }.presentationDragIndicator(.visible)
    }
    @MainActor private func ask() async {
        guard allowShare, let url = URL(string: endpoint), url.scheme?.lowercased() == "https", url.host != nil, url.user == nil, url.password == nil else {
            answer = "Cần địa chỉ HTTPS hợp lệ."; return
        }
        busy = true; answer = ""; defer { busy = false }
        do {
            var request = URLRequest(url: url, timeoutInterval: 60)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer " + accessToken, forHTTPHeaderField: "Authorization")
            let payload = OracleRequest(topic: topic.rawValue, date: civil.label,
                lunar: VietnameseLunarCalendar.solarToLunar(civil)?.label ?? "—", dayCanChi: facts.canChiDay,
                monthCanChi: facts.canChiMonth, yearCanChi: facts.canChiYear, term: facts.solarTerm,
                goodHours: facts.goodHours, western: WesternSign.approximate(civil).rawValue)
            request.httpBody = try JSONEncoder().encode(payload)
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse, http.statusCode == 200, data.count < 200_000 else {
                answer = "Máy chủ chưa sẵn sàng hoặc mã truy cập không hợp lệ."; return
            }
            answer = try JSONDecoder().decode(OracleResponse.self, from: data).answer
        } catch { answer = "Không kết nối được máy chủ AI. Kiểm tra cấu hình và mạng." }
    }
}
