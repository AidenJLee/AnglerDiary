import Combine
import Foundation
import WebKit

class WebViewModel: ObservableObject {
	@Published var urlString: String
	@Published var isLoading: Bool = false
	@Published var url: URL?
	@Published var canGoBack: Bool = false
	@Published var canGoForward: Bool = false
	
	private var webView: WKWebView?
	
	init(urlString: String) {
		self.urlString = urlString
	}
	
	func setWebView(_ webView: WKWebView) {
		self.webView = webView
	}
	
	func updateURL(_ urlString: String) {
		self.urlString = urlString
		if let url = URL(string: urlString) {
			webView?.load(URLRequest(url: url))
		}
	}
	
	func goBack() {
		webView?.goBack()
	}
	
	func goForward() {
		webView?.goForward()
	}
}
