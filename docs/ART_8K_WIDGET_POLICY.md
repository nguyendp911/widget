# ViePN 8K art / Retina WidgetKit policy

Eight independently generated art scenes: Xuân Việt, Trống Đồng, Sen Ngọc, Trăng Tre, Cổng Làng, Cúc Vàng, Vạn Niên, Giỗ Nhà.

**Master exports are 7680×4320 (8K canvas pixels)**, but generated from ~1.6K source images and high-quality upscaled. This must not be represented as native 8K detail. Separate SVG vector art exists in exported desktop pack.

For WidgetKit, use 24 compressed individual family variants: Small 720×720, Medium 1380×720, Large 1240×1240. They are all in `Shared/Lunar/Assets.xcassets` and included in the host and extension target.

Do not display the 8K masters in WidgetKit; they waste memory and can degrade performance. Render calendar date, Can Chi, zodiac commentary, 24 solar terms, auspicious hours and family events using SwiftUI text over protected text surfaces. Do not bake calendar details into images.
