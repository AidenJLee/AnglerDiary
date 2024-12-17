import SwiftUI
import SwiftData
import Combine

@MainActor
class DataManager {
	static let shared = DataManager()
	
	private(set) var container: ModelContainer
	
	private init() {
		let schema = Schema([
			SDUser.self,
			SDSchedule.self,
			SDCatchRecord.self,
			SDEquipment.self,
			SDExpense.self,
			SDFishingPoint.self,
			SDFishSpecies.self,
			SDPost.self,
			SDComment.self,
			SDFishingEvent.self,
			SDPhoto.self
		])
		
		do {
			self.container = try ModelContainer(for: schema)
		} catch {
			fatalError("Failed to create ModelContainer: \(error)")
		}
	}
	
	var context: ModelContext {
		return container.mainContext
	}
	
	// Generic Create
	func create<T: PersistentModel>(_ model: T) {
		context.insert(model)
		saveContext()
	}
	
	// Combined Fetch with Pagination and Filtering
	func fetch<T: PersistentModel>(
		modelType: T.Type,
		filter: Predicate<T>? = nil,
		sortDescriptors: [SortDescriptor<T>] = [],
		page: Int = 0,
		pageSize: Int = 20
	) -> [T] {
		let request = FetchDescriptor<T>(
			predicate: filter,
			sortBy: sortDescriptors
		)
		
		do {
			let results = try context.fetch(request)
			return paginate(results: results, page: page, pageSize: pageSize)
		} catch {
			print("Failed to fetch \(modelType): \(error)")
			return []
		}
	}
	
	// Fetch with pagination helper
	private func paginate<T>(results: [T], page: Int, pageSize: Int) -> [T] {
		let startIndex = page * pageSize
		guard startIndex < results.count else {
			print("Page out of range: startIndex=\(startIndex), results.count=\(results.count)")
			return []
		}
		
		let endIndex = min(startIndex + pageSize, results.count)
		return Array(results[startIndex..<endIndex])
	}
	
	// Fetch Count
	func fetchCount<T: PersistentModel>(
		modelType: T.Type,
		filter: Predicate<T>? = nil
	) -> Int {
		let request = FetchDescriptor<T>(
			predicate: filter
		)
		
		do {
			return try context.fetchCount(request)
		} catch {
			print("Failed to fetch count for \(modelType): \(error)")
			return 0
		}
	}
	
	// Generic Update
	func update<T: PersistentModel>(_ model: T, with updates: () -> Void) {
		updates()
		saveContext()
	}
	
	// Generic Delete
	func delete<T: PersistentModel>(_ model: T) {
		context.delete(model)
		saveContext()
	}
	
	private func saveContext() {
		do {
			try context.save()
		} catch {
			handleError(error)
		}
	}
	
	private func handleError(_ error: Error) {
		// Combine framework can be used to publish the error or notify the user
		print("An error occurred: \(error)")
	}
}
