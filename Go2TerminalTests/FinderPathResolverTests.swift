import XCTest
@testable import Go2Terminal

final class FinderPathResolverTests: XCTestCase {
    func testAppleScriptSource() {
        let script = FinderPathResolver.appleScriptSource
        XCTAssertTrue(script.contains("tell application \"Finder\""))
        XCTAssertTrue(script.contains("count of Finder windows"))
        XCTAssertTrue(script.contains("POSIX path"))
        XCTAssertTrue(script.contains("path to home folder"))
    }
}
