import Foundation

enum TerminalType: String, CaseIterable {
    case terminal = "terminal"
    case iTerm2 = "iTerm2"

    private static let userDefaultsKey = "terminalType"

    var displayName: String {
        switch self {
        case .terminal: return "Terminal"
        case .iTerm2: return "iTerm2"
        }
    }

    var appName: String {
        switch self {
        case .terminal: return "Terminal"
        case .iTerm2: return "iTerm"
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
