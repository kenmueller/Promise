public protocol PromiseLike {
	var asAny: Promise<Any> { get }
	
	func value<NewValue>(as: NewValue.Type) -> Promise<NewValue>
}

extension Promise: PromiseLike {
	public var asAny: Promise<Any> {
		value(as: Any.self)
	}
	
	public func value<NewValue>(as type: NewValue.Type) -> Promise<NewValue> {
		then { value in
			guard let value = value as? NewValue else {
				return .reject(Promise<Any>.Error.valueTypeCastFailed)
			}
			
			return .resolve(value)
		}
	}
}
