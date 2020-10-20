import XCTest
@testable import LetMeIn

final class LetMeInTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(LetMeIn().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
