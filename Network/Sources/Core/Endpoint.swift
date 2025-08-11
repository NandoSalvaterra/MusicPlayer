import Foundation

public protocol Endpoint<Response>: Sendable {
    associatedtype Response: Decodable & Sendable
    var path: String { get }
    var method: HTTPMethod { get }
    var query: [URLQueryItem] { get }
    var headers: [String: String] { get }
    var body: Data? { get }
}

public extension Endpoint {
    var headers: [String: String] { [:] }
    var query: [URLQueryItem] { [] }
    var body: Data? { nil }
}
