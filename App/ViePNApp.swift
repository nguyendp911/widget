import SwiftUI
import UserNotifications

let red = Color(red: 183/255, green: 28/255, blue: 28/255)
let cream = Color(red: 1, green: 248/255, blue: 225/255)
let good = Color(red: 46/255, green: 125/255, blue: 50/255)
let paper = Color(uiColor: .systemGroupedBackground)

@MainActor final class FamilyStore: ObservableObject {
    @Published var events:[FamilyEvent] = []
    @Published var reminderStatus = ""
    private let key="viepn.family.v1"
    init(){ if let data=UserDefaults.standard.data(forKey:key), let decoded=try? JSONDecoder().decode([FamilyEvent].self,from:data){events=decoded} }
    func save(_ e:FamilyEvent){ if let i=events.firstIndex(where:{$0.id==e.id}){events[i]=e}else{events.append(e)};persist() }
    func remove(_ e:FamilyEvent){events.removeAll{$0.id==e.id};persist()}
    func persist(){do {UserDefaults.standard.set(try JSONEncoder().encode(events),forKey:key);Task{await schedule()}}catch{reminderStatus=error.localizedDescription}}
    func enable() async { do { _ = try await UNUserNotificationCenter.current().requestAuthorization(options:[.alert,.sound,.badge]);await schedule() }catch{reminderStatus=error.localizedDescription} }
    func schedule() async {
        let center=UNUserNotificationCenter.current();let settings=await center.notificationSettings()
        guard settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional else {reminderStatus="Chưa cấp quyền thông báo";return}
        let old=await center.pendingNotificationRequests();center.removePendingNotificationRequests(withIdentifiers:old.filter{$0.identifier.hasPrefix("viepn.")}.map(\.identifier))
        let today=SolarDate(Date());var items:[(FamilyEvent,SolarDate,SolarDate)]=[]
        for e in events {for date in e.occurrences(after:today) {for offset in Set([0,e.reminderDays]) {let notify=date.adding(-offset);if notify>=today{items.append((e,date,notify))}}}}
        var added=0
        for (e,date,notify) in items.sorted(by:{$0.2<$1.2}) {
            if added>=60 {break}; var components=DateComponents();components.calendar=SolarDate.calendar;components.timeZone=SolarDate.calendar.timeZone;components.year=notify.year;components.month=notify.month;components.day=notify.day;components.hour=8
            guard let fire=SolarDate.calendar.date(from:components),fire>Date() else{continue}
            let c=UNMutableNotificationContent();c.title=e.title;c.body="Sự kiện ngày \(date.label)";c.sound = .default
            let request=UNNotificationRequest(identifier:"viepn.\(e.id).\(notify.jd)",content:c,trigger:UNCalendarNotificationTrigger(dateMatching:components,repeats:false))
            do {try await center.add(request);added+=1}catch{reminderStatus=error.localizedDescription;return}
        }
        reminderStatus="Đã lập lịch \(added) thông báo gần nhất"
    }
}
@main struct ViePNApp: App {
    @StateObject private var store=FamilyStore()
    @Environment(\.scenePhase) private var scenePhase
    var body: some Scene {WindowGroup { RootView().environmentObject(store).tint(red).onChange(of:scenePhase){_,phase in if phase == .active {Task{await store.schedule()}}} }}
}
struct RootView:View {
    @State private var selection=0
    var body: some View {TabView(selection:$selection){
        NavigationStack{HomeView()}.tabItem{Label("Trang chủ",systemImage:"house")}.tag(0)
        NavigationStack{MonthView()}.tabItem{Label("Lịch",systemImage:"calendar")}.tag(1)
        NavigationStack{GoodDaysView()}.tabItem{Label("Ngày tốt",systemImage:"star")}.tag(2)
        NavigationStack{CultureView()}.tabItem{Label("Văn hóa",systemImage:"book")}.tag(3)
        NavigationStack{SettingsView()}.tabItem{Label("Cài đặt",systemImage:"gearshape")}.tag(4)
    }.onOpenURL{url in if url.scheme=="viepnlichviet" {selection=0}} }
}
struct Surface<Content:View>:View {
    @ViewBuilder var content:Content
    var body:some View {content.padding(14).frame(maxWidth:.infinity,alignment:.leading).background(Color(uiColor:.secondarySystemGroupedBackground),in:RoundedRectangle(cornerRadius:18)).overlay(RoundedRectangle(cornerRadius:18).strokeBorder(Color.primary.opacity(0.055)))}
}
struct AssetIcon:View {let name:String;var body:some View{Image(name).resizable().scaledToFit().frame(width:35,height:35).accessibilityHidden(true)}}
struct HomeView:View {
    @EnvironmentObject var store:FamilyStore
    @State private var date=SolarDate(Date())
    var body:some View {ScrollView{VStack(spacing:14){
        let lunar=LunarEngine.lunar(date)
        VStack(alignment:.leading,spacing:12){
            HStack{Button{if date>SolarDate(1900,1,1){date=date.adding(-1)}}label:{Image(systemName:"chevron.left")};Spacer();Text("ViePN Lịch Việt").font(.headline);Spacer();Button{if date<SolarDate(2100,12,31){date=date.adding(1)}}label:{Image(systemName:"chevron.right")}}.foregroundStyle(.white)
            Button("Hôm nay"){date=SolarDate(Date())}.font(.caption).foregroundStyle(.white)
            NavigationLink{DayView(date:date)}label:{HStack(spacing:0){VStack(spacing:3){Text(date.weekday).font(.headline);Text("\(date.day)").font(.system(size:68,weight:.bold,design:.serif)).foregroundStyle(red);Text("Tháng \(date.month), \(date.year)").font(.subheadline)}.frame(maxWidth:.infinity).padding(.vertical,20).background(.white);VStack(spacing:4){Text("Âm lịch").font(.subheadline);Text("\(lunar.day)").font(.system(size:42,weight:.semibold)).foregroundStyle(red);Text("Tháng \(lunar.month)\(lunar.leap ? " nhuận" : "")");Text(LunarEngine.yearName(lunar.year)).font(.caption)}.frame(maxWidth:.infinity).padding(.vertical,20).background(cream)}.foregroundStyle(.black).clipShape(RoundedRectangle(cornerRadius:18))}.buttonStyle(.plain)
        }.padding(16).background{Image("background_home_red").resizable().scaledToFill().overlay(red.opacity(0.16))}.clipShape(RoundedRectangle(cornerRadius:22))
        NavigationLink{DayView(date:date)}label:{Surface{HStack{Image(systemName:LunarEngine.goodDay(date) ? "leaf.fill":"calendar").foregroundStyle(good);Text(LunarEngine.goodDay(date) ? "Ngày hoàng đạo":"Thông tin ngày");Spacer();Image(systemName:"chevron.right").foregroundStyle(.secondary)}}}.buttonStyle(.plain)
        HStack(spacing:8){NavigationLink{GoodDaysView()}label:{tile("Ngày tốt","icon_star")};NavigationLink{ConvertView()}label:{tile("Đổi ngày","icon_yin_yang")};NavigationLink{CultureView()}label:{tile("Văn hóa","icon_book")};NavigationLink{FamilyView()}label:{tile("Ngày giỗ","icon_bell")}}.buttonStyle(.plain)
        NavigationLink{FamilyView()}label:{Surface{HStack{Image("family_v5_remembrance_frame").resizable().scaledToFit().frame(width:66,height:66);VStack(alignment:.leading){Text("Gia đình Việt").font(.headline);if let e=store.events.compactMap({ e in e.occurrences(after:SolarDate(Date())).first.map{(e,$0)} }).min(by:{$0.1<$1.1}){Text(e.0.title);Text("Còn \(e.1.jd-SolarDate(Date()).jd) ngày").foregroundStyle(red).font(.caption)}else{Text("Lưu ngày giỗ và ngày kỷ niệm").font(.caption).foregroundStyle(.secondary)}};Spacer();Image(systemName:"chevron.right")}}}.buttonStyle(.plain)
        NavigationLink{TermView(index:LunarEngine.termIndex(date))}label:{Surface{HStack{Image("solar_"+LunarEngine.termAssets[LunarEngine.termIndex(date)]).resizable().scaledToFit().frame(width:76,height:76);VStack(alignment:.leading){Text("Tiết khí").font(.caption).foregroundStyle(.secondary);Text(LunarEngine.terms[LunarEngine.termIndex(date)]).font(.headline);Text("Tìm hiểu ý nghĩa").font(.caption)};Spacer();Image(systemName:"chevron.right")}}}.buttonStyle(.plain)
    }.padding()}.background(paper).toolbar(.hidden,for:.navigationBar)}
    func tile(_ title:String,_ name:String)->some View{VStack(spacing:5){AssetIcon(name:name);Text(title).font(.caption2).lineLimit(1)}.frame(maxWidth:.infinity).padding(.vertical,12).background(Color(uiColor:.secondarySystemGroupedBackground),in:RoundedRectangle(cornerRadius:14))}
}
struct MonthView:View {
    @State private var month=SolarDate(Date())
    var first:SolarDate{SolarDate(month.year,month.month,1)}
    var days:Int{SolarDate.calendar.range(of:.day,in:.month,for:first.date!)!.count}
    var offset:Int{(SolarDate.calendar.component(.weekday,from:first.date!)+5)%7}
    var body:some View{ScrollView{Surface{VStack(spacing:18){HStack{Button{change(-1)}label:{Image(systemName:"chevron.left")};Spacer();Text("Tháng \(month.month), \(month.year)").font(.headline).foregroundStyle(red);Spacer();Button{change(1)}label:{Image(systemName:"chevron.right")}};LazyVGrid(columns:Array(repeating:GridItem(.flexible(),spacing:3),count:7),spacing:8){ForEach(["T2","T3","T4","T5","T6","T7","CN"],id:\.self){Text($0).font(.caption).foregroundStyle(.secondary)};ForEach(0..<(offset+days),id:\.self){i in if i<offset{Color.clear.frame(height:46)}else{let s=SolarDate(month.year,month.month,i-offset+1);let l=LunarEngine.lunar(s);let today=s==SolarDate(Date());NavigationLink{DayView(date:s)}label:{VStack(spacing:3){Text("\(s.day)").font(.system(size:17,weight:.semibold));Text(l.day==1 ? "1/\(l.month)":"\(l.day)").font(.caption2)}.foregroundStyle(today ? Color.white : (i%7>=5 ? red:Color.primary)).frame(maxWidth:.infinity,minHeight:46).background(today ? red:Color.clear,in:RoundedRectangle(cornerRadius:12))}.buttonStyle(.plain)}}};Button("Về hôm nay"){month=SolarDate(Date())}}}.padding()}.background(paper).navigationTitle("Lịch tháng")}
    func change(_ n:Int){if let d=SolarDate.calendar.date(byAdding:.month,value:n,to:first.date!){let s=SolarDate(d);if (1900...2100).contains(s.year){month=s}}}
}
struct DayView:View {let date:SolarDate;var body:some View{let l=LunarEngine.lunar(date);ScrollView{VStack(spacing:12){VStack(spacing:8){Text(date.weekday).font(.headline);Text("\(date.day) tháng \(date.month), \(date.year)").font(.title2.bold()).foregroundStyle(red);Text("Âm lịch: \(l.label) · \(LunarEngine.yearName(l.year))").font(.subheadline)}.frame(maxWidth:.infinity).padding(28).background{Image("background_detail_peach").resizable().scaledToFill()}.clipShape(RoundedRectangle(cornerRadius:18));Surface{VStack(alignment:.leading,spacing:12){Label(LunarEngine.goodDay(date) ? "Ngày hoàng đạo":"Ngày không thuộc nhóm hoàng đạo",systemImage:"leaf").font(.headline).foregroundStyle(good);Text("Ngày \(LunarEngine.dayName(date)) · Tháng \(LunarEngine.monthName(l))");Text("Giờ hoàng đạo").font(.headline);Text(LunarEngine.auspiciousHours(date).joined(separator:", ")).font(.subheadline);Text("Theo quy ước lịch dân gian, không phải dự báo khoa học.").font(.caption).foregroundStyle(.secondary)}};NavigationLink{TermView(index:LunarEngine.termIndex(date))}label:{Surface{Label(LunarEngine.terms[LunarEngine.termIndex(date)],systemImage:"sun.max")}}.buttonStyle(.plain)}.padding()}.background(paper).navigationTitle("Chi tiết ngày").navigationBarTitleDisplayMode(.inline)}}
struct GoodDaysView:View{@State private var start=Date();var body:some View{List{DatePicker("Từ ngày",selection:$start,displayedComponents:.date).environment(\.timeZone,SolarDate.calendar.timeZone);Section("Ngày hoàng đạo trong 30 ngày tới"){ForEach((0..<30).map{SolarDate(start).adding($0)}.filter{LunarEngine.goodDay($0)},id:\.self){d in NavigationLink{DayView(date:d)}label:{HStack{Image(systemName:"calendar.badge.checkmark").foregroundStyle(good);VStack(alignment:.leading){Text(d.weekday+", "+d.label).font(.headline);Text("Âm lịch: "+LunarEngine.lunar(d).label).font(.caption).foregroundStyle(.secondary)};Spacer();Text("Tốt").font(.caption).foregroundStyle(good)}}}};Text("Danh sách theo một quy tắc dân gian; không phân loại cưới hỏi, động thổ hoặc khai trương.").font(.caption).foregroundStyle(.secondary)}.navigationTitle("Ngày tốt")}}
struct ConvertView:View{@State private var date=Date();@State private var reverse=false;@State private var day=1;@State private var month=1;@State private var year=2026;@State private var leap=false;var body:some View{Form{Toggle("Âm sang dương",isOn:$reverse);if reverse{Stepper("Ngày: \(day)",value:$day,in:1...30);Stepper("Tháng: \(month)",value:$month,in:1...12);Stepper("Năm: \(year)",value:$year,in:1900...2100);Toggle("Tháng nhuận",isOn:$leap);Text(LunarEngine.solar(.init(year:year,month:month,day:day,leap:leap))?.label ?? "Ngày âm không hợp lệ").font(.title2.bold())}else{DatePicker("Ngày dương",selection:$date,in:SolarDate(1900,1,1).date!...SolarDate(2100,12,31).date!,displayedComponents:.date).environment(\.timeZone,SolarDate.calendar.timeZone);Text(LunarEngine.lunar(SolarDate(date)).label).font(.title2.bold())};Text("Quy ước UTC+7 hiện đại, không tái dựng lịch sử múi giờ.").font(.caption)}.navigationTitle("Đổi ngày âm dương")}}
