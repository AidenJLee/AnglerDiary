import SwiftUI
import Foundation

struct CustomNavigationView: View {
	@Binding var isMenuOpen: Bool // 외부에서 상태를 바인딩하여 관리
	
	// 사용자 지정 초기화 메서드 추가
	init(isMenuOpen: Binding<Bool>) {
		self._isMenuOpen = isMenuOpen
	}
	
	var body: some View {
		HStack {
			Image("Logo_White")
				.resizable()
				.frame(width: 58, height: 24)
				.padding(.leading, 20)
			
			Spacer()
			
			HStack(spacing: 10) {
				// Profile button
				Button(action: {
					// Action for profile button
					print("Profile button clicked")
				}) {
					Image(systemName: "person.circle")
						.resizable()
						.frame(width: 24, height: 24)
						.accentColor(.orange)
						.padding(.vertical, 10) // Expand touch area vertically
				}
				
				// Notification button
				Button(action: {
					// Action for notification button
					print("Notification button clicked")
				}) {
					Image(systemName: "bell")
						.resizable()
						.frame(width: 24, height: 24)
						.accentColor(.gray)
						.padding(.vertical, 10) // Expand touch area vertically
				}
				
				// Menu button
				Button(action: {
					isMenuOpen.toggle()
				}) {
					Image(systemName: "line.horizontal.3")
						.resizable()
						.frame(width: 24, height: 24)
						.accentColor(.white)
						.padding(.vertical, 10) // Expand touch area vertically
				}
			}
			.padding(.trailing, 20)
		}
		.frame(height: 44) // Standard height for navigation bars
		.background(Color.clear)
		.shadow(color: Color.gray.opacity(0.5), radius: 2, x: 0, y: 2)
	}
}
