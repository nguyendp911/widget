import Foundation

/// A cultural reference, not a personality test or a prediction.
struct AnimalGuide: Identifiable {
    let index: Int
    let meaning: String
    let heritage: String
    let strengths: String
    let reflection: String
    var id: String { branch }
    var branch: String { VietnameseLunarCalendar.chi[index] }
    var animal: String { LunarAlmanacFacts.animal(branch) }
    var character: String { ["子","丑","寅","卯","辰","巳","午","未","申","酉","戌","亥"][index] }
    var yinYang: String { index.isMultiple(of: 2) ? "Dương" : "Âm" }
    var element: String { ["Thủy","Thổ","Mộc","Mộc","Thổ","Hỏa","Hỏa","Thổ","Kim","Kim","Thổ","Thủy"][index] }
    var direction: String { ["Bắc","Bắc Đông Bắc","Đông Đông Bắc","Đông","Đông Đông Nam","Nam Đông Nam","Nam","Nam Tây Nam","Tây Tây Nam","Tây","Tây Tây Bắc","Bắc Tây Bắc"][index] }
    var hour: String { String(format: "%02d:00 – %02d:00", (index*2+23)%24, (index*2+1)%24) }
    var opposing: String { VietnameseLunarCalendar.chi[(index+6)%12] }
    var harmony: String { VietnameseLunarCalendar.chi[(13-index)%12] }
    var trine: String { [index,(index+4)%12,(index+8)%12].sorted().map { VietnameseLunarCalendar.chi[$0] }.joined(separator: " · ") }
    var yearExamples: [Int] { (1900...2100).filter { (($0-4)%12+12)%12 == index } }
    static func named(_ branch: String) -> Self? { all.first { $0.branch == branch } }
    static let all: [Self] = [
        .init(index:0, meaning:"Tý đứng đầu vòng 12 Địa Chi. Chuột nhỏ, nhanh, có khả năng thích nghi và tích trữ; trong cách kể dân gian, hình tượng này gợi sự linh hoạt và óc quan sát.", heritage:"Tranh Đông Hồ Đám cưới chuột là ví dụ nổi tiếng về hình tượng chuột trong mỹ thuật Việt. Tác phẩm còn được đọc như một lời châm biếm quan hệ quyền lực, không chỉ là tranh chúc tuổi.", strengths:"Sự nhanh nhạy, biết tính toán, tìm cách giải quyết vấn đề và tận dụng nguồn lực là những phẩm chất thường được gắn với hình tượng Tý.", reflection:"Có thể dùng biểu tượng này để tự hỏi mình đã cân bằng việc chuẩn bị với sự cởi mở, tin cậy và sẵn sàng thử điều mới hay chưa."),
        .init(index:1, meaning:"Sửu là chi thứ hai, ở Việt Nam thường gắn với con trâu nước. Hình tượng trâu nhấn mạnh sức bền, sự kiên nhẫn và lao động bền bỉ.", heritage:"Con trâu gắn với nông nghiệp lúa nước, cày ruộng, đời sống làng quê và hình ảnh mục đồng. Câu nói con trâu là đầu cơ nghiệp phản ánh vai trò kinh tế của trâu trong đời sống nông nghiệp trước đây.", strengths:"Trong cách diễn giải biểu tượng, Sửu thường gợi sự ổn định, trách nhiệm, khả năng làm việc lâu dài và coi trọng kết quả thực chất.", reflection:"Kiên trì không đồng nghĩa với phải giữ nguyên mọi cách làm. Có thể xem đây là lời nhắc kiểm tra lại mục tiêu và đổi phương pháp khi cần."),
        .init(index:2, meaning:"Dần là chi thứ ba, tượng trưng cho hổ. Sức mạnh, sự cảnh giác và dáng vẻ uy nghi là những liên tưởng quen thuộc của hình tượng này.", heritage:"Hổ xuất hiện trong tín ngưỡng dân gian và dòng tranh Hàng Trống, đặc biệt là tranh Ngũ Hổ. Hình ảnh hổ trong đình, đền có thể mang ý nghĩa trấn giữ hoặc bảo hộ theo niềm tin địa phương.", strengths:"Hình tượng hổ thường được dùng để nói về lòng can đảm, chủ động, ý chí bảo vệ và khả năng đối diện thử thách.", reflection:"Sức mạnh có thể đi cùng tự chủ và lắng nghe. Không nên đồng nhất sự quyết đoán với nóng nảy hoặc xem tuổi Dần là căn cứ đánh giá người khác."),
        .init(index:3, meaning:"Mão là chi thứ tư. Trong hệ con giáp Việt Nam, Mão tượng trưng cho mèo, khác với thỏ trong một số truyền thống Đông Á.", heritage:"Mèo gần gũi với đời sống gia đình, kho thóc và không gian làng quê. Hình tượng mèo xuất hiện trong truyện kể, tranh dân gian, chẳng hạn vai mèo trong Đám cưới chuột. Không có một cách giải thích duy nhất được xác nhận cho nguồn gốc việc Việt Nam chọn mèo.", strengths:"Mèo thường gợi sự tinh tế, nhạy bén với môi trường, khéo léo, độc lập và biết giữ khoảng cách.", reflection:"Sự thận trọng có thể hữu ích, nhưng không nhất thiết phải tránh mọi bất đồng. Tính cách và khả năng giao tiếp hình thành từ trải nghiệm cá nhân, không phải từ con giáp."),
        .init(index:4, meaning:"Thìn là chi thứ năm, gắn với rồng — sinh vật huyền thoại duy nhất trong vòng con giáp. Rồng biểu trưng cho sức mạnh, sự hưng thịnh và quyền uy trong nhiều cách diễn giải.", heritage:"Rồng có vị trí nổi bật trong truyền thuyết Lạc Long Quân, mỹ thuật cung đình, kiến trúc đình chùa và tên gọi Thăng Long. Hình dáng rồng Việt thay đổi qua các thời kỳ, chẳng hạn rồng thời Lý và thời Nguyễn.", strengths:"Trong văn hóa biểu tượng, rồng gợi tầm nhìn lớn, sáng tạo, khát vọng và tinh thần đảm nhận trách nhiệm.", reflection:"Khát vọng nên đi cùng kế hoạch và sự tôn trọng người khác. Không có căn cứ khoa học để cho rằng sinh năm Thìn bảo đảm thành công."),
        .init(index:5, meaning:"Tỵ là chi thứ sáu, tượng trưng cho rắn. Hình ảnh rắn thay da thường được liên hệ với thay đổi, tái sinh và sự thích nghi.", heritage:"Rắn và các hình tượng thủy thần xuất hiện trong truyện kể, tín ngưỡng và nghệ thuật ở nhiều vùng. Ý nghĩa của rắn thay đổi theo bối cảnh: vừa có thể gợi sự dè chừng, vừa có thể gắn với sức sống và nước.", strengths:"Những liên tưởng phổ biến gồm sự quan sát, kiên nhẫn, kín đáo, khả năng suy xét trước khi hành động.", reflection:"Có thể lấy sự thay da làm ẩn dụ cho việc học hỏi và bỏ thói quen không còn phù hợp. Không suy diễn sự kín đáo thành tính cách xấu."),
        .init(index:6, meaning:"Ngọ là chi thứ bảy, tượng trưng cho ngựa. Hình tượng ngựa thường gợi sự vận động, hành trình, tự do và sức bền.", heritage:"Ngựa xuất hiện trong lịch sử vận chuyển, quân sự và truyện kể, nổi bật là hình tượng ngựa sắt của Thánh Gióng. Cách nói mã đáo thành công là lời chúc mang tính biểu tượng, không phải dự báo.", strengths:"Ngựa thường được liên hệ với sự nhiệt tình, chủ động, ham khám phá và tinh thần vượt qua giới hạn.", reflection:"Tốc độ cần đi cùng phương hướng. Có thể tự hỏi liệu mình đã dành đủ thời gian cho việc nghỉ ngơi và hoàn thành điều đã bắt đầu hay chưa."),
        .init(index:7, meaning:"Mùi là chi thứ tám; trong cách gọi Việt thường là dê. Hình tượng này gợi sự hiền hòa, linh hoạt và khả năng thích nghi ở địa hình khó.", heritage:"Dê gắn với chăn nuôi, đời sống nông thôn và các biểu tượng mười hai con giáp trong trang trí. Hình ảnh dê, cừu khác nhau giữa các truyền thống, nên không áp dụng cứng nhắc một cách gọi cho mọi nền văn hóa.", strengths:"Dê thường được liên tưởng với sự điềm tĩnh, tinh tế, quan tâm cộng đồng và khả năng tìm lối đi trong hoàn cảnh khó.", reflection:"Sự hòa nhã vẫn cần ranh giới rõ ràng. Việc tự tin trình bày nhu cầu có thể cùng tồn tại với lòng quan tâm người khác."),
        .init(index:8, meaning:"Thân là chi thứ chín, tượng trưng cho khỉ. Sự nhanh nhẹn, tò mò và khéo sử dụng môi trường là các liên tưởng nổi bật.", heritage:"Khỉ xuất hiện trong truyện dân gian, điêu khắc và các câu chuyện chịu ảnh hưởng giao lưu văn hóa. Hình tượng khỉ có thể vừa hài hước vừa gợi trí thông minh và óc ứng biến.", strengths:"Cách đọc biểu tượng thường nhấn mạnh sáng kiến, sự linh hoạt, ham học hỏi và khả năng giải quyết tình huống mới.", reflection:"Nhiều ý tưởng không nhất thiết tạo ra nhiều kết quả. Có thể ưu tiên một việc và theo đuổi đủ lâu để biến sự tò mò thành kỹ năng."),
        .init(index:9, meaning:"Dậu là chi thứ mười, tượng trưng cho gà. Tiếng gà báo sáng gợi nhịp điệu thời gian, sự tỉnh thức và nề nếp.", heritage:"Gà xuất hiện trong tranh Đông Hồ, chẳng hạn tranh Gà đàn, cùng các hình thức trang trí và phong tục gia đình. Ý nghĩa lễ vật thay đổi theo tập quán vùng miền và không phải quy định bắt buộc.", strengths:"Hình tượng gà thường được liên hệ với sự chăm chỉ, rõ ràng, quan sát chi tiết và coi trọng giờ giấc.", reflection:"Kỷ luật có thể giúp ích nếu đi cùng sự linh hoạt. Không cần đòi hỏi bản thân hoặc người khác luôn hoàn hảo."),
        .init(index:10, meaning:"Tuất là chi thứ mười một, tượng trưng cho chó. Hình tượng chó gợi sự gắn bó, cảnh giác và bảo vệ không gian sống.", heritage:"Chó hiện diện trong đời sống gia đình và một số tập quán thờ chó đá ở làng quê Việt. Tục lệ này mang ý nghĩa tín ngưỡng khác nhau tùy nơi, không đại diện cho tất cả người Việt.", strengths:"Các liên tưởng thường gặp gồm sự trung thành, trách nhiệm, tinh thần bảo vệ và coi trọng công bằng.", reflection:"Sự tin cậy được xây dựng từ hành động thực tế. Hãy phân biệt quan tâm với kiểm soát và không đánh giá lòng trung thành chỉ qua năm sinh."),
        .init(index:11, meaning:"Hợi khép lại vòng 12 Địa Chi, tượng trưng cho lợn (heo). Hình tượng này thường gợi sự đủ đầy, sinh sôi và đời sống sung túc.", heritage:"Tranh lợn đàn Đông Hồ nổi bật với hình lợn mẹ, lợn con và các xoáy trang trí; thường mang lời chúc gia đình đầm ấm, sinh sôi. Đây là biểu tượng văn hóa, không phải dấu hiệu của tài lộc chắc chắn.", strengths:"Trong cách diễn giải dân gian, lợn thường gợi sự chân thành, hào sảng, yêu sự bình yên và trân trọng đời sống vật chất giản dị.", reflection:"Tận hưởng cuộc sống có thể đi cùng kế hoạch và giới hạn phù hợp. Không nên quy kết sự giàu nghèo hay tính cách dựa vào tuổi Hợi.")
    ]
}

struct NapAmGuide {
    let name: String
    let element: String
    static let pairs: [(String,String)] = [
        ("Hải Trung Kim","Kim"),("Lư Trung Hỏa","Hỏa"),("Đại Lâm Mộc","Mộc"),("Lộ Bàng Thổ","Thổ"),("Kiếm Phong Kim","Kim"),
        ("Sơn Đầu Hỏa","Hỏa"),("Giản Hạ Thủy","Thủy"),("Thành Đầu Thổ","Thổ"),("Bạch Lạp Kim","Kim"),("Dương Liễu Mộc","Mộc"),
        ("Tuyền Trung Thủy","Thủy"),("Ốc Thượng Thổ","Thổ"),("Tích Lịch Hỏa","Hỏa"),("Tùng Bách Mộc","Mộc"),("Trường Lưu Thủy","Thủy"),
        ("Sa Trung Kim","Kim"),("Sơn Hạ Hỏa","Hỏa"),("Bình Địa Mộc","Mộc"),("Bích Thượng Thổ","Thổ"),("Kim Bạch Kim","Kim"),
        ("Phú Đăng Hỏa","Hỏa"),("Thiên Hà Thủy","Thủy"),("Đại Trạch Thổ","Thổ"),("Thoa Xuyến Kim","Kim"),("Tang Đố Mộc","Mộc"),
        ("Đại Khê Thủy","Thủy"),("Sa Trung Thổ","Thổ"),("Thiên Thượng Hỏa","Hỏa"),("Thạch Lựu Mộc","Mộc"),("Đại Hải Thủy","Thủy")
    ]
    static func lookup(_ canChi: String) -> Self? {
        for i in 0..<60 where VietnameseLunarCalendar.can[i%10] + " " + VietnameseLunarCalendar.chi[i%12] == canChi {
            return Self(name: pairs[i/2].0, element: pairs[i/2].1)
        }
        return nil
    }
}

struct WesternGuide {
    let ruler: String
    let symbol: String
    let archetype: String
    let reflection: String
    static let all: [Self] = [
        .init(ruler:"Sao Hỏa",symbol:"Cừu đực",archetype:"Khởi đầu, hành động, cạnh tranh và dũng khí. Trong chiêm tinh, Bạch Dương mở đầu vòng hoàng đạo và thường được liên hệ với động lực thử điều mới.",reflection:"Tập trung vào cách chủ động nhưng vẫn suy nghĩ trước khi hành động, thay vì xem sự bốc đồng là đặc điểm bắt buộc."),
        .init(ruler:"Sao Kim",symbol:"Bò đực",archetype:"Ổn định, cảm nhận vật chất, thẩm mỹ và giá trị bền vững. Hình tượng bò nhấn mạnh sự kiên trì và nhu cầu xây nền tảng.",reflection:"Có thể xem xét khi nào ổn định hữu ích và khi nào cần chấp nhận thay đổi."),
        .init(ruler:"Sao Thủy",symbol:"Cặp song sinh",archetype:"Giao tiếp, trao đổi, tò mò và nhiều góc nhìn. Biểu tượng song sinh gợi đối thoại, học hỏi và khả năng thay đổi quan điểm.",reflection:"Chọn lọc thông tin, chú ý lắng nghe và hoàn thành việc đã cam kết."),
        .init(ruler:"Mặt Trăng",symbol:"Cua",archetype:"Ký ức, cảm xúc, mái ấm và nhu cầu an toàn. Vỏ cua là hình ảnh ẩn dụ cho việc bảo vệ đời sống riêng tư.",reflection:"Tìm cách cân bằng sự chăm sóc, ranh giới và khả năng nói rõ nhu cầu cá nhân."),
        .init(ruler:"Mặt Trời",symbol:"Sư tử",archetype:"Sáng tạo, biểu đạt, tự tin và mong muốn được ghi nhận. Hình tượng sư tử gợi sự hiện diện và khả năng khích lệ.",reflection:"Thử dùng sức ảnh hưởng để hỗ trợ người khác, không cần đặt giá trị bản thân vào sự chú ý."),
        .init(ruler:"Sao Thủy",symbol:"Thiếu nữ",archetype:"Phân tích, sắp xếp, kỹ năng và việc chăm chút chi tiết. Biểu tượng thu hoạch gợi khả năng phân biệt điều hữu ích và thực hành đều đặn.",reflection:"Duy trì tiêu chuẩn thực tế; học từ sai sót thay vì đòi hỏi sự hoàn hảo."),
        .init(ruler:"Sao Kim",symbol:"Cán cân",archetype:"Hài hòa, hợp tác, công bằng và thẩm mỹ. Cán cân biểu trưng cho việc cân nhắc lợi ích và các quan điểm khác nhau.",reflection:"Tìm sự cân bằng giữa đồng thuận với người khác và quyết định dựa trên giá trị của mình."),
        .init(ruler:"Sao Hỏa (cổ điển); Diêm Vương (hiện đại)",symbol:"Bọ cạp",archetype:"Chiều sâu, thay đổi, sự riêng tư và những điều khó nói. Hình tượng này được dùng để diễn giải quá trình chuyển hóa trong chiêm tinh.",reflection:"Tự quan sát cảm xúc và giao tiếp rõ ràng; không dùng cung này để gán sự nguy hiểm hay bí hiểm cho ai."),
        .init(ruler:"Sao Mộc",symbol:"Cung thủ",archetype:"Khám phá, tri thức, lý tưởng và mở rộng chân trời. Cung tên là ẩn dụ cho mục tiêu và sự hướng tới điều chưa biết.",reflection:"Kết hợp sự cởi mở với kiểm chứng, trách nhiệm và khả năng hoàn thành công việc."),
        .init(ruler:"Sao Thổ",symbol:"Dê biển",archetype:"Kỷ luật, cấu trúc, thời gian và trách nhiệm. Hình tượng leo lên cao gợi thành quả tích lũy qua từng bước.",reflection:"Đặt mục tiêu khả thi, giữ thời gian nghỉ ngơi và không đo toàn bộ giá trị bằng thành tích."),
        .init(ruler:"Sao Thổ (cổ điển); Thiên Vương (hiện đại)",symbol:"Người mang nước",archetype:"Đổi mới, cộng đồng, tư duy độc lập và ý tưởng xã hội. Dù tên và biểu tượng liên quan nước, Bảo Bình được xếp vào nhóm Khí.",reflection:"Thử kết nối ý tưởng mới với nhu cầu thực tế của người xung quanh."),
        .init(ruler:"Sao Mộc (cổ điển); Hải Vương (hiện đại)",symbol:"Hai cá",archetype:"Tưởng tượng, cảm thông, nghệ thuật và sự kết nối. Hai cá tượng trưng cho những hướng cảm nhận khác nhau.",reflection:"Kết hợp trí tưởng tượng với kế hoạch và ranh giới rõ ràng.")
    ]
}
