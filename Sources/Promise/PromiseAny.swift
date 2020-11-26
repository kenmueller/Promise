public extension Promise where Value == Any {
	static func resolve() -> Promise<Void> {
		.resolve(())
	}
	
	@discardableResult
	static func all(_ promises: [PromiseLike]) -> Promise<[Any]> {
		.init { resolve, reject in
			var didReject = false
			
			var remaining = promises.count
			var acc = [Any?](repeating: nil, count: remaining)
			
			for (index, promise) in promises.enumerated() {
				promise.asAny
					.then { value in
						if didReject { return }
						
						remaining -= 1
						acc[index] = value
						
						if remaining <= 0 {
							resolve(acc as [Any])
						}
					}
					.catch { error -> Void in
						if didReject { return }
						
						didReject = true
						reject(error)
					}
			}
		}
	}
}
