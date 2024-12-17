import Foundation
import SwiftData

enum AppMigrationPlan: SchemaMigrationPlan {
	// 스키마 버전 목록 정의
	static var schemas: [any VersionedSchema.Type] = [AppSchemaV1.self, AppSchemaV2.self]

	// 마이그레이션 단계 정의
	static var stages: [MigrationStage] = [
		MigrationStage.custom(
			fromVersion: AppSchemaV1.self,
			toVersion: AppSchemaV2.self,
			willMigrate: { context in
				guard let users = try? context.fetch(FetchDescriptor<AppSchemaV1.User>()) else { return }

				var duplicates = Set<AppSchemaV1.User>()
				var uniqueSet = Set<String>()

				for user in users {
					if !uniqueSet.insert(user.email).inserted {
						duplicates.insert(user)
					}
				}

				for user in duplicates {
					let userToBeUpdated = users.first(where: { $0.id == user.id } )!
					userToBeUpdated.email = userToBeUpdated.email + " \(generateUniqueRandomNumber())"
				}

				try? context.save()
			},
			didMigrate: nil
		)
	]
	
	static func generateUniqueRandomNumber() -> Int {
		return Int.random(in: 1000...9999)
	}
}

enum AppSchemaV1: VersionedSchema {
	static var versionIdentifier: Schema.Version = Schema.Version(1, 0, 0) // 첫 번째 버전

	static var models: [any PersistentModel.Type] {
		[User.self]
	}

	@Model
	final class User: Identifiable {
		var email: String
		var nickname: String
		var phoneNumber: String

		init(email: String, nickname: String, phoneNumber: String) {
			self.email = email
			self.nickname = nickname
			self.phoneNumber = phoneNumber
		}
	}
}

enum AppSchemaV2: VersionedSchema {
	static var versionIdentifier: Schema.Version = Schema.Version(2, 0, 0) // 두 번째 버전

	static var models: [any PersistentModel.Type] {
		[User.self]
	}

	@Model
	final class User: Identifiable {
		@Attribute(.unique) var email: String
		var nickname: String
		var phoneNumber: String

		init(email: String, nickname: String, phoneNumber: String) {
			self.email = email
			self.nickname = nickname
			self.phoneNumber = phoneNumber
		}
	}
}
