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
        NSApp.activate(ignoringOtherApps: true)
    }
}
