public extension Promise where Value == Any {
	enum Error: Swift.Error {
		case valueTypeCastFailed
	}
}
