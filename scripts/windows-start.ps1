# From the repository root on Windows PowerShell:
$ErrorActionPreference = 'Stop'
Write-Host 'ViePN Widget+ | source validation' -ForegroundColor Cyan
python .\scripts\validate_source.py
Write-Host 'Open this folder with VS Code / Codex. Use a Mac or macOS GitHub Actions runner for iOS builds.' -ForegroundColor Green
