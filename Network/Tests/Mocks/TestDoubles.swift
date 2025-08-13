import Foundation
@testable import Network

struct TestEndpoint: Endpoint {
    typealias Response = TestResponse

    let path: String
    let method: HTTPMethod
    let query: [URLQueryItem]
    let headers: [String: String]
    let body: Data?

    init(
        path: String = "search",
        method: HTTPMethod = .get,
        query: [URLQueryItem] = [URLQueryItem(name: "term", value: "test")],
        headers: [String: String] = ["Accept": "application/json"],
        body: Data? = nil
    ) {
        self.path = path
        self.method = method
        self.query = query
        self.headers = headers
        self.body = body
    }
}

struct TestResponse: Decodable, Sendable {
    let message: String
    let count: Int?

    init(message: String, count: Int? = nil) {
        self.message = message
        self.count = count
    }
}

enum TestDataFactory {

    static func createItunesSearchResponse(resultCount: Int = 1) -> Data {
        let trackData = (0..<resultCount).map { index in
            """
            {
                "wrapperType": "track",
                "trackId": \(1000 + index),
                "trackName": "Test Song \(index + 1)",
                "artistName": "Test Artist",
                "collectionName": "Test Album",
                "trackTimeMillis": 180000,
                "trackNumber": \(index + 1),
                "discNumber": 1
            }
            """
        }.joined(separator: ",")

        let json = """
        {
            "resultCount": \(resultCount),
            "results": [\(trackData)]
        }
        """
        return json.data(using: .utf8)!
    }

    static func createItunesAlbumResponse(trackCount: Int = 3) -> Data {
        let collection = """
        {
            "wrapperType": "collection",
            "artistName": "Test Artist",
            "collectionName": "Test Album",
            "collectionId": 123456789,
            "trackCount": \(trackCount),
            "discCount": 1,
            "releaseDate": "2023-01-01T00:00:00Z",
            "primaryGenreName": "Rock"
        }
        """

        let tracks = (1...trackCount).map { index in
            """
            {
                "wrapperType": "track",
                "trackId": \(2000 + index),
                "trackName": "Track \(index)",
                "artistName": "Test Artist",
                "collectionName": "Test Album",
                "collectionId": 123456789,
                "trackTimeMillis": 180000,
                "trackNumber": \(index),
                "discNumber": 1
            }
            """
        }.joined(separator: ",")

        let json = """
        {
            "resultCount": \(trackCount + 1),
            "results": [\(collection),\(tracks)]
        }
        """
        return json.data(using: .utf8)!
    }

    static func createInvalidJSON() -> Data {
        return "{ invalid json data }".data(using: .utf8)!
    }

    static func createEmptyResponse() -> Data {
        let json = """
        {
            "resultCount": 0,
            "results": []
        }
        """
        return json.data(using: .utf8)!
    }

    static func createTestResponse(message: String = "success", count: Int? = nil) -> Data {
        let countJson = count.map { ", \"count\": \($0)" } ?? ""
        let json = """
        {
            "message": "\(message)"\(countJson)
        }
        """
        return json.data(using: .utf8)!
    }

    static func createLargeResponse(itemCount: Int = 1000) -> Data {
        let items = (0..<itemCount).map { index in
            """
            {
                "wrapperType": "track",
                "trackId": \(index),
                "trackName": "Song \(index)",
                "artistName": "Artist \(index % 10)"
            }
            """
        }.joined(separator: ",")

        let json = """
        {
            "resultCount": \(itemCount),
            "results": [\(items)]
        }
        """
        return json.data(using: .utf8)!
    }
}

extension URLRequest {

    static func testRequest(
        url: String = "https://itunes.apple.com/search?term=test",
        method: String = "GET",
        headers: [String: String] = ["Accept": "application/json"]
    ) -> URLRequest {
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = method
        headers.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }
        return request
    }
}

extension HTTPURLResponse {

    static func testResponse(
        url: String = "https://itunes.apple.com/search",
        statusCode: Int = 200,
        headers: [String: String]? = ["Content-Type": "application/json"]
    ) -> HTTPURLResponse {
        return HTTPURLResponse(
            url: URL(string: url)!,
            statusCode: statusCode,
            httpVersion: "HTTP/1.1",
            headerFields: headers
        )!
    }
}
