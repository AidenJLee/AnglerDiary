//
//  FlowNet.swift
//  AnglerDiary
//
//  Created by HoJun Lee on 12/23/24.
//

import Foundation

@available(iOS 15, macOS 10.15, *)
public struct FlowNet {
    public var baseURL: String
    public var core: FlowNetCore
    
    private let logger: FlowNetLogger
    
    public init(baseURL: String, logLevel: NetworkingLogLevel = .debug) {
        self.baseURL = baseURL
        self.logger = FlowNetLogger(logLevel: logLevel)
        self.core = FlowNetCore(logger: logger)
    }
    
    public func send<Request: FlowNetRequest>(_ request: Request) async throws -> Request.ReturnType {
        guard let urlRequest = request.asURLRequest(baseURL: baseURL) else {
            throw URLError(.badURL)
        }
        
        logger.log(request: urlRequest)
        return try await core.send(request: urlRequest, decoder: request.decoder)
    }
}


// MARK: - FlowNetRequest
public protocol FlowNetRequest {
    associatedtype ReturnType: Codable
    
    var path: String { get }
    var method: HTTPMethod { get }
    var contentType: HTTPContentType { get }
    var queryParams: HTTPParams? { get }
    var body: Params? { get }
    var headers: HTTPHeaders? { get }
    var multipartData: [MultipartData]? { get }
    var authToken: String? { get }
    var decoder: JSONDecoder? { get }
}

public extension FlowNetRequest {
    var method: HTTPMethod { .get }
    var contentType: HTTPContentType { .json }
    var queryParams: HTTPParams? { nil }
    var body: Params? { nil }
    var headers: HTTPHeaders? { nil }
    var multipartData: [MultipartData]? { nil }
    var authToken: String? { nil }
    var decoder: JSONDecoder? { JSONDecoder() }
}

extension FlowNetRequest {
    func asURLRequest(baseURL: String) -> URLRequest? {
        guard var urlComponents = URLComponents(string: baseURL) else { return nil }
        urlComponents.path += path
        urlComponents.queryItems = queryItemsFrom(params: queryParams)
        
        guard let finalURL = urlComponents.url else { return nil }
        var request = URLRequest(url: finalURL)
        
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers
        request.httpBody = requestBodyFrom(params: body)
        
        return request
    }
    
    private func queryItemsFrom(params: HTTPParams?) -> [URLQueryItem]? {
        params?.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
    }
    
    private func requestBodyFrom(params: Params?) -> Data? {
        guard let params = params else { return nil }
        return try? JSONSerialization.data(withJSONObject: params)
    }
}


// MARK: - FlowNet Core
@available(iOS 15, macOS 10.15, *)
public struct FlowNetCore {
    private let urlSession: URLSession = .shared
    private let logger: FlowNetLogger
    
    init(logger: FlowNetLogger) {
        self.logger = logger
    }
    
    func send<ReturnType: Codable>(request: URLRequest, decoder: JSONDecoder?) async throws -> ReturnType {
        let decoder = decoder ?? JSONDecoder()
        let (data, response) = try await urlSession.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw NetworkRequestError.serverError(data)
        }
        
        logger.log(response: response, data: data)
        
        #if DEBUG
        do {
            return try decoder.decode(ReturnType.self, from: data)
        } catch {
            print("Decoding Error: \(error)")
            throw NetworkRequestError.decodingError(error.localizedDescription)
        }
        #else
        return try decoder.decode(ReturnType.self, from: data)
        #endif
    }
}


public struct FlowNetLogger {
    let logLevel: NetworkingLogLevel
    
    init(logLevel: NetworkingLogLevel) {
        self.logLevel = logLevel
    }
    
    func log(request: URLRequest) {
        print("[FlowNet] Request: \(request.httpMethod ?? "Unknown") \(request.url?.absoluteString ?? "Unknown URL")")
    }
    
    func log(response: URLResponse, data: Data) {
        print("[FlowNet] Response: \(response)")
    }
}


// 네트워크 요청 에러 처리
public enum NetworkRequestError: LocalizedError, Equatable {
    case invalidRequest(_ data: Data? = nil)
    case badRequest(_ data: Data? = nil)
    case unauthorized(_ data: Data? = nil)
    case forbidden(_ data: Data? = nil)
    case notFound(_ data: Data? = nil)
    case error4xx(_ code: Int, data: Data? = nil)
    case serverError(_ data: Data? = nil)
    case serviceError(_ code: Int, data: Data? = nil)
    case error5xx(_ code: Int, data: Data? = nil)
    case decodingError(_ description: String)
    case urlSessionFailed(_ error: URLError)
    case unknownError(_ data: Data? = nil)
}

// Params 타입은 [String: CustomStringConvertible] 타입의 typealias로 정의됩니다.
public typealias Params = [String: CustomStringConvertible]

// HTTPParams 타입은 [String: Any] 타입의 typealias로 정의됩니다.
public typealias HTTPParams = [String: Any]

// HTTPHeaders 타입은 [String: String] 타입의 typealias로 정의됩니다.
public typealias HTTPHeaders = [String: String]

// HTTPContentType 열거형은 String rawValue를 가지며, 각 케이스는 HTTP 요청의 Content-Type을 나타냅니다.
public enum HTTPContentType: String {
    case json = "application/json"
    case urlEncoded = "application/x-www-form-urlencoded"
    case multipart = "multipart/form-data"
}

// HTTPHeaderField 열거형은 String rawValue를 가지며, 각 케이스는 HTTP 요청의 헤더 필드를 나타냅니다.
public enum HTTPHeaderField: String {
    case authentication = "Authorization"
    case contentType = "Content-Type"
    case acceptType = "Accept"
    case authToken = "X-AUTH-TOKEN"
    case acceptEncoding = "Accept-Encoding"
}

// HTTPMethod 구조체는 String rawValue를 가지며, HTTP 요청의 메소드를 나타냅니다.
public struct HTTPMethod: RawRepresentable, Equatable, Hashable {
    
    public static let get = HTTPMethod(rawValue: "GET")         // `GET` 메소드.
    public static let post = HTTPMethod(rawValue: "POST")       // `POST` 메소드.
    public static let put = HTTPMethod(rawValue: "PUT")         // `PUT` 메소드.
    public static let delete = HTTPMethod(rawValue: "DELETE")   // `DELETE` 메소드.
    
    public let rawValue: String
    
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}

// HttpBodyConvertible 프로토콜은 HTTP 요청의 Body를 생성하는 메소드를 가지고 있습니다.
public protocol HttpBodyConvertible {
    func buildHttpBodyPart(boundary: String) -> Data
}

// MultipartData 구조체는 HTTP 요청의 Body에 포함될 멀티파트 데이터를 나타냅니다.
public struct MultipartData {
    let name: String
    let fileData: Data
    let fileName: String
    let mimeType: String
    
    public init(name: String, fileData: Data, fileName: String, mimeType: String) {
        self.name = name
        self.fileData = fileData
        self.fileName = fileName
        self.mimeType = mimeType
    }
}

// HttpBodyConvertible 프로토콜을 채택한 MultipartData 구조체는 buildHttpBodyPart 메소드를 구현합니다.
extension MultipartData: HttpBodyConvertible {
    public func buildHttpBodyPart(boundary: String) -> Data {
        let httpBody = NSMutableData()
        httpBody.appendString("--\(boundary)\r\n")
        httpBody.appendString("Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(fileName)\"\r\n")
        httpBody.appendString("Content-Type: \(mimeType)\r\n\r\n")
        httpBody.append(fileData)
        httpBody.appendString("\r\n")
        return httpBody as Data
    }
}

// Params 타입에 asPercentEncodedString 메소드를 추가합니다.
extension Params {
    public func asPercentEncodedString(parentKey: String? = nil) -> String {
        return self.map { key, value in
            var escapedKey = "\(key)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            if let `parentKey` = parentKey {
                escapedKey = "\(parentKey)[\(escapedKey)]"
            }
            
            if let dict = value as? Params {
                return dict.asPercentEncodedString(parentKey: escapedKey)
            } else if let array = value as? [CustomStringConvertible] {
                return array.map { entry in
                    let escapedValue = "\(entry)"
                        .addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
                    return "\(escapedKey)[]=\(escapedValue)"
                }.joined(separator: "&")
            } else {
                let escapedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
                return "\(escapedKey)=\(escapedValue)"
            }
        }
        .joined(separator: "&")
    }
}

// HttpBodyConvertible 프로토콜을 채택한 Params 타입은 buildHttpBodyPart 메소드를 구현합니다.
extension Params: HttpBodyConvertible {
    public func buildHttpBodyPart(boundary: String) -> Data {
        let httpBody = NSMutableData()
        forEach { (name, value) in
            httpBody.appendString("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n")
            httpBody.appendString("\(value)")
            httpBody.appendString("\r\n")
        }
        return httpBody as Data
    }
}

// URL 쿼리 문자열에 포함될 수 없는 문자를 인코딩하기 위한 CharacterSet을 정의합니다.
extension CharacterSet {
    static let urlQueryValueAllowed: CharacterSet = {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="
        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        return allowed
    }()
}

// NSMutableData에 appendString 메소드를 추가합니다.
internal extension NSMutableData {
    func appendString(_ string: String) {
        if let data = string.data(using: .utf8) {
            self.append(data)
        }
    }
}


public enum NetworkingLogLevel {
    case off
    case info
    case debug
}

extension URLRequest {
    // URLRequest를 cURL command로 변환하는 함수
    public func toCurlCommand() -> String {
        guard let url: URL = url else { return "" }
        var command: [String] = [#"curl "\#(url.absoluteString)""#]
        
        if let httpMethod, httpMethod != "GET", httpMethod != "HEAD" {
            command.append("-X \(httpMethod)")
        }
        
        allHTTPHeaderFields?
            .filter { $0.key != "Cookie" }
            .forEach { key, value in
                command.append("-H '\(key): \(value)'")
            }
        
        if let data = httpBody, let body = String(data: data, encoding: .utf8) {
            command.append("-d '\(body)'")
        }
        
        return command.joined(separator: " \\\n\t")
    }
}
