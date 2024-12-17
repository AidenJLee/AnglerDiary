import Security
import Foundation

/// 라이브러리에서 사용되는 상수들
public struct KeychainConstants {
	/// Keychain 항목을 공유하는 데 사용되는 Keychain 액세스 그룹을 지정합니다.
	public static var accessGroup: String { return toString(kSecAttrAccessGroup) }
	
	/**
	 데이터에 대한 앱의 액세스를 나타내는 값입니다. 기본값은 AccessibleWhenUnlocked입니다. 가능한 값 목록은 KeychainSwiftAccessOptions를 참조하십시오.
	 */
	public static var accessible: String { return toString(kSecAttrAccessible) }
	
	/// Keychain 값 설정/가져오기 시 String 키를 지정하는 데 사용됩니다.
	public static var attrAccount: String { return toString(kSecAttrAccount) }
	
	/// 기기 간 Keychain 항목 동기화를 지정하는 데 사용됩니다.
	public static var attrSynchronizable: String { return toString(kSecAttrSynchronizable) }
	
	/// Keychain 검색 사전을 구성하는 데 사용되는 항목 클래스 키입니다.
	public static var klass: String { return toString(kSecClass) }
	
	/// Keychain에서 반환되는 값의 수를 지정합니다. 라이브러리는 단일 값만 지원합니다.
	public static var matchLimit: String { return toString(kSecMatchLimit) }
	
	/// Keychain에서 데이터를 가져오기 위해 사용되는 반환 데이터 유형입니다.
	public static var returnData: String { return toString(kSecReturnData) }
	
	/// Used for specifying a value when setting a Keychain value.
	public static var valueData: String { return toString(kSecValueData) }
	
	/// Keychain에서 데이터에 대한 참조를 반환하는 데 사용됩니다.
	public static var returnReference: String { return toString(kSecReturnPersistentRef) }
	
	/// 항목 속성을 반환할지 여부를 나타내는 부울 값을 포함하는 키입니다.
	public static var returnAttributes : String { return toString(kSecReturnAttributes) }
	
	/// 무제한 항목 일치에 해당하는 값입니다.
	public static var secMatchLimitAll : String { return toString(kSecMatchLimitAll) }
	
	static func toString(_ value: CFString) -> String {
		return value as String
	}
}

/**
 키체인 항목이 읽기 가능할 때를 결정하는 데 사용되는 옵션입니다. 기본값은 AccessibleWhenUnlocked입니다.
 */
public enum KeychainAccessOptions {
	
	/**
	 기기가 사용자에 의해 잠금 해제될 때만 Keychain 항목의 데이터에 액세스할 수 있습니다.
	 
	 이는 앱이 포그라운드에 있는 동안에만 액세스해야하는 항목에 권장됩니다. 이 속성이 없이 추가된 키체인 항목은 새 기기로 이동할 때 암호화된 백업을 사용할 때 이동합니다.
	 
	 이것은 명시적으로 액세스성 상수를 설정하지 않은 항목에 대한 기본값입니다.
	 */
	case accessibleWhenUnlocked
	
	/**
	 기기가 사용자에 의해 잠금 해제될 때만 Keychain 항목의 데이터에 액세스할 수 있습니다.
	 
	 이는 앱이 포그라운드에 있는 동안에만 액세스해야하는 항목에 권장됩니다. 이 속성을 가진 항목은 새 기기로 이동하지 않습니다. 따라서 다른 기기의 백업을 복원한 후 이러한 항목이 존재하지 않습니다.
	 */
	case accessibleWhenUnlockedThisDeviceOnly
	
	/**
	 기기가 사용자에 의해 최초로 잠금 해제될 때까지 키체인 항목의 데이터에 액세스할 수 없습니다.
	 
	 첫 번째 잠금 해제 후 데이터는 다음 재부팅까지 액세스할 수 있습니다. 이는 백그라운드 애플리케이션에서 액세스해야하는 항목에 권장됩니다. 이 속성을 가진 항목은 새 기기로 이동할 때 암호화된 백업을 사용합니다.
	 */
	case accessibleAfterFirstUnlock
	
	/**
	 기기가 사용자에 의해 최초로 잠금 해제될 때까지 키체인 항목의 데이터에 액세스할 수 없습니다.
	 
	 첫 번째 잠금 해제 후 데이터는 다음 재부팅까지 액세스할 수 있습니다. 이는 백그라운드 애플리케이션에서 액세스해야하는 항목에 권장됩니다. 이 속성을 가진 항목은 새 기기로 이동하지 않습니다. 따라서 다른 기기의 백업을 복원한 후 이러한 항목이 존재하지 않습니다.
	 */
	case accessibleAfterFirstUnlockThisDeviceOnly
	
	/**
	 기기가 잠금 상태인 경우에만 Keychain의 데이터에 액세스할 수 있습니다. 장치에 패스 코드가 설정된 경우에만 사용할 수 있습니다.
	 
	 이는 앱이 포그라운드에 있는 동안에만 액세스해야하는 항목에 권장됩니다. 이 속성을 가진 항목은 새 기기로 이동하지 않습니다. 백업이 새 기기로 복원된 후 이러한 항목이 없습니다. 장치 패스 코드를 비활성화하면이 클래스에 모든 항목이 삭제됩니다.
	 */
	case accessibleWhenPasscodeSetThisDeviceOnly
	
	static var defaultOption: KeychainAccessOptions {
		return .accessibleWhenUnlocked
	}
	
	var value: String {
		switch self {
		case .accessibleWhenUnlocked:
			return toString(kSecAttrAccessibleWhenUnlocked)
			
		case .accessibleWhenUnlockedThisDeviceOnly:
			return toString(kSecAttrAccessibleWhenUnlockedThisDeviceOnly)
			
		case .accessibleAfterFirstUnlock:
			return toString(kSecAttrAccessibleAfterFirstUnlock)
			
		case .accessibleAfterFirstUnlockThisDeviceOnly:
			return toString(kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly)
			
		case .accessibleWhenPasscodeSetThisDeviceOnly:
			return toString(kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly)
		}
	}
	
	func toString(_ value: CFString) -> String {
		return KeychainConstants.toString(value)
	}
}

/// 키체인에 텍스트 및 데이터를 저장하기 위한 도우미 함수 모음
open class KeychainSwift {
	
	var lastQueryParameters: [String: Any]? // 단위 테스트에서 사용됨
	
	/// 마지막 작업에서의 결과 코드를 포함합니다. 성공한 결과의 경우 값은 noErr (0)입니다.
	open var lastResultCode: OSStatus = noErr
	
	var keyPrefix = "" // 테스트에 유용할 수 있습니다.
	
	/// Keychain 항목에 액세스할 Keychain 액세스 그룹을 지정합니다. 액세스 그룹은 애플리케이션 간에 Keychain 항목을 공유하는 데 사용될 수 있습니다. 액세스 그룹 값이 nil인 경우 모든 애플리케이션 액세스 그룹이 액세스됩니다. 액세스 그룹 이름은 set, get, delete 및 clear의 모든 함수에서 사용됩니다.
	open var accessGroup: String?
	
	/**
	 iCloud를 통해 다른 기기와 동기화될 수 있는 항목인지를 지정합니다. 이 속성을 true로 설정하면 다른 기기에 항목이 추가되고 `set` 메서드를 사용하여 항목을 가져올 수 있습니다. 동기화 가능한 항목을 삭제하면 모든 기기에서 해당 항목이 제거됩니다. Keychain 동기화가 작동하려면 사용자가 iCloud 설정에서 "Keychain"을 활성화해야 합니다.
	 
	 macOS에서는 작동하지 않습니다.
	 */
	open var synchronizable: Bool = false
	
	private let lock = NSLock()
	
	/// KeychainSwift 객체를 인스턴스화합니다.
	public init() { }
	
	/**
	 - parameter keyPrefix: get/set 메서드에서 키 앞에 추가되는 접두사입니다. 주의할 점은 `clear` 메서드는 여전히 Keychain에서 모두 지웁니다.
	 */
	public init(keyPrefix: String) {
		self.keyPrefix = keyPrefix
	}
	
	/**
	 Keychain 항목에 주어진 키 아래에 텍스트 값을 저장합니다.
	 
	 - parameter key: Keychain에 텍스트 값이 저장되는 키입니다.
	 - parameter value: Keychain에 쓰여질 텍스트 문자열입니다.
	 - parameter withAccess: 앱이 Keychain 항목의 텍스트에 액세스해야하는 시기를 나타내는 값입니다. 기본적으로 .AccessibleWhenUnlocked 옵션이 사용됩니다. 이 옵션은 기기가 사용자에 의해 잠금 해제될 때만 데이터에 액세스할 수 있도록 허용합니다.
	 
	 - returns: 텍스트가 Keychain에 성공적으로 쓰여졌으면 true를 반환합니다.
	 */
	@discardableResult
	open func set(_ value: String, forKey key: String,
				  withAccess access: KeychainAccessOptions? = nil) -> Bool {
		
		if let value = value.data(using: String.Encoding.utf8) {
			return set(value, forKey: key, withAccess: access)
		}
		
		return false
	}
	
	/**
	 Keychain 항목에 주어진 키 아래에 데이터를 저장합니다.
	 
	 - parameter key: Keychain에 데이터가 저장되는 키입니다.
	 - parameter value: Keychain에 쓰여질 데이터입니다.
	 - parameter withAccess: 앱이 Keychain 항목의 텍스트에 액세스해야하는 시기를 나타내는 값입니다. 기본적으로 .AccessibleWhenUnlocked 옵션이 사용됩니다. 이 옵션은 기기가 사용자에 의해 잠금 해제될 때만 데이터에 액세스할 수 있도록 허용합니다.
	 
	 - returns: 텍스트가 Keychain에 성공적으로 쓰여졌으면 true를 반환합니다.
	 */
	@discardableResult
	open func set(_ value: Data, forKey key: String,
				  withAccess access: KeychainAccessOptions? = nil) -> Bool {
		
		// 코드가 여러 스레드에서 동시에 실행되는 것을 방지하기 위해 잠금을 사용합니다.
		lock.lock()
		defer { lock.unlock() }
		
		deleteNoLock(key) // 저장되기 전에 기존 키를 삭제합니다.
		
		let accessible = access?.value ?? KeychainAccessOptions.defaultOption.value
		
		let prefixedKey = keyWithPrefix(key)
		
		var query: [String : Any] = [
			KeychainConstants.klass    : kSecClassGenericPassword,
			KeychainConstants.attrAccount : prefixedKey,
			KeychainConstants.valueData  : value,
			KeychainConstants.accessible : accessible
		]
		
		query = addAccessGroupWhenPresent(query)
		query = addSynchronizableIfRequired(query, addingItems: true)
		lastQueryParameters = query
		
		lastResultCode = SecItemAdd(query as CFDictionary, nil)
		
		return lastResultCode == noErr
	}
	
	/**
	 Keychain 항목에 주어진 키 아래에 부울 값을 저장합니다.
	 
	 - parameter key: Keychain에 값이 저장되는 키입니다.
	 - parameter value: Keychain에 쓰여질 부울 값입니다.
	 - parameter withAccess: 앱이 Keychain 항목의 값에 액세스해야하는 시기를 나타내는 값입니다. 기본적으로 .AccessibleWhenUnlocked 옵션이 사용됩니다. 이 옵션은 기기가 사용자에 의해 잠금 해제될 때만 데이터에 액세스할 수 있도록 허용합니다.
	 
	 - returns: 값이 Keychain에 성공적으로 쓰여졌으면 true를 반환합니다.
	 */
	@discardableResult
	open func set(_ value: Bool, forKey key: String,
				  withAccess access: KeychainAccessOptions? = nil) -> Bool {
		
		let bytes: [UInt8] = value ? [1] : [0]
		let data = Data(bytes)
		
		return set(data, forKey: key, withAccess: access)
	}
	
	/**
	 주어진 키와 해당하는 Keychain에서 텍스트 값을 검색합니다.
	 
	 - parameter key: Keychain 항목을 읽는 데 사용되는 키입니다.
	 - returns: Keychain에서의 텍스트 값입니다. 항목을 읽을 수 없는 경우 nil을 반환합니다.
	 */
	open func get(_ key: String) -> String? {
		if let data = getData(key) {
			
			if let currentString = String(data: data, encoding: .utf8) {
				return currentString
			}
			
			lastResultCode = -67853 // errSecInvalidEncoding
		}
		
		return nil
	}
	
	/**
	 주어진 키와 해당하는 Keychain에서 데이터를 검색합니다.
	 
	 - parameter key: Keychain 항목을 읽는 데 사용되는 키입니다.
	 - parameter asReference: true인 경우 참조로 데이터를 반환합니다 (NEVPNProtocol과 같은 항목에 필요함).
	 - returns: Keychain에서의 텍스트 값입니다. 항목을 읽을 수 없는 경우 nil을 반환합니다.
	 */
	open func getData(_ key: String, asReference: Bool = false) -> Data? {
		// 코드가 여러 스레드에서 동시에 실행되는 것을 방지하기 위해 잠금을 사용합니다.
		lock.lock()
		defer { lock.unlock() }
		
		let prefixedKey = keyWithPrefix(key)
		
		var query: [String: Any] = [
			KeychainConstants.klass    : kSecClassGenericPassword,
			KeychainConstants.attrAccount : prefixedKey,
			KeychainConstants.matchLimit : kSecMatchLimitOne
		]
		
		if asReference {
			query[KeychainConstants.returnReference] = kCFBooleanTrue
		} else {
			query[KeychainConstants.returnData] = kCFBooleanTrue
		}
		
		query = addAccessGroupWhenPresent(query)
		query = addSynchronizableIfRequired(query, addingItems: false)
		lastQueryParameters = query
		
		var result: AnyObject?
		
		lastResultCode = withUnsafeMutablePointer(to: &result) {
			SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
		}
		
		if lastResultCode == noErr {
			return result as? Data
		}
		
		return nil
	}
	
	/**
	 주어진 키와 해당하는 Keychain에서 부울 값을 검색합니다.
	 
	 - parameter key: Keychain 항목을 읽는 데 사용되는 키입니다.
	 - returns: Keychain에서의 부울 값입니다. 항목을 읽을 수 없는 경우 nil을 반환합니다.
	 */
	open func getBool(_ key: String) -> Bool? {
		guard let data = getData(key) else { return nil }
		guard let firstBit = data.first else { return nil }
		return firstBit == 1
	}
	
	/**
	 주어진 키를 사용하여 키체인에서 단일 키체인 항목을 삭제합니다.
	 
	 - parameter key: 키체인 항목을 삭제하는 데 사용되는 키입니다.
	 - returns: 항목이 성공적으로 삭제되었으면 true를 반환합니다.
	 */
	@discardableResult
	open func delete(_ key: String) -> Bool {
		// 코드가 여러 스레드에서 동시에 실행되는 것을 방지하기 위해 잠금을 사용합니다.
		lock.lock()
		defer { lock.unlock() }
		
		return deleteNoLock(key)
	}
	
	/**
	 Keychain에서 모든 키를 반환합니다.
	 
	 - returns: Keychain에서 모든 키의 문자열 배열입니다.
	 */
	public var allKeys: [String] {
		var query: [String: Any] = [
			KeychainConstants.klass : kSecClassGenericPassword,
			KeychainConstants.returnData : true,
			KeychainConstants.returnAttributes: true,
			KeychainConstants.returnReference: true,
			KeychainConstants.matchLimit: KeychainConstants.secMatchLimitAll
		]
		
		query = addAccessGroupWhenPresent(query)
		query = addSynchronizableIfRequired(query, addingItems: false)
		
		var result: AnyObject?
		
		let lastResultCode = withUnsafeMutablePointer(to: &result) {
			SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
		}
		
		if lastResultCode == noErr {
			return (result as? [[String: Any]])?.compactMap {
				$0[KeychainConstants.attrAccount] as? String } ?? []
		}
		
		return []
	}
	
	/**
	 `delete`와 동일하지만 내부적으로만 액세스되므로 스레드 안전성이 없습니다.
	 
	 - parameter key: 키체인 항목을 삭제하는 데 사용되는 키입니다.
	 - returns: 항목이 성공적으로 삭제되었으면 true를 반환합니다.
	 */
	@discardableResult
	func deleteNoLock(_ key: String) -> Bool {
		let prefixedKey = keyWithPrefix(key)
		
		var query: [String: Any] = [
			KeychainConstants.klass    : kSecClassGenericPassword,
			KeychainConstants.attrAccount : prefixedKey
		]
		
		query = addAccessGroupWhenPresent(query)
		query = addSynchronizableIfRequired(query, addingItems: false)
		lastQueryParameters = query
		
		lastResultCode = SecItemDelete(query as CFDictionary)
		
		return lastResultCode == noErr
	}
	
	/**
	 앱에서 사용하는 모든 Keychain 항목을 삭제합니다. 이 메서드는 클래스를 초기화할 때 설정된 접두사 설정에 관계없이 모든 항목을 삭제합니다.
	 
	 - returns: Keychain 항목이 성공적으로 삭제되었으면 true를 반환합니다.
	 */
	@discardableResult
	open func clear() -> Bool {
		// 코드가 여러 스레드에서 동시에 실행되는 것을 방지하기 위해 잠금을 사용합니다.
		lock.lock()
		defer { lock.unlock() }
		
		var query: [String: Any] = [ kSecClass as String : kSecClassGenericPassword ]
		query = addAccessGroupWhenPresent(query)
		query = addSynchronizableIfRequired(query, addingItems: false)
		lastQueryParameters = query
		
		lastResultCode = SecItemDelete(query as CFDictionary)
		
		return lastResultCode == noErr
	}
	
	func keyWithPrefix(_ key: String) -> String {
		return "\(keyPrefix)\(key)"
	}
	
	func addAccessGroupWhenPresent(_ items: [String: Any]) -> [String: Any] {
		guard let accessGroup = accessGroup else { return items }
		var result: [String: Any] = items
		result[KeychainConstants.accessGroup] = accessGroup
		return result
	}
	
	func addSynchronizableIfRequired(_ items: [String: Any], addingItems: Bool) -> [String: Any] {
		if synchronizable {
			var result: [String: Any] = items
			result[KeychainConstants.attrSynchronizable] = addingItems == true ? true : kSecAttrSynchronizableAny
			return result
		}
		return items
	}
}
