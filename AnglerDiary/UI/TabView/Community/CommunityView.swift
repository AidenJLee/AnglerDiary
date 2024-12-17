import SwiftUI
import SwiftData

// 커뮤니티 뷰
struct CommunityView: View {
	// 샘플 데이터
	@Query private var posts: [SDPost]
	@Query private var photos: [SDPhoto]
	@Query private var events: [SDFishingEvent]
	
	var body: some View {
		ScrollView {
			VStack(alignment: .leading, spacing: 20) {
				// 포럼 섹션
				Text("Forum")
					.font(.largeTitle)
					.fontWeight(.bold)
					.padding([.leading, .top])
				
				ForEach(posts) { post in
					PostCard(post: post)
				}
				
				// 사진 갤러리 섹션
				Text("Photo Gallery")
					.font(.largeTitle)
					.fontWeight(.bold)
					.padding([.leading, .top])
				
				ScrollView(.horizontal, showsIndicators: false) {
					HStack(spacing: 15) {
						ForEach(photos) { photo in
							PhotoCard(photo: photo)
						}
					}
					.padding(.leading)
				}
				
				// 이벤트 보드 섹션
				Text("Events")
					.font(.largeTitle)
					.fontWeight(.bold)
					.padding([.leading, .top])
				
				ForEach(events) { event in
					EventCard(event: event)
				}
			}
			.padding(.bottom, 20)
		}
	}
}

// 포스트 카드 뷰
struct PostCard: View {
	var post: SDPost
	
	var body: some View {
		VStack(alignment: .leading, spacing: 10) {
			HStack {
				Image(systemName: "person.circle.fill")
					.resizable()
					.frame(width: 40, height: 40)
				VStack(alignment: .leading) {
					Text(post.author.nickname)
						.font(.headline)
						.fontWeight(.bold)
					Text(post.date, formatter: DateFormatter.shortDate)
						.font(.subheadline)
						.foregroundColor(.gray)
				}
				Spacer()
				Text("\(post.likes) likes")
					.font(.subheadline)
			}
			
			Text(post.title)
				.font(.headline)
				.fontWeight(.bold)
			
			if let imageName = post.imageName {
				Image(imageName)
					.resizable()
					.scaledToFill()
					.frame(height: 200)
					.clipped()
			}
			
			Text(post.content)
				.font(.body)
			
			Divider()
		}
		.padding()
		.background(Color.gray.opacity(0.1))
		.cornerRadius(10)
		.padding(.horizontal)
	}
}

// 사진 카드 뷰
struct PhotoCard: View {
	var photo: SDPhoto
	
	var body: some View {
		VStack {
			Image(photo.imageName)
				.resizable()
				.frame(width: 150, height: 150)
				.clipShape(RoundedRectangle(cornerRadius: 10))
			Text(photo.uploader.nickname)
				.font(.caption)
				.foregroundColor(.gray)
			Text("\(photo.likes) likes")
				.font(.caption)
				.foregroundColor(.gray)
		}
		.padding()
		.background(Color.white)
		.cornerRadius(10)
		.shadow(radius: 5)
	}
}

// 이벤트 카드 뷰
struct EventCard: View {
	var event: SDFishingEvent
	
	var body: some View {
		VStack(alignment: .leading, spacing: 10) {
			Text(event.title)
				.font(.headline)
				.fontWeight(.bold)
			
			Text("Date: \(event.date, formatter: DateFormatter.shortDate)")
				.font(.subheadline)
				.foregroundColor(.gray)
			
			Text("Location: \(event.location)")
				.font(.subheadline)
			
			HStack {
				Text("Participants: \(event.participants.count)")
					.font(.footnote)
				Spacer()
				Button(action: {
					// 참여하기 버튼 액션
					print("Join Event tapped")
				}) {
					Text("Join")
						.padding(5)
						.background(Color.blue)
						.foregroundColor(.white)
						.cornerRadius(5)
				}
			}
		}
		.padding()
		.background(Color.gray.opacity(0.1))
		.cornerRadius(10)
		.padding(.horizontal)
	}
}

// 프리뷰를 위한 더미 데이터 설정
#Preview {
	CommunityView()
		.modelContainer(for: [SDPost.self, SDPhoto.self, SDFishingEvent.self, SDUser.self]) { result in
			switch result {
			case .success(let container):
				let context = container.mainContext
				
				// 더미 데이터 생성
				let users = [
					SDUser(email: "john@example.com", nickname: "John"),
					SDUser(email: "doe@example.com", nickname: "Doe")
				]
				
				let posts = [
					SDPost(author: users[0], title: "Great Fishing Spot!", content: "I found a great spot for fishing near the lake.", date: Date(), likes: 5, imageName: "fishing_spot"),
					SDPost(author: users[1], title: "New Techniques", content: "Here are some new techniques to catch bass.", date: Date(), likes: 10)
				]
				
				let photos = [
					SDPhoto(uploader: users[0], imageName: "catch1", uploadDate: Date(), likes: 15)
				]
				
				let events = [
					SDFishingEvent(title: "Fishing Meetup", date: Date().addingTimeInterval(86400), location: "Green Lake")
				]
				
				// 데이터 삽입
				users.forEach { context.insert($0) }
				posts.forEach { context.insert($0) }
				photos.forEach { context.insert($0) }
				events.forEach { context.insert($0) }
			case .failure(let error):
				fatalError("Failed to create ModelContainer: \(error)")
			}
		}
}
