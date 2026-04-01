#!/bin/bash
set -euo pipefail

APP_NAME="Go2Shell"
BUILD_DIR=".build/release"
BUNDLE_DIR="${APP_NAME}.app"

echo "Creating ${BUNDLE_DIR}..."

rm -rf "${BUNDLE_DIR}"
mkdir -p "${BUNDLE_DIR}/Contents/MacOS"
mkdir -p "${BUNDLE_DIR}/Contents/Resources"

cp "${BUILD_DIR}/${APP_NAME}" "${BUNDLE_DIR}/Contents/MacOS/${APP_NAME}"
cp "Resources/Info.plist" "${BUNDLE_DIR}/Contents/Info.plist"

echo "APPL????" > "${BUNDLE_DIR}/Contents/PkgInfo"

echo "Done. ${BUNDLE_DIR} is ready."
echo "To install: hold Command and drag ${BUNDLE_DIR} to Finder toolbar."
