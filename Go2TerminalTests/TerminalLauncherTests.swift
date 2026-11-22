import XCTest
@testable import Go2Terminal

final class TerminalLauncherTests: XCTestCase {
    func testTerminalScriptCompiles() throws {
        let outputURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString + ".scpt")
        defer { try? FileManager.default.removeItem(at: outputURL) }

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/osacompile")
        process.arguments = ["-o", outputURL.path, "-e", TerminalLauncher.terminalAppleScriptSource]
        let errors = Pipe()
        process.standardError = errors
        try process.run()
        process.waitUntilExit()

        let message = String(data: errors.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
        XCTAssertEqual(process.terminationStatus, 0, message)
    }

    func testTerminalPassesSpecialCharactersAsSeparateArgument() {
        let path = "/tmp/a 'quoted' \"directory\"; $(echo example)\nnext line"
        let process = TerminalLauncher.launchProcess(for: .terminal, directoryURL: URL(fileURLWithPath: path))
        XCTAssertEqual(process.executableURL?.path, "/usr/bin/osascript")
        XCTAssertEqual(process.arguments, ["-e", TerminalLauncher.terminalAppleScriptSource, "--", path])
        XCTAssertFalse(TerminalLauncher.terminalAppleScriptSource.contains(path))
    }

    func testOtherTerminalsContinueOpeningDirectoryDirectly() {
        for terminal in [TerminalType.iTerm2, .ghostty] {
            let process = TerminalLauncher.launchProcess(for: terminal, directoryURL: URL(fileURLWithPath: "/tmp"))
            XCTAssertEqual(process.executableURL?.path, "/usr/bin/open")
            XCTAssertEqual(process.arguments, ["-a", TerminalLauncher.applicationName(for: terminal), "/tmp"])
        }
    }

    func testTerminalApplicationPath() {
        let url = TerminalLauncher.applicationURL(for: .terminal)
        XCTAssertEqual(url.lastPathComponent, "Terminal.app")
        XCTAssertEqual(TerminalLauncher.applicationName(for: .terminal), "Terminal")
    }

    func testITermApplicationPath() {
        let url = TerminalLauncher.applicationURL(for: .iTerm2)
        XCTAssertEqual(url.lastPathComponent, "iTerm.app")
        XCTAssertEqual(TerminalLauncher.applicationName(for: .iTerm2), "iTerm")
    }

    func testGhosttyApplicationPath() {
        let url = TerminalLauncher.applicationURL(for: .ghostty)
        XCTAssertEqual(url.lastPathComponent, "Ghostty.app")
        XCTAssertEqual(TerminalLauncher.applicationName(for: .ghostty), "Ghostty")
    }

    func testValidatedDirectoryURLUsesExistingPath() throws {
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tempDir) }

        let url = TerminalLauncher.validatedDirectoryURL(for: tempDir.path)
        XCTAssertEqual(url.path, tempDir.path)
    }

    func testValidatedDirectoryURLFallsBackToHomeForMissingPath() {
        let url = TerminalLauncher.validatedDirectoryURL(for: "/path/that/does/not/exist/\(UUID().uuidString)")
        XCTAssertEqual(url.path, NSHomeDirectory())
    }

    func testITermNotInstalledCheck() {
        let result = TerminalLauncher.isAppInstalled("SomeNonExistentApp12345")
        XCTAssertFalse(result)
    }
}
