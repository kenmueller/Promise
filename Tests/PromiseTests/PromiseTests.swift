import XCTest
@testable import Promise

final class PromiseTests: XCTestCase {
	static let allTests = [
		("testAll", testAll)
	]
	
	func testAll() {
		let promise = expectation(description: "Cast")
		var success: Bool?
		
		Promise
			.resolve("")
			.value(as: String.self)
			.then { _ -> Void in
				success = true
				promise.fulfill()
			}
			.catch { _ -> Void in
				success = false
				promise.fulfill()
			}
		
		waitForExpectations(timeout: 5, handler: nil)
		XCTAssertTrue(success == true)
	}
}
