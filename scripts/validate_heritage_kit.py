from pathlib import Path
import json
import struct

ROOT = Path(__file__).resolve().parents[1]
ASSET_ROOT = ROOT / "Shared/Lunar/Assets.xcassets"
ASSETS = [
    "HeritageTitleRed", "HeritageTitleCream", "HeritageTitleGreen",
    "HeritageActionCalendar", "HeritageActionBell", "HeritageActionHeart",
    "HeritageActionFamily", "HeritageActionSettings", "HeritageActionCulture",
    "HeritageActionSearch", "HeritageActionSend", "HeritageActionBookmark",
    "HeritageActionFavorite", "HeritageFestivalTet", "HeritageFestivalTao",
    "HeritageFestivalVuLan", "HeritageFestivalMidAutumn", "HeritageFestivalGioChap",
    "HeritageFestivalHungKings", "HeritageFestivalDuanNgo", "HeritageFestivalHaNguyen",
    "HeritageFestivalTrungCuu", "HeritageFestivalHanThuc",
    "HeritageNavPrev", "HeritageNavNext", "HeritageNavPrevRed",
    "HeritageNavNextRed", "HeritageNavDate", "HeritageNavAdd",
    "HeritagePatternPaper", "HeritagePatternRed", "HeritagePatternJade", "HeritagePatternGold"
]

def main():
    for name in ASSETS:
        directory = ASSET_ROOT / f"{name}.imageset"
        contents = json.loads((directory / "Contents.json").read_text())
        assert contents["images"][0]["filename"] == name + ".png", name
        content = (directory / f"{name}.png").read_bytes()
        assert content[:8] == b"\x89PNG\r\n\x1a\n", name
        width, height = struct.unpack(">II", content[16:24])
        assert width > 45 and height >= 43, (name, width, height)
    # Separate JPG scenes for Small, Medium, and Large widgets.
    scenes = [
        "ViePNCongLang", "ViePNCucVang", "ViePNGioNha",
        "ViePNSenNgoc", "ViePNTrangTre", "ViePNTrongDong",
        "ViePNVanNien", "ViePNXuanViet"
    ]
    for scene in scenes:
        for family in ("Small", "Medium", "Large"):
            name = scene + family
            directory = ASSET_ROOT / f"{name}.imageset"
            contents = json.loads((directory / "Contents.json").read_text())
            assert contents["images"][0]["filename"] == name + ".jpg", name
            image = (directory / f"{name}.jpg").read_bytes()
            assert image[:3] == bytes((255, 216, 255)), name
    vector_ui = (ROOT / "Shared/Lunar/LunarVectorUI.swift").read_text()
    cards = (ROOT / "Shared/Lunar/LunarWidgetCards.swift").read_text()
    for title in ["CAN CHI THÁNG / NĂM", "SAO · TRỰC", "TIẾT KHÍ",
                  "Giờ hoàng đạo", "Tử vi dân gian", "LunarVectorFact", "LunarVectorIcon"]:
        assert title in cards + vector_ui, title
    swift = (ROOT / "Shared/Lunar/LunarHeritageComponents.swift").read_text()
    calendar = (ROOT / "ViePNApp/Views/Lunar/LunarCalendarHomeView.swift").read_text()
    widget = (ROOT / "Shared/Lunar/LunarWidgetCards.swift").read_text()
    for term in ["HeritageFestivalTet", "HeritageActionCalendar", "HeritageNavPrev", "HeritageTitleCream", "HeritagePatternPaper"]:
        assert term in swift + calendar + widget, term
    print(f"Verified {len(ASSETS)} extra user heritage assets, all parseable PNGs with Xcode imageset metadata")

if __name__ == "__main__":
    main()
