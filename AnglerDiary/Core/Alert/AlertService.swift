import SwiftUI

class AlertService: ObservableObject {
	static let shared = AlertService()
	
	@Published var isShowingAlert = false
	@Published var alertTitle = ""
	@Published var alertMessage = ""
	@Published var alertButtons: [Alert.Button] = []
	
	private var alertQueue: [(title: String, message: String, buttons: [Alert.Button])] = []
	
	private init() { }
	
	func showAlert(title: String, message: String, buttons: [Alert.Button] = [.default(Text("OK"))]) {
		DispatchQueue.main.async {
			self.alertQueue.append((title, message, buttons))
			self.showNextAlert()
		}
	}
	
	func showNextAlert() {
		guard !alertQueue.isEmpty else { return }
		
		if !isShowingAlert {
			let nextAlert = alertQueue.removeFirst()
			alertTitle = nextAlert.title
			alertMessage = nextAlert.message
			alertButtons = nextAlert.buttons
			isShowingAlert = true
		}
	}
	
	func alertDismissed() {
		DispatchQueue.main.async {
			self.isShowingAlert = false
			self.showNextAlert()
		}
	}
	
	// Additional methods for testing
	func getAlertQueue() -> [(title: String, message: String, buttons: [Alert.Button])] {
		return alertQueue
	}
	
	func reset() {
		isShowingAlert = false
		alertTitle = ""
		alertMessage = ""
		alertButtons = []
		alertQueue.removeAll()
	}
}
