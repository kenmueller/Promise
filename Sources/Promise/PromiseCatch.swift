public extension Promise {
	@discardableResult
	func `catch`(_ handler: @escaping ThrowingRejecter) -> Promise<Void> {
		if value != nil {
			return .resolve(())
		}
		
		if let error = error {
			do {
				try handler(error)
				return .resolve(())
			} catch {
				return .reject(error)
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
	func `catch`(_ handler: @escaping ChainingRejecter<Any>) -> Promise<Any> {
		if let value = value {
			return .resolve(value)
		}
		
		if let error = error {
			do {
				return try handler(error)
			} catch {
				return .reject(error)
			}
		}
		
		return .init { resolve, reject in
			finalizers.append {
				if let value = self.value {
					resolve(value)
				} else if let error = self.error {
					do {
						try handler(error).then(resolve).catch(reject)
					} catch {
						reject(error)
					}
				}
			}
		}
	}
}
