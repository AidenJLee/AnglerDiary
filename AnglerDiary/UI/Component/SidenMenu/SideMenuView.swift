import SwiftUI

struct SideMenuView: View {
	var body: some View {
		VStack {
			Text("Side Menu")
				.font(.largeTitle)
				.padding()
			Spacer()
		}
		.frame(maxWidth: .infinity)
		.background(Color.white)
		.shadow(radius: 10)
	}
}

#Preview {
	SideMenuView()
}
