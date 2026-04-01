import XCTest
@testable import Go2ShellLib

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

    func testRawValues() {
        XCTAssertEqual(TerminalType.terminal.rawValue, "terminal")
        XCTAssertEqual(TerminalType.iTerm2.rawValue, "iTerm2")
    }

    func testDisplayName() {
        XCTAssertEqual(TerminalType.terminal.displayName, "Terminal")
        XCTAssertEqual(TerminalType.iTerm2.displayName, "iTerm2")
    }

    func testAppName() {
        XCTAssertEqual(TerminalType.terminal.appName, "Terminal")
        XCTAssertEqual(TerminalType.iTerm2.appName, "iTerm")
    }
}
