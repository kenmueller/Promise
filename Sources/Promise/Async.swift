import Dispatch

fileprivate let queue = DispatchQueue(label: "promise.async", attributes: .concurrent)

@discardableResult
public func async<Value>(_ body: () throws -> Value) -> Promise<Value> {
	do {
		return .resolve(try body())
	} catch {
		return .reject(error)
	}
}

prefix operator ^

@discardableResult
public prefix func ^ <Value>(_ body: () throws -> Value) -> Promise<Value> {
	async(body)
}
