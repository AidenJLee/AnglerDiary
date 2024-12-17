import SwiftUI
import SwiftData

// 날씨 정보 모델
struct WeatherInfo {
	var iconName: String
	var temperature: Double
	var tideInfo: String
}

// HomeView
struct HomeView: View {
	// SwiftData에서 일정 데이터를 가져오기 위한 쿼리
	@Query(sort: \SDSchedule.startDate) private var schedules: [SDSchedule]
	@State private var weatherInfo = WeatherInfo(iconName: "sun.max.fill", temperature: 25.0, tideInfo: "High Tide")
	
	var body: some View {
		ZStack {
			ScrollView {
				VStack(alignment: .leading, spacing: 20) {
					// 일정 미리보기 섹션
					Text("Upcoming Fishing Trips")
						.font(.title)
						.fontWeight(.bold)
						.padding([.leading, .top])
					
					ForEach(schedules) { schedule in
						HomeScheduleCard(schedule: schedule)
					}
					
					// 날씨 및 물때 정보 섹션
					WeatherTideView(weatherInfo: weatherInfo)
					
					// 추천 콘텐츠 섹션
					Text("Recommended for You")
						.font(.title)
						.fontWeight(.bold)
						.padding(.leading)
				}
			}
			
			// 일정 만들기 버튼 (FAB)
			VStack {
				Spacer()
				HStack {
					Spacer()
					Button(action: {
						// 일정 만들기 액션
						print("Create Schedule tapped")
						// 여기에 일정 만들기 로직 추가
					}) {
						Image(systemName: "plus")
							.resizable()
							.frame(width: 24, height: 24)
							.padding()
					}
					.background(Color.blue)
					.foregroundColor(.white)
					.clipShape(Circle())
					.shadow(radius: 5)
					.padding()
				}
			}
		}
	}
}

// 날씨 및 물때 뷰
struct WeatherTideView: View {
	var weatherInfo: WeatherInfo
	
	var body: some View {
		HStack(spacing: 20) {
			Image(systemName: weatherInfo.iconName)
				.resizable()
				.frame(width: 50, height: 50)
			VStack(alignment: .leading) {
				Text("Temperature: \(Int(weatherInfo.temperature))°C")
					.font(.subheadline)
				Text("Tide: \(weatherInfo.tideInfo)")
					.font(.subheadline)
			}
		}
		.padding()
		.background(Color.blue.opacity(0.2))
		.cornerRadius(10)
		.padding([.leading, .trailing])
	}
}

// 일정 카드 뷰
struct HomeScheduleCard: View {
	var schedule: SDSchedule
	
	var body: some View {
		VStack(alignment: .leading, spacing: 10) {
			Text(schedule.title)
				.font(.headline)
				.foregroundColor(.black)
			Text("Time: \(schedule.startDate, formatter: DateFormatter.hhmm) - \(schedule.endDate, formatter: DateFormatter.hhmm)")
				.font(.subheadline)
				.foregroundColor(.gray)
			Text("Location: \(schedule.location)")
				.font(.subheadline)
				.foregroundColor(.gray)
			HStack {
				ForEach(schedule.participants.prefix(3)) { user in
					Image(systemName: "person.circle.fill")
						.resizable()
						.frame(width: 30, height: 30)
						.clipShape(Circle())
				}
			}
		}
		.padding()
		.background(Color(.systemGray6))
		.cornerRadius(10)
		.frame(maxWidth: .infinity, alignment: .leading)
	}
}

// 샘플 데이터를 위한 프리뷰
#Preview {
	HomeView()
		.modelContainer(for: [SDSchedule.self, SDUser.self]) { result in
			switch result {
			case .success(let container):
				let context = container.mainContext
				SampleData.schedules.forEach { context.insert($0) }
			case .failure(let error):
				fatalError("Failed to create ModelContainer: \(error)")
			}
		}
}

// 샘플 데이터 생성
struct SampleData {
	static let users: [SDUser] = {
		let user1 = SDUser(email: "john@example.com", nickname: "John", phoneNumber: "123456789")
		let user2 = SDUser(email: "jane@example.com", nickname: "Jane", phoneNumber: "987654321")
		return [user1, user2]
	}()
	
	static let schedules: [SDSchedule] = {
		let schedule1 = SDSchedule(title: "Morning Fishing", startDate: Date(), endDate: Date().addingTimeInterval(3600), location: "Lake Park", notes: "Bring sunscreen.")
		let schedule2 = SDSchedule(title: "Evening Fishing", startDate: Date().addingTimeInterval(86400), endDate: Date().addingTimeInterval(10800), location: "River Side", notes: "Bring extra bait.")
		
		// Assign participants to schedules
		schedule1.participants.append(SampleData.users[0])
		schedule2.participants.append(SampleData.users[1])
		
		return [schedule1, schedule2]
	}()
}
