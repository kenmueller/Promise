public final class Promise<Value> {
	public typealias Resolver = (Value) -> Void
	public typealias ThrowingResolver = (Value) throws -> Void
	public typealias ChainingResolver<NewValue> = (Value) -> Promise<NewValue>
	
	public typealias Rejecter = (Error) -> Void
	public typealias ThrowingRejecter = (Error) throws -> Void
	public typealias ChainingRejecter<NewValue> = (Error) -> Promise<NewValue>
	
	public typealias Initializer = (@escaping Resolver, @escaping Rejecter) -> Void
	
	private var finalizers = [() -> Void]()
	
	private var value: Value? {
		willSet { errorIfFinalized() }
		didSet { finalize() }
	}
	
	private var error: Error? {
		willSet { errorIfFinalized() }
		didSet { finalize() }
	}
	
	private var isFinalized: Bool {
		!(value == nil && error == nil)
	}
	
	public init(_ initializer: Initializer) {
		initializer({ self.value = $0 }, { self.error = $0 })
	}
	
	private init() {}
	
	private init(value: Value) {
		self.value = value
	}
	
	private init(error: Error) {
		self.error = error
	}
	
	public static func resolve(_ value: Value) -> Promise<Value> {
		.init(value: value)
	}
	
	public static func reject(_ error: Error) -> Promise<Value> {
		.init(error: error)
	}
	
	private func errorIfFinalized() {
		guard isFinalized else { return }
		fatalError("The promise has already been finalized")
	}
	
	private func finalize() {
		for finalizer in finalizers {
			finalizer()
		}
		
		finalizers = []
	}
	
	@discardableResult
	public func then(_ handler: @escaping ThrowingResolver) -> Promise<Void> {
		if let value = value {
			do {
				try handler(value)
				return .init(value: ())
			} catch {
				return .init(error: error)
			}
		}
		
		if let error = error {
			return .init(error: error)
		}
		
		return .init { resolve, reject in
			finalizers.append {
				if let value = self.value {
					do {
						try handler(value)
						resolve(())
					} catch {
						reject(error)
					}
				} else if let error = self.error {
					reject(error)
				}
			}
		}
	}
	
	@discardableResult
	public func then<NewValue>(_ handler: @escaping ChainingResolver<NewValue>) -> Promise<NewValue> {
		if let value = value {
			return handler(value)
		}
		
		if let error = error {
			return .init(error: error)
		}
		
		return .init { resolve, reject in
			finalizers.append {
				if let value = self.value {
					handler(value).then(resolve).catch(reject)
				} else if let error = self.error {
					reject(error)
				}
			}
		}
	}
	
	@discardableResult
	public func `catch`(_ handler: @escaping ThrowingRejecter) -> Promise<Void> {
		if value != nil {
			return .init(value: ())
		}
		
		if let error = error {
			do {
				try handler(error)
				return .init(value: ())
			} catch {
				return .init(error: error)
			}
		}
		
		return .init { resolve, reject in
			finalizers.append {
				if self.value != nil {
					resolve(())
				} else if let error = self.error {
					do {
						try handler(error)
						resolve(())
					} catch {
						reject(error)
					}
				}
			}
		}
	}
	
	@discardableResult
	public func `catch`(_ handler: @escaping ChainingRejecter<Any>) -> Promise<Any> {
		if let value = value {
			return .init(value: value)
		}
		
		if let error = error {
			return handler(error)
		}
		
		return .init { resolve, reject in
			finalizers.append {
				if let value = self.value {
					resolve(value)
				} else if let error = self.error {
					handler(error)
						.then(resolve)
						.catch(reject)
				}
			}
		}
	}
}
