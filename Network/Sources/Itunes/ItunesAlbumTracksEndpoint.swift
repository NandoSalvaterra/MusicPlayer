import Foundation

public struct ItunesAlbumTracksEndpoint: Endpoint {
    public typealias Response = ItunesSearchResponseDTO

    public let path: String = "lookup"
    public let method: HTTPMethod = .get
    public let query: [URLQueryItem]
    public let headers: [String : String] = ["Accept": "application/json"]
    public let body: Data? = nil

    public init(collectionId: Int) {
        self.query = [
            .init(name: "id", value: String(collectionId)),
            .init(name: "entity", value: "song"),
            .init(name: "media", value: "music"),
        ]
    }
}
