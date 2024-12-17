import SwiftUI
import SwiftData

// ScheduleView를 위한 SwiftUI 뷰
struct ScheduleView: View {
	// SwiftData를 사용하여 일정 데이터를 쿼리
	@Query(sort: \SDSchedule.startDate) var schedules: [SDSchedule]
	@State private var selectedDate = Date()
	@State private var showCreateScheduleModal = false
	
	var body: some View {
		NavigationView {
			VStack {
				Text("Plan Your Trips")
					.font(.largeTitle)
					.fontWeight(.bold)
					.padding(.top, 20)
				
				// 캘린더 컴포넌트
				CalendarComponent(selectedDate: $selectedDate)
				
				// 선택한 날짜의 일정 세부 정보
				ScheduleDetails(selectedDate: selectedDate, schedules: schedules)
				
				// 새 일정 추가를 위한 Floating Action Button
				FloatingActionButton(showCreateScheduleModal: $showCreateScheduleModal)
			}
			.navigationTitle("Schedule")
			.sheet(isPresented: $showCreateScheduleModal) {
				CreateScheduleModal(isPresented: $showCreateScheduleModal)
			}
			.padding(.horizontal)
		}
	}
}

// 캘린더 컴포넌트 뷰
struct CalendarComponent: View {
	@Binding var selectedDate: Date
	
	var body: some View {
		VStack {
			// 커스텀 캘린더 또는 타사 라이브러리 사용 가능
			Text("Calendar Placeholder")
				.frame(maxWidth: .infinity, minHeight: 300)
				.background(Color.gray.opacity(0.1))
				.cornerRadius(10)
		}
	}
}

// 일정 세부 정보 뷰
struct ScheduleDetails: View {
	var selectedDate: Date
	var schedules: [SDSchedule]
	
	var body: some View {
		VStack(alignment: .leading) {
			ForEach(schedules.filter { Calendar.current.isDate($0.startDate, inSameDayAs: selectedDate) }) { schedule in
				ScheduleCard(schedule: schedule)
			}
		}
	}
}

// 일정 카드 뷰
struct ScheduleCard: View {
	var schedule: SDSchedule
	
	var body: some View {
		VStack(alignment: .leading, spacing: 10) {
			Text(schedule.title)
				.font(.system(size: 14, weight: .bold))
				.foregroundColor(.black)
			Text("Time: \(schedule.startDate, formatter: DateFormatter.hhmm) - \(schedule.endDate, formatter: DateFormatter.hhmm)")
				.font(.system(size: 12))
				.foregroundColor(.gray)
			Text("Location: \(schedule.location)")
				.font(.system(size: 12))
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

// Floating Action Button 뷰
struct FloatingActionButton: View {
	@Binding var showCreateScheduleModal: Bool
	
	var body: some View {
		Button(action: {
			showCreateScheduleModal.toggle()
		}) {
			Image(systemName: "plus")
				.resizable()
				.frame(width: 24, height: 24)
				.foregroundColor(.white)
				.padding()
				.background(Color.blue)
				.clipShape(Circle())
				.shadow(radius: 5)
		}
		.frame(width: 56, height: 56)
		.padding()
	}
}

// 일정 생성 모달 뷰
struct CreateScheduleModal: View {
	@Binding var isPresented: Bool
	@State private var title = ""
	@State private var startDate = Date()
	@State private var endDate = Date().addingTimeInterval(3600)
	@State private var location = ""
	@State private var notes = ""
	@State private var invitees: [SDUser] = []
	
	var body: some View {
		NavigationView {
			Form {
				Section(header: Text("Schedule Details")) {
					TextField("Title", text: $title)
						.font(.system(size: 14))
						.foregroundColor(.gray)
					
					DatePicker("Start Date", selection: $startDate, displayedComponents: [.date, .hourAndMinute])
					
					DatePicker("End Date", selection: $endDate, displayedComponents: [.date, .hourAndMinute])
					
					TextField("Location", text: $location)
						.font(.system(size: 14))
						.foregroundColor(.gray)
					
					TextField("Notes", text: $notes)
						.font(.system(size: 14))
						.foregroundColor(.gray)
				}
				
				Section(header: Text("Invite Participants")) {
					// 참가자 선택을 위한 플레이스홀더
					Text("Select contacts to invite")
						.font(.system(size: 14))
						.foregroundColor(.gray)
				}
				
				Section {
					Toggle(isOn: .constant(false)) {
						Text("Enable Notifications")
							.font(.system(size: 14))
							.foregroundColor(.gray)
					}
				}
			}
			.navigationTitle("Create Schedule")
			.navigationBarItems(trailing: Button("Done") {
				// 일정을 저장
				isPresented = false
			})
		}
	}
}

// 프리뷰를 위한 더미 데이터
#Preview {
	ScheduleView()
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
