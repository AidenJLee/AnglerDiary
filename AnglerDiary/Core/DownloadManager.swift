import Foundation

class DownloadManager: NSObject {
	private var downloadTasks: [URL: URLSessionDownloadTask] = [:]
	private var downloadProgressHandlers: [URL: (Float) -> Void] = [:]
	private var downloadCompletionHandlers: [URL: (Result<URL, Error>) -> Void] = [:]
	private var resumeDataDict: [URL: Data] = [:]
	private let maxRetries = 3
	private let queue = DispatchQueue(label: "com.download.queue", attributes: .concurrent)
	
	private lazy var session: URLSession = {
		let configuration = URLSessionConfiguration.background(withIdentifier: UUID().uuidString)
		return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
	}()
	
	func download(url: URL, to destination: FileManager.Path, progress: @escaping (Float) -> Void, completion: @escaping (Result<URL, Error>) -> Void) {
		queue.async(flags: .barrier) {
			let task = self.session.downloadTask(with: url)
			self.downloadTasks[url] = task
			self.downloadProgressHandlers[url] = progress
			self.downloadCompletionHandlers[url] = { [weak self] result in
				guard self != nil else { return }
				switch result {
				case .success(let tempLocation):
					do {
						// 파일 이동 전에 필요한 디렉토리가 있는지 확인하고 생성
						try destination.createDirectoryIfNeeded()
						
						// 임시 파일 위치에서 최종 위치로 파일 이동
						let finalURL = destination.url
						if FileManager.default.fileExists(atPath: finalURL.path) {
							try FileManager.default.removeItem(at: finalURL)  // 기존 파일 삭제
						}
						try FileManager.default.moveItem(at: tempLocation, to: finalURL)
						
						// 파일 이동 성공 후 완료 핸들러 호출
						completion(.success(finalURL))
					} catch {
						completion(.failure(error))
					}
				case .failure(let error):
					completion(.failure(error))
				}
			}
			task.resume()
		}
	}
	
	func pauseDownload(url: URL) {
		queue.async(flags: .barrier) {
			guard let task = self.downloadTasks[url] else { return }
			task.cancel { resumeData in
				if let resumeData = resumeData {
					self.resumeDataDict[url] = resumeData
				}
			}
			self.downloadTasks[url] = nil
		}
	}
	
	func resumeDownload(url: URL) {
		queue.async(flags: .barrier) {
			if let resumeData = self.resumeDataDict[url] {
				let task = self.session.downloadTask(withResumeData: resumeData)
				self.downloadTasks[url] = task
				task.resume()
				self.resumeDataDict[url] = nil
			} else {
				guard let task = self.downloadTasks[url] else { return }
				task.resume()
			}
		}
	}
	
	func cancelDownload(url: URL) {
		queue.async(flags: .barrier) {
			guard let task = self.downloadTasks[url] else { return }
			task.cancel()
			self.clearHandlers(for: url)
		}
	}
	
	private func clearHandlers(for url: URL) {
		downloadTasks[url] = nil
		downloadProgressHandlers[url] = nil
		downloadCompletionHandlers[url] = nil
		resumeDataDict[url] = nil
	}
}

extension DownloadManager: URLSessionDownloadDelegate {
	func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
		guard let originalURL = downloadTask.originalRequest?.url,
			  let completionHandler = downloadCompletionHandlers[originalURL] else { return }
		
		// 지정된 destination을 사용하도록 변경
		let destinationPath = FileManager.Path.customPath(originalURL.lastPathComponent)
		
		do {
			// 파일 이동 전에 필요한 디렉토리가 있는지 확인하고 생성
			try destinationPath.createDirectoryIfNeeded()
			
			// 임시 파일 위치에서 최종 위치로 파일 이동
			let finalURL = destinationPath.url
			if FileManager.default.fileExists(atPath: finalURL.path) {
				try FileManager.default.removeItem(at: finalURL)  // 기존 파일 삭제
			}
			try FileManager.default.moveItem(at: location, to: finalURL)
			
			// 파일 이동 성공 후 완료 핸들러 호출
			completionHandler(.success(finalURL))
		} catch {
			// 에러 발생 시 완료 핸들러에서 에러 처리
			completionHandler(.failure(error))
		}
	}
	
	func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
		guard let originalURL = downloadTask.originalRequest?.url else { return }
		let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
		downloadProgressHandlers[originalURL]?(progress)
	}
	
	func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
		guard let originalURL = task.originalRequest?.url else { return }
		
		if let error = error {
			downloadCompletionHandlers[originalURL]?(.failure(error))
		}
	}
}
