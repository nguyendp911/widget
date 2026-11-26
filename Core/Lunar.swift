import Foundation

struct SolarDate: Codable, Hashable, Comparable {
    let year: Int, month: Int, day: Int
    static var calendar: Calendar { var c = Calendar(identifier: .gregorian); c.timeZone = TimeZone(secondsFromGMT: 25200)!; return c }
    init(_ year: Int, _ month: Int, _ day: Int) { self.year = year; self.month = month; self.day = day }
    init(_ date: Date) { let c = Self.calendar.dateComponents([.year,.month,.day], from: date); self.init(c.year!, c.month!, c.day!) }
    var date: Date? { guard let d = Self.calendar.date(from: DateComponents(year:year,month:month,day:day,hour:12)), SolarDate(d) == self else { return nil }; return d }
    var label: String { "\(day)/\(month)/\(year)" }
    var weekday: String { guard let d = date else { return "" }; return ["Chủ Nhật","Thứ Hai","Thứ Ba","Thứ Tư","Thứ Năm","Thứ Sáu","Thứ Bảy"][Self.calendar.component(.weekday,from:d)-1] }
    static func < (a: Self,b: Self) -> Bool { (a.year,a.month,a.day) < (b.year,b.month,b.day) }
    func adding(_ days: Int) -> Self { SolarDate(Self.calendar.date(byAdding:.day,value:days,to:date!)!) }
    var jd: Int { let a = (14-month)/12, y = year+4800-a, m = month+12*a-3; return day+(153*m+2)/5+365*y+y/4-y/100+y/400-32045 }
}
struct LunarDate: Codable, Hashable {
    let year: Int, month: Int, day: Int, leap: Bool
    var label: String { "\(day)/\(month)\(leap ? " nhuận" : "")/\(year)" }
}
enum LunarEngine {
    static let stems = ["Giáp","Ất","Bính","Đinh","Mậu","Kỷ","Canh","Tân","Nhâm","Quý"]
    static let branches = ["Tý","Sửu","Dần","Mão","Thìn","Tỵ","Ngọ","Mùi","Thân","Dậu","Tuất","Hợi"]
    static let terms = ["Xuân Phân","Thanh Minh","Cốc Vũ","Lập Hạ","Tiểu Mãn","Mang Chủng","Hạ Chí","Tiểu Thử","Đại Thử","Lập Thu","Xử Thử","Bạch Lộ","Thu Phân","Hàn Lộ","Sương Giáng","Lập Đông","Tiểu Tuyết","Đại Tuyết","Đông Chí","Tiểu Hàn","Đại Hàn","Lập Xuân","Vũ Thủy","Kinh Trập"]
    static let termAssets = ["xuan_phan","thanh_minh","coc_vu","lap_ha","tieu_man","mang_chung","ha_chi","tieu_thu","dai_thu","lap_thu","xu_thu","bach_lo","thu_phan","han_lo","suong_giang","lap_dong","tieu_tuyet","dai_tuyet","dong_chi","tieu_han","dai_han","lap_xuan","vu_thuy","kinh_trap"]
    static func mod(_ x:Int,_ n:Int)->Int { (x%n+n)%n }
    static func moon(_ k:Int)->Int {
        let k = Double(k), t = k/1236.85, t2=t*t,t3=t2*t,r=Double.pi/180
        let base=2415020.75933+29.53058868*k+0.0001178*t2-0.000000155*t3+0.00033*sin((166.56+132.87*t-0.009173*t2)*r)
        let m=(359.2242+29.10535608*k-0.0000333*t2-0.00000347*t3)*r
        let p=(306.0253+385.81691806*k+0.0107306*t2+0.00001236*t3)*r
        let f=(21.2964+390.67050646*k-0.0016528*t2-0.00000239*t3)*r
        var c=(0.1734-0.000393*t)*sin(m)+0.0021*sin(2*m)
        c += -0.4068*sin(p)+0.0161*sin(2*p)-0.0004*sin(3*p)+0.0104*sin(2*f)
        c += -0.0051*sin(m+p)-0.0074*sin(m-p)+0.0004*sin(2*f+m)-0.0004*sin(2*f-m)
        c += -0.0006*sin(2*f+p)+0.0010*sin(2*f-p)+0.0005*sin(2*p+m)
        let delta:Double = t < -11 ? 0.001+0.000839*t+0.0002261*t2-0.00000845*t3-0.000000081*t*t3 : -0.000278+0.000265*t+0.000262*t2
        return Int(floor(base+c-delta+0.5+7.0/24))
    }
    static func longitude(_ jd:Double)->Double {
        let t=(jd-2451545)/36525, r=Double.pi/180
        let m=357.52910+35999.05030*t-0.0001559*t*t-0.00000048*t*t*t
        let l=280.46645+36000.76983*t+0.0003032*t*t
        let correction=(1.914600-0.004817*t-0.000014*t*t)*sin(m*r)+(0.019993-0.000101*t)*sin(2*m*r)+0.000290*sin(3*m*r)
        let a=l+correction; return a-360*floor(a/360)
    }
    static func sector(_ jd:Int)->Int { Int(longitude(Double(jd)-0.5-7.0/24)/30) }
    static func month11(_ y:Int)->Int { let k=Int(floor(Double(SolarDate(y,12,31).jd-2415021)/29.530588853)); let n=moon(k); return sector(n)>=9 ? moon(k-1):n }
    static func leapOffset(_ a:Int)->Int {
        let k=Int(floor((Double(a)-2415021.076998695)/29.530588853+0.5)); var previous=sector(moon(k+1)); var i=2
        while i<14 { let next=sector(moon(k+i)); if next==previous {break}; previous=next;i+=1 }; return i-1
    }
    static func lunar(_ s:SolarDate)->LunarDate {
        let j=s.jd,k=Int(floor((Double(j)-2415021.076998695)/29.530588853))
        var n=k; while moon(n)>j {n-=1}; while moon(n+1)<=j {n+=1}; let start=moon(n)
        var a=month11(s.year), b=a, y=s.year
        if a>=start {a=month11(s.year-1)} else {y+=1;b=month11(s.year+1)}
        let diff=(start-a)/29; var m=diff+11, leap=false
        if b-a>365 {let offset=leapOffset(a);if diff>=offset {m=diff+10;leap=diff==offset}}
        if m>12 {m-=12};if m>=11 && diff<4 {y-=1}
        return LunarDate(year:y,month:m,day:j-start+1,leap:leap)
    }
    static func solar(_ l:LunarDate)->SolarDate? {
        guard (1899...2101).contains(l.year),(1...12).contains(l.month),(1...30).contains(l.day) else{return nil}
        let a=month11(l.month<11 ? l.year-1:l.year), b=month11(l.month<11 ? l.year:l.year+1)
        let k=Int(floor((Double(a)-2415021.076998695)/29.530588853+0.5))
        var offset=l.month-11;if offset<0 {offset+=12}
        if b-a>365 { let leap=leapOffset(a); if l.leap && offset != leap-1 {return nil};if l.leap || offset>=leap {offset+=1} } else if l.leap {return nil}
        let j=moon(k+offset)+l.day-1
        let base=SolarDate(2000,1,1);let s=base.adding(j-base.jd)
        return lunar(s)==l ? s:nil
    }
    static func yearName(_ y:Int)->String { stems[mod(y+6,10)]+" "+branches[mod(y+8,12)] }
    static func dayName(_ s:SolarDate)->String { stems[mod(s.jd+9,10)]+" "+branches[mod(s.jd+1,12)] }
    static func monthName(_ l:LunarDate)->String { stems[mod(l.year*12+l.month+3,10)]+" "+branches[mod(l.month+1,12)] }
    static func termIndex(_ s:SolarDate)->Int { Int(longitude(Double(s.jd)-7.0/24)/15) }
    static func auspiciousHours(_ s:SolarDate)->[String] {
        let pairs=[[0,1,3,6,8,9],[2,3,5,8,10,11],[0,1,4,5,7,10],[0,2,3,6,7,9],[2,4,5,8,9,11],[1,4,6,7,10,11]]
        return pairs[mod(s.jd+1,12)%6].map { i in "\(branches[i]) (\(String(format:"%02d",(2*i+23)%24))–\(String(format:"%02d",(2*i+1)%24))h)" }
    }
    static func goodDay(_ s:SolarDate)->Bool { let l=lunar(s); let start=mod(2*(l.month-1),12);return [0,1,4,5,7,10].contains(mod(s.jd+1-start,12)) }
}
