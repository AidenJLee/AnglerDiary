import Foundation
import SwiftUI
import AVFoundation
import Photos
import Combine
import LocalAuthentication
import UserNotifications
import AppTrackingTransparency

public protocol Permission {
	var statusPublisher: AnyPublisher<PermissionStatus, Never> { get }
	func requestPermission() async -> PermissionStatus
	func checkStatus()
}

public enum PermissionStatus {
	case authorized
	case denied
	case notDetermined
	case restricted
}

extension PermissionStatus {
	var description: String {
		switch self {
		case .authorized: return "Authorized"
		case .denied: return "Denied"
		case .notDetermined: return "Not Determined"
		case .restricted: return "Restricted"
		}
	}
	
	var color: Color {
		switch self {
		case .authorized: return .green
		case .denied, .restricted: return .red
		case .notDetermined: return .gray
		}
	}
}

public class PermissionsService: ObservableObject {
	public static let shared = PermissionsService()
	
	@Published var cameraStatus: PermissionStatus = .notDetermined
	@Published var photoStatus: PermissionStatus = .notDetermined
	@Published var faceIDStatus: PermissionStatus = .notDetermined
	@Published var notificationsStatus: PermissionStatus = .notDetermined
	@Published var trackingStatus: PermissionStatus = .notDetermined
	
	private var cancellables = Set<AnyCancellable>()
	
	private let permissions: [Permission]
	
	private init() {
		self.permissions = [
			CameraPermission(),
			PhotoPermission(),
			FaceIDPermission(),
			NotificationsPermission(),
			TrackingPermission()
		]
		setupPermissions()
	}
	
	func setupPermissions() {
		for permission in permissions {
			checkStatus(for: permission)
		}
	}
	
	private func checkStatus(for permission: Permission) {
		permission.statusPublisher
			.receive(on: DispatchQueue.main)
			.sink { status in
				self.updateStatus(for: permission, with: status)
			}
			.store(in: &cancellables)
	}
	
	func updateStatus(for permission: Permission, with status: PermissionStatus) {
		switch permission {
		case is CameraPermission: cameraStatus = status
		case is PhotoPermission: photoStatus = status
		case is FaceIDPermission: faceIDStatus = status
		case is NotificationsPermission: notificationsStatus = status
		case is TrackingPermission: trackingStatus = status
		default: break
		}
	}
	
	public func requestPermission(for permission: Permission) async -> PermissionStatus {
		return await permission.requestPermission()
	}
	
	public func openSettings() {
		if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
			UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
		}
	}
}

// CameraPermission
public class CameraPermission: Permission {
	private var statusSubject = CurrentValueSubject<PermissionStatus, Never>(.notDetermined)
	
	public init() {
		checkStatus()
	}
	
	public var statusPublisher: AnyPublisher<PermissionStatus, Never> {
		return statusSubject.eraseToAnyPublisher()
	}
	
	public func checkStatus() {
		let status = AVCaptureDevice.authorizationStatus(for: .video)
		updateStatus(status)
	}
	
	private func updateStatus(_ status: AVAuthorizationStatus) {
		switch status {
		case .authorized:
			statusSubject.send(.authorized)
		case .denied, .restricted:
			statusSubject.send(.denied)
		case .notDetermined:
			statusSubject.send(.notDetermined)
		@unknown default:
			statusSubject.send(.denied)
		}
	}
	
	public func requestPermission() async -> PermissionStatus {
		return await withCheckedContinuation { continuation in
			AVCaptureDevice.requestAccess(for: .video) { granted in
				let status: PermissionStatus = granted ? .authorized : .denied
				self.statusSubject.send(status)
				continuation.resume(returning: status)
			}
		}
	}
}

// PhotoPermission
public class PhotoPermission: Permission {
	private var statusSubject = CurrentValueSubject<PermissionStatus, Never>(.notDetermined)
	
	public init() {
		checkStatus()
	}
	
	public var statusPublisher: AnyPublisher<PermissionStatus, Never> {
		return statusSubject.eraseToAnyPublisher()
	}
	
	public func checkStatus() {
		let status = PHPhotoLibrary.authorizationStatus()
		updateStatus(status)
	}
	
	private func updateStatus(_ status: PHAuthorizationStatus) {
		switch status {
		case .authorized, .limited:
			statusSubject.send(.authorized)
		case .denied, .restricted:
			statusSubject.send(.denied)
		case .notDetermined:
			statusSubject.send(.notDetermined)
		@unknown default:
			statusSubject.send(.denied)
		}
	}
	
	public func requestPermission() async -> PermissionStatus {
		return await withCheckedContinuation { continuation in
			PHPhotoLibrary.requestAuthorization { status in
				let permissionStatus: PermissionStatus
				switch status {
				case .authorized, .limited:
					permissionStatus = .authorized
				case .denied, .restricted:
					permissionStatus = .denied
				case .notDetermined:
					permissionStatus = .notDetermined
				@unknown default:
					permissionStatus = .denied
				}
				self.statusSubject.send(permissionStatus)
				continuation.resume(returning: permissionStatus)
			}
		}
	}
}

// FaceIDPermission
public class FaceIDPermission: Permission {
	private var statusSubject = CurrentValueSubject<PermissionStatus, Never>(.notDetermined)
	
	public init() {
		checkStatus()
	}
	
	public var statusPublisher: AnyPublisher<PermissionStatus, Never> {
		return statusSubject.eraseToAnyPublisher()
	}
	
	public func checkStatus() {
		let context = LAContext()
		var error: NSError?
		let canEvaluatePolicy = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
		
		if canEvaluatePolicy {
			statusSubject.send(.authorized)
		} else {
			if let laError = error as? LAError {
				switch laError.code {
				case .biometryNotAvailable, .biometryNotEnrolled, .biometryLockout:
					statusSubject.send(.denied)
				default:
					statusSubject.send(.denied)
				}
			} else {
				statusSubject.send(.notDetermined)
			}
		}
	}
	
	public func requestPermission() async -> PermissionStatus {
		checkStatus() // FaceID 권한 요청은 별도의 요청이 없고 사용 시점에 요청하므로 여기서는 checkStatus만 제공
		return statusSubject.value
	}
}

// NotificationsPermission
public class NotificationsPermission: Permission {
	private var statusSubject = CurrentValueSubject<PermissionStatus, Never>(.notDetermined)
	
	public init() {
		checkStatus()
	}
	
	public var statusPublisher: AnyPublisher<PermissionStatus, Never> {
		return statusSubject.eraseToAnyPublisher()
	}
	
	public func checkStatus() {
		UNUserNotificationCenter.current().getNotificationSettings { settings in
			let status: PermissionStatus
			switch settings.authorizationStatus {
			case .authorized, .provisional:
				status = .authorized
			case .denied:
				status = .denied
			case .notDetermined:
				status = .notDetermined
			case .ephemeral:
				status = .authorized
			@unknown default:
				status = .denied
			}
			DispatchQueue.main.async {
				self.statusSubject.send(status)
			}
		}
	}
	
	public func requestPermission() async -> PermissionStatus {
		return await withCheckedContinuation { continuation in
			UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
				let status: PermissionStatus = granted ? .authorized : .denied
				self.statusSubject.send(status)
				continuation.resume(returning: status)
			}
		}
	}
}

// TrackingPermission
public class TrackingPermission: Permission {
	private var statusSubject = CurrentValueSubject<PermissionStatus, Never>(.notDetermined)
	
	public init() {
		checkStatus()
	}
	
	public var statusPublisher: AnyPublisher<PermissionStatus, Never> {
		return statusSubject.eraseToAnyPublisher()
	}
	
	public func checkStatus() {
		let status = ATTrackingManager.trackingAuthorizationStatus
		updateStatus(status)
	}
	
	private func updateStatus(_ status: ATTrackingManager.AuthorizationStatus) {
		switch status {
		case .authorized:
			statusSubject.send(.authorized)
		case .denied:
			statusSubject.send(.denied)
		case .notDetermined:
			statusSubject.send(.notDetermined)
		case .restricted:
			statusSubject.send(.restricted)
		@unknown default:
			statusSubject.send(.denied)
		}
	}
	
	public func requestPermission() async -> PermissionStatus {
		return await withCheckedContinuation { continuation in
			ATTrackingManager.requestTrackingAuthorization { status in
				let permissionStatus: PermissionStatus
				switch status {
				case .authorized:
					permissionStatus = .authorized
				case .denied:
					permissionStatus = .denied
				case .notDetermined:
					permissionStatus = .notDetermined
				case .restricted:
					permissionStatus = .restricted
				@unknown default:
					permissionStatus = .denied
				}
				self.statusSubject.send(permissionStatus)
				continuation.resume(returning: permissionStatus)
			}
		}
	}
}
