import Foundation

public struct Track: Identifiable, Sendable, Hashable {
    public let id: Int
    public let title: String
    public let artist: String
    public let album: String?
    public let albumId: Int?
    public let duration: TimeInterval?
    public let trackNumber: Int?
    public let discNumber: Int?
    public let artworkURL: URL?
    public let previewURL: URL?
    public let genre: String?
    
    public init(
        id: Int,
        title: String,
        artist: String,
        album: String? = nil,
        albumId: Int? = nil,
        duration: TimeInterval? = nil,
        trackNumber: Int? = nil,
        discNumber: Int? = nil,
        artworkURL: URL? = nil,
        previewURL: URL? = nil,
        genre: String? = nil
    ) {
        self.id = id
        self.title = title
        self.artist = artist
        self.album = album
        self.albumId = albumId
        self.duration = duration
        self.trackNumber = trackNumber
        self.discNumber = discNumber
        self.artworkURL = artworkURL
        self.previewURL = previewURL
        self.genre = genre
    }
}

public extension Track {
    var formattedDuration: String? {
        guard let duration = duration else { return nil }
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    var hasPreview: Bool {
        previewURL != nil
    }
}