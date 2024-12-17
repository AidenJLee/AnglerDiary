import Foundation

// Enum 정의
enum FishingMethod: String, Codable {
	case lure = "루어"
	case oneTwo = "원투"
	case floatFishing = "찌낚시"
	case boatFishing = "배낚시"
	case rockFishing = "갯바위"
	
	var englishName: String {
		switch self {
		case .lure:
			return "Lure Fishing"
		case .oneTwo:
			return "One-Two Fishing"
		case .floatFishing:
			return "Float Fishing"
		case .boatFishing:
			return "Boat Fishing"
		case .rockFishing:
			return "Rock Fishing"
		}
	}
}

enum ExperienceLevel: String, Codable {
	case novice = "입문자"
	case beginner = "초급자"
	case intermediate = "중급자"
	case advanced = "상급자"
	case master = "마스터"
	
	var englishName: String {
		switch self {
		case .novice:
			return "Novice"
		case .beginner:
			return "Beginner"
		case .intermediate:
			return "Intermediate"
		case .advanced:
			return "Advanced"
		case .master:
			return "Master"
		}
	}
}

// 사용자 모델
struct User: Codable, Identifiable {
	var id: UUID = UUID()
	var email: String
	var nickname: String
	var phoneNumber: String?
	var profileImageURL: URL?
	var signUpDate: Date = Date()
	var friendList: [User] = []
	var achievements: [Achievement] = []
	var experienceLevel: ExperienceLevel
	var preferredMethods: [FishingMethod] = []
	var favoriteFishingSpots: [FishingPoint] = []
	var equipments: [Equipment] = []
	var catchRecords: [CatchRecord] = []
}

extension User {
	func toSwiftData() -> SDUser {
		let sdUser = SDUser(email: email, nickname: nickname, phoneNumber: phoneNumber)
		sdUser.id = id
		sdUser.profileImageURL = profileImageURL
		sdUser.signUpDate = signUpDate
		sdUser.friendList = friendList.map { $0.toSwiftData() }
		sdUser.achievements = achievements.map { $0.toSwiftData() }
		sdUser.experienceLevel = experienceLevel
		sdUser.preferredMethods = preferredMethods
		sdUser.favoriteFishingSpots = favoriteFishingSpots.map { $0.toSwiftData() }
		sdUser.equipments = equipments.map { $0.toSwiftData(owner: sdUser) }
		sdUser.catchRecords = catchRecords.map { $0.toSwiftData(user: sdUser) }
		return sdUser
	}
	
	init(from sdUser: SDUser) {
		self.id = sdUser.id
		self.email = sdUser.email
		self.nickname = sdUser.nickname
		self.phoneNumber = sdUser.phoneNumber
		self.profileImageURL = sdUser.profileImageURL
		self.signUpDate = sdUser.signUpDate
		self.friendList = sdUser.friendList.map { User(from: $0) }
		self.achievements = sdUser.achievements.map { Achievement(from: $0) }
		self.experienceLevel = sdUser.experienceLevel
		self.preferredMethods = sdUser.preferredMethods
		self.favoriteFishingSpots = sdUser.favoriteFishingSpots.map { FishingPoint(from: $0) }
		self.equipments = sdUser.equipments.map { Equipment(from: $0) }
		self.catchRecords = sdUser.catchRecords.map { CatchRecord(from: $0) }
	}
}

// 업적 모델
struct Achievement: Codable, Identifiable {
	var id: UUID = UUID()
	var title: String
	var details: String
	var dateAchieved: Date
}

extension Achievement {
	func toSwiftData() -> SDAchievement {
		let sdAchievement = SDAchievement(title: title, details: details, dateAchieved: dateAchieved)
		sdAchievement.id = id
		return sdAchievement
	}
	
	init(from sdAchievement: SDAchievement) {
		self.id = sdAchievement.id
		self.title = sdAchievement.title
		self.details = sdAchievement.details
		self.dateAchieved = sdAchievement.dateAchieved
	}
}

// 일정 모델
struct Schedule: Codable, Identifiable {
	var id: UUID = UUID()
	var title: String
	var startDate: Date
	var endDate: Date
	var location: String
	var notes: String?
	var participants: [User] = []
}

extension Schedule {
	func toSwiftData() -> SDSchedule {
		let sdSchedule = SDSchedule(title: title, startDate: startDate, endDate: endDate, location: location, notes: notes)
		sdSchedule.id = id
		sdSchedule.participants = participants.map { $0.toSwiftData() }
		return sdSchedule
	}
	
	init(from sdSchedule: SDSchedule) {
		self.id = sdSchedule.id
		self.title = sdSchedule.title
		self.startDate = sdSchedule.startDate
		self.endDate = sdSchedule.endDate
		self.location = sdSchedule.location
		self.notes = sdSchedule.notes
		self.participants = sdSchedule.participants.map { User(from: $0) }
	}
}

// 조과 기록 모델
struct CatchRecord: Codable, Identifiable {
	var id: UUID = UUID()
	var fishSpecies: FishSpecies
	var weight: Double?
	var length: Double?
	var location: String
	var time: Date
	var photo: URL
	var method: FishingMethod
	var user: User
	var schedule: Schedule?
}

extension CatchRecord {
	func toSwiftData(user: SDUser) -> SDCatchRecord {
		let sdCatchRecord = SDCatchRecord(user: user, fishSpecies: fishSpecies.toSwiftData(), weight: weight, length: length, location: location, time: time, method: method, photo: photo, schedule: schedule?.toSwiftData())
		sdCatchRecord.id = id
		return sdCatchRecord
	}
	
	init(from sdCatchRecord: SDCatchRecord) {
		self.id = sdCatchRecord.id
		self.fishSpecies = FishSpecies(from: sdCatchRecord.fishSpecies)
		self.weight = sdCatchRecord.weight
		self.length = sdCatchRecord.length
		self.location = sdCatchRecord.location
		self.time = sdCatchRecord.time
		self.photo = sdCatchRecord.photo
		self.method = sdCatchRecord.method
		self.user = User(from: sdCatchRecord.user)
		self.schedule = sdCatchRecord.schedule.map { Schedule(from: $0) }
	}
}

// 장비 모델
struct Equipment: Codable, Identifiable {
	var id: UUID = UUID()
	var name: String
	var brand: String
	var model: String
	var purchaseDate: Date?
	var usageFrequency: Int
	var owner: User
}

extension Equipment {
	func toSwiftData(owner: SDUser) -> SDEquipment {
		let sdEquipment = SDEquipment(name: name, brand: brand, model: model, owner: owner, purchaseDate: purchaseDate, usageFrequency: usageFrequency)
		sdEquipment.id = id
		return sdEquipment
	}
	
	init(from sdEquipment: SDEquipment) {
		self.id = sdEquipment.id
		self.name = sdEquipment.name
		self.brand = sdEquipment.brand
		self.model = sdEquipment.model
		self.purchaseDate = sdEquipment.purchaseDate
		self.usageFrequency = sdEquipment.usageFrequency
		self.owner = User(from: sdEquipment.owner)
	}
}

// 지출 모델
struct Expense: Codable, Identifiable {
	var id: UUID = UUID()
	var amount: Double
	var memo: String
	var date: Date
	var payer: User
	var schedule: Schedule?
	var sharedWith: [User]
}

extension Expense {
	func toSwiftData(payer: SDUser) -> SDExpense {
		let sdExpense = SDExpense(amount: amount, memo: memo, date: date, payer: payer, schedule: schedule?.toSwiftData(), sharedWith: sharedWith.map { $0.toSwiftData() })
		sdExpense.id = id
		return sdExpense
	}
	
	init(from sdExpense: SDExpense) {
		self.id = sdExpense.id
		self.amount = sdExpense.amount
		self.memo = sdExpense.memo
		self.date = sdExpense.date
		self.payer = User(from: sdExpense.payer)
		self.schedule = sdExpense.schedule.map { Schedule(from: $0) }
		self.sharedWith = sdExpense.sharedWith.map { User(from: $0) }
	}
}

// 낚시터 정보 모델
struct FishingPoint: Codable, Identifiable {
	var id: UUID = UUID()
	var name: String
	var location: String
	var conditions: String
	var fishTypes: [String]
}

extension FishingPoint {
	func toSwiftData() -> SDFishingPoint {
		let sdFishingPoint = SDFishingPoint(name: name, location: location, conditions: conditions, fishTypes: fishTypes)
		sdFishingPoint.id = id
		return sdFishingPoint
	}
	
	init(from sdFishingPoint: SDFishingPoint) {
		self.id = sdFishingPoint.id
		self.name = sdFishingPoint.name
		self.location = sdFishingPoint.location
		self.conditions = sdFishingPoint.conditions
		self.fishTypes = sdFishingPoint.fishTypes
	}
}

// 어류 정보 모델
struct FishSpecies: Codable, Identifiable {
	var id: UUID = UUID()
	var name: String
	var scientificName: String
	var habitat: String
	var memo: String
	var imageURL: URL?
	var commonFishingMethods: [FishingMethod]
	var bestSeason: String
}

extension FishSpecies {
	func toSwiftData() -> SDFishSpecies {
		let sdFishSpecies = SDFishSpecies(name: name, scientificName: scientificName, habitat: habitat, memo: memo, imageURL: imageURL, commonFishingMethods: commonFishingMethods, bestSeason: bestSeason)
		sdFishSpecies.id = id
		return sdFishSpecies
	}
	
	init(from sdFishSpecies: SDFishSpecies) {
		self.id = sdFishSpecies.id
		self.name = sdFishSpecies.name
		self.scientificName = sdFishSpecies.scientificName
		self.habitat = sdFishSpecies.habitat
		self.memo = sdFishSpecies.memo
		self.imageURL = sdFishSpecies.imageURL
		self.commonFishingMethods = sdFishSpecies.commonFishingMethods
		self.bestSeason = sdFishSpecies.bestSeason
	}
}

// 낚시 이벤트 모델
struct FishingEvent: Codable, Identifiable {
	var id: UUID = UUID()
	var title: String
	var date: Date
	var location: String
	var participants: [User] = []
}

extension FishingEvent {
	func toSwiftData() -> SDFishingEvent {
		let sdFishingEvent = SDFishingEvent(title: title, date: date, location: location)
		sdFishingEvent.id = id
		sdFishingEvent.participants = participants.map { $0.toSwiftData() }
		return sdFishingEvent
	}
	
	init(from sdFishingEvent: SDFishingEvent) {
		self.id = sdFishingEvent.id
		self.title = sdFishingEvent.title
		self.date = sdFishingEvent.date
		self.location = sdFishingEvent.location
		self.participants = sdFishingEvent.participants.map { User(from: $0) }
	}
}

// 사진 모델
struct Photo: Codable, Identifiable {
	var id: UUID = UUID()
	var uploader: User
	var imageName: String
	var uploadDate: Date
	var likes: Int
}

extension Photo {
	func toSwiftData(uploader: SDUser) -> SDPhoto {
		let sdPhoto = SDPhoto(uploader: uploader, imageName: imageName, uploadDate: uploadDate, likes: likes)
		sdPhoto.id = id
		return sdPhoto
	}
	
	init(from sdPhoto: SDPhoto) {
		self.id = sdPhoto.id
		self.uploader = User(from: sdPhoto.uploader)
		self.imageName = sdPhoto.imageName
		self.uploadDate = sdPhoto.uploadDate
		self.likes = sdPhoto.likes
	}
}

// 게시물 모델
struct Post: Codable, Identifiable {
	var id: UUID = UUID()
	var author: User
	var title: String
	var content: String
	var date: Date
	var comments: [Comment] = []
	var likes: Int
	var imageName: String?
}

extension Post {
	func toSwiftData(author: SDUser) -> SDPost {
		let sdPost = SDPost(author: author, title: title, content: content, date: date, likes: likes, imageName: imageName)
		sdPost.id = id
		sdPost.comments = comments.map { $0.toSwiftData(author: author) }
		return sdPost
	}
	
	init(from sdPost: SDPost) {
		self.id = sdPost.id
		self.author = User(from: sdPost.author)
		self.title = sdPost.title
		self.content = sdPost.content
		self.date = sdPost.date
		self.comments = sdPost.comments.map { Comment(from: $0) }
		self.likes = sdPost.likes
		self.imageName = sdPost.imageName
	}
}

// 댓글 모델
struct Comment: Codable, Identifiable {
	var id: UUID = UUID()
	var author: User
	var content: String
	var date: Date
}

extension Comment {
	func toSwiftData(author: SDUser) -> SDComment {
		let sdComment = SDComment(author: author, content: content, date: date)
		sdComment.id = id
		return sdComment
	}
	
	init(from sdComment: SDComment) {
		self.id = sdComment.id
		self.author = User(from: sdComment.author)
		self.content = sdComment.content
		self.date = sdComment.date
	}
}
