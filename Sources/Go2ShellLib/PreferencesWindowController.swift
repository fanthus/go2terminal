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
        window.title = "Go2Shell Preferences"
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
