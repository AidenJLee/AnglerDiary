import Network
import Combine
import SwiftUI

class NetworkMonitorService: ObservableObject {
	static let shared = NetworkMonitorService()
	private let monitor = NWPathMonitor()
	private let queue = DispatchQueue.global(qos: .background)
	
	@Published var isConnected: Bool = true
	@Published var isOffline: Bool = false
	
	private var cancellables = Set<AnyCancellable>()
	private var bufferTime: TimeInterval = 3.0
	
	private init() {
		monitor.start(queue: queue)
		monitor.pathUpdateHandler = { [weak self] path in
			DispatchQueue.main.async {
				self?.isConnected = path.status == .satisfied
			}
		}
		setupBindings()
	}
	
	private func setupBindings() {
		$isConnected
			.removeDuplicates()
			.flatMap { isConnected in
				isConnected ? Just(isConnected).eraseToAnyPublisher() : Just(isConnected).delay(for: .seconds(self.bufferTime), scheduler: RunLoop.main).eraseToAnyPublisher()
			}
			.sink { [weak self] isConnected in
				self?.isOffline = !isConnected
				if self?.isOffline == true {
					print("Offline mode: No internet connection for \(self?.bufferTime ?? 0) seconds")
				} else {
					print("Online mode: Internet connection restored")
				}
			}
			.store(in: &cancellables)
	}
	
	deinit {
		monitor.cancel()
	}
}
