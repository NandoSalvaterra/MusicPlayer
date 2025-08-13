import Foundation
@testable import Data
@testable import Network

public struct TestDataFactory {

    public static func createTrackDTO(
        id: Int = 123,
        name: String = "Test Song",
        artist: String = "Test Artist",
        album: String? = "Test Album",
        trackNumber: Int? = 1,
        discNumber: Int? = 1,
        duration: Int? = 240000
    ) -> ItunesTrackDTO {
        return ItunesTrackDTO(
            trackId: id,
            trackName: name,
            artistName: artist,
            collectionName: album,
            previewUrl: URL(string: "https://example.com/preview.mp3"),
            artworkUrl100: URL(string: "https://example.com/artwork.jpg"),
            collectionId: 456,
            trackTimeMillis: duration,
            trackNumber: trackNumber,
            discNumber: discNumber,
            trackCount: 10,
            discCount: 1,
            releaseDate: "2023-01-01T00:00:00Z",
            primaryGenreName: "Rock",
            wrapperType: .track
        )
    }
    
    public static func createAlbumDTO(
        id: Int = 456,
        name: String = "Test Album",
        artist: String = "Test Artist"
    ) -> ItunesTrackDTO {
        return ItunesTrackDTO(
            trackId: nil,
            trackName: nil,
            artistName: artist,
            collectionName: name,
            previewUrl: nil,
            artworkUrl100: URL(string: "https://example.com/album-artwork.jpg"),
            collectionId: id,
            trackTimeMillis: nil,
            trackNumber: nil,
            discNumber: nil,
            trackCount: 12,
            discCount: 1,
            releaseDate: "2023-01-01T00:00:00Z",
            primaryGenreName: "Rock",
            wrapperType: .collection
        )
    }

    public static func createSearchResponse(
        tracks: [ItunesTrackDTO] = [],
        albums: [ItunesTrackDTO] = []
    ) -> ItunesSearchResponseDTO {
        let allResults = tracks + albums
        return ItunesSearchResponseDTO(
            resultCount: allResults.count,
            results: allResults
        )
    }
    
    public static func createAlbumTracksResponse(
        albumDTO: ItunesTrackDTO? = nil,
        tracks: [ItunesTrackDTO] = []
    ) -> ItunesSearchResponseDTO {
        var results: [ItunesTrackDTO] = []

        if let album = albumDTO {
            results.append(album)
        }

        results.append(contentsOf: tracks)
        
        return ItunesSearchResponseDTO(
            resultCount: results.count,
            results: results
        )
    }
    
    public static func createMultiDiscAlbum() -> ItunesSearchResponseDTO {
        let albumDTO = createAlbumDTO(name: "Multi-Disc Album")
        
        let disc1Tracks = [
            createTrackDTO(id: 1, name: "Song 1", trackNumber: 1, discNumber: 1),
            createTrackDTO(id: 2, name: "Song 2", trackNumber: 2, discNumber: 1),
            createTrackDTO(id: 3, name: "Song 3", trackNumber: 3, discNumber: 1)
        ]
        
        let disc2Tracks = [
            createTrackDTO(id: 4, name: "Song 4", trackNumber: 1, discNumber: 2),
            createTrackDTO(id: 5, name: "Song 5", trackNumber: 2, discNumber: 2)
        ]
        
        return createAlbumTracksResponse(
            albumDTO: albumDTO,
            tracks: disc1Tracks + disc2Tracks
        )
    }
    
    public static func createMixedSearchResults() -> ItunesSearchResponseDTO {
        let tracks = [
            createTrackDTO(id: 1, name: "Track 1"),
            createTrackDTO(id: 2, name: "Track 2")
        ]
        
        let albums = [
            createAlbumDTO(id: 100, name: "Album 1"),
            createAlbumDTO(id: 101, name: "Album 2")
        ]
        
        return createSearchResponse(tracks: tracks, albums: albums)
    }
}
