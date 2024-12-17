import SwiftUI
import Combine

struct MainTabView: View {
	// 현재 선택된 탭
	@State var selectedTab: AppTab = .one

	init() {
		configureTabBarAppearance()
	}

	var body: some View {
		ZStack {
			TabView(selection: $selectedTab) {
				ForEach(AppTab.allCases, id: \.self) { tab in
					tab.content
						.tabItem {
							createTabItem(tab: tab, isSelected: selectedTab == tab)
						}
						.tag(tab)
				}
			}
			.accentColor(.red)
			.onChange(of: selectedTab) { oldValue, newValue in
				
			}
		}
	}

	// 탭 아이템을 생성하는 메서드
	private func createTabItem(tab: AppTab, isSelected: Bool) -> some View {
		VStack {
			if let uiImage = UIImage(named: tab.imageName) {
				Image(uiImage: uiImage)
					.renderingMode(.original)
			} else {
				Image(systemName: "photo") // 대체 이미지
					.renderingMode(.original)
			}
			Text(tab.title)
				.font(.headline)
		}
	}

	private func configureTabBarAppearance() {
		let appearance = UITabBarAppearance()
		appearance.backgroundColor = UIColor.white
		appearance.shadowColor = UIColor.gray.withAlphaComponent(0.5)
		UITabBar.appearance().standardAppearance = appearance
		UITabBar.appearance().scrollEdgeAppearance = appearance
		UITabBar.appearance().isTranslucent = false
		UITabBar.appearance().unselectedItemTintColor = .gray
		UITabBar.appearance().tintColor = UIColor(named: "TabTint")
	}
}

enum AppTab: String, Hashable, CaseIterable {
	case one
	case two
	case three
	case four
	case five

	@ViewBuilder
	var content: some View {
		switch self {
		case .one:
			HomeView()
		case .two:
			ScheduleView()
		case .three:
			NowView()
		case .four:
			CommunityView()
		case .five:
			EquipmentView()
		}
	}

	// 각 탭의 라벨 이름 반환
	var title: String {
		switch self {
		case .one:
			return "Home"
		case .two:
			return "Schedule"
		case .three:
			return "Now"
		case .four:
			return "Community"
		case .five:
			return "Gear"
		}
	}

	// 각 탭에 대한 기본 이미지 이름 반환
	var imageName: String {
		switch self {
		case .one:
			return "T1"
		case .two:
			return "T2"
		case .three:
			return "T3"
		case .four:
			return "T4"
		case .five:
			return "T5"
		}
	}
}

#Preview {
	MainTabView()
}
