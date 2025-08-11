import Foundation

public struct ItunesSearchEndpoint: Endpoint {
    public typealias Response = ItunesSearchResponseDTO

    public let path: String = "search"
    public let method: HTTPMethod = .get
    public let query: [URLQueryItem]
    public let headers: [String : String] = ["Accept": "application/json"]
    public let body: Data? = nil


    public init(term: String, limit: Int = 20, offset: Int = 0, country: String = "BR") {
        self.query = [
            .init(name: "term", value: term),
            .init(name: "entity", value: "song"),
            .init(name: "media", value: "music"),
            .init(name: "limit", value: String(limit)),
            .init(name: "offset", value: String(offset)),
            .init(name: "country", value: country)
        ]
    }
}
