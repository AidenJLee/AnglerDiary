import SwiftUI
import SwiftData

struct ContentView: View {
	@State private var isSideMenuOpen: Bool = false // 사이드 메뉴의 상태를 관리하는 State 변수
	
	var body: some View {
		ZStack(alignment: .top) { // Align to top
			// 메인 콘텐츠
			MainTabView()
				.edgesIgnoringSafeArea(.all) // 탭뷰가 전체 영역을 차지하도록 설정
			CustomNavigationView(isMenuOpen: $isSideMenuOpen)
			// 사이드 메뉴
			SideMenu(isMenuOpen: $isSideMenuOpen)
		}
	}
}
