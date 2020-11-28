extension Promise: CustomStringConvertible {
	public var description: String {
		if let value = value {
			return "Promise<\(type(of: value))> (resolved) \(String(describing: value))"
		}
		
		if let error = error {
			return "Promise (rejected) \(String(describing: error))"
		}
		
		return "Promise (pending)"
	}
}
