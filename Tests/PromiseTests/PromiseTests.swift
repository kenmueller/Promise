import XCTest
@testable import Promise

final class PromiseTests: XCTestCase {
	static let allTests = [
		("testCast", testCast),
		("testAsynchronous", testAsynchronous),
		("testAwait", testAwait)
	]
	
	func testCast() {
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
	
	func testAsynchronous() {
		sleep(for: 1).then { _ in print("sleep 1") }
		print("mid")
		sleep(for: 2).then { _ in print("sleep 2") }
	}
	
	func testAwait() {
		do {
			try *sleep(for: 1)
			XCTAssertTrue(true)
		} catch {
			XCTAssertTrue(false)
		}
	}
	
	func sleep(for timeInterval: TimeInterval) -> Promise<Timer> {
		.init { resolve, _ in
			Timer.scheduledTimer(
				withTimeInterval: timeInterval,
				repeats: false,
				block: resolve
			)
		}
	}
}
