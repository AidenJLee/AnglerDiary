import SwiftUI

public enum PageViewDirection {
	case horizontal, vertical
}

struct CurrentPageView<Content: View>: View {
	let currentPage: Int
	let totalPages: Int
	let getPage: (Int) -> Content
	let size: CGSize
	let direction: PageViewDirection
	
	var body: some View {
		ZStack {
			if totalPages > 1 {
				// Previous page
				getPage((currentPage - 1 + totalPages) % totalPages)
					.frame(width: size.width, height: size.height)
					.offset(x: direction == .horizontal ? -size.width : 0,
							y: direction == .vertical ? -size.height : 0)
				
				// Next page
				getPage((currentPage + 1) % totalPages)
					.frame(width: size.width, height: size.height)
					.offset(x: direction == .horizontal ? size.width : 0,
							y: direction == .vertical ? size.height : 0)
			}
			
			// Current page
			getPage(currentPage)
				.frame(width: size.width, height: size.height)
		}
	}
}

public struct PagerView<Content: View>: View {
	@Environment(\.scenePhase) var scenePhase
	
	@State private var currentPage: Int
	@State private var offset: CGSize = .zero
	@State private var isAnimating: Bool = false
	@State private var size: CGSize = .zero
	@State private var autoScrollTimer: Timer?
	@GestureState private var isDragging: Bool = false
	
	let pages: [Int]
	let getPage: (Int) -> Content
	let animationDuration: Double
	let direction: PageViewDirection
	let autoScrollInterval: Double
	let autoScrollEnabled: Bool
	
	public init(
		initialPage: Int = 0,
		pages: [Int],
		direction: PageViewDirection = .horizontal,
		animationDuration: Double = 0.22,
		autoScrollInterval: Double = 3.0,
		autoScrollEnabled: Bool = false,
		@ViewBuilder getPage: @escaping (Int) -> Content
	) {
		_currentPage = State(initialValue: min(max(initialPage, 0), pages.count - 1))
		self.pages = pages
		self.direction = direction
		self.animationDuration = animationDuration
		self.autoScrollInterval = autoScrollInterval
		self.autoScrollEnabled = autoScrollEnabled
		self.getPage = getPage
	}
	
	public var body: some View {
		GeometryReader { proxy in
			let size = proxy.size
			ZStack {
				CurrentPageView(
					currentPage: currentPage,
					totalPages: pages.count,
					getPage: getPage,
					size: size,
					direction: direction
				)
				.offset(x: offset.width, y: offset.height)
			}
			.gesture(
				DragGesture()
					.updating($isDragging) { _, state, _ in
						state = true
					}
					.onChanged { value in
						guard !isAnimating else { return }
						handleDragChange(value: value)
					}
					.onEnded { value in
						guard !isAnimating else { return }
						handleDragEnd(value: value)
					}
			)
			.onChange(of: isDragging) { oldValue, newValue in
				if !newValue {
					handleDragEndInternally()
				}
			}
			.onAppear {
				self.size = size
				if autoScrollEnabled {
					startAutoScroll()
				}
			}
			.onDisappear {
				stopAutoScroll()
			}
			.onChange(of: scenePhase) { oldValue, newValue in
				if newValue == .active {
					resetPosition()
					if autoScrollEnabled {
						startAutoScroll()
					}
				} else {
					stopAutoScroll()
				}
			}
		}
	}
	
	private func startAutoScroll() {
		guard autoScrollTimer == nil else { return }
		autoScrollTimer = Timer.scheduledTimer(withTimeInterval: autoScrollInterval, repeats: true) { _ in
			goToNextPage()
		}
	}
	
	private func stopAutoScroll() {
		autoScrollTimer?.invalidate()
		autoScrollTimer = nil
	}
	
	private func resetPosition() {
		withAnimation(.easeOut(duration: animationDuration)) {
			offset = .zero
		}
		DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
			isAnimating = false
		}
	}
	
	private func handleDragChange(value: DragGesture.Value) {
		guard pages.count > 1 else { return }
		if direction == .horizontal {
			offset = CGSize(width: value.translation.width, height: 0)
		} else {
			offset = CGSize(width: 0, height: value.translation.height)
		}
		
		stopAutoScroll() // 터치가 시작되면 자동 스크롤을 멈춤
	}
	
	private func handleDragEnd(value: DragGesture.Value) {
		isAnimating = true
		
		let pageSize = direction == .horizontal ? size.width : size.height
		let threshold = pageSize / 3
		let translation = direction == .horizontal ? value.translation.width : value.translation.height
		let predictedEndTranslation = direction == .horizontal ? value.predictedEndTranslation.width : value.predictedEndTranslation.height
		
		let shouldTransition = abs(translation) > threshold || abs(predictedEndTranslation) > threshold
		
		if shouldTransition {
			transitionPage(translation: translation)
		} else {
			resetPosition()
		}
		
		if autoScrollEnabled {
			DispatchQueue.main.asyncAfter(deadline: .now() + autoScrollInterval) {
				startAutoScroll() // 터치가 끝난 후 일정 시간이 지나면 자동 스크롤을 다시 시작
			}
		}
	}
	
	private func handleDragEndInternally() {
		if !isAnimating {
			isAnimating = true
			let pageSize = direction == .horizontal ? size.width : size.height
			let threshold = pageSize / 3
			let translation = direction == .horizontal ? offset.width : offset.height
			
			let shouldTransition = abs(translation) > threshold
			
			if shouldTransition {
				transitionPage(translation: translation)
			} else {
				resetPosition()
			}
			
			if autoScrollEnabled {
				DispatchQueue.main.asyncAfter(deadline: .now() + autoScrollInterval) {
					startAutoScroll() // 터치가 끝난 후 일정 시간이 지나면 자동 스크롤을 다시 시작
				}
			}
		}
	}
	
	private func transitionPage(translation: CGFloat) {
		var newPage = currentPage
		
		let pageSize = direction == .horizontal ? size.width : size.height
		let finalOffset = direction == .horizontal ?
			CGSize(width: (translation > 0 ? pageSize : -pageSize), height: 0) :
			CGSize(width: 0, height: (translation > 0 ? pageSize : -pageSize))
		
		if direction == .horizontal {
			newPage = (currentPage + (translation > 0 ? -1 : 1) + pages.count) % pages.count
		} else {
			newPage = (currentPage + (translation > 0 ? -1 : 1) + pages.count) % pages.count
		}
		
		withAnimation(.easeOut(duration: animationDuration)) {
			offset = finalOffset
		}
		
		DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
			currentPage = newPage
			offset = .zero
			isAnimating = false
		}
	}
	
	private func goToNextPage() {
		guard pages.count > 0 else { return }
		let nextPage = (currentPage + 1) % pages.count
		
		withAnimation(.easeOut(duration: animationDuration)) {
			if direction == .horizontal {
				offset = CGSize(width: -size.width, height: 0)
			} else {
				offset = CGSize(width: 0, height: -size.height)
			}
		}
		
		DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
			currentPage = nextPage
			offset = .zero
			isAnimating = false
		}
	}
}
