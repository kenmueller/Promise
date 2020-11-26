public extension Promise {
	@discardableResult
	func then(_ handler: @escaping ThrowingResolver) -> Promise<Void> {
		if let value = value {
			do {
				try handler(value)
				return .resolve(())
			} catch {
				return .reject(error)
			}
		}
		
		if let error = error {
			return .reject(error)
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
	func then<NewValue>(_ handler: @escaping ChainingResolver<NewValue>) -> Promise<NewValue> {
		if let value = value {
			return handler(value)
		}
		
		if let error = error {
			return .reject(error)
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
}
