import XCTest
@testable import Go2Terminal

final class TerminalTypeTests: XCTestCase {
    override func setUp() {
        super.setUp()
        UserDefaults.standard.removeObject(forKey: "terminalType")
    }

    func testDefaultTerminalType() {
        let terminalType = TerminalType.preferred
        XCTAssertEqual(terminalType, .terminal)
    }

    func testSaveAndLoadTerminal() {
        TerminalType.terminal.saveAsPreferred()
        XCTAssertEqual(TerminalType.preferred, .terminal)
    }

    func testSaveAndLoadITerm() {
        TerminalType.iTerm2.saveAsPreferred()
        XCTAssertEqual(TerminalType.preferred, .iTerm2)
    }

    func testSaveAndLoadGhostty() {
        TerminalType.ghostty.saveAsPreferred()
        XCTAssertEqual(TerminalType.preferred, .ghostty)
    }

    func testRawValues() {
        XCTAssertEqual(TerminalType.terminal.rawValue, "terminal")
        XCTAssertEqual(TerminalType.iTerm2.rawValue, "iTerm2")
        XCTAssertEqual(TerminalType.ghostty.rawValue, "ghostty")
    }

    func testDisplayName() {
        XCTAssertEqual(TerminalType.terminal.displayName, "Terminal")
        XCTAssertEqual(TerminalType.iTerm2.displayName, "iTerm2")
        XCTAssertEqual(TerminalType.ghostty.displayName, "Ghostty")
    }

    func testAppName() {
        XCTAssertEqual(TerminalType.terminal.appName, "Terminal")
        XCTAssertEqual(TerminalType.iTerm2.appName, "iTerm")
        XCTAssertEqual(TerminalType.ghostty.appName, "Ghostty")
    }
}
