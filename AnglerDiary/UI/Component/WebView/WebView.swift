import SwiftUI
import WebKit
import Combine

struct WebView: UIViewRepresentable {
	@ObservedObject var webViewModel: WebViewModel
	
	func makeCoordinator() -> Coordinator {
		Coordinator(webViewModel: webViewModel)
	}
	
	func makeUIView(context: Context) -> WKWebView {
		let configuration = WKWebViewConfiguration()
		let userContentController = WKUserContentController()
		
		// Add JavaScript message handlers
		userContentController.add(context.coordinator, name: "loginUser")
		userContentController.add(context.coordinator, name: "loginSNS")
		userContentController.add(context.coordinator, name: "loginBioAuth")
		userContentController.add(context.coordinator, name: "registerBioAuth")
		userContentController.add(context.coordinator, name: "logout")
		userContentController.add(context.coordinator, name: "checkDeviceBioAvailability")
		userContentController.add(context.coordinator, name: "checkBioAuthSetting")
		userContentController.add(context.coordinator, name: "checkBrightnessControl")
		userContentController.add(context.coordinator, name: "checkCameraAuth")
		userContentController.add(context.coordinator, name: "scanPassportData")
		userContentController.add(context.coordinator, name: "addToAppleWallet")
		userContentController.add(context.coordinator, name: "addToSamsungWallet")
		userContentController.add(context.coordinator, name: "openSnsShare")
		userContentController.add(context.coordinator, name: "goHome")
		userContentController.add(context.coordinator, name: "goBack")
		userContentController.add(context.coordinator, name: "openMenu")
		userContentController.add(context.coordinator, name: "updateCsrfToken")
		userContentController.add(context.coordinator, name: "trackHybridEvent")
		userContentController.add(context.coordinator, name: "trackAdbrixEvent")
		userContentController.add(context.coordinator, name: "setLanguageSuccess")
		
		configuration.userContentController = userContentController
		configuration.allowsInlineMediaPlayback = true
		configuration.applicationNameForUserAgent = "/GA_iOS_WK"
		
		// Create WKWebpagePreferences and set allowsContentJavaScript
		let webpagePreferences = WKWebpagePreferences()
		webpagePreferences.allowsContentJavaScript = true
		configuration.defaultWebpagePreferences = webpagePreferences
		
		let webView = WKWebView(frame: .zero, configuration: configuration)
		webView.navigationDelegate = context.coordinator
		webView.uiDelegate = context.coordinator
		
		webViewModel.setWebView(webView)
		
		if let url = URL(string: webViewModel.urlString) {
			webView.load(URLRequest(url: url))
		}
		
		context.coordinator.setupObservers(for: webView)
		
		return webView
	}
	
	func updateUIView(_ uiView: WKWebView, context: Context) {
		// No additional updates needed
	}
	
	class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {
		@ObservedObject var webViewModel: WebViewModel
		private var cancellables: Set<AnyCancellable> = []
		
		init(webViewModel: WebViewModel) {
			self.webViewModel = webViewModel
		}
		
		func setupObservers(for webView: WKWebView) {
			// URL 변경 감지 제거
			webView.publisher(for: \.isLoading)
				.receive(on: RunLoop.main)
				.sink { [weak self] isLoading in
					self?.webViewModel.isLoading = isLoading
				}
				.store(in: &cancellables)
			
			webView.publisher(for: \.canGoBack)
				.receive(on: RunLoop.main)
				.sink { [weak self] canGoBack in
					self?.webViewModel.canGoBack = canGoBack
				}
				.store(in: &cancellables)
			
			webView.publisher(for: \.canGoForward)
				.receive(on: RunLoop.main)
				.sink { [weak self] canGoForward in
					self?.webViewModel.canGoForward = canGoForward
				}
				.store(in: &cancellables)
		}
		
		func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
			webViewModel.isLoading = true
			webViewModel.url = webView.url
		}
		
		func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
			webViewModel.isLoading = false
			let gaClientid = "aaa"
			let script = "document.cookie = '_ga_cid = \(gaClientid)';"
			webView.evaluateJavaScript(script, completionHandler: { (result, error) in
				if let error = error {
					print("Error injecting JavaScript: \(error)")
				}
			})
		}
		
		func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
			webViewModel.isLoading = false
		}
		
		func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
			webViewModel.isLoading = false
		}
		
		func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
			if let response = navigationResponse.response as? HTTPURLResponse {
				let headers = response.allHeaderFields as! [String: String]
				let cookies = HTTPCookie.cookies(withResponseHeaderFields: headers, for: response.url!)
				
				for cookie in cookies {
					HTTPCookieStorage.shared.setCookie(cookie)
				}
//				self.cookies.append(contentsOf: cookies)
				
				if response.url?.absoluteString.contains("app/payment/complete?encPnrNumber") == true {
					webViewModel.isLoading = false
				}
			}
			
			decisionHandler(.allow)
		}
		
		func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
			// Handle JavaScript messages
			if let messageBody = message.body as? String {
				switch message.name {
				case "loginUser":
					loginUser(messageBody: messageBody)
				case "loginSNS":
					loginSNS(messageBody: messageBody)
				case "loginBioAuth":
					loginBioAuth()
				case "registerBioAuth":
					registerBioAuth()
				case "logout":
					logout()
				case "checkDeviceBioAvailability":
					let available = checkDeviceBioAvailability()
					print(available)
					// Optionally send a response back to JavaScript
				case "checkBioAuthSetting":
					let settingEnabled = checkBioAuthSetting()
					print(settingEnabled)
					// Optionally send a response back to JavaScript
				case "checkBrightnessControl":
					let brightnessControlAvailable = checkBrightnessControl()
					print(brightnessControlAvailable)
					// Optionally send a response back to JavaScript
				case "checkCameraAuth":
					let cameraAuthorized = checkCameraAuth()
					print(cameraAuthorized)
					// Optionally send a response back to JavaScript
				case "scanPassportData":
					scanPassportData()
				case "addToAppleWallet":
					addToAppleWallet()
				case "addToSamsungWallet":
					addToSamsungWallet()
				case "openSnsShare":
					openSnsShare()
				case "goHome":
					goHome()
				case "goBack":
					goBack()
				case "openMenu":
					openMenu()
				case "updateCsrfToken":
					updateCsrfToken(messageBody)
				case "trackHybridEvent":
					trackHybridEvent(messageBody)
				case "trackAdbrixEvent":
					trackAdbrixEvent(messageBody)
				case "setLanguageSuccess":
					setLanguageSuccess(messageBody)
				default:
					print("Unknown message received")
				}
			}
		}
		
		func loginUser(messageBody: String) {
			print("Login User with details: \(messageBody)")
		}
		
		func loginSNS(messageBody: String) {
			print("Login via SNS with token: \(messageBody)")
		}
		
		func loginBioAuth() {
			print("Performing biometric authentication")
		}
		
		func registerBioAuth() {
			print("Registering biometric data")
		}
		
		func logout() {
			print("Logging out user")
		}
		
		func checkDeviceBioAvailability() -> Bool {
			// Assume checking device's capability
			return true
		}
		
		func checkBioAuthSetting() -> Bool {
			// Assume checking if biometric is set up
			return true
		}
		
		func checkBrightnessControl() -> Bool {
			// Assume checking if brightness control is allowed
			return true
		}
		
		func checkCameraAuth() -> Bool {
			// Assume checking if camera access is authorized
			return true
		}
		
		func scanPassportData() {
			print("Scanning passport data")
		}
		
		func addToAppleWallet() {
			print("Adding to Apple Wallet")
		}
		
		func addToSamsungWallet() {
			print("Adding to Samsung Wallet")
		}
		
		func openSnsShare() {
			print("Opening SNS share interface")
		}
		
		func goHome() {
			print("Going to home screen")
			webViewModel.updateURL("https://www.example.com")
		}
		
		func goBack() {
			print("Going back in web history")
			webViewModel.goBack()
		}
		
		func openMenu() {
			print("Opening side menu")
		}
		
		func updateCsrfToken(_ token: String) {
			print("Updating CSRF token to: \(token)")
		}
		
		func trackHybridEvent(_ eventDetails: String) {
			print("Tracking hybrid event: \(eventDetails)")
		}
		
		func trackAdbrixEvent(_ eventDetails: String) {
			print("Tracking Adbrix event: \(eventDetails)")
		}
		
		func setLanguageSuccess(_ languageCode: String) {
			print("Setting language success with code: \(languageCode)")
		}
	}
}
