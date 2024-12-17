import Foundation
import Combine
import SwiftUI

@propertyWrapper
struct PublishedAppStorage<Value> {
	@UserDefault private var storedValue: Value
	
	private var publisher: Publisher?
	private var objectWillChange: ObservableObjectPublisher?
	
	struct Publisher: Combine.Publisher {
		typealias Output = Value
		typealias Failure = Never
		
		func receive<S: Subscriber>(subscriber: S) where S.Input == Value, S.Failure == Never {
			subject.subscribe(subscriber)
		}
		
		fileprivate let subject: CurrentValueSubject<Value, Never>
		
		fileprivate init(_ output: Output) {
			self.subject = .init(output)
		}
	}
	
	var projectedValue: Publisher {
		mutating get {
			if let publisher {
				return publisher
			}
			let publisher = Publisher(storedValue)
			self.publisher = publisher
			return publisher
		}
	}
	
	@available(*, unavailable, message: "@Published is only available on properties of classes")
	var wrappedValue: Value {
		get { fatalError() }
		set { fatalError() }
	}
	
	static subscript<EnclosingSelf: ObservableObject>(
		_enclosingInstance object: EnclosingSelf,
		wrapped _: ReferenceWritableKeyPath<EnclosingSelf, Value>,
		storage storageKeyPath: ReferenceWritableKeyPath<EnclosingSelf, PublishedAppStorage<Value>>
	) -> Value {
		get { object[keyPath: storageKeyPath].storedValue }
		set {
			(object.objectWillChange as? ObservableObjectPublisher)?.send()
			object[keyPath: storageKeyPath].publisher?.subject.send(newValue)
			object[keyPath: storageKeyPath].storedValue = newValue
		}
	}
	
	init(wrappedValue: Value, _ key: String, store: UserDefaults = .standard) {
		self._storedValue = UserDefault(wrappedValue: wrappedValue, key, store: store)
	}
}

@propertyWrapper
struct PublishedCodableStorage<Value: Codable> { // Codable을 준수해야 한다고 명시
	@CodableUserDefault private var storedValue: Value
	
	private var publisher: Publisher?
	private var objectWillChange: ObservableObjectPublisher?
	
	struct Publisher: Combine.Publisher {
		typealias Output = Value
		typealias Failure = Never
		
		func receive<S: Subscriber>(subscriber: S) where S.Input == Value, S.Failure == Never {
			subject.subscribe(subscriber)
		}
		
		fileprivate let subject: CurrentValueSubject<Value, Never>
		
		fileprivate init(_ output: Output) {
			self.subject = .init(output)
		}
	}
	
	var projectedValue: Publisher {
		mutating get {
			if let publisher {
				return publisher
			}
			let publisher = Publisher(storedValue)
			self.publisher = publisher
			return publisher
		}
	}
	
	@available(*, unavailable, message: "@Published is only available on properties of classes")
	var wrappedValue: Value {
		get { fatalError() }
		set { fatalError() }
	}
	
	static subscript<EnclosingSelf: ObservableObject>(
		_enclosingInstance object: EnclosingSelf,
		wrapped _: ReferenceWritableKeyPath<EnclosingSelf, Value>,
		storage storageKeyPath: ReferenceWritableKeyPath<EnclosingSelf, PublishedCodableStorage<Value>>
	) -> Value {
		get { object[keyPath: storageKeyPath].storedValue }
		set {
			(object.objectWillChange as? ObservableObjectPublisher)?.send()
			object[keyPath: storageKeyPath].publisher?.subject.send(newValue)
			object[keyPath: storageKeyPath].storedValue = newValue
		}
	}
	
	init(wrappedValue: Value, _ key: String, store: UserDefaults = .standard) {
		self._storedValue = CodableUserDefault(wrappedValue: wrappedValue, key, store: store)
	}
}
