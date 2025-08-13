import XCTest
@testable import Network

final class URLSessionClientTests: XCTestCase {

    func testInitializationWithDefaultConfiguration() {
        let mockMonitor = MockNetworkMonitor()
        _  = URLSessionClient(networkMonitor: mockMonitor)

        XCTAssertTrue(mockMonitor.startMonitoringCalled)
    }

    func testInitializationWithCustomConfiguration() {
        let mockMonitor = MockNetworkMonitor()
        let configuration = URLSessionConfiguration.ephemeral
        configuration.timeoutIntervalForRequest = 30
        _ = URLSessionClient(configuration: configuration, networkMonitor: mockMonitor)

        XCTAssertTrue(mockMonitor.startMonitoringCalled)
    }

    func testDeinitStopsMonitoring() {
        let mockMonitor = MockNetworkMonitor()
        do {
            let client = URLSessionClient(networkMonitor: mockMonitor)
            _ = client
        }

        XCTAssertTrue(mockMonitor.stopMonitoringCalled)
    }

    func testRequestWhenOfflineThrowsError() async {
        let mockMonitor = MockNetworkMonitor()
        mockMonitor.isConnected = false

        let client = URLSessionClient(networkMonitor: mockMonitor)
        let request = createTestRequest()

        do {
            let _: ItunesSearchResponseDTO = try await client.send(request)
            XCTFail("Expected offline error")
        } catch {
            guard case NetworkError.offline = error else {
                XCTFail("Expected NetworkError.offline, got \(error)")
                return
            }
        }
    }

    func testRequestWhenOnlineProceedsWithRequest() async {
        let mockMonitor = MockNetworkMonitor()
        let mockSession = MockURLSession()
        mockMonitor.isConnected = true

        let testData = createTestJSON()
        mockSession.mockSuccess(data: testData, statusCode: 200)

        let client = URLSessionClient(session: mockSession, networkMonitor: mockMonitor)
        let request = createTestRequest()

        do {
            let response: ItunesSearchResponseDTO = try await client.send(request)
            XCTAssertEqual(response.resultCount, 1)
            XCTAssertEqual(mockSession.dataTaskCallCount, 1)
            XCTAssertEqual(mockSession.lastRequest, request)
        } catch {
            XCTFail("Expected successful request, got error: \(error)")
        }
    }

    func testInvalidResponseTypeThrowsError() async {
        let mockMonitor = MockNetworkMonitor()
        let mockSession = MockURLSession()
        mockMonitor.isConnected = true

        mockSession.configure(scenario: .noResponse)

        let client = URLSessionClient(session: mockSession, networkMonitor: mockMonitor)
        let request = createTestRequest()

        do {
            let _: ItunesSearchResponseDTO = try await client.send(request)
            XCTFail("Expected invalid response error")
        } catch {
            guard case NetworkError.invalidResponse = error else {
                XCTFail("Expected NetworkError.invalidResponse, got \(error)")
                return
            }
        }
    }

    func testClientErrorStatusCodesThrowCorrectErrors() {
        let testCases: [(Int, NetworkError)] = [
            (400, .statusCode(400, nil)),
            (401, .unauthorized),
            (403, .forbidden),
            (404, .notFound),
            (418, .statusCode(418, nil))
        ]

        for (statusCode, expectedError) in testCases {
            let mappedError = NetworkError.mapStatus(statusCode, data: nil)

            switch (mappedError, expectedError) {
            case (.statusCode(let code1, _), .statusCode(let code2, _)):
                XCTAssertEqual(code1, code2)
            case (.unauthorized, .unauthorized),
                (.forbidden, .forbidden),
                (.notFound, .notFound):
                XCTAssertTrue(true)
            default:
                XCTFail("Unexpected error mapping for status \(statusCode)")
            }
        }
    }

    func testServerErrorStatusCodesThrowServerError() {
        let serverErrorCodes = [500, 502, 503, 504, 599]

        for statusCode in serverErrorCodes {
            let mappedError = NetworkError.mapStatus(statusCode, data: nil)

            if case .serverError(let code, _) = mappedError {
                XCTAssertEqual(code, statusCode)
            } else {
                XCTFail("Expected serverError for status \(statusCode), got \(mappedError)")
            }
        }
    }

    func testValidJSONDecodingSucceeds() {
        let jsonData = createTestJSON()
        let decoder = JSONDecoder()

        do {
            let response = try decoder.decode(ItunesSearchResponseDTO.self, from: jsonData)
            XCTAssertEqual(response.resultCount, 1)
            XCTAssertEqual(response.results.count, 1)
            XCTAssertEqual(response.results[0].trackName, "Test Song 1")
        } catch {
            XCTFail("Failed to decode valid JSON: \(error)")
        }
    }

    func testInvalidJSONDecodingFails() {
        let invalidJSON = TestDataFactory.createInvalidJSON()
        let decoder = JSONDecoder()

        XCTAssertThrowsError(try decoder.decode(ItunesSearchResponseDTO.self, from: invalidJSON)) { error in
            XCTAssertTrue(error is DecodingError)
        }
    }

    func testMissingRequiredFieldsDecodingFails() {
        let incompleteJSON = """
        {
            "results": []
        }
        """.data(using: .utf8)!
        let decoder = JSONDecoder()

        XCTAssertThrowsError(try decoder.decode(ItunesSearchResponseDTO.self, from: incompleteJSON)) { error in
            XCTAssertTrue(error is DecodingError)
        }
    }

    func testEmptyDataThrowsDecodingError() {
        let emptyData = Data()
        let decoder = JSONDecoder()

        XCTAssertThrowsError(try decoder.decode(ItunesSearchResponseDTO.self, from: emptyData)) { error in
            XCTAssertTrue(error is DecodingError)
        }
    }

    func testLargeJSONDecoding() {
        let largeJSON = TestDataFactory.createLargeResponse(itemCount: 100)
        let decoder = JSONDecoder()

        do {
            let response = try decoder.decode(ItunesSearchResponseDTO.self, from: largeJSON)
            XCTAssertEqual(response.resultCount, 100)
            XCTAssertEqual(response.results.count, 100)
        } catch {
            XCTFail("Failed to decode large JSON: \(error)")
        }
    }

    private func createTestRequest() -> URLRequest {
        return URLRequest.testRequest()
    }

    private func createSuccessResponse(statusCode: Int = 200) -> HTTPURLResponse {
        return HTTPURLResponse.testResponse(statusCode: statusCode)
    }

    private func createTestJSON() -> Data {
        return TestDataFactory.createItunesSearchResponse()
    }
}
