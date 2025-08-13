import XCTest
@testable import Network

final class RequestBuilderTests: XCTestCase {

    func testRequestBuilderInitialization() {
        let baseURL = createBaseURL()
        let builder = RequestBuilder(baseURL: baseURL)

        XCTAssertEqual(builder.baseURL, baseURL)
    }

    func testMakeRequestBasic() throws {
        let baseURL = createBaseURL()
        let builder = RequestBuilder(baseURL: baseURL)
        let endpoint = createTestEndpoint()

        let request = try builder.makeRequest(endpoint)

        XCTAssertEqual(request.httpMethod, "GET")
        XCTAssertEqual(request.url?.absoluteString, "https://itunes.apple.com/search?term=test")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Accept"), "application/json")
        XCTAssertNil(request.httpBody)
    }

    func testMakeRequestWithDifferentMethods() throws {
        let baseURL = createBaseURL()
        let builder = RequestBuilder(baseURL: baseURL)

        let methods: [HTTPMethod] = [.get, .post, .put, .delete, .patch]

        for method in methods {
            let endpoint = TestEndpoint(method: method)
            let request = try builder.makeRequest(endpoint)

            XCTAssertEqual(request.httpMethod, method.rawValue)
        }
    }

    func testMakeRequestWithSimplePath() throws {
        let baseURL = URL(string: "https://api.example.com")!
        let builder = RequestBuilder(baseURL: baseURL)
        let endpoint = TestEndpoint(path: "users")

        let request = try builder.makeRequest(endpoint)

        XCTAssertEqual(request.url?.absoluteString, "https://api.example.com/users?term=test")
    }

    func testMakeRequestWithNestedPath() throws {
        let baseURL = URL(string: "https://api.example.com/v1")!
        let builder = RequestBuilder(baseURL: baseURL)
        let endpoint = TestEndpoint(path: "users/123/posts")

        let request = try builder.makeRequest(endpoint)

        XCTAssertEqual(request.url?.absoluteString, "https://api.example.com/v1/users/123/posts?term=test")
    }

    func testMakeRequestWithEmptyPath() throws {
        let baseURL = createBaseURL()
        let builder = RequestBuilder(baseURL: baseURL)
        let endpoint = TestEndpoint(path: "")

        let request = try builder.makeRequest(endpoint)

        XCTAssertEqual(request.url?.absoluteString, "https://itunes.apple.com/?term=test")
    }

    func testMakeRequestWithNoQueryParameters() throws {
        let baseURL = createBaseURL()
        let builder = RequestBuilder(baseURL: baseURL)
        let endpoint = TestEndpoint(query: [])

        let request = try builder.makeRequest(endpoint)

        XCTAssertEqual(request.url?.absoluteString, "https://itunes.apple.com/search")
        XCTAssertNil(request.url?.query)
    }

    func testMakeRequestWithMultipleQueryParameters() throws {
        let baseURL = createBaseURL()
        let builder = RequestBuilder(baseURL: baseURL)
        let queryItems = [
            URLQueryItem(name: "term", value: "jack johnson"),
            URLQueryItem(name: "entity", value: "song"),
            URLQueryItem(name: "limit", value: "50")
        ]
        let endpoint = TestEndpoint(query: queryItems)

        let request = try builder.makeRequest(endpoint)

        let url = request.url!
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        let resultQuery = components.queryItems!

        XCTAssertEqual(resultQuery.count, 3)
        XCTAssertTrue(resultQuery.contains(URLQueryItem(name: "term", value: "jack johnson")))
        XCTAssertTrue(resultQuery.contains(URLQueryItem(name: "entity", value: "song")))
        XCTAssertTrue(resultQuery.contains(URLQueryItem(name: "limit", value: "50")))
    }

    func testMakeRequestWithSpecialCharactersInQuery() throws {
        let baseURL = createBaseURL()
        let builder = RequestBuilder(baseURL: baseURL)
        let queryItems = [
            URLQueryItem(name: "term", value: "Green Day & U2"),
            URLQueryItem(name: "artist", value: "Björk"),
            URLQueryItem(name: "space test", value: "value with spaces")
        ]
        let endpoint = TestEndpoint(query: queryItems)

        let request = try builder.makeRequest(endpoint)

        XCTAssertNotNil(request.url)
        let components = URLComponents(url: request.url!, resolvingAgainstBaseURL: false)!
        let resultQuery = components.queryItems!

        XCTAssertEqual(resultQuery.count, 3)
        XCTAssertTrue(resultQuery.contains(where: { $0.name == "term" && $0.value == "Green Day & U2" }))
    }

    func testMakeRequestWithNoHeaders() throws {
        let baseURL = createBaseURL()
        let builder = RequestBuilder(baseURL: baseURL)
        let endpoint = TestEndpoint(headers: [:])

        let request = try builder.makeRequest(endpoint)

        XCTAssertEqual(request.allHTTPHeaderFields?.count ?? 0, 0)
    }

    func testMakeRequestWithMultipleHeaders() throws {
        let baseURL = createBaseURL()
        let builder = RequestBuilder(baseURL: baseURL)
        let headers = [
            "Accept": "application/json",
            "User-Agent": "MusicPlayer/1.0",
            "Authorization": "Bearer token123"
        ]
        let endpoint = TestEndpoint(headers: headers)

        let request = try builder.makeRequest(endpoint)

        XCTAssertEqual(request.value(forHTTPHeaderField: "Accept"), "application/json")
        XCTAssertEqual(request.value(forHTTPHeaderField: "User-Agent"), "MusicPlayer/1.0")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "Bearer token123")
    }

    func testMakeRequestWithCustomContentType() throws {
        let baseURL = createBaseURL()
        let builder = RequestBuilder(baseURL: baseURL)
        let headers = ["Content-Type": "application/xml"]
        let body = "<xml>test</xml>".data(using: .utf8)
        let endpoint = TestEndpoint(method: .post, headers: headers, body: body)

        let request = try builder.makeRequest(endpoint)

        XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/xml")
    }

    func testMakeRequestWithGetMethodHasNoBody() throws {
        let baseURL = createBaseURL()
        let builder = RequestBuilder(baseURL: baseURL)
        let endpoint = TestEndpoint(method: .get, body: "test".data(using: .utf8))

        let request = try builder.makeRequest(endpoint)

        XCTAssertNil(request.httpBody)
    }

    func testMakeRequestWithPostMethodAndBody() throws {
        let baseURL = createBaseURL()
        let builder = RequestBuilder(baseURL: baseURL)
        let bodyData = """
        {"term": "test", "limit": 10}
        """.data(using: .utf8)!
        let endpoint = TestEndpoint(method: .post, body: bodyData)

        let request = try builder.makeRequest(endpoint)

        XCTAssertEqual(request.httpBody, bodyData)
        XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/json; charset=utf-8")
    }

    func testMakeRequestWithBodyButNoContentType() throws {
        let baseURL = createBaseURL()
        let builder = RequestBuilder(baseURL: baseURL)
        let bodyData = "test data".data(using: .utf8)!
        let endpoint = TestEndpoint(method: .post, headers: [:], body: bodyData)

        let request = try builder.makeRequest(endpoint)

        XCTAssertEqual(request.httpBody, bodyData)
        XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/json; charset=utf-8")
    }

    func testMakeRequestWithPutMethodAndBody() throws {
        let baseURL = createBaseURL()
        let builder = RequestBuilder(baseURL: baseURL)
        let bodyData = "updated data".data(using: .utf8)!
        let endpoint = TestEndpoint(method: .put, body: bodyData)

        let request = try builder.makeRequest(endpoint)

        XCTAssertEqual(request.httpBody, bodyData)
    }

    func testMakeRequestWithPatchMethodAndBody() throws {
        let baseURL = createBaseURL()
        let builder = RequestBuilder(baseURL: baseURL)
        let bodyData = "patch data".data(using: .utf8)!
        let endpoint = TestEndpoint(method: .patch, body: bodyData)

        let request = try builder.makeRequest(endpoint)

        XCTAssertEqual(request.httpBody, bodyData)
    }

    func testMakeRequestWithItunesSearchEndpoint() throws {
        let baseURL = createBaseURL()
        let builder = RequestBuilder(baseURL: baseURL)
        let searchEndpoint = ItunesSearchEndpoint(term: "jack johnson", limit: 25, offset: 0)

        let request = try builder.makeRequest(searchEndpoint)

        XCTAssertEqual(request.httpMethod, "GET")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Accept"), "application/json")
        XCTAssertNil(request.httpBody)

        let url = request.url!
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)!

        XCTAssertEqual(components.path, "/search")

        let queryItems = components.queryItems!
        XCTAssertTrue(queryItems.contains(URLQueryItem(name: "term", value: "jack johnson")))
        XCTAssertTrue(queryItems.contains(URLQueryItem(name: "limit", value: "25")))
        XCTAssertTrue(queryItems.contains(URLQueryItem(name: "offset", value: "0")))
    }

    func testMakeRequestWithItunesAlbumTracksEndpoint() throws {
        let baseURL = createBaseURL()
        let builder = RequestBuilder(baseURL: baseURL)
        let albumEndpoint = ItunesAlbumTracksEndpoint(collectionId: 1440857781)

        let request = try builder.makeRequest(albumEndpoint)

        XCTAssertEqual(request.httpMethod, "GET")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Accept"), "application/json")
        XCTAssertNil(request.httpBody)

        let url = request.url!
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)!

        XCTAssertEqual(components.path, "/lookup")

        let queryItems = components.queryItems!
        XCTAssertTrue(queryItems.contains(URLQueryItem(name: "id", value: "1440857781")))
        XCTAssertTrue(queryItems.contains(URLQueryItem(name: "entity", value: "song")))
        XCTAssertTrue(queryItems.contains(URLQueryItem(name: "media", value: "music")))
    }

    private func createTestEndpoint() -> TestEndpoint {
        return TestEndpoint()
    }

    private func createBaseURL() -> URL {
        return URL(string: "https://itunes.apple.com")!
    }

}
