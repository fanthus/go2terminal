import XCTest
@testable import Go2Terminal

final class TerminalLauncherTests: XCTestCase {
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
