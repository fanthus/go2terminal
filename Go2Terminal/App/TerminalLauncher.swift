import AppKit

enum TerminalLauncher {
    static func appleScriptSource(for terminal: TerminalType, path: String) -> String {
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

    static func isAppInstalled(_ appName: String) -> Bool {
        let path = "/Applications/\(appName).app"
        return FileManager.default.fileExists(atPath: path)
    }

    static func launch(terminal: TerminalType, path: String) -> Bool {
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

extension Notification.Name {
    static let openPreferences = Notification.Name("openPreferences")
}
