from pathlib import Path
import json
import re

root = Path(__file__).resolve().parents[1]
project = (root / "project.yml").read_text(encoding="utf-8")
assert "ViePNWidgets:" not in project, "Widget Extension must not be in the app"
assert "WidgetExtension" not in project
assert "GalleryView" not in project and "UtilityStore" not in project
assert "PRODUCT_BUNDLE_IDENTIFIER: com.viepn.widgetplus" in project
assert "group.com.viepn.widgetplus" in project, "Legacy memorial store must remain accessible"
swift_app = root / "ViePNApp" / "ThienNienVietApp.swift"
assert swift_app.exists() and "@main" in swift_app.read_text()
assert len(list((root / "ViePNApp").rglob("*App.swift"))) == 1
assert not (root / "WidgetExtension").exists()
assets = root / "Shared/Lunar/Assets.xcassets"
for name in ("TNVCloud", "TNVLotus", "TNVBamboo", "TNVBlossom", "TNVMountain", "TNVDrum", "TNVIncense", "TNVLacquerPlaque", "TNVJadePlaque", "TNVPaperPlaque", "ViePNVanNienLarge", "ViePNSenNgocLarge", "ViePNIconCulture",
             "ViePNIconCanChi", "ViePNIconGoodHours", "ViePNIconMemorial"):
    directory = assets / (name + ".imageset")
    data = json.loads((directory / "Contents.json").read_text())
    for item in data["images"]:
        if "filename" in item:
            assert (directory / item["filename"]).is_file(), name
print("Standalone iPhone Lunar app verified, no Widget Extension; legacy bundle ID retained.")
