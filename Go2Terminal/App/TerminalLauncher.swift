import AppKit

enum TerminalLauncher {
    static func applicationName(for terminal: TerminalType) -> String {
        switch terminal {
        case .terminal: return "Terminal"
        case .iTerm2: return "iTerm"
        }
    }

    static func applicationURL(for terminal: TerminalType) -> URL {
        switch terminal {
        case .terminal:
            return URL(fileURLWithPath: "/System/Applications/Utilities/Terminal.app")
        case .iTerm2:
            return URL(fileURLWithPath: "/Applications/iTerm.app")
        }
    }

    static func validatedDirectoryURL(for path: String) -> URL {
        var isDirectory: ObjCBool = false
        if FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory), isDirectory.boolValue {
            return URL(fileURLWithPath: path, isDirectory: true)
        }
        return URL(fileURLWithPath: NSHomeDirectory(), isDirectory: true)
    }

    static func isAppInstalled(_ appName: String) -> Bool {
        let paths = [
            "/Applications/\(appName).app",
            NSHomeDirectory() + "/Applications/\(appName).app",
        ]
        if paths.contains(where: { FileManager.default.fileExists(atPath: $0) }) {
            return true
        }
        if appName == "iTerm" {
            return NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.googlecode.iterm2") != nil
        }
        return false
    }

    static func launch(terminal: TerminalType, path: String) -> Bool {
        if terminal == .iTerm2 && !isAppInstalled("iTerm") {
            showITermNotInstalledAlert()
            return false
        }

        let directoryURL = validatedDirectoryURL(for: path)
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/open")
        process.arguments = ["-a", applicationName(for: terminal), directoryURL.path]

        do {
            try process.run()
            process.waitUntilExit()
        } catch {
            NSLog("TerminalLauncher error: %@", error.localizedDescription)
            showLaunchFailedAlert()
            return false
        }

        if process.terminationStatus != 0 {
            NSLog("TerminalLauncher error: open exited with status %d for path %@", process.terminationStatus, directoryURL.path)
            showLaunchFailedAlert()
            return false
        }

        return true
    }

    private static func showAlert(_ alert: NSAlert) -> NSApplication.ModalResponse {
        NSApp.activate(ignoringOtherApps: true)
        return alert.runModal()
    }

    private static func showITermNotInstalledAlert() {
        let alert = NSAlert()
        alert.messageText = "iTerm2 Not Found"
        alert.informativeText = "iTerm2 is not installed. Please switch to Terminal in preferences, or install iTerm2."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Open Preferences")
        alert.addButton(withTitle: "OK")
        if showAlert(alert) == .alertFirstButtonReturn {
            AppDelegate.requestShowSettings()
        }
    }

    private static func showLaunchFailedAlert() {
        let alert = NSAlert()
        alert.messageText = "Unable to Open Terminal"
        alert.informativeText = "Go2Terminal could not open the selected terminal application."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        showAlert(alert)
    }
}
