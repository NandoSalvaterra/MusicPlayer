import Foundation

public protocol HTTPClient: Sendable {
    func send<T: Decodable & Sendable>(_ request: URLRequest,
                                       decoder: JSONDecoder) async throws(Error) -> T
}

public extension HTTPClient {
    func send<T: Decodable & Sendable>(_ request: URLRequest) async throws(Error) -> T {
        let decoder = JSONDecoder()
        return try await send(request, decoder: decoder)
    }
}
