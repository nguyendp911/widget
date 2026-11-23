#!/usr/bin/env bash
# Run on macOS after installing Xcode and XcodeGen.
set -euo pipefail
cd "$(dirname "$0")/.."
command -v xcodegen >/dev/null || { echo 'Install XcodeGen: brew install xcodegen'; exit 1; }
xcodegen generate
DERIVED="${TMPDIR:-/tmp}/ViePNDerivedData"
xcodebuild -project ViePNWidgetPlus.xcodeproj -scheme ViePNWidgetPlus \
  -configuration Release -sdk iphoneos -destination 'generic/platform=iOS' \
  -derivedDataPath "$DERIVED" CODE_SIGNING_ALLOWED=NO \
  CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY='' build
APP="$DERIVED/Build/Products/Release-iphoneos/ViePNWidgetPlus.app"
test -d "$APP"
STAGING="$(mktemp -d)"
trap 'rm -rf "$STAGING"' EXIT
mkdir -p "$STAGING/Payload" dist
cp -R "$APP" "$STAGING/Payload/"
(cd "$STAGING" && /usr/bin/zip -qry "$OLDPWD/dist/ViePN-WidgetPlus-unsigned.ipa" Payload)
shasum -a 256 dist/ViePN-WidgetPlus-unsigned.ipa
printf 'IPA: %s/dist/ViePN-WidgetPlus-unsigned.ipa\n' "$PWD"
