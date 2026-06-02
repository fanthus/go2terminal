import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    private var preferencesController: PreferencesWindowController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(showPreferences),
            name: .openPreferences,
            object: nil
        )

        handleActivation()
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        handleActivation()
        return true
    }

    private func handleActivation() {
        if NSEvent.modifierFlags.contains(.option) {
            showPreferences()
            return
        }

        performTerminalLaunch()
    }

    private func performTerminalLaunch() {
        let success = openTerminalAtFinderPath()
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

    @objc private func showPreferences() {
        if preferencesController == nil {
            preferencesController = PreferencesWindowController()
        }
        preferencesController?.showWindow(nil)
        preferencesController?.window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
