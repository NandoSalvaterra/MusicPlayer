import Foundation
import Network

public enum AlbumMapper {
    public static func map(_ dto: ItunesTrackDTO) throws(DataError) -> Album {
        guard dto.wrapperType == .collection else {
            throw .mappingFailed("Not a collection type")
        }
        
        guard let collectionId = dto.collectionId,
              let collectionName = dto.collectionName,
              let artistName = dto.artistName else {
            throw .mappingFailed("Missing required album fields")
        }
        
        let releaseDate: Date? = {
            guard let releaseDateString = dto.releaseDate else { return nil }
            let formatter = ISO8601DateFormatter()
            return formatter.date(from: releaseDateString)
        }()
        
        return Album(
            id: collectionId,
            name: collectionName,
            artist: artistName,
            artworkURL: dto.artworkUrl100,
            trackCount: dto.trackCount,
            discCount: dto.discCount,
            releaseDate: releaseDate,
            genre: dto.primaryGenreName
        )
    }
    
    public static func mapAlbums(_ dtos: [ItunesTrackDTO]) -> [Album] {
        return dtos.compactMap { dto in
            try? map(dto)
        }
    }
    
    public static func mapResponse(_ response: ItunesSearchResponseDTO) -> [Album] {
        let albumDTOs = response.results.filter { $0.wrapperType == .collection }
        return mapAlbums(albumDTOs)
    }
}
