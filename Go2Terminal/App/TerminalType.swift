import Foundation

enum TerminalType: String, CaseIterable {
    case terminal = "terminal"
    case iTerm2 = "iTerm2"
    case ghostty = "ghostty"

    static let preferencesKey = "terminalType"

    private static let userDefaultsKey = preferencesKey

    var displayName: String {
        switch self {
        case .terminal: return "Terminal"
        case .iTerm2: return "iTerm2"
        case .ghostty: return "Ghostty"
        }
    }

    var appName: String {
        switch self {
        case .terminal: return "Terminal"
        case .iTerm2: return "iTerm"
        case .ghostty: return "Ghostty"
        }
    }

    static var preferred: TerminalType {
        guard let raw = UserDefaults.standard.string(forKey: userDefaultsKey),
              let type = TerminalType(rawValue: raw) else {
            return .terminal
        }
        return type
    }

    func saveAsPreferred() {
        UserDefaults.standard.set(rawValue, forKey: TerminalType.userDefaultsKey)
    }
}
