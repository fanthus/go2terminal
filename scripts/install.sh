#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

APP_NAME="Go2Terminal"
XCODE_PROJECT="Go2Terminal.xcodeproj"
SCHEME="Go2Terminal"
DERIVED_DATA=".build/xcode"
BUILD_DIR="${DERIVED_DATA}/Build/Products/Release"
APP_PATH="${BUILD_DIR}/${APP_NAME}.app"

echo "==> Building Release..."
xcodebuild \
    -project "$XCODE_PROJECT" \
    -scheme "$SCHEME" \
    -configuration Release \
    -derivedDataPath "$DERIVED_DATA" \
    build

if [[ ! -d "$APP_PATH" ]]; then
    echo "Build failed: ${APP_PATH} not found" >&2
    exit 1
fi

echo "==> Installing ${APP_NAME}.app..."
rm -rf "${APP_NAME}.app"
cp -R "$APP_PATH" "${APP_NAME}.app"
bash scripts/codesign.sh "${APP_NAME}.app"
cp -R "${APP_NAME}.app" /Applications/

echo "Installed to /Applications/${APP_NAME}.app"
echo "To add to Finder toolbar: hold Command and drag the app to the toolbar."
