import Foundation
import Network

public enum TrackMapper {
    public static func map(_ dto: ItunesTrackDTO) throws(DataError) -> Track {
        guard dto.wrapperType == .track else {
            throw .mappingFailed("Not a track type")
        }
        
        guard let trackId = dto.trackId,
              let trackName = dto.trackName,
              let artistName = dto.artistName else {
            throw .mappingFailed("Missing required track fields")
        }
        
        let duration: TimeInterval? = {
            guard let timeMillis = dto.trackTimeMillis else { return nil }
            return TimeInterval(timeMillis) / 1000.0
        }()
        
        return Track(
            id: trackId,
            title: trackName,
            artist: artistName,
            album: dto.collectionName,
            albumId: dto.collectionId,
            duration: duration,
            trackNumber: dto.trackNumber,
            discNumber: dto.discNumber,
            artworkURL: dto.artworkUrl100,
            previewURL: dto.previewUrl,
            genre: dto.primaryGenreName
        )
    }
    
    public static func mapTracks(_ dtos: [ItunesTrackDTO]) -> [Track] {
        return dtos.compactMap { dto in
            try? map(dto)
        }
    }
    
    public static func mapResponse(_ response: ItunesSearchResponseDTO) -> [Track] {
        let trackDTOs = response.results.filter { $0.wrapperType == .track }
        return mapTracks(trackDTOs)
    }
}
