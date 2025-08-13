import Foundation

public protocol MusicRepositoryProtocol: Sendable {
    func searchTracks(
        query: String,
        limit: Int,
        offset: Int
    ) async throws(DataError) -> SearchResult
    
    func getAlbumTracks(albumId: Int) async throws(DataError) -> [Track]
}