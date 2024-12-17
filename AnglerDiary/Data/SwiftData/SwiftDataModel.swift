import SwiftData
import Foundation

// 사용자 모델
@Model
final class SDUser: Identifiable {
	var id: UUID
	@Attribute(.unique) var email: String
	var nickname: String
	var phoneNumber: String?
	var profileImageURL: URL?
	var signUpDate: Date = Date()
	var friendList: [SDUser] = []
	var achievements: [SDAchievement] = []
	var experienceLevel: ExperienceLevel
	var preferredMethods: [FishingMethod] = []
	var favoriteFishingSpots: [SDFishingPoint] = []
	
	@Relationship(deleteRule: .cascade) var equipments: [SDEquipment] = []
	@Relationship(deleteRule: .cascade) var catchRecords: [SDCatchRecord] = []
	
	init(email: String, nickname: String, phoneNumber: String? = nil) {
		self.id = UUID()
		self.email = email
		self.nickname = nickname
		self.phoneNumber = phoneNumber
		self.experienceLevel = .novice
	}
}

extension SDUser {
	convenience init(from user: User) {
		self.init(email: user.email, nickname: user.nickname, phoneNumber: user.phoneNumber)
		self.id = user.id
		self.profileImageURL = user.profileImageURL
		self.signUpDate = user.signUpDate
		self.friendList = user.friendList.map { SDUser(from: $0) }
		self.achievements = user.achievements.map { SDAchievement(from: $0) }
		self.experienceLevel = user.experienceLevel
		self.preferredMethods = user.preferredMethods
		self.favoriteFishingSpots = user.favoriteFishingSpots.map { SDFishingPoint(from: $0) }
		self.equipments = user.equipments.map { SDEquipment(from: $0, owner: self) }
		self.catchRecords = user.catchRecords.map { SDCatchRecord(from: $0, user: self) }
	}
}

// 업적 모델
@Model
final class SDAchievement: Identifiable {
	var id: UUID
	var title: String
	var details: String
	var dateAchieved: Date
	
	init(title: String, details: String, dateAchieved: Date) {
		self.id = UUID()
		self.title = title
		self.details = details
		self.dateAchieved = dateAchieved
	}
}

extension SDAchievement {
	convenience init(from achievement: Achievement) {
		self.init(title: achievement.title, details: achievement.details, dateAchieved: achievement.dateAchieved)
		self.id = achievement.id
	}
}

// 일정 모델
@Model
final class SDSchedule: Identifiable {
	var id: UUID
	var title: String
	var startDate: Date
	var endDate: Date
	var location: String
	var notes: String?
	var participants: [SDUser] = []
	
	init(title: String, startDate: Date, endDate: Date, location: String, notes: String? = nil) {
		self.id = UUID()
		self.title = title
		self.startDate = startDate
		self.endDate = endDate
		self.location = location
		self.notes = notes
	}
}

extension SDSchedule {
	convenience init(title: String, startDate: Date, endDate: Date, location: String, notes: String? = nil, participants: [SDUser] = []) {
		self.init(title: title, startDate: startDate, endDate: endDate, location: location, notes: notes)
		self.participants = participants
	}
	
	convenience init(from schedule: Schedule) {
		self.init(title: schedule.title, startDate: schedule.startDate, endDate: schedule.endDate, location: schedule.location, notes: schedule.notes)
		self.id = schedule.id
		self.participants = schedule.participants.map { SDUser(from: $0) }
	}
}

// 조과 기록 모델
@Model
final class SDCatchRecord: Identifiable {
	var id: UUID
	var fishSpecies: SDFishSpecies
	var weight: Double?
	var length: Double?
	var location: String
	var time: Date
	var photo: URL
	var method: FishingMethod
	
	@Relationship(inverse: \SDUser.catchRecords) var user: SDUser
	var schedule: SDSchedule?
	
	init(user: SDUser, fishSpecies: SDFishSpecies, weight: Double? = nil, length: Double? = nil, location: String, time: Date, method: FishingMethod, photo: URL, schedule: SDSchedule? = nil) {
		self.id = UUID()
		self.user = user
		self.fishSpecies = fishSpecies
		self.weight = weight
		self.length = length
		self.location = location
		self.time = time
		self.method = method
		self.photo = photo
		self.schedule = schedule
	}
}

extension SDCatchRecord {
	convenience init(from record: CatchRecord, user: SDUser) {
		self.init(user: user, fishSpecies: SDFishSpecies(from: record.fishSpecies), weight: record.weight, length: record.length, location: record.location, time: record.time, method: record.method, photo: record.photo, schedule: record.schedule.map { SDSchedule(from: $0) })
		self.id = record.id
	}
}

// 장비 모델
@Model
final class SDEquipment: Identifiable {
	var id: UUID
	var name: String
	var brand: String
	var model: String
	var purchaseDate: Date?
	var usageFrequency: Int
	
	@Relationship(inverse: \SDUser.equipments) var owner: SDUser
	
	init(name: String, brand: String, model: String, owner: SDUser, purchaseDate: Date? = nil, usageFrequency: Int = 0) {
		self.id = UUID()
		self.name = name
		self.brand = brand
		self.model = model
		self.owner = owner
		self.purchaseDate = purchaseDate
		self.usageFrequency = usageFrequency
	}
}

extension SDEquipment {
	convenience init(from equipment: Equipment, owner: SDUser) {
		self.init(name: equipment.name, brand: equipment.brand, model: equipment.model, owner: owner, purchaseDate: equipment.purchaseDate, usageFrequency: equipment.usageFrequency)
		self.id = equipment.id
	}
}

// 지출 모델
@Model
final class SDExpense: Identifiable {
	var id: UUID
	var amount: Double
	var memo: String
	var date: Date
	
	@Relationship(inverse: nil) var payer: SDUser
	var schedule: SDSchedule?
	var sharedWith: [SDUser]
	
	init(amount: Double, memo: String, date: Date, payer: SDUser, schedule: SDSchedule? = nil, sharedWith: [SDUser] = []) {
		self.id = UUID()
		self.amount = amount
		self.memo = memo
		self.date = date
		self.payer = payer
		self.schedule = schedule
		self.sharedWith = sharedWith
	}
}

extension SDExpense {
	convenience init(from expense: Expense, payer: SDUser) {
		self.init(amount: expense.amount, memo: expense.memo, date: expense.date, payer: payer, schedule: expense.schedule.map { SDSchedule(from: $0) }, sharedWith: expense.sharedWith.map { SDUser(from: $0) })
		self.id = expense.id
	}
}

// 낚시터 정보 모델
@Model
final class SDFishingPoint: Identifiable {
	var id: UUID
	var name: String
	var location: String
	var conditions: String
	var fishTypes: [String]
	
	init(name: String, location: String, conditions: String, fishTypes: [String]) {
		self.id = UUID()
		self.name = name
		self.location = location
		self.conditions = conditions
		self.fishTypes = fishTypes
	}
}

extension SDFishingPoint {
	convenience init(from point: FishingPoint) {
		self.init(name: point.name, location: point.location, conditions: point.conditions, fishTypes: point.fishTypes)
		self.id = point.id
	}
}

// 어류 정보 모델
@Model
final class SDFishSpecies: Identifiable {
	var id: UUID
	var name: String
	var scientificName: String
	var habitat: String
	var memo: String
	var imageURL: URL?
	var commonFishingMethods: [FishingMethod]
	var bestSeason: String
	
	init(name: String, scientificName: String, habitat: String, memo: String, imageURL: URL? = nil, commonFishingMethods: [FishingMethod], bestSeason: String) {
		self.id = UUID()
		self.name = name
		self.scientificName = scientificName
		self.habitat = habitat
		self.memo = memo
		self.imageURL = imageURL
		self.commonFishingMethods = commonFishingMethods
		self.bestSeason = bestSeason
	}
}

extension SDFishSpecies {
	convenience init(from species: FishSpecies) {
		self.init(name: species.name, scientificName: species.scientificName, habitat: species.habitat, memo: species.memo, imageURL: species.imageURL, commonFishingMethods: species.commonFishingMethods, bestSeason: species.bestSeason)
		self.id = species.id
	}
}

// 낚시 이벤트 모델
@Model
final class SDFishingEvent: Identifiable {
	var id: UUID
	var title: String
	var date: Date
	var location: String
	var participants: [SDUser] = []

	init(title: String, date: Date, location: String) {
		self.id = UUID()
		self.title = title
		self.date = date
		self.location = location
	}
}

extension SDFishingEvent {
	convenience init(title: String, date: Date, location: String, participants: [SDUser]) {
		self.init(title: title, date: date, location: location)
		self.participants = participants
	}

	convenience init(from event: FishingEvent) {
		self.init(title: event.title, date: event.date, location: event.location)
		self.id = event.id
		self.participants = event.participants.map { SDUser(from: $0) }
	}
}

// 사진 모델
@Model
final class SDPhoto: Identifiable {
	var id: UUID
	var uploader: SDUser
	var imageName: String
	var uploadDate: Date
	var likes: Int
	
	init(uploader: SDUser, imageName: String, uploadDate: Date, likes: Int = 0) {
		self.id = UUID()
		self.uploader = uploader
		self.imageName = imageName
		self.uploadDate = uploadDate
		self.likes = likes
	}
}

extension SDPhoto {
	convenience init(from photo: Photo, uploader: SDUser) {
		self.init(uploader: uploader, imageName: photo.imageName, uploadDate: photo.uploadDate, likes: photo.likes)
		self.id = photo.id
	}
}

// 게시물 모델
@Model
final class SDPost: Identifiable {
	var id: UUID
	var author: SDUser
	var title: String
	var content: String
	var date: Date
	var comments: [SDComment] = []
	var likes: Int
	var imageName: String?
	
	init(author: SDUser, title: String, content: String, date: Date, likes: Int = 0, imageName: String? = nil) {
		self.id = UUID()
		self.author = author
		self.title = title
		self.content = content
		self.date = date
		self.likes = likes
		self.imageName = imageName
	}
}

extension SDPost {
	convenience init(from post: Post, author: SDUser) {
		self.init(author: author, title: post.title, content: post.content, date: post.date, likes: post.likes, imageName: post.imageName)
		self.id = post.id
		self.comments = post.comments.map { SDComment(from: $0, author: author) }
	}
}

// 댓글 모델
@Model
final class SDComment: Identifiable {
	var id: UUID
	var author: SDUser
	var content: String
	var date: Date
	
	init(author: SDUser, content: String, date: Date) {
		self.id = UUID()
		self.author = author
		self.content = content
		self.date = date
	}
}

extension SDComment {
	convenience init(from comment: Comment, author: SDUser) {
		self.init(author: author, content: comment.content, date: comment.date)
		self.id = comment.id
	}
}
