import Combine
import SwiftUI

enum APPEnvironment {
	case production
	case development
}

class EnvironmentManager: ObservableObject {
	static let shared = EnvironmentManager()
	
	// 앱 환경 설정
	@Published var state: APPEnvironment = .production
	
	// API URL
	@Published var currentOPENAPIURL: String = ""
	
	// 초기 설정 및 셋팅이 끝났는지 확인 (Splash -> Main) : 앱 재시작과 비슷한 효과를 원하면 값을 변경
	@Published var isInitialSetupCompleted: Bool = false
	
	// 사이드 메뉴 제어
	@Published var presentSideMenu: Bool = false
	
	// 리소스 업데이트 체크 완료
	@Published var AllResourcesUpdated: Bool = false
	
	// 탑승권 버튼
	@Published var showMobileBoardingPassButton: Bool = false
	
	private var cancellables = Set<AnyCancellable>()
	
	private init() {
		// 구독 설정
		$state
			.removeDuplicates()
			.map { [weak self] state in
				self?.APIURL(for: state) ?? ""
			}
			.assign(to: \.currentOPENAPIURL, on: self)
			.store(in: &cancellables)
	}
	
	// Extension에 있는데 함수로 만든이유 : Published는 값이 바로 바뀌지 않음. 이전 값으로 잘 못 가져오기 때문에 state값으로 바로 처리하기 위해 함수로 작성
	func APIURL(for state: APPEnvironment) -> String {
		switch state {
		case .production:
			return "https://api.anglerdiary.com"
		case .development:
			return "https://devapi.anglerdiary.com"
		}
	}
}

extension EnvironmentManager {
	var OPENAPIURL: String {
		return self.APIURL(for: state)
	}
}
