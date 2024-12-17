import SwiftUI
import SwiftData

// NowView는 낚시 활동의 세 가지 단계(준비, 진행 중, 종료 후)를 관리합니다.
struct NowView: View {
	// 현재 낚시 활동 상태
	enum FishingStage {
		case preparation, onFishing, postFishing
	}
	
	@State private var currentStage: FishingStage = .preparation
	
	var body: some View {
		VStack {
			// 탭에 따른 제목
			Text(getTitle(for: currentStage))
				.font(.largeTitle)
				.fontWeight(.bold)
				.padding()
			
			// 상태에 따른 뷰
			switch currentStage {
			case .preparation:
				PreparationView()
			case .onFishing:
				OnFishingView()
			case .postFishing:
				PostFishingView()
			}
			
			// 상태 전환 버튼
			HStack {
				Button(action: { currentStage = .preparation }) {
					Text("Preparation")
						.padding()
						.background(currentStage == .preparation ? Color.blue : Color.gray.opacity(0.3))
						.foregroundColor(.white)
						.cornerRadius(10)
				}
				
				Button(action: { currentStage = .onFishing }) {
					Text("On Fishing")
						.padding()
						.background(currentStage == .onFishing ? Color.blue : Color.gray.opacity(0.3))
						.foregroundColor(.white)
						.cornerRadius(10)
				}
				
				Button(action: { currentStage = .postFishing }) {
					Text("Post Fishing")
						.padding()
						.background(currentStage == .postFishing ? Color.blue : Color.gray.opacity(0.3))
						.foregroundColor(.white)
						.cornerRadius(10)
				}
			}
			.padding()
		}
	}
	
	private func getTitle(for stage: FishingStage) -> String {
		switch stage {
		case .preparation:
			return "Get Ready"
		case .onFishing:
			return "In the Moment"
		case .postFishing:
			return "Reflect and Learn"
		}
	}
}

// 사전 준비 뷰
struct PreparationView: View {
	@Query(sort: \SDSchedule.startDate) var schedules: [SDSchedule]
	
	var body: some View {
		VStack(spacing: 20) {
			// 일정 관리 카드
			ForEach(schedules) { schedule in
				ScheduleCard(schedule: schedule)
			}
			
			// 장비 준비 상태
			EquipmentChecklistView()
			
			// 실시간 포인트 정보
			FishingPointInfoView()
		}
		.padding()
	}
}

// 낚시 중 뷰
struct OnFishingView: View {
	var body: some View {
		VStack(spacing: 20) {
			// 실시간 조과 업데이트
			CatchUpdateFeedView()
			
			// 채팅 및 위치 공유
			ChatAndLocationSharingView()
			
			// 조과 기록
			CatchRecordingView()
			
			// 비용 추적
			ExpenseTrackingView()
		}
		.padding()
	}
}

// 낚시 후 뷰
struct PostFishingView: View {
	var body: some View {
		VStack(spacing: 20) {
			// 조과 요약 및 분석
			CatchSummaryView()
			
			// 비용 관리 및 정산
			ExpenseManagementView()
			
			// SNS 공유 및 피드백
			SocialSharingAndFeedbackView()
		}
		.padding()
	}
}

// 장비 준비 상태 체크리스트
struct EquipmentChecklistView: View {
	var body: some View {
		VStack(alignment: .leading, spacing: 10) {
			Text("Equipment Checklist")
				.font(.headline)
				.fontWeight(.bold)
			List {
				EquipmentCheckItem(name: "Rod", isChecked: false)
				EquipmentCheckItem(name: "Reel", isChecked: true)
				EquipmentCheckItem(name: "Bait", isChecked: false)
			}
			.frame(height: 150)
		}
		.padding()
		.background(Color.gray.opacity(0.2))
		.cornerRadius(10)
	}
}

struct EquipmentCheckItem: View {
	var name: String
	@State var isChecked: Bool
	
	var body: some View {
		HStack {
			Text(name)
			Spacer()
			Button(action: { isChecked.toggle() }) {
				Image(systemName: isChecked ? "checkmark.circle.fill" : "circle")
					.foregroundColor(isChecked ? Color.green : Color.gray)
			}
		}
	}
}

// 실시간 포인트 정보
struct FishingPointInfoView: View {
	var body: some View {
		VStack(alignment: .leading, spacing: 10) {
			Text("Fishing Point Info")
				.font(.headline)
				.fontWeight(.bold)
			Text("Catch Rate: High")
			Text("Weather: Sunny")
		}
		.padding()
		.background(Color.gray.opacity(0.2))
		.cornerRadius(10)
	}
}

// 실시간 조과 업데이트 뷰
struct CatchUpdateFeedView: View {
	var body: some View {
		VStack(alignment: .leading, spacing: 10) {
			Text("Catch Updates")
				.font(.headline)
				.fontWeight(.bold)
			HStack {
				Image("catch1")
					.resizable()
					.frame(width: 100, height: 100)
					.clipShape(RoundedRectangle(cornerRadius: 10))
				VStack(alignment: .leading) {
					Text("Species: Bass")
					Text("Location: North Dock")
				}
			}
		}
		.padding()
		.background(Color.blue.opacity(0.2))
		.cornerRadius(10)
	}
}

// 채팅 및 위치 공유 뷰
struct ChatAndLocationSharingView: View {
	var body: some View {
		VStack(alignment: .leading, spacing: 10) {
			Text("Chat & Location")
				.font(.headline)
				.fontWeight(.bold)
			TextField("Type a message", text: .constant(""))
				.padding()
				.background(Color.white)
				.cornerRadius(10)
				.shadow(radius: 2)
			Button(action: {}) {
				Image(systemName: "location.fill")
					.resizable()
					.frame(width: 30, height: 30)
			}
			.padding()
			.background(Color.blue)
			.foregroundColor(.white)
			.clipShape(Circle())
			.shadow(radius: 5)
		}
		.padding()
		.background(Color.gray.opacity(0.2))
		.cornerRadius(10)
	}
}

// 조과 기록 뷰
struct CatchRecordingView: View {
	var body: some View {
		VStack(alignment: .leading, spacing: 10) {
			Text("Record a Catch")
				.font(.headline)
				.fontWeight(.bold)
			HStack {
				TextField("Species", text: .constant(""))
					.padding()
					.background(Color.white)
					.cornerRadius(10)
					.shadow(radius: 2)
				TextField("Weight", text: .constant(""))
					.padding()
					.background(Color.white)
					.cornerRadius(10)
					.shadow(radius: 2)
			}
			Button(action: {}) {
				Image(systemName: "camera.fill")
					.resizable()
					.frame(width: 30, height: 30)
			}
			.padding()
			.background(Color.green)
			.foregroundColor(.white)
			.clipShape(Circle())
			.shadow(radius: 5)
		}
		.padding()
		.background(Color.gray.opacity(0.2))
		.cornerRadius(10)
	}
}

// 비용 추적 뷰
struct ExpenseTrackingView: View {
	var body: some View {
		VStack(alignment: .leading, spacing: 10) {
			Text("Expense Tracking")
				.font(.headline)
				.fontWeight(.bold)
			List {
				ExpenseItem(name: "Bait", amount: 15.0)
				ExpenseItem(name: "Food", amount: 10.0)
			}
			.frame(height: 120)
		}
		.padding()
		.background(Color.gray.opacity(0.2))
		.cornerRadius(10)
	}
}

struct ExpenseItem: View {
	var name: String
	var amount: Double
	
	var body: some View {
		HStack {
			Text(name)
			Spacer()
			Text("$\(amount, specifier: "%.2f")")
				.foregroundColor(.blue)
		}
	}
}

// 조과 요약 및 분석 뷰
struct CatchSummaryView: View {
	var body: some View {
		VStack(alignment: .leading, spacing: 10) {
			Text("Catch Summary")
				.font(.headline)
				.fontWeight(.bold)
			Text("Total Catches: 15")
			// 그래프 예시 (파이 차트, 막대 그래프 등)
		}
		.padding()
		.background(Color.gray.opacity(0.2))
		.cornerRadius(10)
	}
}

// 비용 관리 및 정산 뷰
struct ExpenseManagementView: View {
	var body: some View {
		VStack(alignment: .leading, spacing: 10) {
			Text("Expense Management")
				.font(.headline)
				.fontWeight(.bold)
			Text("Total Expense: $50.00")
			// 비용 정산 테이블
		}
		.padding()
		.background(Color.gray.opacity(0.2))
		.cornerRadius(10)
	}
}

// SNS 공유 및 피드백 뷰
struct SocialSharingAndFeedbackView: View {
	var body: some View {
		VStack(alignment: .leading, spacing: 10) {
			Text("Share & Feedback")
				.font(.headline)
				.fontWeight(.bold)
			HStack {
				Button(action: {}) {
					Image(systemName: "square.and.arrow.up")
						.resizable()
						.frame(width: 40, height: 40)
				}
				.padding()
				.background(Color.blue)
				.foregroundColor(.white)
				.clipShape(Circle())
				.shadow(radius: 5)
			}
		}
		.padding()
		.background(Color.gray.opacity(0.2))
		.cornerRadius(10)
	}
}

// 프리뷰를 위한 더미 데이터 설정
#Preview {
	NowView()
		.modelContainer(for: [SDSchedule.self, SDUser.self]) { result in
			switch result {
			case .success(let container):
				let context = container.mainContext
				
				// 더미 데이터 생성
				let users = [
					SDUser(email: "john@example.com", nickname: "John", phoneNumber: "123456789"),
					SDUser(email: "jane@example.com", nickname: "Jane", phoneNumber: "987654321")
				]
				
				let schedules = [
					SDSchedule(title: "Fishing Trip", startDate: Date(), endDate: Date().addingTimeInterval(7200), location: "Ocean Park", notes: "Catch some big fish!", participants: [users[0]]),
					SDSchedule(title: "Lake Expedition", startDate: Date().addingTimeInterval(86400), endDate: Date().addingTimeInterval(10800), location: "Green Lake", notes: "Bring extra bait.", participants: [users[1]])
				]
				
				// 데이터 삽입
				users.forEach { context.insert($0) }
				schedules.forEach { context.insert($0) }
			case .failure(let error):
				fatalError("Failed to create ModelContainer: \(error)")
			}
		}
}
