#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
OUT=$(mktemp -d)
trap 'rm -rf "$OUT"' EXIT
swiftc -O Core/*.swift Tests/main.swift -o "$OUT/test"
"$OUT/test"
