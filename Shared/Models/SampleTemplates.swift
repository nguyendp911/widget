import Foundation

enum SampleTemplates {
    static let catalog: [WidgetDesign] = [
        .init(name: "Midnight Clock", kind: .clock, title: "Bây giờ", message: "Tận hưởng hiện tại", backgroundHex: "#101625", foregroundHex: "#FFFFFF", accentHex: "#AAB6FF"),
        .init(name: "Sunny Time", kind: .clock, title: "Hello", message: "Ngày mới vui vẻ", backgroundHex: "#FFF5D8", foregroundHex: "#292B36", accentHex: "#E9A33D"),
        .init(name: "Ocean Calendar", kind: .calendar, title: "Hôm nay", message: "Lịch của bạn", backgroundHex: "#074F66", foregroundHex: "#F7FEFF", accentHex: "#8CE4E4"),
        .init(name: "Simple Calendar", kind: .calendar, title: "Today", message: "Mỗi ngày là một cơ hội", backgroundHex: "#F1F4F8", foregroundHex: "#1E293B", accentHex: "#6B83B6"),
        .init(name: "Photo Memories", kind: .photo, title: "Khoảnh khắc", message: "Chạm để lưu kỷ niệm", backgroundHex: "#3F234B", foregroundHex: "#FFFFFF", accentHex: "#F8BEDC"),
        .init(name: "Lovely Photo", kind: .photo, title: "Hạnh phúc", message: "Những điều giản dị", backgroundHex: "#E6D9F2", foregroundHex: "#443351", accentHex: "#8E5CC0"),
        .init(name: "Daily Quote", kind: .quote, title: "Nhắc mình", message: "Bình yên bắt đầu từ những điều nhỏ bé.", backgroundHex: "#222B27", foregroundHex: "#F6FFEE", accentHex: "#C9DE98", fontPreset: .serif),
        .init(name: "Positive Mind", kind: .quote, title: "Động lực", message: "Cứ đi rồi sẽ đến, cứ sống tốt rồi sẽ vui.", backgroundHex: "#F5EBD9", foregroundHex: "#453527", accentHex: "#BC8B53", fontPreset: .serif),
        .init(name: "Big Day", kind: .countdown, title: "Sự kiện sắp tới", message: "Đếm từng ngày", backgroundHex: "#311B43", foregroundHex: "#FFFFFF", accentHex: "#D5B4F4", targetDate: Calendar.current.date(byAdding: .day, value: 30, to: Date())),
        .init(name: "Launch Countdown", kind: .countdown, title: "Ngày ra mắt", message: "Cùng chờ nhé!", backgroundHex: "#12293B", foregroundHex: "#EFF9FF", accentHex: "#7FCAED", targetDate: Calendar.current.date(byAdding: .day, value: 90, to: Date())),
        .init(name: "Drink Water", kind: .habit, title: "Uống đủ nước", message: "Hoàn thành hôm nay", backgroundHex: "#103F4D", foregroundHex: "#FFFFFF", accentHex: "#8BE3F2"),
        .init(name: "Daily Reading", kind: .habit, title: "Đọc sách", message: "10 phút mỗi ngày", backgroundHex: "#433723", foregroundHex: "#FFF8E9", accentHex: "#E8C884")
    ]
}
