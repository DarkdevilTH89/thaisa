#!/usr/bin/env bash
# Build standalone macOS disk image (.dmg) for ไทยSA (slug: thaisa)
set -euo pipefail

echo "==> 1/5 Preparing Python virtual environment & sidecar binary..."
cd backend
if [ ! -d ".venv" ]; then
  python3 -m venv .venv
fi
source .venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt pyinstaller
pyinstaller --noconfirm --clean thaisa_backend.spec
deactivate
cd ..

echo "==> 2/5 Installing Node dependencies..."
npm install
npm --prefix frontend install
npm --prefix electron install

echo "==> 3/5 Building React + TypeScript frontend..."
npm --prefix frontend run build

echo "==> 4/5 Building Electron main & preload scripts..."
npm --prefix electron run build

echo "==> 5/5 Packaging macOS .dmg installer (release/thaisa-*-macos-*.dmg)..."
npm run dist:mac

echo "Done! macOS .dmg installer(s) generated under release/"
