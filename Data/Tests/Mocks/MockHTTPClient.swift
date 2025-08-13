import Foundation
@testable import Data
@testable import Network

public final class MockHTTPClient: HTTPClient, @unchecked Sendable {

    public private(set) var sendCalls: [(request: URLRequest, decoder: JSONDecoder)] = []
    public var sendCallCount: Int { sendCalls.count }

    public var responses: [String: Result<Any, Error>] = [:]
    public var defaultResponse: Result<Any, Error>?

    public func setResponse<T: Codable>(for path: String, response: T) {
        responses[path] = .success(response)
    }
    
    public func setError(for path: String, error: Error) {
        responses[path] = .failure(error)
    }
    
    public func setDefaultResponse<T: Codable>(_ response: T) {
        defaultResponse = .success(response)
    }
    
    public func setDefaultError(_ error: Error) {
        defaultResponse = .failure(error)
    }

    public func send<T: Decodable & Sendable>(_ request: URLRequest, decoder: JSONDecoder) async throws -> T {
        sendCalls.append((request, decoder))

        let path = request.url?.path ?? ""

        let result = responses[path] ?? defaultResponse
        
        guard let result = result else {
            throw NetworkError.noResponse
        }
        
        switch result {
        case .success(let response):
            guard let typedResponse = response as? T else {
                throw NetworkError.invalidResponse
            }
            return typedResponse
            
        case .failure(let error):
            throw error
        }
    }
    
    public func reset() {
        sendCalls.removeAll()
        responses.removeAll()
        defaultResponse = nil
    }
    
    public func lastRequest() -> URLRequest? {
        return sendCalls.last?.request
    }
    
    public func requestsFor(path: String) -> [URLRequest] {
        return sendCalls.compactMap { call in
            guard call.request.url?.path == path else { return nil }
            return call.request
        }
    }
}
