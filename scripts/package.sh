#!/bin/bash
# Build, sign, and zip Go2Terminal.app for distribution.
#
# Usage:
#   ./scripts/package.sh [options]
#
# Options:
#   --skip-test          Skip unit tests before building
#   --sign IDENTITY      Code signing identity (default: ad-hoc "-")
#   --output-dir DIR     Output directory (default: dist)
#   -h, --help           Show help

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

APP_NAME="Go2Terminal"
XCODE_PROJECT="Go2Terminal.xcodeproj"
SCHEME="Go2Terminal"
DERIVED_DATA=".build/xcode"
BUILD_DIR="${DERIVED_DATA}/Build/Products/Release"
DIST_DIR="dist"
SKIP_TEST=false
SIGN_IDENTITY="-"

usage() {
    sed -n '2,11p' "$0" | sed 's/^# \?//'
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --skip-test)
            SKIP_TEST=true
            shift
            ;;
        --sign)
            SIGN_IDENTITY="${2:?missing value for --sign}"
            shift 2
            ;;
        --output-dir)
            DIST_DIR="${2:?missing value for --output-dir}"
            shift 2
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1" >&2
            usage >&2
            exit 1
            ;;
    esac
done

echo "==> Go2Terminal packaging"
echo "    Project:  ${XCODE_PROJECT}"
echo "    Sign:     ${SIGN_IDENTITY}"
echo "    Output:   ${DIST_DIR}/"

if [[ "$SKIP_TEST" == false ]]; then
    echo "==> Running tests..."
    xcodebuild \
        -project "$XCODE_PROJECT" \
        -scheme "$SCHEME" \
        -configuration Debug \
        -derivedDataPath "$DERIVED_DATA" \
        test
else
    echo "==> Skipping tests"
fi

echo "==> Building Release..."
xcodebuild \
    -project "$XCODE_PROJECT" \
    -scheme "$SCHEME" \
    -configuration Release \
    -derivedDataPath "$DERIVED_DATA" \
    build

APP_SRC="${BUILD_DIR}/${APP_NAME}.app"
if [[ ! -d "$APP_SRC" ]]; then
    echo "Build failed: ${APP_SRC} not found" >&2
    exit 1
fi

STAGING="$(mktemp -d)"
trap 'rm -rf "$STAGING"' EXIT

echo "==> Signing ${APP_NAME}.app..."
cp -R "$APP_SRC" "${STAGING}/${APP_NAME}.app"
codesign --force --deep --sign "$SIGN_IDENTITY" "${STAGING}/${APP_NAME}.app"
codesign --verify --verbose=2 "${STAGING}/${APP_NAME}.app"

VERSION="$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" "${STAGING}/${APP_NAME}.app/Contents/Info.plist")"
BUILD_NUM="$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion" "${STAGING}/${APP_NAME}.app/Contents/Info.plist")"
ARCH="$(uname -m)"

mkdir -p "$DIST_DIR"
ZIP_NAME="${APP_NAME}-${VERSION}-build${BUILD_NUM}-${ARCH}.zip"
ZIP_PATH="${DIST_DIR}/${ZIP_NAME}"
CHECKSUM_PATH="${ZIP_PATH}.sha256"

echo "==> Creating ${ZIP_PATH}..."
rm -f "$ZIP_PATH" "$CHECKSUM_PATH"
ditto -c -k --keepParent \
    "${STAGING}/${APP_NAME}.app" \
    "$ZIP_PATH"

shasum -a 256 "$ZIP_PATH" | awk '{print $1}' > "$CHECKSUM_PATH"

ZIP_SIZE="$(du -h "$ZIP_PATH" | awk '{print $1}')"

echo ""
echo "Package ready:"
echo "  App:      ${STAGING}/${APP_NAME}.app (staging, removed on exit)"
echo "  Archive:  ${ZIP_PATH} (${ZIP_SIZE})"
echo "  Checksum: ${CHECKSUM_PATH}"
echo ""
echo "Install: unzip and drag ${APP_NAME}.app to Finder toolbar (hold Command)."
