import SwiftUI
import Foundation

final class PreferenceManager: ObservableObject {
	static let shared = PreferenceManager()
	
	// 외부에 변화를 알릴 필요 없이 체크만 하는 속성
	@UserDefault(wrappedValue: 0, "installTime") var installTime: TimeInterval					// 설치 시간 : 푸시 데이터 가져 올 때 기준 값(설치 이전 푸시는 무시)
	@UserDefault(wrappedValue: false, "isLanguageSetupComplete") var isLanguageSetupComplete	// 최초 언어 설정 유무
	@UserDefault(wrappedValue: false, "gdprConsent") var gdprConsent
	
	// 외부에 변화를 알릴 필요가 있는 속성
	@PublishedAppStorage("regionCode") var regionCode: String = "KR"
	@PublishedAppStorage("languageCode") var languageCode: String = "ko-KR"
}
