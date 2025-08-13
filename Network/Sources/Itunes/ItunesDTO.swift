import Foundation

public enum ItunesWrapperType: String, Decodable, Sendable {
    case collection = "collection"
    case track = "track"
}

public struct ItunesSearchResponseDTO: Decodable, Sendable {
    public let resultCount: Int
    public let results: [ItunesTrackDTO]
}

public struct ItunesTrackDTO: Decodable, Sendable {
    public let trackId: Int?
    public let trackName: String?
    public let artistName: String?
    public let collectionName: String?
    public let previewUrl: URL?
    public let artworkUrl100: URL?
    public let collectionId: Int?
    public let trackTimeMillis: Int?
    public let trackNumber: Int?
    public let discNumber: Int?
    public let trackCount: Int?
    public let discCount: Int?
    public let releaseDate: String?
    public let primaryGenreName: String?
    public let wrapperType: ItunesWrapperType
}
