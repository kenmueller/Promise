import XCTest
@testable import Promise

final class PromiseTests: XCTestCase {
	static let allTests = [
		("testTrue", testTrue)
	]
	
	func testTrue() {
		XCTAssertTrue(true)
	}
}
