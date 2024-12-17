import Foundation

public extension FileManager {
	enum Path {
		case customPath(String)
		case webURL(URL)
		
		public var url: URL {
			switch self {
			case .customPath(let path):
				// 도큐먼트 디렉토리에 있는 경로를 반환합니다.
				return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(path)
			case .webURL(let url):
				return url
			}
		}
		
		public func fileName() -> String {
			return url.lastPathComponent
		}
		
		/// 디렉토리가 필요한 경우 생성합니다.
		public func createDirectoryIfNeeded() throws {
			let directoryURL = url.deletingLastPathComponent()
			let fileManager = FileManager.default
			if !fileManager.fileExists(atPath: directoryURL.path) {
				do {
					try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
				} catch {
					throw FileManagerError.couldNotCreateDirectory(path: directoryURL.path, underlyingError: error)
				}
			}
		}
		
		/// 데이터를 파일로 저장합니다.
		public func save(data: Data) throws {
			do {
				try createDirectoryIfNeeded()
				try data.write(to: url)
			} catch {
				throw FileManagerError.couldNotSaveFile(path: url.path, underlyingError: error)
			}
		}
		
		/// 파일에서 데이터를 읽습니다.
		public func read() throws -> Data {
			if FileManager.default.fileExists(atPath: url.path) {
				do {
					return try Data(contentsOf: url)
				} catch {
					throw FileManagerError.couldNotReadFile(path: url.path, underlyingError: error)
				}
			} else {
				throw FileManagerError.fileDoesNotExist(path: url.path)
			}
		}
		
		/// 파일을 삭제합니다.
		public func delete() throws {
			let fileManager = FileManager.default
			if fileManager.fileExists(atPath: url.path) {
				do {
					try fileManager.removeItem(at: url)
				} catch {
					throw FileManagerError.couldNotDeleteFile(path: url.path, underlyingError: error)
				}
			} else {
				throw FileManagerError.fileDoesNotExist(path: url.path)
			}
		}
	}
	
	enum FileManagerError: Error, LocalizedError {
		case couldNotCreateDirectory(path: String, underlyingError: Error)
		case couldNotSaveFile(path: String, underlyingError: Error)
		case couldNotReadFile(path: String, underlyingError: Error)
		case couldNotDeleteFile(path: String, underlyingError: Error)
		case fileDoesNotExist(path: String)
		
		public var errorDescription: String? {
			switch self {
			case .couldNotCreateDirectory(let path, let error):
				return "Could not create directory at \(path): \(error.localizedDescription)"
			case .couldNotSaveFile(let path, let error):
				return "Could not save file at \(path): \(error.localizedDescription)"
			case .couldNotReadFile(let path, let error):
				return "Could not read file at \(path): \(error.localizedDescription)"
			case .couldNotDeleteFile(let path, let error):
				return "Could not delete file at \(path): \(error.localizedDescription)"
			case .fileDoesNotExist(let path):
				return "File does not exist at \(path)"
			}
		}
	}
}

public extension FileManager {
	func fileExists(at url: URL) -> Bool {
		let fileManager = FileManager.default
		return fileManager.fileExists(atPath: url.path)
	}
	
	func clearFileManager() {
		// 도큐먼트 디렉토리 데이터 삭제
		let fileManager = FileManager.default
		if let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
			do {
				let fileURLs = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil, options: [])
				for fileURL in fileURLs {
					try fileManager.removeItem(at: fileURL)
				}
			} catch {
				print("Error clearing documents directory: \(error)")
			}
		}
		
		// 캐시 디렉토리 데이터 삭제
		if let cacheURL = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first {
			do {
				let fileURLs = try fileManager.contentsOfDirectory(at: cacheURL, includingPropertiesForKeys: nil, options: [])
				for fileURL in fileURLs {
					try fileManager.removeItem(at: fileURL)
				}
			} catch {
				print("Error clearing cache directory: \(error)")
			}
		}
	}
}
