import Foundation
struct FamilyEvent: Codable, Identifiable, Hashable {
    var id=UUID(); var title:String; var note:String=""; var day:Int; var month:Int; var lunar:Bool=true; var leap:Bool=false; var clamp:Bool=true; var reminderDays:Int=7
    func occurrences(after today:SolarDate, years:Int=8)->[SolarDate] {
        let y=lunar ? LunarEngine.lunar(today).year:today.year
        return (y...y+years).compactMap { year -> SolarDate? in
            var candidate:SolarDate?
            if lunar { candidate=LunarEngine.solar(.init(year:year,month:month,day:day,leap:leap)); if candidate==nil && clamp && day==30 {candidate=LunarEngine.solar(.init(year:year,month:month,day:29,leap:leap))} }
            else { candidate=SolarDate(year,month,day); if candidate?.date==nil {candidate=clamp && month==2 && day==29 ? SolarDate(year,2,28):nil} }
            guard let candidate, candidate>=today else{return nil};return candidate
        }.sorted()
    }
}
