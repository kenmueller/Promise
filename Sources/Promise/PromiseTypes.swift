public extension Promise {
	typealias Resolver = (Value) -> Void
	typealias ThrowingResolver = (Value) throws -> Void
	typealias ChainingResolver<NewValue> = (Value) throws -> Promise<NewValue>
	
	typealias Rejecter = (Swift.Error) -> Void
	typealias ThrowingRejecter = (Swift.Error) throws -> Void
	typealias ChainingRejecter<NewValue> = (Swift.Error) throws -> Promise<NewValue>
	
	typealias Initializer = (@escaping Resolver, @escaping Rejecter) throws -> Void
}
