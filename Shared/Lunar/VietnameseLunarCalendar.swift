import Foundation

/// Astronomy-based Vietnamese lunisolar calendar (UTC+7 civil days).
/// Supported: Gregorian 1900...2100. The approximation must be checked against
/// published Vietnamese lunar reference tables, especially near midnight/new moon.
struct SolarCivilDate: Codable, Equatable, Hashable, Comparable {
    let year: Int
    let month: Int
    let day: Int

    static func < (lhs: Self, rhs: Self) -> Bool {
        [lhs.year, lhs.month, lhs.day].lexicographicallyPrecedes([rhs.year, rhs.month, rhs.day])
    }

    init(year: Int, month: Int, day: Int) {
        self.year = year; self.month = month; self.day = day
    }

    init?(date: Date, timeZone: TimeZone = VietnameseLunarCalendar.vietnamTimeZone) {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        let c = calendar.dateComponents([.day, .month, .year], from: date)
        guard let day = c.day, let month = c.month, let year = c.year else { return nil }
        self.init(year: year, month: month, day: day)
    }

    func asDate(hour: Int = 12, timeZone: TimeZone = VietnameseLunarCalendar.vietnamTimeZone) -> Date? {
        var c = Calendar(identifier: .gregorian)
        c.timeZone = timeZone
        return c.date(from: DateComponents(timeZone: timeZone, year: year, month: month, day: day, hour: hour))
    }

    var label: String { String(format: "%02d/%02d/%04d", day, month, year) }
}

struct VietnameseLunarDate: Codable, Equatable, Hashable {
    var day: Int
    var month: Int
    var year: Int
    var isLeapMonth: Bool
    var label: String { "\(day)/\(month)\(isLeapMonth ? " nhuận" : "")/\(year)" }
}

struct CanChi: Codable, Equatable {
    let day: String
    let month: String
    let year: String
}

struct LunarSolarTerm: Codable, Equatable {
    let name: String
    let startsToday: Bool
}

/// Port of the published Ho Ngoc Duc / Jean Meeus new-moon and apparent-solar-longitude
/// approximations. Astronomical new-moon date depends on UTC+7; do not use the device
/// time zone to calculate lunar month boundaries.
enum VietnameseLunarCalendar {
    static let vietnamTimeZone = TimeZone(secondsFromGMT: 7 * 3600)!
    static let can = ["Giáp", "Ất", "Bính", "Đinh", "Mậu", "Kỷ", "Canh", "Tân", "Nhâm", "Quý"]
    static let chi = ["Tý", "Sửu", "Dần", "Mão", "Thìn", "Tỵ", "Ngọ", "Mùi", "Thân", "Dậu", "Tuất", "Hợi"]
    /// Beginning at Sun's ecliptic longitude 0° (Xuân phân), counterclockwise in 15° intervals.
    static let terms = ["Xuân phân", "Thanh minh", "Cốc vũ", "Lập hạ", "Tiểu mãn", "Mang chủng", "Hạ chí", "Tiểu thử", "Đại thử", "Lập thu", "Xử thử", "Bạch lộ", "Thu phân", "Hàn lộ", "Sương giáng", "Lập đông", "Tiểu tuyết", "Đại tuyết", "Đông chí", "Tiểu hàn", "Đại hàn", "Lập xuân", "Vũ thủy", "Kinh trập"]
    private static let pi = Double.pi
    private static let rad = pi / 180
    private static func norm(_ x: Int, _ n: Int) -> Int { (x % n + n) % n }

    static func isValid(_ solar: SolarCivilDate) -> Bool {
        guard (1900...2100).contains(solar.year), let date = solar.asDate(),
              let check = SolarCivilDate(date: date) else { return false }
        return solar == check
    }

    static func jdn(_ d: SolarCivilDate) -> Int {
        let a = (14 - d.month) / 12
        let y = d.year + 4800 - a
        let m = d.month + 12 * a - 3
        return d.day + (153 * m + 2) / 5 + 365 * y + y / 4 - y / 100 + y / 400 - 32045
    }

    static func civilDate(_ jd: Int) -> SolarCivilDate {
        let a = jd + 32044
        let b = (4 * a + 3) / 146097
        let c = a - (146097 * b) / 4
        let d = (4 * c + 3) / 1461
        let e = c - (1461 * d) / 4
        let m = (5 * e + 2) / 153
        return SolarCivilDate(year: 100 * b + d - 4800 + m / 10, month: m + 3 - 12 * (m / 10), day: e - (153 * m + 2) / 5 + 1)
    }

    /// Julian day number of the local civil day containing the astronomical new moon.
    static func newMoonDay(_ k: Int) -> Int {
        let t = Double(k) / 1236.85
        let t2 = t * t
        let t3 = t2 * t
        let jd1 = 2415020.75933 + 29.53058868 * Double(k) + 0.0001178 * t2 - 0.000000155 * t3
            + 0.00033 * sin((166.56 + 132.87 * t - 0.009173 * t2) * rad)
        let m = 359.2242 + 29.10535608 * Double(k) - 0.0000333 * t2 - 0.00000347 * t3
        let mp = 306.0253 + 385.81691806 * Double(k) + 0.0107306 * t2 + 0.00001236 * t3
        let f = 21.2964 + 390.67050646 * Double(k) - 0.0016528 * t2 - 0.00000239 * t3
        let c1 = (0.1734 - 0.000393 * t) * sin(m * rad) + 0.0021 * sin(2 * m * rad)
            - 0.4068 * sin(mp * rad) + 0.0161 * sin(2 * mp * rad) - 0.0004 * sin(3 * mp * rad)
            + 0.0104 * sin(2 * f * rad) - 0.0051 * sin((m + mp) * rad)
            - 0.0074 * sin((m - mp) * rad) + 0.0004 * sin((2 * f + m) * rad)
            - 0.0004 * sin((2 * f - m) * rad) - 0.0006 * sin((2 * f + mp) * rad)
            + 0.001 * sin((2 * f - mp) * rad) + 0.0005 * sin((2 * mp + m) * rad)
        let deltaT: Double = t < -11
            ? 0.001 + 0.000839 * t + 0.0002261 * t2 - 0.00000845 * t3 - 0.000000081 * t * t3
            : -0.000278 + 0.000265 * t + 0.000262 * t2
        return Int(floor(jd1 + c1 - deltaT + 0.5 + 7.0 / 24.0))
    }

    /// Approximate ecliptic longitude of the Sun in degrees at Julian Date `jd`.
    private static func longitude(_ jd: Double) -> Double {
        let t = (jd - 2451545.0) / 36525.0
        let t2 = t * t
        let m = (357.52910 + 35999.05030 * t - 0.0001559 * t2 - 0.00000048 * t * t2) * rad
        let l0 = 280.46645 + 36000.76983 * t + 0.0003032 * t2
        let dl = (1.914600 - 0.004817 * t - 0.000014 * t2) * sin(m)
            + (0.019993 - 0.000101 * t) * sin(2 * m) + 0.000290 * sin(3 * m)
        let value = (l0 + dl).truncatingRemainder(dividingBy: 360)
        return value < 0 ? value + 360 : value
    }

    /// Midnight in Viet Nam in astronomical Julian Date scale.
    private static func vietnamMidnightJD(_ jd: Int) -> Double { Double(jd) - 0.5 - 7.0 / 24.0 }
    private static func majorTerm(_ jdn: Int) -> Int {
        Int(floor(longitude(vietnamMidnightJD(jdn)) / 30.0))
    }

    static func solarTerm(on date: SolarCivilDate) -> LunarSolarTerm {
        let j = jdn(date)
        let today = Int(floor(longitude(vietnamMidnightJD(j)) / 15.0))
        let tomorrow = Int(floor(longitude(vietnamMidnightJD(j + 1)) / 15.0))
        let term = norm(tomorrow, 24)
        return LunarSolarTerm(name: terms[term], startsToday: today != tomorrow)
    }

    private static func month11(_ year: Int) -> Int {
        let off = jdn(SolarCivilDate(year: year, month: 12, day: 31)) - 2415021
        let k = Int(floor(Double(off) / 29.530588853))
        let moon = newMoonDay(k)
        return majorTerm(moon) >= 9 ? newMoonDay(k - 1) : moon
    }

    private static func leapOffset(_ a11: Int) -> Int {
        let k = Int(floor(0.5 + (Double(a11) - 2415021.076998695) / 29.530588853))
        var last = 0
        var i = 1
        var arc = majorTerm(newMoonDay(k + i))
        repeat {
            last = arc
            i += 1
            arc = majorTerm(newMoonDay(k + i))
        } while arc != last && i < 14
        return i - 1
    }

    static func solarToLunar(_ solar: SolarCivilDate) -> VietnameseLunarDate? {
        guard isValid(solar) else { return nil }
        let j = jdn(solar)
        // Mean-cycle estimate can land one lunation too late near a new moon.
        // Bracket the day explicitly; otherwise rare dates produce lunar day 0.
        var k = Int(floor((Double(j) - 2415021.076998695) / 29.530588853))
        while newMoonDay(k) > j { k -= 1 }
        while newMoonDay(k + 1) <= j { k += 1 }
        let start = newMoonDay(k)
        var a11 = month11(solar.year)
        var b11 = a11
        var year: Int
        if a11 >= start { year = solar.year; a11 = month11(solar.year - 1) }
        else { year = solar.year + 1; b11 = month11(solar.year + 1) }
        let diff = Int(floor(Double(start - a11) / 29))
        var month = diff + 11
        var leap = false
        if b11 - a11 > 365 {
            let leapDiff = leapOffset(a11)
            if diff >= leapDiff {
                month = diff + 10
                if diff == leapDiff { leap = true }
            }
        }
        if month > 12 { month -= 12 }
        if month >= 11 && diff < 4 { year -= 1 }
        return VietnameseLunarDate(day: j - start + 1, month: month, year: year, isLeapMonth: leap)
    }

    /// Returns nil for impossible dates (day 30 in a 29-day lunar month, nonexistent leap month).
    static func lunarToSolar(_ lunar: VietnameseLunarDate) -> SolarCivilDate? {
        guard (1...12).contains(lunar.month), (1...30).contains(lunar.day), (1899...2100).contains(lunar.year) else { return nil }
        let a11: Int
        let b11: Int
        if lunar.month < 11 { a11 = month11(lunar.year - 1); b11 = month11(lunar.year) }
        else { a11 = month11(lunar.year); b11 = month11(lunar.year + 1) }
        var off = lunar.month - 11
        if off < 0 { off += 12 }
        if b11 - a11 > 365 {
            let leapOff = leapOffset(a11)
            var leapMonth = leapOff - 2
            if leapMonth < 0 { leapMonth += 12 }
            if lunar.isLeapMonth && lunar.month != leapMonth { return nil }
            if lunar.isLeapMonth || off >= leapOff { off += 1 }
        } else if lunar.isLeapMonth { return nil }
        let k = Int(floor(0.5 + (Double(a11) - 2415021.076998695) / 29.530588853))
        let solar = civilDate(newMoonDay(k + off) + lunar.day - 1)
        guard solarToLunar(solar) == lunar else { return nil }
        return solar
    }

    static func monthLength(month: Int, year: Int, leap: Bool = false) -> Int? {
        let begin = VietnameseLunarDate(day: 1, month: month, year: year, isLeapMonth: leap)
        guard let date = lunarToSolar(begin) else { return nil }
        let solar = civilDate(jdn(date) + 29)
        return solarToLunar(solar)?.month == month && solarToLunar(solar)?.isLeapMonth == leap ? 30 : 29
    }

    static func leapMonth(in year: Int) -> Int? {
        for month in 1...12 where lunarToSolar(VietnameseLunarDate(day: 1, month: month, year: year, isLeapMonth: true)) != nil {
            return month
        }
        return nil
    }

    static func canChi(_ solar: SolarCivilDate) -> CanChi? {
        guard let lunar = solarToLunar(solar) else { return nil }
        let j = jdn(solar)
        return CanChi(day: "\(can[norm(j + 9, 10)]) \(chi[norm(j + 1, 12)])",
                      month: "\(can[norm(lunar.year * 12 + lunar.month + 3, 10)]) \(chi[norm(lunar.month + 1, 12)])",
                      year: "\(can[norm(lunar.year + 6, 10)]) \(chi[norm(lunar.year + 8, 12)])")
    }

    static func luckyHours(_ solar: SolarCivilDate) -> [String] {
        let dayChi = norm(jdn(solar) + 1, 12)
        // Based on the 12 cyclic spirits of the hour, starting Thanh Long at the
        // branch: Thân/Tuất/Tý/Dần/Thìn/Ngọ for Tý/ Sửu/ Dần/ Mão/ Thìn/ Tỵ groups.
        let start = [8, 10, 0, 2, 4, 6][dayChi % 6]
        let goodSpirits = Set([0, 1, 4, 5, 7, 10])
        return (0..<12).filter { goodSpirits.contains(norm($0 - start, 12)) }.map { chi[$0] }
    }

    /// Traditional cycle; month branch is based on solar term (not lunar month).
    /// Cultural reference only: different almanac traditions can disagree.
    static func traditionalDayInfo(_ solar: SolarCivilDate) -> (spirit: String, auspicious: Bool, officer: String) {
        let spirits = ["Thanh Long", "Minh Đường", "Thiên Hình", "Chu Tước", "Kim Quỹ", "Bảo Quang", "Bạch Hổ", "Ngọc Đường", "Thiên Lao", "Huyền Vũ", "Tư Mệnh", "Câu Trần"]
        let officers = ["Kiến", "Trừ", "Mãn", "Bình", "Định", "Chấp", "Phá", "Nguy", "Thành", "Thu", "Khai", "Bế"]
        let j = jdn(solar)
        let dayBranch = norm(j + 1, 12)
        // Solar-term month: Dần from Lập xuân (315°), then advances every 30°.
        let longitudeToday = longitude(vietnamMidnightJD(j) + 0.5)
        let monthBranch = norm(Int(floor((longitudeToday - 315 + 360).truncatingRemainder(dividingBy: 360) / 30)) + 2, 12)
        // Thanh Long starts at the branch of the solar-term month, shifted by 10.
        let solarMonthIndex = norm(monthBranch - 2, 12)
        let startSpirit = norm(0 - 2 * (solarMonthIndex % 6), 12)
        let spiritIndex = norm(dayBranch - startSpirit, 12)
        return (spirits[spiritIndex], [0, 1, 4, 5, 7, 10].contains(spiritIndex), officers[norm(dayBranch - monthBranch, 12)])
    }
}
