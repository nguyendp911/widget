import SwiftUI

struct ZodiacArticleView: View {
    let guide: AnimalGuide
    let referenceYear: Int
    @Environment(\.dismiss) private var dismiss
    private var examples: [Int] {
        Array(guide.yearExamples.sorted { abs($0-referenceYear) < abs($1-referenceYear) }.prefix(6)).sorted()
    }
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(spacing: 12) {
                        HeritageAnimalArtwork(branch: guide.branch).frame(width: 224, height: 224)
                        Text(guide.branch + " · " + guide.animal).font(.system(size: 34, weight: .bold, design: .serif))
                        Text(guide.character + "  ·  ĐỊA CHI " + String(guide.index+1) + "/12")
                            .font(.subheadline.weight(.medium)).tracking(2)
                    }.frame(maxWidth: .infinity).padding(20)
                    .foregroundStyle(Color(hex: "#FFF1C9"))
                    .background(LinearGradient(colors:[Color(hex:"#501216"), HeritagePalette.red],startPoint:.topLeading,endPoint:.bottomTrailing),in:RoundedRectangle(cornerRadius:24))
                    .overlay(RoundedRectangle(cornerRadius:24).strokeBorder(HeritagePalette.gold,lineWidth:1.5))
                    VStack(alignment: .leading, spacing: 8) {
                        HeritagePlaque(title: "Hồ sơ Địa Chi", jade: true)
                        fact("Âm dương",guide.yinYang)
                        fact("Hành của Địa Chi",guide.element)
                        fact("Phương vị truyền thống",guide.direction)
                        fact("Khung giờ",guide.hour)
                        fact("Lục hợp",guide.harmony)
                        fact("Tam hợp",guide.trine)
                        fact("Lục xung",guide.opposing)
                        Text("Hành của Địa Chi không phải nạp âm năm sinh. Hợp/xung là phân loại truyền thống, không xác định chất lượng mối quan hệ.").font(.caption).foregroundStyle(HeritagePalette.soft)
                    }.padding(14).heritageFrame()
                    section("Ý nghĩa và vị trí", "book", guide.meaning)
                    section("Dấu ấn trong văn hóa Việt", "building.columns", guide.heritage)
                    section("Phẩm chất trong biểu tượng dân gian", "sparkles", guide.strengths)
                    section("Gợi ý tự chiêm nghiệm", "heart.text.square", guide.reflection)
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Các năm tuổi " + guide.branch).font(.system(.headline, design:.serif)).foregroundStyle(HeritagePalette.red)
                        Text("Ví dụ gần năm đang tra cứu; năm âm lịch bắt đầu từ Tết, không phải ngày 1/1 dương lịch.").font(.caption)
                        ForEach(examples,id:\.self) { year in
                            let stem = VietnameseLunarCalendar.can[((year-4)%10+10)%10]
                            let cycle = stem + " " + guide.branch
                            let nap = NapAmGuide.lookup(cycle)
                            HStack {
                                Text(String(year)).font(.headline.monospacedDigit())
                                Spacer()
                                VStack(alignment:.trailing,spacing:4) {
                                    Text(cycle).font(.subheadline.weight(.semibold))
                                    Text(nap.map { $0.name + " · " + $0.element } ?? "—").font(.caption)
                                }
                            }.padding(.vertical,5)
                            Divider()
                        }
                    }.padding(16).heritageFrame()
                    VStack(alignment:.leading,spacing:8) {
                        Text("Cách đọc thông tin").font(.headline)
                        Text("Đây là hồ sơ văn hóa của một Địa Chi, không phải lá số Tử Vi Đẩu Số. Muốn xác định Can Chi năm sinh, cần quy đổi ngày sinh sang lịch âm Việt Nam; muốn lập lá số cá nhân còn cần giờ sinh và các quy tắc của trường phái cụ thể.").font(.subheadline)
                        Link("Tư liệu so sánh con giáp Việt Nam và Hàn Quốc",destination:URL(string:"https://www.kci.go.kr/kciportal/ci/sereArticleSearch/ciSereArtiView.kci?sereArticleSearchBean.artiId=ART002476832")!)
                        Text("Không dùng tuổi để đánh giá nhân phẩm, chọn người kết hôn, quyết định sức khỏe hay tài chính.").font(.caption).foregroundStyle(HeritagePalette.soft)
                    }.padding(16).heritageFrame()
                }.padding(16)
            }.background(HeritagePalette.paper.ignoresSafeArea())
            .navigationTitle("Tuổi " + guide.branch)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement:.confirmationAction) { Button("Đóng") { dismiss() } } }
        }.foregroundStyle(HeritagePalette.ink).tint(HeritagePalette.red)
    }
    private func fact(_ label:String,_ value:String)->some View {
        HStack(alignment:.firstTextBaseline) {
            Text(label).font(.subheadline).foregroundStyle(HeritagePalette.soft)
            Spacer(minLength:12)
            Text(value).font(.subheadline.weight(.semibold)).multilineTextAlignment(.trailing)
        }.padding(.vertical,5)
    }
    private func section(_ title:String,_ icon:String,_ value:String)->some View {
        VStack(alignment:.leading,spacing:10) {
            Label(title,systemImage:icon).font(.system(.headline,design:.serif)).foregroundStyle(HeritagePalette.red)
            Text(value).font(.body).fixedSize(horizontal:false,vertical:true)
        }.frame(maxWidth:.infinity,alignment:.leading).padding(16).heritageFrame()
    }
}

struct WesternSignArticleView: View {
    let sign: WesternSign
    @Environment(\.dismiss) private var dismiss
    private var index: Int { WesternSign.allCases.firstIndex(of:sign)! }
    private var guide: WesternGuide { WesternGuide.all[index] }
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment:.leading,spacing:16) {
                    VStack(spacing:10) {
                        WesternArtwork(sign:sign).frame(width:224,height:224)
                        Text(sign.symbol + " " + sign.name).font(.system(size:32,weight:.bold,design:.serif))
                        Text(sign.period).font(.headline)
                    }.frame(maxWidth:.infinity).padding(20)
                    .foregroundStyle(Color(hex:"#FFF1C9"))
                    .background(LinearGradient(colors:[Color(hex:"#123B35"),Color(hex:"#26736A")],startPoint:.topLeading,endPoint:.bottomTrailing),in:RoundedRectangle(cornerRadius:24))
                    .overlay(RoundedRectangle(cornerRadius:24).strokeBorder(HeritagePalette.gold,lineWidth:1.5))
                    VStack(alignment:.leading,spacing:12) {
                        HeritagePlaque(title:"Hồ sơ cung hoàng đạo",jade:true)
                        line("Biểu tượng",guide.symbol)
                        line("Nguyên tố",sign.element)
                        line("Tính chất",["Tiên phong","Cố định","Linh hoạt"][index%3])
                        line("Chủ tinh theo truyền thống",guide.ruler)
                        line("Kinh độ hoàng đạo",String(index*30)+"° – "+String((index+1)*30)+"°")
                        line("Cung đối diện",WesternSign.allCases[(index+6)%12].name)
                    }.padding(14).heritageFrame()
                    VStack(alignment:.leading,spacing:10) {
                        Text("Ý nghĩa biểu tượng").font(.headline).foregroundStyle(HeritagePalette.red)
                        Text(guide.archetype)
                        Divider()
                        Text("Gợi ý tự chiêm nghiệm").font(.headline).foregroundStyle(HeritagePalette.red)
                        Text(guide.reflection)
                    }.padding(16).heritageFrame()
                    VStack(alignment:.leading,spacing:8) {
                        Text("Phân biệt thiên văn và chiêm tinh").font(.headline)
                        Text("Hệ hoàng đạo nhiệt đới chia vòng kinh độ hoàng đạo thành 12 phần đều nhau, bắt đầu từ điểm xuân phân. Khoảng ngày ở đây là ước tính phổ biến, không trùng hoàn toàn với ranh giới chòm sao thiên văn. Ngày sát ranh giới cần phép tính vị trí Mặt Trời theo giờ sinh.").font(.subheadline)
                        Text("Chiêm tinh là hệ diễn giải văn hóa; không có bằng chứng khoa học đáng tin cậy để suy ra tính cách hoặc tương lai từ cung sinh.").font(.caption)
                    }.padding(16).heritageFrame()
                }.padding(16)
            }.background(HeritagePalette.paper.ignoresSafeArea())
            .navigationTitle(sign.name).navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement:.confirmationAction) { Button("Đóng") { dismiss() } } }
        }.foregroundStyle(HeritagePalette.ink).tint(HeritagePalette.red)
    }
    private func line(_ label:String,_ value:String)->some View {
        HStack(alignment:.firstTextBaseline) {
            Text(label).font(.subheadline).foregroundStyle(HeritagePalette.soft)
            Spacer(minLength:8)
            Text(value).font(.subheadline.weight(.semibold)).multilineTextAlignment(.trailing)
        }
    }
}
