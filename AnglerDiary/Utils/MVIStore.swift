import Combine
import Foundation

// Reducer 프로토콜
protocol Reducer {
	associatedtype State
	associatedtype Intent
	
	func reduce(state: inout State, intent: Intent)
}

// Store 클래스
class Store<R: Reducer>: ObservableObject {
	@Published private(set) var state: R.State
	
	private let reducer: R
	
	init(initialState: R.State, reducer: R) {
		self.state = initialState
		self.reducer = reducer
	}
	
	func send(intent: R.Intent) {
		reducer.reduce(state: &state, intent: intent)
	}
}
