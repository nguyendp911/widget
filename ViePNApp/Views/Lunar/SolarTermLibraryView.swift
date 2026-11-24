import SwiftUI

struct SolarTermLibraryView: View {
    let civil: SolarCivilDate
    @State private var selection: SolarTermGuide?
    private var current: SolarTermGuide? {
        SolarTermGuide.named(VietnameseLunarCalendar.solarTerm(on: civil).name)
    }
    private var annual: [(guide: SolarTermGuide, date: SolarCivilDate)] { SolarTermGuide.starts(in: civil.year) }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let current {
                let period = SolarTermGuide.period(on: civil)
                Button { selection = current } label: {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: current.symbol).font(.system(size: 34))
                            VStack(alignment: .leading, spacing: 5) {
                                Text("TIẾT KHÍ ĐANG XEM").font(.caption.weight(.semibold)).tracking(1)
                                Text(current.name).font(.system(.largeTitle, design: .serif).bold())
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        Text(current.meaning).font(.subheadline)
                        if let start = period.start {
                            Text("Bắt đầu: " + start.label).font(.subheadline.weight(.medium))
                        }
                        if let next = period.next {
                            let days = VietnameseLunarCalendar.jdn(next) - VietnameseLunarCalendar.jdn(civil)
                            Text("Còn " + String(days) + " ngày đến " + VietnameseLunarCalendar.solarTerm(on: next).name + " · " + next.label)
                                .font(.caption)
                        }
                        Text("Chạm để xem ý nghĩa, thiên nhiên và phong tục").font(.caption.weight(.medium))
                    }.frame(maxWidth: .infinity, alignment: .leading).padding(20)
                    .foregroundStyle(Color(hex: "#FFF0C7"))
                    .background(LinearGradient(colors: [Color(hex: "#70151B"), HeritagePalette.red], startPoint: .topLeading, endPoint: .bottomTrailing), in: RoundedRectangle(cornerRadius: 20))
                    .overlay(RoundedRectangle(cornerRadius: 20).strokeBorder(HeritagePalette.gold, lineWidth: 1.5))
                }.buttonStyle(.plain)
            }
            Text("24 tiết khí là 24 mốc theo chuyển động biểu kiến của Mặt Trời, cách nhau 15° kinh độ hoàng đạo.").font(.subheadline)
                .foregroundStyle(HeritagePalette.ink)
            ForEach(["Xuân","Hạ","Thu","Đông"], id: \.self) { season in
                HeritagePlaque(title: "Mùa " + season, jade: season == "Xuân" || season == "Hạ")
                VStack(spacing: 0) {
                    ForEach(SolarTermGuide.all.filter { $0.season == season }) { item in
                        Button { selection = item } label: {
                            HStack(spacing: 12) {
                                Image(systemName: item.symbol)
                                    .font(.title3).foregroundStyle(HeritagePalette.gold)
                                    .frame(width: 34)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.name).font(.system(.headline, design: .serif))
                                    Text(annual.first(where: { $0.guide.name == item.name })?.date.label ?? item.usualDate)
                                        .font(.caption).foregroundStyle(HeritagePalette.soft)
                                    if item.name == current?.name {
                                        Text("Tiết khí đang xem").font(.caption.weight(.semibold)).foregroundStyle(HeritagePalette.red)
                                    }
                                }
                                Spacer()
                                Image(systemName: "chevron.right").font(.caption.weight(.semibold)).foregroundStyle(HeritagePalette.soft)
                            }.padding(12).contentShape(Rectangle())
                        }.buttonStyle(.plain)
                        if item.name != SolarTermGuide.all.last(where: { $0.season == season })?.name {
                            Divider().padding(.horizontal, 12)
                        }
                    }
                }.heritageFrame()
            }
            Text("Tên mùa và thời tiết là quy ước truyền thống của Bắc bán cầu, không phải dự báo thời tiết Việt Nam.").font(.caption).foregroundStyle(HeritagePalette.soft)
        }
        .foregroundStyle(HeritagePalette.ink)
        .fullScreenCover(item: $selection) { item in
            SolarTermArticleView(guide: item, year: civil.year)
        }
    }
}

private struct SolarTermArticleView: View {
    let guide: SolarTermGuide
    let year: Int
    @Environment(\.dismiss) private var dismiss
    private var start: SolarCivilDate? {
        SolarTermGuide.starts(in: year).first { $0.guide.name == guide.name }?.date
    }
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    ZStack {
                        LinearGradient(colors: [Color(hex: "#73151B"), HeritagePalette.red], startPoint: .topLeading, endPoint: .bottomTrailing)
                        HeritageDrumMark(tint: HeritagePalette.gold).frame(width: 180, height: 180).opacity(0.18)
                        VStack(spacing: 9) {
                            Image(systemName: guide.symbol).font(.system(size: 42))
                            Text(guide.name).font(.system(size: 36, weight: .bold, design: .serif))
                            Text("MÙA " + guide.season.uppercased()).font(.caption.weight(.semibold)).tracking(2)
                            Text(start?.label ?? guide.usualDate).font(.headline)
                        }.padding(24)
                    }.frame(minHeight: 200).foregroundStyle(Color(hex: "#FFF0C7"))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .overlay(RoundedRectangle(cornerRadius: 20).strokeBorder(HeritagePalette.gold, lineWidth: 1.5))
                    article("Ý nghĩa tên gọi", icon: "book", content: guide.meaning)
                    article("Đặc điểm thiên nhiên", icon: "leaf", content: guide.nature)
                    article("Văn hóa và sinh hoạt", icon: "house", content: guide.culture)
                    article("Thông tin thiên văn", icon: "sun.max", content: "Kinh độ hoàng đạo: " + String(guide.longitude) + "°. Thường bắt đầu ngày " + guide.usualDate + " dương lịch. Ngày giao tiết năm " + String(year) + " được tính gần đúng theo UTC+7.")
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Tài liệu tham khảo").font(.headline)
                        Link("Đài Thiên văn Hồng Kông — 24 tiết khí", destination: URL(string: "https://www.hko.gov.hk/en/gts/time/24solarterms.htm")!)
                        Link("Tạp chí Hán Nôm — lịch tiết khí", destination: URL(string: "https://hannom.vass.gov.vn/web/tchn/DATA1/0506v.htm")!)
                        Text("Nội dung diễn giải văn hóa; không dùng để dự báo thời tiết, quyết định sức khỏe hoặc vận mệnh.").font(.caption).foregroundStyle(HeritagePalette.soft)
                    }.padding(16).heritageFrame()
                }.padding(16)
            }.background(HeritagePalette.paper.ignoresSafeArea())
            .navigationTitle(guide.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Đóng") { dismiss() } } }
            .foregroundStyle(HeritagePalette.ink)
            .tint(HeritagePalette.red)
        }
    }
    private func article(_ title: String, icon: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 9) {
            Label(title, systemImage: icon).font(.system(.headline, design: .serif)).foregroundStyle(HeritagePalette.red)
            Text(content).font(.body).fixedSize(horizontal: false, vertical: true)
        }.frame(maxWidth: .infinity, alignment: .leading).padding(16).heritageFrame()
    }
}
