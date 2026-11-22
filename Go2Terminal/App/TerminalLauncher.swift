import AppKit

enum TerminalLauncher {
    // Match the profile Terminal uses when opened directly. Its startup profile
    // can differ from the default profile used for subsequent windows.
    static let terminalAppleScriptSource = """
        on run argv
            set directoryPath to item 1 of argv
            tell application "Terminal"
                set newTab to do script ("cd -- " & quoted form of directoryPath)
                set current settings of newTab to startup settings
                activate
            end tell
        end run
        """

    static func launchProcess(for terminal: TerminalType, directoryURL: URL) -> Process {
        let process = Process()
        if terminal == .terminal {
            process.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
            // Pass the path as data, keeping quotes and shell metacharacters out of the script.
            process.arguments = ["-e", terminalAppleScriptSource, "--", directoryURL.path]
        } else {
            process.executableURL = URL(fileURLWithPath: "/usr/bin/open")
            process.arguments = ["-a", applicationName(for: terminal), directoryURL.path]
        }
        return process
    }

    static func applicationName(for terminal: TerminalType) -> String {
        switch terminal {
        case .terminal: return "Terminal"
        case .iTerm2: return "iTerm"
        case .ghostty: return "Ghostty"
        }
    }

    static func applicationURL(for terminal: TerminalType) -> URL {
        switch terminal {
        case .terminal:
            return URL(fileURLWithPath: "/System/Applications/Utilities/Terminal.app")
        case .iTerm2:
            return URL(fileURLWithPath: "/Applications/iTerm.app")
        case .ghostty:
            return URL(fileURLWithPath: "/Applications/Ghostty.app")
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
        if appName == "Ghostty" {
            return NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.mitchellh.ghostty") != nil
        }
        return false
    }

    static func launch(terminal: TerminalType, path: String) -> Bool {
        if terminal == .iTerm2 && !isAppInstalled("iTerm") {
            showTerminalNotInstalledAlert(name: "iTerm2", installHint: "install iTerm2")
            return false
        }
        if terminal == .ghostty && !isAppInstalled("Ghostty") {
            showTerminalNotInstalledAlert(name: "Ghostty", installHint: "install Ghostty")
            return false
        }

        let directoryURL = validatedDirectoryURL(for: path)
        let process = launchProcess(for: terminal, directoryURL: directoryURL)

        do {
            try process.run()
            process.waitUntilExit()
        } catch {
            NSLog("TerminalLauncher error: %@", error.localizedDescription)
            showLaunchFailedAlert()
            return false
        }

        if process.terminationStatus != 0 {
            NSLog("TerminalLauncher error: launcher exited with status %d for path %@", process.terminationStatus, directoryURL.path)
            showLaunchFailedAlert()
            return false
        }

        return true
    }

    private static func showAlert(_ alert: NSAlert) -> NSApplication.ModalResponse {
        NSApp.activate(ignoringOtherApps: true)
        return alert.runModal()
    }

    private static func showTerminalNotInstalledAlert(name: String, installHint: String) {
        let alert = NSAlert()
        alert.messageText = "\(name) Not Found"
        alert.informativeText = "\(name) is not installed. Please switch to Terminal in preferences, or \(installHint)."
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
        alert.informativeText = "Go2Terminal could not open the selected terminal application. If prompted, allow Go2Terminal to control Terminal in System Settings → Privacy & Security → Automation."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        showAlert(alert)
    }
}
