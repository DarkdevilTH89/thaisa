# Build standalone Windows installer (.exe) for ไทยSA (slug: thaisa)
$ErrorActionPreference = "Stop"

Write-Host "==> 1/4 Building Python sidecar (thaisa-backend.exe) via PyInstaller..." -ForegroundColor Cyan
Push-Location backend
.\.venv\Scripts\pyinstaller.exe --noconfirm --clean thaisa_backend.spec
Pop-Location

Write-Host "==> 2/4 Building React + TypeScript frontend..." -ForegroundColor Cyan
npm.cmd --prefix frontend run build

Write-Host "==> 3/4 Building Electron main & preload scripts..." -ForegroundColor Cyan
npm.cmd --prefix electron run build

Write-Host "==> 4/4 Packaging Windows installer (release/thaisa-*-win-x64.exe)..." -ForegroundColor Cyan
npm.cmd run dist:win

Write-Host "Done! Installer generated under release\" -ForegroundColor Green
