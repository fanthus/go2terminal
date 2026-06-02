#!/bin/bash
set -euo pipefail

APP_PATH="${1:-Go2Terminal.app}"

if [[ ! -d "$APP_PATH" ]]; then
    echo "App bundle not found: $APP_PATH" >&2
    exit 1
fi

echo "Signing $APP_PATH..."
codesign --force --deep --sign - "$APP_PATH"
codesign --verify --verbose=2 "$APP_PATH"
echo "Signed successfully."
