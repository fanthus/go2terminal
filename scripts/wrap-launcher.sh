#!/bin/bash
# Wrap the app executable so Option/Shift is checked before Swift starts.
# Finder toolbar launches do not pass modifier keys to the child process.
set -euo pipefail

APP_PATH="${1:?app bundle path required}"

if [[ ! -d "$APP_PATH" ]]; then
    echo "App bundle not found: $APP_PATH" >&2
    exit 1
fi

MACOS="${APP_PATH}/Contents/MacOS"
EXEC_NAME="$(/usr/libexec/PlistBuddy -c "Print CFBundleExecutable" "${APP_PATH}/Contents/Info.plist")"
BINARY="${MACOS}/${EXEC_NAME}"
REAL="${MACOS}/${EXEC_NAME}.real"
HELPER="${MACOS}/${EXEC_NAME}ModifierProbe"

if [[ ! -f "$REAL" && ! -f "$BINARY" ]]; then
    echo "Executable not found: $BINARY" >&2
    exit 1
fi

if [[ ! -f "$REAL" ]]; then
    mv "$BINARY" "$REAL"
fi

build_helper() {
    local source
    source="$(mktemp "${TMPDIR:-/tmp}/go2terminal-modifier-probe.XXXXXX")"
    cat > "$source" <<'C'
#include <ApplicationServices/ApplicationServices.h>
#include <stdbool.h>

static bool modifier_down_in_state(CGEventSourceStateID state) {
    CGEventFlags flags = CGEventSourceFlagsState(state);
    return (flags & kCGEventFlagMaskAlternate) != 0 ||
           (flags & kCGEventFlagMaskShift) != 0;
}

int main(void) {
    return modifier_down_in_state(kCGEventSourceStateHIDSystemState) ||
           modifier_down_in_state(kCGEventSourceStateCombinedSessionState) ? 0 : 1;
}
C

    local compile_args=(-x c "$source" -mmacosx-version-min=13.0 -arch arm64 -arch x86_64 -framework ApplicationServices -o "$HELPER")

    if command -v xcrun >/dev/null 2>&1; then
        xcrun clang "${compile_args[@]}" || {
            rm -f "$source"
            return 1
        }
    else
        /usr/bin/clang "${compile_args[@]}" || {
            rm -f "$source"
            return 1
        }
    fi

    rm -f "$source"
    chmod +x "$HELPER"
}

if ! build_helper; then
    echo "Warning: failed to build native modifier probe; falling back to system Python if available." >&2
    rm -f "$HELPER"
fi

cat > "$BINARY" <<EOF
#!/bin/bash
DIR="\$(cd "\$(dirname "\$0")" && pwd)"
REAL="\${DIR}/${EXEC_NAME}.real"
HELPER="\${DIR}/${EXEC_NAME}ModifierProbe"
ARGS=()

modifier_down() {
    if [[ -x "\$HELPER" ]] && "\$HELPER"; then
        return 0
    fi

    /usr/bin/python3 - <<'PY' 2>/dev/null
import Quartz

state = Quartz.kCGEventSourceStateHIDSystemState
option = Quartz.CGEventSourceKeyState(state, 58) or Quartz.CGEventSourceKeyState(state, 61)
shift = Quartz.CGEventSourceKeyState(state, 56) or Quartz.CGEventSourceKeyState(state, 60)
raise SystemExit(0 if option or shift else 1)
PY
}

if modifier_down; then
    ARGS+=(--settings)
fi

exec "\$REAL" "\${ARGS[@]}" "\$@"
EOF

chmod +x "$BINARY"
echo "Installed launcher wrapper in ${APP_PATH}"
