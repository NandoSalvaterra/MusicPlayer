import Foundation
@testable import Network

final class MockURLSession: URLSessionProtocol, @unchecked Sendable {
    
    var mockData: Data?
    var mockResponse: URLResponse?
    var mockError: Error?
    
    private(set) var dataTaskCallCount = 0
    private(set) var lastRequest: URLRequest?
    private(set) var allRequests: [URLRequest] = []
    
    enum MockScenario {
        case success(data: Data, statusCode: Int)
        case httpError(statusCode: Int, data: Data?)
        case networkError(Error)
        case timeout
        case noResponse
    }
    
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        dataTaskCallCount += 1
        lastRequest = request
        allRequests.append(request)

        if let error = mockError {
            throw error
        }

        let data = mockData ?? Data()
        let response = mockResponse ?? createDefaultHTTPResponse(for: request)
        
        return (data, response)
    }

    func mockSuccess(data: Data, statusCode: Int = 200) {
        mockData = data
        mockResponse = HTTPURLResponse(
            url: URL(string: "https://test.com")!,
            statusCode: statusCode,
            httpVersion: "HTTP/1.1",
            headerFields: ["Content-Type": "application/json"]
        )
        mockError = nil
    }

    func mockHTTPError(statusCode: Int, data: Data? = nil) {
        mockData = data ?? Data()
        mockResponse = HTTPURLResponse(
            url: URL(string: "https://test.com")!,
            statusCode: statusCode,
            httpVersion: "HTTP/1.1",
            headerFields: nil
        )
        mockError = nil
    }

    func mockNetworkError(_ error: Error) {
        mockError = error
        mockData = nil
        mockResponse = nil
    }

    func mockTimeout() {
        mockError = URLError(.timedOut)
        mockData = nil
        mockResponse = nil
    }

    func mockOffline() {
        mockError = URLError(.notConnectedToInternet)
        mockData = nil
        mockResponse = nil
    }

    func reset() {
        mockData = nil
        mockResponse = nil
        mockError = nil
        dataTaskCallCount = 0
        lastRequest = nil
        allRequests.removeAll()
    }

    func configure(scenario: MockScenario) {
        reset()
        
        switch scenario {
        case .success(let data, let statusCode):
            mockSuccess(data: data, statusCode: statusCode)
            
        case .httpError(let statusCode, let data):
            mockHTTPError(statusCode: statusCode, data: data)
            
        case .networkError(let error):
            mockNetworkError(error)
            
        case .timeout:
            mockTimeout()
            
        case .noResponse:
            mockResponse = URLResponse() 
            mockData = Data()
            mockError = nil
        }
    }

    private func createDefaultHTTPResponse(for request: URLRequest) -> HTTPURLResponse {
        return HTTPURLResponse(
            url: request.url!,
            statusCode: 200,
            httpVersion: "HTTP/1.1",
            headerFields: ["Content-Type": "application/json"]
        )!
    }
}
