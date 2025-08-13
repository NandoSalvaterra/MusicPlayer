import Foundation
import Network

public enum SearchMapper {
    public static func mapSearchResult(_ response: ItunesSearchResponseDTO) -> SearchResult {
        let tracks = TrackMapper.mapResponse(response)
        let albums = AlbumMapper.mapResponse(response)
        
        return SearchResult(
            tracks: tracks,
            albums: albums,
            totalCount: response.resultCount,
            hasMoreResults: response.resultCount > (tracks.count + albums.count)
        )
    }
    
    public static func mapTracksOnly(_ response: ItunesSearchResponseDTO) -> [Track] {
        return TrackMapper.mapResponse(response)
    }
    
    public static func mapAlbumsOnly(_ response: ItunesSearchResponseDTO) -> [Album] {
        return AlbumMapper.mapResponse(response)
    }
}