import Foundation

extension DateFormatter {
	static let ymdhms: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyyMMddHHmmss"
		formatter.timeZone = TimeZone.current  // 기기의 현재 시간대 사용
		return formatter
	}()
	
	static let ymd: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyyMMdd"
		formatter.timeZone = TimeZone.current
		return formatter
	}()
	
	static let yyyyMMdd: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd"
		return formatter
	}()
	
	static let hhmm: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "HH:mm"
		return formatter
	}()
	
	static let shortDate: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateStyle = .short
		return formatter
	}()
}

extension String {
	func toDate() -> Date? {
		return DateFormatter.ymdhms.date(from: self)
	}
	
	func toDate(formatter: DateFormatter) -> Date? {
		return formatter.date(from: self)
	}
}
