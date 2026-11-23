"""Static checks usable on Windows, without Apple SDK / Xcode."""
from pathlib import Path
import plistlib
import sys

root = Path(__file__).resolve().parents[1]
checks = {
    "XcodeGen spec": root / "project.yml",
    "main App": root / "ViePNApp/ViePNWidgetPlusApp.swift",
    "widget extension": root / "WidgetExtension/ViePNWidgets.swift",
    "shared models": root / "Shared/Models/WidgetDesign.swift",
    "shared storage": root / "Shared/Storage/SharedRepository.swift",
    "editor": root / "ViePNApp/Views/WidgetEditorView.swift",
    "tech spec": root / "docs/TECHNICAL_SPEC.md",
}
errors = []
for name, path in checks.items():
    print(("OK" if path.is_file() else "FAIL"), name)
    if not path.is_file(): errors.append(name)
for path in [root / 'ViePNApp/PrivacyInfo.xcprivacy',root / 'WidgetExtension/PrivacyInfo.xcprivacy']:
    try:
        with path.open('rb') as f: manifest=plistlib.load(f)
        assert manifest['NSPrivacyAccessedAPITypes']
        print('OK privacy manifest:',path.relative_to(root))
    except Exception as e: errors.append(str(e))
try:
    import yaml
    spec=yaml.safe_load((root / 'project.yml').read_text(encoding='utf-8'))
    assert {'ViePNWidgetPlus','ViePNWidgets','ViePNTests'} <= set(spec['targets'])
    print('OK project.yml YAML')
except ImportError:
    print('SKIP YAML validation (install PyYAML to enable)')
except Exception as e:
    errors.append('project.yml: '+str(e))
if errors:
    print('FAILED:',errors)
    sys.exit(1)
print('Static validation passed. Real iOS compilation requires macOS + Xcode.')
