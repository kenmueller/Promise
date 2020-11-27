import Dispatch

fileprivate let queue = DispatchQueue(label: "promise.await", attributes: .concurrent)

@discardableResult
public func await<Value>(_ promise: Promise<Value>) throws -> Value {
	var value: Value?
	var error: Error?
	
	let semaphore = DispatchSemaphore(value: 0)
	
	promise
		.then { _value -> Void in
			value = _value
			semaphore.signal()
		}
		.catch { _error -> Void in
			error = _error
			semaphore.signal()
		}
	
	_ = semaphore.wait(timeout: .distantFuture)
	
	if let value = value {
		return value
	}
	
	if let error = error {
		throw error
	}
	
	throw Promise.Error.awaitTimedOut
}

@discardableResult
public func await<Value>(_ body: () throws -> Promise<Value>) throws -> Value {
	try await(try body())
}

prefix operator *

@discardableResult
public prefix func * <Value>(_ promise: Promise<Value>) throws -> Value {
	try await(promise)
}

@discardableResult
public prefix func * <Value>(_ body: () throws -> Promise<Value>) throws -> Value {
	try await(body)
}
