public protocol PromiseLike {
	var asAny: Promise<Any> { get }
}

extension Promise: PromiseLike {}
