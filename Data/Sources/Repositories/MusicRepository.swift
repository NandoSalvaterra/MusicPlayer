import Foundation
import Network

public final class MusicRepository: MusicRepositoryProtocol {
    private let httpClient: HTTPClient
    private let requestBuilder: RequestBuilder
    
    public init(
        httpClient: HTTPClient? = nil,
        baseURL: URL = URL(string: "https://itunes.apple.com/")!
    ) {
        self.httpClient = httpClient ?? URLSessionClient(networkMonitor: NetworkMonitor())
        self.requestBuilder = RequestBuilder(baseURL: baseURL)
    }
    
    public func searchTracks(
        query: String,
        limit: Int = 50,
        offset: Int = 0
    ) async throws(DataError) -> SearchResult {
        do {
            let endpoint = ItunesSearchEndpoint(
                term: query,
                limit: limit,
                offset: offset
            )
            let request = try requestBuilder.makeRequest(endpoint)
            let response: ItunesSearchResponseDTO = try await httpClient.send(request)
            
            return SearchMapper.mapSearchResult(response)
        } catch let networkError as NetworkError {
            throw .map(from: networkError)
        } catch {
            throw .unknown(error)
        }
    }
    
    public func getAlbumTracks(albumId: Int) async throws(DataError) -> [Track] {
        do {
            let endpoint = ItunesAlbumTracksEndpoint(collectionId: albumId)
            let request = try requestBuilder.makeRequest(endpoint)
            let response: ItunesSearchResponseDTO = try await httpClient.send(request)
            
            let tracks = TrackMapper.mapResponse(response)
            return tracks.sorted { lhs, rhs in
                if let lhsDisc = lhs.discNumber, let rhsDisc = rhs.discNumber {
                    if lhsDisc != rhsDisc {
                        return lhsDisc < rhsDisc
                    }
                }
                if let lhsTrack = lhs.trackNumber, let rhsTrack = rhs.trackNumber {
                    return lhsTrack < rhsTrack
                }
                return false
            }
        } catch let networkError as NetworkError {
            throw .map(from: networkError)
        } catch {
            throw .unknown(error)
        }
    }
}
