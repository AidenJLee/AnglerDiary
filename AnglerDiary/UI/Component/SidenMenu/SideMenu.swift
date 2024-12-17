import SwiftUI

struct SideMenu: View {
	@GestureState private var translation: CGSize = .zero // 제스처 상태를 추적하는 GestureState 속성
	@Binding var isMenuOpen: Bool // 외부에서 상태를 바인딩하여 관리

	var edgeTransition: AnyTransition = .move(edge: .trailing) // 메뉴바 방향
	private var maxDragWidth: CGFloat = 120 // 사이드 메뉴를 숨기는 기준 너비

	// 사용자 지정 초기화 메서드 추가
	init(isMenuOpen: Binding<Bool>) {
		self._isMenuOpen = isMenuOpen
	}

	var body: some View {
		ZStack(alignment: .bottom) {
			if isMenuOpen {
				SideMenuView()
					.transition(edgeTransition)
					.offset(x: max(translation.width, 0))
					.gesture(
						DragGesture()
							.updating($translation) { value, state, _ in
								state = value.translation // 제스처의 변화를 translation에 반영
							}
							.onEnded { value in
								if value.translation.width > self.maxDragWidth { // 사이드 메뉴를 숨김
									isMenuOpen = false
								} else { // 원래의 트랜지션으로 돌아감
									isMenuOpen = true
								}
							}
					)
			}
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
		.ignoresSafeArea()
		.animation(.easeInOut, value: isMenuOpen)
	}
}
