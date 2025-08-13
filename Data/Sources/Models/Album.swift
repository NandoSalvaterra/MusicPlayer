import Foundation

public struct Album: Identifiable, Sendable, Hashable {
    public let id: Int
    public let name: String
    public let artist: String
    public let artworkURL: URL?
    public let trackCount: Int?
    public let discCount: Int?
    public let releaseDate: Date?
    public let genre: String?
    
    public init(
        id: Int,
        name: String,
        artist: String,
        artworkURL: URL? = nil,
        trackCount: Int? = nil,
        discCount: Int? = nil,
        releaseDate: Date? = nil,
        genre: String? = nil
    ) {
        self.id = id
        self.name = name
        self.artist = artist
        self.artworkURL = artworkURL
        self.trackCount = trackCount
        self.discCount = discCount
        self.releaseDate = releaseDate
        self.genre = genre
    }
}

public extension Album {
    var hasMultipleDiscs: Bool {
        guard let discCount = discCount else { return false }
        return discCount > 1
    }
    
    var formattedTrackCount: String? {
        guard let trackCount = trackCount else { return nil }
        return trackCount == 1 ? "1 track" : "\(trackCount) tracks"
    }
}