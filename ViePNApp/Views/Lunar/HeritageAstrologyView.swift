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
    @State private var category = 0
    @State private var query = ""
    private var civil: SolarCivilDate { SolarCivilDate(date: date) ?? SolarCivilDate(year: 2026, month: 11, day: 24) }
    private var facts: LunarAlmanacFacts { LunarAlmanacFacts(civil) }
    private var sign: WesternSign { WesternSign.approximate(civil) }
    private func matches(_ text: String) -> Bool {
        query.trimmingCharacters(in:.whitespacesAndNewlines).isEmpty ||
        text.folding(options:[.caseInsensitive,.diacriticInsensitive],locale:Locale(identifier:"vi_VN"))
            .contains(query.trimmingCharacters(in:.whitespacesAndNewlines).folding(options:[.caseInsensitive,.diacriticInsensitive],locale:Locale(identifier:"vi_VN")))
    }

    var body: some View {
        ScrollView {
            VStack(alignment:.leading,spacing:20) {
                EditorialSectionTitle(eyebrow:"Thư viện văn hóa",title:"Thiên mệnh")
                profile
                if !HeritageArtCatalog.missingAssets.isEmpty {
                    Label("Thiếu " + String(HeritageArtCatalog.missingAssets.count) + "/24 ảnh trong bản cài đặt.", systemImage:"exclamationmark.triangle").font(.caption).foregroundStyle(HeritagePalette.red)
                }
                EditorialSectionTitle(eyebrow:"Khám phá",title:"Hồ sơ biểu tượng")
                Picker("Thư viện",selection:$category) {
                    Text("Con giáp Việt").tag(0)
                    Text("Hoàng đạo").tag(1)
                }.pickerStyle(.segmented)
                HStack {
                    Image(systemName:"magnifyingglass").foregroundStyle(HeritagePalette.soft)
                    TextField("Tìm theo tên, ngũ hành hoặc nguyên tố",text:$query)
                        .autocorrectionDisabled()
                    if !query.isEmpty {
                        Button { query = "" } label: { Image(systemName:"xmark.circle.fill") }.accessibilityLabel("Xóa tìm kiếm")
                    }
                }.padding(12).editorialSurface(radius:14)
                if category == 0 {
                    let animals = AnimalGuide.all.filter { matches($0.branch + " " + $0.animal + " " + $0.element) }
                    if animals.isEmpty { Text("Không tìm thấy con giáp phù hợp.").font(.subheadline).foregroundStyle(HeritagePalette.soft) }
                    LazyVGrid(columns:[GridItem(.flexible(),spacing:12),GridItem(.flexible(),spacing:12)],spacing:12) {
                        ForEach(animals) { guide in
                            Button { selectedAnimal = guide } label: {
                                galleryTile(title:guide.branch + " · " + guide.animal, subtitle:guide.yinYang + " " + guide.element, index:String(format:"%02d",guide.index+1)) {
                                    HeritageAnimalArtwork(branch:guide.branch)
                                }
                            }.buttonStyle(.plain)
                        }
                    }
                } else {
                    let signs = WesternSign.allCases.filter { matches($0.name + " " + $0.rawValue + " " + $0.element) }
                    if signs.isEmpty { Text("Không tìm thấy cung phù hợp.").font(.subheadline).foregroundStyle(HeritagePalette.soft) }
                    LazyVGrid(columns:[GridItem(.flexible(),spacing:12),GridItem(.flexible(),spacing:12)],spacing:12) {
                        ForEach(signs) { item in
                            Button { selectedSign = item } label: {
                                galleryTile(title:item.name,subtitle:item.element + " · " + item.period,index:item.symbol) {
                                    WesternArtwork(sign:item)
                                }
                            }.buttonStyle(.plain)
                        }
                    }
                }
                Text("Con giáp theo năm âm lịch. Cung Mặt Trời là ước tính theo ngày; chiêm tinh và tử vi là văn hóa tham khảo.").font(.caption).foregroundStyle(HeritagePalette.soft)
            }.padding(16)
        }
        .background(HeritagePalette.paper.ignoresSafeArea())
        .foregroundStyle(HeritagePalette.ink)
        .navigationTitle("Thiên mệnh")
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(item:$selectedSign) { WesternSignArticleView(sign:$0) }
        .fullScreenCover(item:$selectedAnimal) { ZodiacArticleView(guide:$0,referenceYear:civil.year) }
        .onChange(of:category) { _,_ in query = "" }
    }

    private var profile: some View {
        VStack(alignment:.leading,spacing:16) {
            HStack {
                VStack(alignment:.leading,spacing:5) {
                    Text("TRA CỨU THEO NGÀY SINH").font(.caption2.weight(.semibold)).tracking(1.2)
                    Text("Dấu ấn của bạn").font(.system(.title2,design:.serif).weight(.semibold))
                }
                Spacer()
                Image(systemName:"calendar").font(.title2)
            }.foregroundStyle(Color(hex:"#E7C583"))
            DatePicker("Ngày sinh",selection:$date,in:SolarCivilDate(year:1900,month:1,day:1).asDate()!...SolarCivilDate(year:2100,month:12,day:31).asDate()!,displayedComponents:.date)
                .environment(\.timeZone,VietnameseLunarCalendar.vietnamTimeZone)
                .environment(\.locale,Locale(identifier:"vi_VN"))
                .padding(9).background(Color(hex:"#FFF5DE"),in:RoundedRectangle(cornerRadius:12))
                .foregroundStyle(HeritagePalette.ink)
            HStack(alignment:.top,spacing:13) {
                Button { selectedAnimal = AnimalGuide.named(facts.yearAnimal) } label: {
                    VStack(spacing:8) {
                        HeritageAnimalArtwork(branch:facts.yearAnimal).frame(height:120)
                        Text(facts.canChiYear).font(.system(.headline,design:.serif))
                        Text(NapAmGuide.lookup(facts.canChiYear)?.name ?? facts.yearAnimalName).font(.caption)
                        Label("Hồ sơ tuổi",systemImage:"arrow.up.right").font(.caption2.weight(.medium)).foregroundStyle(Color(hex:"#E7C583"))
                    }.frame(maxWidth:.infinity)
                }.buttonStyle(.plain)
                Rectangle().fill(Color(hex:"#E7C583").opacity(0.28)).frame(width:1,height:166)
                Button { selectedSign = sign } label: {
                    VStack(spacing:8) {
                        WesternArtwork(sign:sign).frame(height:120)
                        Text(sign.name).font(.system(.headline,design:.serif))
                        Text("Nguyên tố " + sign.element).font(.caption)
                        Label("Hồ sơ cung",systemImage:"arrow.up.right").font(.caption2.weight(.medium)).foregroundStyle(Color(hex:"#E7C583"))
                    }.frame(maxWidth:.infinity)
                }.buttonStyle(.plain)
            }
        }.padding(18).foregroundStyle(Color(hex:"#FFF0D2"))
        .background(LinearGradient(colors:[Color(hex:"#3F141B"),Color(hex:"#782B30")],startPoint:.topLeading,endPoint:.bottomTrailing),in:RoundedRectangle(cornerRadius:24))
    }

    private func galleryTile<Artwork:View>(title:String,subtitle:String,index:String,@ViewBuilder artwork:()->Artwork) -> some View {
        VStack(alignment:.leading,spacing:8) {
            ZStack(alignment:.topLeading) {
                Color(hex:"#EFE4D1")
                artwork().padding(13).frame(maxWidth:.infinity,maxHeight:.infinity)
                Text(index).font(.caption2.weight(.semibold)).foregroundStyle(HeritagePalette.soft).padding(10)
            }.frame(height:145).clipShape(RoundedRectangle(cornerRadius:15))
            HStack(alignment:.firstTextBaseline) {
                Text(title).font(.system(.headline,design:.serif)).fixedSize(horizontal:false,vertical:true)
                Spacer(minLength:0)
                Image(systemName:"arrow.up.right").font(.caption).foregroundStyle(HeritagePalette.red)
            }
            Text(subtitle).font(.caption).foregroundStyle(HeritagePalette.soft).fixedSize(horizontal:false,vertical:true)
        }.padding(9).frame(maxWidth:.infinity,alignment:.topLeading).editorialSurface(radius:20)
    }
}
