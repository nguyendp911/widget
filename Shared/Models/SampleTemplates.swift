import Foundation

enum SampleTemplates {
    static let catalog: [WidgetDesign] = {
        var result: [WidgetDesign] = []
        let selections: [(LivingScene, WidgetKind, String, String, String)] = [
            (.aurora, .clock, "Northern Lights", "LIVE IN THE MOMENT", "Một ngày mới, một cơ hội mới."),
            (.cosmos, .smart, "Cosmic Control", "YOUR DAILY UNIVERSE", "3 mục tiêu quan trọng hôm nay"),
            (.zen, .quote, "Zen Morning", "STAY PRESENT", "Bình yên bắt đầu từ những điều nhỏ bé."),
            (.neon, .clock, "Midnight Tokyo", "AFTER DARK", "The city never sleeps."),
            (.dream, .memory, "Our Memories", "SPECIAL MOMENTS", "Mỗi ngày bên nhau là một món quà."),
            (.noir, .calendar, "Noir Calendar", "TIME IS ART", "Make today count."),
            (.cosmos, .countdown, "Stardust Countdown", "THE BIG DAY", "Đến ngày quan trọng"),
            (.aurora, .habit, "Aurora Ritual", "DAILY RITUAL", "Đọc sách 15 phút"),
            (.neon, .photo, "Neon Portrait", "MY PERSPECTIVE", "Capture the moment."),
            (.zen, .smart, "Mindful Day", "BREATHE & FOCUS", "Hôm nay mình sẽ sống chậm."),
            (.dream, .quote, "Soft Dreams", "A LITTLE MAGIC", "Đừng ngại bắt đầu lại từ đầu."),
            (.noir, .memory, "Monochrome Memory", "FOREVER & ALWAYS", "Những kỷ niệm đẹp nhất")
        ]
        for (scene, kind, name, title, message) in selections {
            var design = WidgetDesign.fresh(kind, scene: scene)
            design.name = name; design.title = title; design.message = message
            if kind == .clock || kind == .quote {
                var main = CanvasLayer.make(kind == .clock ? .clock : .text, foreground: design.foregroundHex)
                main.x = 0.5; main.y = 0.48; main.scale = kind == .clock ? 1.6 : 1.1
                main.text = message
                var label = CanvasLayer.make(.text, foreground: design.foregroundHex)
                label.text = title; label.x = 0.5; label.y = 0.16; label.scale = 0.52; label.opacity = 0.8
                design.layers = [main, label]
            }
            result.append(design)
        }
        return result
    }()
}
