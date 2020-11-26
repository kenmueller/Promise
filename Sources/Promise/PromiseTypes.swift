public extension Promise {
	typealias Resolver = (Value) -> Void
	typealias ThrowingResolver = (Value) throws -> Void
	typealias ChainingResolver<NewValue> = (Value) -> Promise<NewValue>
	
	typealias Rejecter = (Error) -> Void
	typealias ThrowingRejecter = (Error) throws -> Void
	typealias ChainingRejecter<NewValue> = (Error) -> Promise<NewValue>
	
	typealias Initializer = (@escaping Resolver, @escaping Rejecter) -> Void
}
