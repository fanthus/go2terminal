import XCTest
@testable import Go2ShellLib

final class TerminalLauncherTests: XCTestCase {
    func testTerminalAppScript() {
        let script = TerminalLauncher.appleScriptSource(for: .terminal, path: "/Users/test/Documents")
        XCTAssertTrue(script.contains("tell application \"Terminal\""))
        XCTAssertTrue(script.contains("activate"))
        XCTAssertTrue(script.contains("do script \"cd '/Users/test/Documents'\""))
    }

    func testITermScript() {
        let script = TerminalLauncher.appleScriptSource(for: .iTerm2, path: "/Users/test/Documents")
        XCTAssertTrue(script.contains("tell application \"iTerm\""))
        XCTAssertTrue(script.contains("activate"))
        XCTAssertTrue(script.contains("create window with default profile"))
        XCTAssertTrue(script.contains("write text \"cd '/Users/test/Documents'\""))
    }

    func testPathWithSpaces() {
        let script = TerminalLauncher.appleScriptSource(for: .terminal, path: "/Users/test/My Documents")
        XCTAssertTrue(script.contains("cd '/Users/test/My Documents'"))
    }

    func testPathWithSingleQuote() {
        let script = TerminalLauncher.appleScriptSource(for: .terminal, path: "/Users/test/it's a dir")
        XCTAssertTrue(script.contains("cd '/Users/test/it'\\''s a dir'"))
    }

    func testITermNotInstalledError() {
        let result = TerminalLauncher.isAppInstalled("SomeNonExistentApp12345")
        XCTAssertFalse(result)
    }
}
