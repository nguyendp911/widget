#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
OUTPUT="${TMPDIR:-/tmp}/viepn-utility-smoke-$$"
trap 'rm -f "$OUTPUT"' EXIT
swiftc Shared/Models/UtilityModels.swift Shared/Storage/UtilityRepository.swift scripts/smoke/main.swift -o "$OUTPUT"
"$OUTPUT"
