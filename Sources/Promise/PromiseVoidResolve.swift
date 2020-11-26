public extension Promise where Value == Any {
	static func resolve() -> Promise<Void> {
		.resolve(())
	}
}
