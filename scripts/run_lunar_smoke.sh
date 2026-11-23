#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
OUTPUT="${TMPDIR:-/tmp}/viepn-lunar-smoke-$$"
trap 'rm -f "$OUTPUT"' EXIT
swiftc -parse-as-library Shared/Lunar/VietnameseLunarCalendar.swift \
       Shared/Lunar/LunarFamilyEvents.swift \
       Shared/Lunar/LunarHighlights.swift \
       Shared/Lunar/LunarICSExporter.swift \
       Shared/Lunar/LunarAppearance.swift \
       Shared/Lunar/LunarCulture.swift \
       scripts/lunar/main.swift -o "$OUTPUT"
"$OUTPUT"
