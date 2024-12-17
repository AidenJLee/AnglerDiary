import SwiftUI
import SwiftData

@main
struct AnglerDiaryApp: App {
	@Environment(\.scenePhase) var scenePhase
	@UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
	
	init() {
		
	}
	
	var body: some Scene {
		WindowGroup {
			ContentView()
				.modelContainer(DataManager.shared.container)
				.onOpenURL { url in
					navigateAccordingToURL(url)
				}
				.onContinueUserActivity(NSUserActivityTypeBrowsingWeb) { userActivity in
					if let incomingURL = userActivity.webpageURL {
						handleIncomingURL(incomingURL)
					}
				}
		}
		.onChange(of: scenePhase) { oldScenePhase, newScenePhase in
			switch newScenePhase {
			case .active:
				print("ScenePhase: \(newScenePhase)")
			case .inactive:
				print("ScenePhase: \(newScenePhase)")
			case .background:
				print("ScenePhase: \(newScenePhase)")
			@unknown default:
				print("ScenePhase: \(newScenePhase)")
			}
		}
	}
	
	private func navigateAccordingToURL(_ url: URL) {
		print("앱 관련 부분으로 네비게이션: \(url)")
	}
	
	private func handleIncomingURL(_ url: URL) {
		print("사용자 활동으로부터 URL 처리: \(url)")
	}
}
