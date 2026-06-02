import AppKit
import Carbon.HIToolbox
import CoreGraphics
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    static weak var shared: AppDelegate?

    private(set) var launchedForSettings = false
    private var settingsCloseObserver: NSObjectProtocol?
    private var settingsWindow: NSWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        AppDelegate.shared = self
        guard !isRunningTests else { return }

        if CommandLine.arguments.contains(where: { $0 == "--settings" || $0 == "-settings" }) {
            DispatchQueue.main.async { [weak self] in
                self?.showSettings()
            }
            return
        }

        DispatchQueue.main.async { [weak self] in
            self?.resolveLaunchIntent { openSettings in
                if openSettings {
                    self?.showSettings()
                } else {
                    self?.performTerminalLaunch()
                }
            }
        }
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        guard !isRunningTests else { return true }
        resolveLaunchIntent { [weak self] openSettings in
            if openSettings {
                self?.showSettings()
            } else {
                self?.performTerminalLaunch()
            }
        }
        return true
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        launchedForSettings
    }

    private var isRunningTests: Bool {
        ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
    }

    static func requestShowSettings() {
        shared?.showSettings()
    }

    private func resolveLaunchIntent(completion: @escaping (Bool) -> Void) {
        if shouldOpenSettings() {
            completion(true)
            return
        }

        pollForSettingsIntent(attempt: 0, maxAttempts: 8, completion: completion)
    }

    private func pollForSettingsIntent(attempt: Int, maxAttempts: Int, completion: @escaping (Bool) -> Void) {
        if shouldOpenSettings() {
            completion(true)
            return
        }
        guard attempt < maxAttempts else {
            completion(false)
            return
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
            self?.pollForSettingsIntent(attempt: attempt + 1, maxAttempts: maxAttempts, completion: completion)
        }
    }

    private func shouldOpenSettings() -> Bool {
        let flags = modifierFlagsRawValue()
        return (flags & Int32(optionKey)) != 0 || (flags & Int32(shiftKey)) != 0
    }

    private func modifierFlagsRawValue() -> Int32 {
        var flags = Int32(GetCurrentKeyModifiers())

        let eventStates: [CGEventSourceStateID] = [.hidSystemState, .combinedSessionState]
        for state in eventStates {
            let cgFlags = CGEventSource.flagsState(state)
            if cgFlags.contains(.maskAlternate) {
                flags |= Int32(optionKey)
            }
            if cgFlags.contains(.maskShift) {
                flags |= Int32(shiftKey)
            }
        }

        return flags
    }

    private func performTerminalLaunch() {
        let success = openTerminalAtFinderPath()
        if launchedForSettings {
            return
        }
        if success {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                NSApp.terminate(nil)
            }
        } else {
            NSApp.terminate(nil)
        }
    }

    private func openTerminalAtFinderPath() -> Bool {
        let path = FinderPathResolver.resolve()
        let terminal = TerminalType.preferred
        return TerminalLauncher.launch(terminal: terminal, path: path)
    }

    private func showSettings() {
        launchedForSettings = true
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)

        if settingsWindow == nil {
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 420, height: 160),
                styleMask: [.titled, .closable],
                backing: .buffered,
                defer: false
            )
            window.title = "Go2Terminal Settings"
            window.center()
            window.contentView = NSHostingView(rootView: SettingsView())
            window.isReleasedWhenClosed = false
            settingsWindow = window
        }

        settingsWindow?.makeKeyAndOrderFront(nil)
        observeSettingsWindowClose()
    }

    private func observeSettingsWindowClose() {
        if let settingsCloseObserver {
            NotificationCenter.default.removeObserver(settingsCloseObserver)
        }

        settingsCloseObserver = NotificationCenter.default.addObserver(
            forName: NSWindow.willCloseNotification,
            object: settingsWindow,
            queue: .main
        ) { [weak self] _ in
            guard let self, self.launchedForSettings else { return }
            self.launchedForSettings = false
            self.settingsWindow = nil
            NSApp.terminate(nil)
        }
    }
}
