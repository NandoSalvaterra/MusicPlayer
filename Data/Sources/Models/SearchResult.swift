import Foundation

public struct SearchResult: Sendable {
    public let tracks: [Track]
    public let albums: [Album]
    public let totalCount: Int
    public let hasMoreResults: Bool
    
    public init(
        tracks: [Track] = [],
        albums: [Album] = [],
        totalCount: Int = 0,
        hasMoreResults: Bool = false
    ) {
        self.tracks = tracks
        self.albums = albums
        self.totalCount = totalCount
        self.hasMoreResults = hasMoreResults
    }
}

public extension SearchResult {
    var isEmpty: Bool {
        tracks.isEmpty && albums.isEmpty
    }
    
    var allItems: [any Identifiable] {
        var items: [any Identifiable] = []
        items.append(contentsOf: tracks)
        items.append(contentsOf: albums)
        return items
    }
}