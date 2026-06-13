import SwiftUI

struct SettingsView: View {
    @AppStorage(TerminalType.preferencesKey) private var terminalTypeRaw = TerminalType.terminal.rawValue

    var body: some View {
        Form {
            Picker("Default Terminal:", selection: $terminalTypeRaw) {
                ForEach(TerminalType.allCases, id: \.rawValue) { type in
                    Text(type.displayName).tag(type.rawValue)
                }
            }
            .pickerStyle(.radioGroup)
        }
        .formStyle(.grouped)
        .frame(width: 420, height: 160)
    }
}
