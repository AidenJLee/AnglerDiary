import Foundation

@propertyWrapper
struct UserDefault<Value> {
	let defaultValue: Value
	let key: String
	var store: UserDefaults
	
	init(wrappedValue defaultValue: Value, _ key: String, store: UserDefaults = .standard) {
		self.defaultValue = defaultValue
		self.key = key
		self.store = store
	}
	
	var wrappedValue: Value {
		get { store.object(forKey: key) as? Value ?? defaultValue }
		set { store.set(newValue, forKey: key) }
	}
}

@propertyWrapper
struct CodableUserDefault<Value: Codable> {
	let key: String
	let defaultValue: Value
	let store: UserDefaults
	
	init(wrappedValue defaultValue: Value, _ key: String, store: UserDefaults = .standard) {
		self.defaultValue = defaultValue
		self.key = key
		self.store = store
	}
	
	var wrappedValue: Value {
		get {
			guard let data = store.data(forKey: key) else {
				return defaultValue
			}
			let decoder = JSONDecoder()
			do {
				let decodedValue = try decoder.decode(Value.self, from: data)
				return decodedValue
			} catch {
				print("Failed to decode \(key): \(error)")
				return defaultValue
			}
		}
		set {
			let encoder = JSONEncoder()
			do {
				let encodedData = try encoder.encode(newValue)
				store.set(encodedData, forKey: key)
				print("Successfully saved data for key: \(key)")
			} catch {
				print("Failed to encode \(key): \(error)")
			}
		}
	}
}

extension UserDefaults {
	static func isFirstLaunch() -> Bool {
		let hasBeenLaunchedBeforeFlag = "launchedBefore"
		let isFirstLaunch = !UserDefaults.standard.bool(forKey: hasBeenLaunchedBeforeFlag)
		if (isFirstLaunch) {
			UserDefaults.standard.set(true, forKey: hasBeenLaunchedBeforeFlag)
		}
		return isFirstLaunch
	}
	
	func clearUserDefaults() {
		// UserDefaults 데이터 삭제
		if let appDomain = Bundle.main.bundleIdentifier {
			UserDefaults.standard.removePersistentDomain(forName: appDomain)
		}
	}
}
