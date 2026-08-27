#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."

echo "Building (release)..."
swift build -c release

echo "Generating app icon..."
swift Scripts/generate_icon.swift

echo "Assembling Pomodoro.app..."
rm -rf build/Pomodoro.app
mkdir -p build/Pomodoro.app/Contents/MacOS
mkdir -p build/Pomodoro.app/Contents/Resources

cp .build/release/Pomodoro build/Pomodoro.app/Contents/MacOS/Pomodoro
cp Resources/Info.plist build/Pomodoro.app/Contents/Info.plist
iconutil -c icns build/AppIcon.iconset -o build/Pomodoro.app/Contents/Resources/AppIcon.icns

codesign --force --deep --sign - build/Pomodoro.app

echo ""
echo "Done. Launch with:"
echo "  open build/Pomodoro.app"
