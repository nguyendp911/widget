import Foundation
let fixtures=[(SolarDate(2024,2,10),LunarDate(year:2024,month:1,day:1,leap:false)),(SolarDate(2025,1,29),LunarDate(year:2025,month:1,day:1,leap:false)),(SolarDate(2026,2,17),LunarDate(year:2026,month:1,day:1,leap:false)),(SolarDate(2023,3,22),LunarDate(year:2023,month:2,day:1,leap:true)),(SolarDate(2025,7,25),LunarDate(year:2025,month:6,day:1,leap:true))]
for (s,l) in fixtures { precondition(LunarEngine.lunar(s)==l,"fixture \(s) \(LunarEngine.lunar(s))");precondition(LunarEngine.solar(l)==s) }
var s=SolarDate(1900,1,1), count=0
while s<=SolarDate(2100,12,31) { let l=LunarEngine.lunar(s);if !(1...30).contains(l.day) {print("BAD DAY",s,l);exit(1)};if LunarEngine.solar(l) != s {print("FAIL",s,l);exit(1)};count+=1;s=s.adding(1) }
let event=FamilyEvent(title:"Giỗ",day:1,month:1);precondition(event.occurrences(after:SolarDate(2025,2,1)).first==SolarDate(2026,2,17))
precondition(LunarEngine.solar(.init(year:2024,month:1,day:31,leap:false))==nil)
print("PASS: \(fixtures.count) fixtures, \(count) roundtrips, recurring event, invalid date")
