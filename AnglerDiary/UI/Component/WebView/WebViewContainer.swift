import SwiftUI

struct WebViewContainer: View {
	@StateObject private var webViewModel: WebViewModel
	
	init(urlString: String) {
		_webViewModel = StateObject(wrappedValue: WebViewModel(urlString: urlString))
	}
	
	var body: some View {
		ZStack {
			WebView(webViewModel: webViewModel)
				.frame(maxWidth: .infinity, maxHeight: .infinity)
				.onReceive(webViewModel.$isLoading) { isLoading in
					print("Loading status: \(isLoading)")
				}
				.onReceive(webViewModel.$canGoBack) { canGoBack in
					print("Can Go Back: \(canGoBack)")
				}
				.onReceive(webViewModel.$canGoForward) { canGoForward in
					print("Can Go Forward: \(canGoForward)")
				}
			if webViewModel.isLoading {
				ProgressView()
			}
		}
	}
}
