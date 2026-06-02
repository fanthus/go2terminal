# Go2Terminal Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a macOS Finder toolbar utility that opens a terminal window at the current Finder directory.

**Architecture:** Swift macOS app using NSAppleScript to query Finder and control Terminal.app/iTerm2. Built with Swift Package Manager (library + executable targets) and packaged into a .app bundle via a build script.

**Tech Stack:** Swift, AppKit, NSAppleScript, Swift Package Manager, XCTest

---

## File Structure

```
Go2Terminal/
├── Package.swift                          # SPM manifest: Go2TerminalLib, Go2Terminal, Go2TerminalTests
├── Sources/
│   ├── Go2Terminal/
│   │   └── main.swift                     # Entry point: launches NSApplication
│   └── Go2TerminalLib/
│       ├── AppDelegate.swift              # NSApplicationDelegate, Option key detection
│       ├── TerminalType.swift             # Enum: terminal/iTerm2, UserDefaults read/write
│       ├── FinderPathResolver.swift       # AppleScript generation + execution for Finder path
│       ├── TerminalLauncher.swift         # AppleScript generation + execution to open terminal
│       └── PreferencesWindowController.swift  # NSWindowController with terminal dropdown
├── Tests/
│   └── Go2TerminalTests/
│       ├── TerminalTypeTests.swift        # TerminalType enum + preferences tests
│       ├── FinderPathResolverTests.swift  # AppleScript string generation tests
│       └── TerminalLauncherTests.swift    # AppleScript string generation tests
├── Resources/
│   └── Info.plist                         # LSUIElement=YES, bundle ID, version
├── scripts/
│   └── bundle.sh                          # Packages binary into .app bundle
└── Makefile                               # Build, test, bundle commands
```

---

### Task 1: Project Scaffolding

**Files:**
- Create: `Package.swift`
- Create: `Sources/Go2Terminal/main.swift`
- Create: `Sources/Go2TerminalLib/AppDelegate.swift` (placeholder)
- Create: `Makefile`

- [ ] **Step 1: Create Package.swift**

```swift
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Go2Terminal",
    platforms: [.macOS(.v12)],
    targets: [
        .target(
            name: "Go2TerminalLib",
            path: "Sources/Go2TerminalLib"
        ),
        .executableTarget(
            name: "Go2Terminal",
            dependencies: ["Go2TerminalLib"],
            path: "Sources/Go2Terminal"
        ),
        .testTarget(
            name: "Go2TerminalTests",
            dependencies: ["Go2TerminalLib"],
            path: "Tests/Go2TerminalTests"
        ),
    ]
)
```

- [ ] **Step 2: Create minimal main.swift**

File: `Sources/Go2Terminal/main.swift`

```swift
import AppKit
import Go2TerminalLib

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
```

- [ ] **Step 3: Create placeholder AppDelegate**

File: `Sources/Go2TerminalLib/AppDelegate.swift`

```swift
import AppKit

public class AppDelegate: NSObject, NSApplicationDelegate {
    public override init() {
        super.init()
    }

    public func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.terminate(nil)
    }
}
```

- [ ] **Step 4: Create Makefile**

```makefile
.PHONY: build test bundle clean

build:
	swift build -c release

test:
	swift test

bundle: build
	bash scripts/bundle.sh

clean:
	swift package clean
	rm -rf Go2Terminal.app
```

- [ ] **Step 5: Verify build**

Run: `cd /Users/fanthus/Documents/fanthus/go2terminal && swift build`
Expected: Build succeeds with no errors.

- [ ] **Step 6: Commit**

```bash
git add Package.swift Sources/ Makefile
git commit -m "feat: project scaffolding with SPM"
```

---

### Task 2: TerminalType Enum and Preferences

**Files:**
- Create: `Sources/Go2TerminalLib/TerminalType.swift`
- Create: `Tests/Go2TerminalTests/TerminalTypeTests.swift`

- [ ] **Step 1: Write failing tests**

File: `Tests/Go2TerminalTests/TerminalTypeTests.swift`

```swift
import XCTest
@testable import Go2TerminalLib

final class TerminalTypeTests: XCTestCase {
    override func setUp() {
        super.setUp()
        UserDefaults.standard.removeObject(forKey: "terminalType")
    }

    func testDefaultTerminalType() {
        let terminalType = TerminalType.preferred
        XCTAssertEqual(terminalType, .terminal)
    }

    func testSaveAndLoadTerminal() {
        TerminalType.terminal.saveAsPreferred()
        XCTAssertEqual(TerminalType.preferred, .terminal)
    }

    func testSaveAndLoadITerm() {
        TerminalType.iTerm2.saveAsPreferred()
        XCTAssertEqual(TerminalType.preferred, .iTerm2)
    }

    func testRawValues() {
        XCTAssertEqual(TerminalType.terminal.rawValue, "terminal")
        XCTAssertEqual(TerminalType.iTerm2.rawValue, "iTerm2")
    }

    func testDisplayName() {
        XCTAssertEqual(TerminalType.terminal.displayName, "Terminal")
        XCTAssertEqual(TerminalType.iTerm2.displayName, "iTerm2")
    }

    func testAppName() {
        XCTAssertEqual(TerminalType.terminal.appName, "Terminal")
        XCTAssertEqual(TerminalType.iTerm2.appName, "iTerm")
    }
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `swift test --filter TerminalTypeTests 2>&1 | tail -5`
Expected: Compilation error — `TerminalType` not defined.

- [ ] **Step 3: Implement TerminalType**

File: `Sources/Go2TerminalLib/TerminalType.swift`

```swift
import Foundation

public enum TerminalType: String, CaseIterable {
    case terminal = "terminal"
    case iTerm2 = "iTerm2"

    private static let userDefaultsKey = "terminalType"

    public var displayName: String {
        switch self {
        case .terminal: return "Terminal"
        case .iTerm2: return "iTerm2"
        }
    }

    public var appName: String {
        switch self {
        case .terminal: return "Terminal"
        case .iTerm2: return "iTerm"
        }
    }

    public static var preferred: TerminalType {
        guard let raw = UserDefaults.standard.string(forKey: userDefaultsKey),
              let type = TerminalType(rawValue: raw) else {
            return .terminal
        }
        return type
    }

    public func saveAsPreferred() {
        UserDefaults.standard.set(rawValue, forKey: TerminalType.userDefaultsKey)
    }
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `swift test --filter TerminalTypeTests 2>&1 | tail -5`
Expected: All 6 tests pass.

- [ ] **Step 5: Commit**

```bash
git add Sources/Go2TerminalLib/TerminalType.swift Tests/Go2TerminalTests/TerminalTypeTests.swift
git commit -m "feat: add TerminalType enum with UserDefaults persistence"
```

---

### Task 3: FinderPathResolver

**Files:**
- Create: `Sources/Go2TerminalLib/FinderPathResolver.swift`
- Create: `Tests/Go2TerminalTests/FinderPathResolverTests.swift`

- [ ] **Step 1: Write failing tests for script generation**

File: `Tests/Go2TerminalTests/FinderPathResolverTests.swift`

```swift
import XCTest
@testable import Go2TerminalLib

final class FinderPathResolverTests: XCTestCase {
    func testAppleScriptSource() {
        let script = FinderPathResolver.appleScriptSource
        XCTAssertTrue(script.contains("tell application \"Finder\""))
        XCTAssertTrue(script.contains("count of Finder windows"))
        XCTAssertTrue(script.contains("POSIX path"))
        XCTAssertTrue(script.contains("path to home folder"))
    }
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `swift test --filter FinderPathResolverTests 2>&1 | tail -5`
Expected: Compilation error — `FinderPathResolver` not defined.

- [ ] **Step 3: Implement FinderPathResolver**

File: `Sources/Go2TerminalLib/FinderPathResolver.swift`

```swift
import Foundation

public enum FinderPathResolver {
    static let appleScriptSource = """
        tell application "Finder"
            if (count of Finder windows) > 0 then
                return POSIX path of (target of front Finder window as alias)
            else
                return POSIX path of (path to home folder)
            end if
        end tell
        """

    public static func resolve() -> String {
        let script = NSAppleScript(source: appleScriptSource)
        var error: NSDictionary?
        let result = script?.executeAndReturnError(&error)

        if let error = error {
            NSLog("FinderPathResolver error: %@", error)
            return NSHomeDirectory()
        }

        return result?.stringValue ?? NSHomeDirectory()
    }
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `swift test --filter FinderPathResolverTests 2>&1 | tail -5`
Expected: All tests pass.

- [ ] **Step 5: Commit**

```bash
git add Sources/Go2TerminalLib/FinderPathResolver.swift Tests/Go2TerminalTests/FinderPathResolverTests.swift
git commit -m "feat: add FinderPathResolver with AppleScript Finder path query"
```

---

### Task 4: TerminalLauncher

**Files:**
- Create: `Sources/Go2TerminalLib/TerminalLauncher.swift`
- Create: `Tests/Go2TerminalTests/TerminalLauncherTests.swift`

- [ ] **Step 1: Write failing tests for script generation**

File: `Tests/Go2TerminalTests/TerminalLauncherTests.swift`

```swift
import XCTest
@testable import Go2TerminalLib

final class TerminalLauncherTests: XCTestCase {
    func testTerminalAppScript() {
        let script = TerminalLauncher.appleScriptSource(for: .terminal, path: "/Users/test/Documents")
        XCTAssertTrue(script.contains("tell application \"Terminal\""))
        XCTAssertTrue(script.contains("activate"))
        XCTAssertTrue(script.contains("do script \"cd '/Users/test/Documents'\""))
    }

    func testITermScript() {
        let script = TerminalLauncher.appleScriptSource(for: .iTerm2, path: "/Users/test/Documents")
        XCTAssertTrue(script.contains("tell application \"iTerm\""))
        XCTAssertTrue(script.contains("activate"))
        XCTAssertTrue(script.contains("create window with default profile"))
        XCTAssertTrue(script.contains("write text \"cd '/Users/test/Documents'\""))
    }

    func testPathWithSpaces() {
        let script = TerminalLauncher.appleScriptSource(for: .terminal, path: "/Users/test/My Documents")
        XCTAssertTrue(script.contains("cd '/Users/test/My Documents'"))
    }

    func testPathWithSingleQuote() {
        let script = TerminalLauncher.appleScriptSource(for: .terminal, path: "/Users/test/it's a dir")
        XCTAssertTrue(script.contains("cd '/Users/test/it'\\''s a dir'"))
    }

    func testITermNotInstalledError() {
        let result = TerminalLauncher.isAppInstalled("SomeNonExistentApp12345")
        XCTAssertFalse(result)
    }
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `swift test --filter TerminalLauncherTests 2>&1 | tail -5`
Expected: Compilation error — `TerminalLauncher` not defined.

- [ ] **Step 3: Implement TerminalLauncher**

File: `Sources/Go2TerminalLib/TerminalLauncher.swift`

```swift
import AppKit

public enum TerminalLauncher {
    public static func appleScriptSource(for terminal: TerminalType, path: String) -> String {
        let escapedPath = path.replacingOccurrences(of: "'", with: "'\\''")
        switch terminal {
        case .terminal:
            return """
                tell application "Terminal"
                    activate
                    do script "cd '\(escapedPath)'"
                end tell
                """
        case .iTerm2:
            return """
                tell application "iTerm"
                    activate
                    create window with default profile
                    tell current session of current window
                        write text "cd '\(escapedPath)'"
                    end tell
                end tell
                """
        }
    }

    public static func isAppInstalled(_ appName: String) -> Bool {
        let path = "/Applications/\(appName).app"
        return FileManager.default.fileExists(atPath: path)
    }

    public static func launch(terminal: TerminalType, path: String) -> Bool {
        if terminal == .iTerm2 && !isAppInstalled("iTerm") {
            showITermNotInstalledAlert()
            return false
        }

        let source = appleScriptSource(for: terminal, path: path)
        let script = NSAppleScript(source: source)
        var error: NSDictionary?
        script?.executeAndReturnError(&error)

        if let error = error {
            NSLog("TerminalLauncher error: %@", error)
            showPermissionDeniedAlert()
            return false
        }

        return true
    }

    private static func showITermNotInstalledAlert() {
        let alert = NSAlert()
        alert.messageText = "iTerm2 Not Found"
        alert.informativeText = "iTerm2 is not installed. Please switch to Terminal in preferences, or install iTerm2."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Open Preferences")
        alert.addButton(withTitle: "OK")
        if alert.runModal() == .alertFirstButtonReturn {
            NotificationCenter.default.post(name: .openPreferences, object: nil)
        }
    }

    private static func showPermissionDeniedAlert() {
        let alert = NSAlert()
        alert.messageText = "Permission Required"
        alert.informativeText = "Go2Terminal needs Automation permission. Please enable it in System Settings → Privacy & Security → Automation."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Open System Settings")
        alert.addButton(withTitle: "OK")
        if alert.runModal() == .alertFirstButtonReturn {
            NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Automation")!)
        }
    }
}

public extension Notification.Name {
    static let openPreferences = Notification.Name("openPreferences")
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `swift test --filter TerminalLauncherTests 2>&1 | tail -5`
Expected: All 5 tests pass.

- [ ] **Step 5: Commit**

```bash
git add Sources/Go2TerminalLib/TerminalLauncher.swift Tests/Go2TerminalTests/TerminalLauncherTests.swift
git commit -m "feat: add TerminalLauncher with Terminal.app and iTerm2 support"
```

---

### Task 5: PreferencesWindowController

**Files:**
- Create: `Sources/Go2TerminalLib/PreferencesWindowController.swift`

- [ ] **Step 1: Implement PreferencesWindowController**

File: `Sources/Go2TerminalLib/PreferencesWindowController.swift`

```swift
import AppKit

public class PreferencesWindowController: NSWindowController {
    private var terminalPopUp: NSPopUpButton!

    public init() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 320, height: 120),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.title = "Go2Terminal Preferences"
        window.center()
        super.init(window: window)
        setupUI()
        loadPreferences()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        guard let contentView = window?.contentView else { return }

        let label = NSTextField(labelWithString: "Default Terminal:")
        label.frame = NSRect(x: 20, y: 60, width: 120, height: 24)

        terminalPopUp = NSPopUpButton(frame: NSRect(x: 150, y: 58, width: 150, height: 28))
        for type in TerminalType.allCases {
            terminalPopUp.addItem(withTitle: type.displayName)
        }
        terminalPopUp.target = self
        terminalPopUp.action = #selector(terminalChanged(_:))

        contentView.addSubview(label)
        contentView.addSubview(terminalPopUp)
    }

    private func loadPreferences() {
        let current = TerminalType.preferred
        terminalPopUp.selectItem(withTitle: current.displayName)
    }

    @objc private func terminalChanged(_ sender: NSPopUpButton) {
        guard let title = sender.selectedItem?.title,
              let type = TerminalType.allCases.first(where: { $0.displayName == title }) else {
            return
        }
        type.saveAsPreferred()
    }
}
```

- [ ] **Step 2: Verify build**

Run: `swift build 2>&1 | tail -5`
Expected: Build succeeds.

- [ ] **Step 3: Commit**

```bash
git add Sources/Go2TerminalLib/PreferencesWindowController.swift
git commit -m "feat: add preferences window with terminal selection"
```

---

### Task 6: AppDelegate — Wire Everything Together

**Files:**
- Modify: `Sources/Go2TerminalLib/AppDelegate.swift`

- [ ] **Step 1: Implement full AppDelegate**

File: `Sources/Go2TerminalLib/AppDelegate.swift` (replace entire content)

```swift
import AppKit

public class AppDelegate: NSObject, NSApplicationDelegate {
    private var preferencesController: PreferencesWindowController?

    public override init() {
        super.init()
    }

    public func applicationDidFinishLaunching(_ notification: Notification) {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(showPreferences),
            name: .openPreferences,
            object: nil
        )

        if NSEvent.modifierFlags.contains(.option) {
            showPreferences()
        } else {
            openTerminalAtFinderPath()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                NSApp.terminate(nil)
            }
        }
    }

    private func openTerminalAtFinderPath() {
        let path = FinderPathResolver.resolve()
        let terminal = TerminalType.preferred
        _ = TerminalLauncher.launch(terminal: terminal, path: path)
    }

    @objc private func showPreferences() {
        if preferencesController == nil {
            preferencesController = PreferencesWindowController()
        }
        preferencesController?.showWindow(nil)
        preferencesController?.window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringAllApps: true)
    }
}
```

- [ ] **Step 2: Verify build**

Run: `swift build 2>&1 | tail -5`
Expected: Build succeeds.

- [ ] **Step 3: Commit**

```bash
git add Sources/Go2TerminalLib/AppDelegate.swift
git commit -m "feat: wire AppDelegate with Option key detection and main flow"
```

---

### Task 7: Info.plist and App Bundle Script

**Files:**
- Create: `Resources/Info.plist`
- Create: `scripts/bundle.sh`

- [ ] **Step 1: Create Info.plist**

File: `Resources/Info.plist`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key>
    <string>Go2Terminal</string>
    <key>CFBundleDisplayName</key>
    <string>Go2Terminal</string>
    <key>CFBundleIdentifier</key>
    <string>com.go2terminal.app</string>
    <key>CFBundleVersion</key>
    <string>1.0.0</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0.0</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleExecutable</key>
    <string>Go2Terminal</string>
    <key>LSMinimumSystemVersion</key>
    <string>12.0</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSAppleEventsUsageDescription</key>
    <string>Go2Terminal needs permission to control Finder and your terminal to open a terminal window at the current directory.</string>
</dict>
</plist>
```

- [ ] **Step 2: Create bundle script**

File: `scripts/bundle.sh`

```bash
#!/bin/bash
set -euo pipefail

APP_NAME="Go2Terminal"
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
```

- [ ] **Step 3: Make bundle script executable and build**

Run:
```bash
chmod +x scripts/bundle.sh
swift build -c release && bash scripts/bundle.sh
```
Expected: `Go2Terminal.app` directory created with correct structure.

- [ ] **Step 4: Verify app bundle structure**

Run: `ls -R Go2Terminal.app/`
Expected:
```
Contents/
Contents/Info.plist
Contents/MacOS/
Contents/MacOS/Go2Terminal
Contents/PkgInfo
Contents/Resources/
```

- [ ] **Step 5: Commit**

```bash
git add Resources/Info.plist scripts/bundle.sh Makefile
git commit -m "feat: add Info.plist and app bundle build script"
```

---

### Task 8: Final Build and Verification

- [ ] **Step 1: Run all tests**

Run: `swift test 2>&1 | tail -20`
Expected: All tests pass.

- [ ] **Step 2: Build release and bundle**

Run: `make bundle`
Expected: `Go2Terminal.app` created successfully.

- [ ] **Step 3: Verify app launches**

Run: `open Go2Terminal.app`
Expected: App launches, gets Finder path, opens Terminal window at that directory, then exits.

- [ ] **Step 4: Verify preferences (Option key)**

Manually hold Option key and click Go2Terminal.app in Finder toolbar.
Expected: Preferences window opens with terminal dropdown.

- [ ] **Step 5: Final commit**

```bash
git add -A
git commit -m "feat: Go2Terminal v1.0.0 — Finder toolbar terminal launcher"
```
