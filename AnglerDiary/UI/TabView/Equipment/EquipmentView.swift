import SwiftUI
import SwiftData

// 장비 목록을 표시하는 메인 뷰
struct EquipmentView: View {
	// SwiftData를 사용하여 장비 데이터를 쿼리
	@Query private var equipments: [SDEquipment]
	
	var body: some View {
		ScrollView {
			VStack(alignment: .leading, spacing: 20) {
				// 장비 인벤토리
				Text("Gear Vault")
					.font(.largeTitle)
					.fontWeight(.bold)
					.padding([.leading, .top])
				
				ForEach(equipments) { equipment in
					EquipmentCard(equipment: equipment)
				}
				
				// 장비 추가 버튼
				VStack {
					Spacer()
					HStack {
						Spacer()
						Button(action: {
							// 장비 추가 액션
							print("Add Equipment tapped")
							// 여기에 장비 추가 로직 추가
						}) {
							Image(systemName: "plus")
								.resizable()
								.frame(width: 24, height: 24)
								.padding()
						}
						.background(Color.orange)
						.foregroundColor(.white)
						.clipShape(Circle())
						.shadow(radius: 5)
						.padding()
					}
				}
			}
			.padding(.bottom, 20)
		}
	}
}

// 장비 카드 뷰
struct EquipmentCard: View {
	var equipment: SDEquipment
	
	var body: some View {
		VStack(alignment: .leading, spacing: 10) {
			HStack {
				Image(systemName: "gear")
					.resizable()
					.frame(width: 60, height: 60)
					.clipShape(Circle())
					.shadow(radius: 2)
				VStack(alignment: .leading) {
					Text(equipment.name)
						.font(.headline)
						.fontWeight(.bold)
						.foregroundColor(.white)
					Text("\(equipment.brand) - \(equipment.model)")
						.font(.subheadline)
						.foregroundColor(.white)
				}
				Spacer()
				Text(equipmentStatusText(for: equipment))
					.font(.subheadline)
					.padding(5)
					.background(equipmentStatusColor(for: equipment))
					.foregroundColor(.white)
					.clipShape(Capsule())
			}
			
			// 사용 빈도 게이지
			UsageFrequencyView(frequency: equipment.usageFrequency)
		}
		.padding()
		.background(Color(#colorLiteral(red: 0.1725490196, green: 0.2470588235, blue: 0.3137254902, alpha: 1)))
		.cornerRadius(10)
		.padding(.horizontal)
	}
	
	private func equipmentStatusText(for equipment: SDEquipment) -> String {
		if equipment.usageFrequency < 10 {
			return "새 것"
		} else if equipment.usageFrequency < 30 {
			return "사용 중"
		} else {
			return "교체 필요"
		}
	}
	
	private func equipmentStatusColor(for equipment: SDEquipment) -> Color {
		if equipment.usageFrequency < 10 {
			return Color.green
		} else if equipment.usageFrequency < 30 {
			return Color.orange
		} else {
			return Color.red
		}
	}
}

// 사용 빈도 게이지 뷰
struct UsageFrequencyView: View {
	var frequency: Int
	
	var body: some View {
		HStack {
			Text("Usage:")
				.foregroundColor(.white)
			GeometryReader { geometry in
				ZStack(alignment: .leading) {
					Rectangle()
						.fill(Color.gray.opacity(0.3))
					Rectangle()
						.fill(Color.green)
						.frame(width: geometry.size.width * CGFloat(frequency) / 100)
				}
				.frame(height: 8)
				.cornerRadius(4)
			}
		}
		.frame(height: 20)
	}
}

// 프리뷰를 위한 더미 데이터 설정
#Preview {
	EquipmentView()
		.modelContainer(for: [SDEquipment.self, SDUser.self]) { result in
			switch result {
			case .success(let container):
				let context = container.mainContext
				
				// 더미 데이터 생성
				let users = [
					SDUser(email: "john@example.com", nickname: "John"),
					SDUser(email: "doe@example.com", nickname: "Doe"),
					SDUser(email: "jane@example.com", nickname: "Jane")
				]
				
				let equipments = [
					SDEquipment(name: "Fishing Rod", brand: "Shimano", model: "XYZ123", owner: users[0], purchaseDate: Date(), usageFrequency: 10),
					SDEquipment(name: "Reel", brand: "Daiwa", model: "ABC456", owner: users[1], purchaseDate: Date(), usageFrequency: 30),
					SDEquipment(name: "Bait", brand: "Berkley", model: "ZOO789", owner: users[2], purchaseDate: Date(), usageFrequency: 5)
				]
				
				// 데이터 삽입
				users.forEach { context.insert($0) }
				equipments.forEach { context.insert($0) }
			case .failure(let error):
				fatalError("Failed to create ModelContainer: \(error)")
			}
		}
}
