public final class Promise<Value> {
	var finalizers = [() -> Void]()
	
	var value: Value? {
		willSet { errorIfFinalized() }
		didSet { finalize() }
	}
	
	var error: Swift.Error? {
		willSet { errorIfFinalized() }
		didSet { finalize() }
	}
	
	private var isFinalized: Bool {
		!(value == nil && error == nil)
	}
	
	public init(_ initializer: Initializer) {
		initializer({ self.value = $0 }, { self.error = $0 })
	}
	
	private init(value: Value? = nil, error: Swift.Error? = nil) {
		self.value = value
		self.error = error
	}
	
	public static func resolve(_ value: Value) -> Promise<Value> {
		.init(value: value)
	}
	
	public static func reject(_ error: Swift.Error) -> Promise<Value> {
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
}
