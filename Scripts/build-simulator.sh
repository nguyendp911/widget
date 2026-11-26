#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
if ! command -v xcodebuild >/dev/null; then echo 'Xcode on macOS is required'; exit 1; fi
xcodebuild -project ViePNLichViet.xcodeproj -scheme ViePNLichViet -configuration Debug -destination 'generic/platform=iOS Simulator' -derivedDataPath build CODE_SIGNING_ALLOWED=NO build
