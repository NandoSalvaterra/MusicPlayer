import Foundation
import Data

@Observable
@MainActor
final class SongListViewModel {

    var tracks: [Track] = []
    var isLoading = false
    var isLoadingMorePages = false
    var errorMessage: String?
    var searchText = ""
    var hasMoreResults = false

    private let repository: MusicRepositoryProtocol
    private var lastPaginationOffset = -1
    private var currentQuery = ""
    private var currentOffset = 0
    private let pageSize = 20

    init(repository: MusicRepositoryProtocol = MusicRepository()) {
        self.repository = repository
    }
    
    func refresh() async {
        let query = searchText.isEmpty ? "Nirvana" : searchText
        await search(query: query)
    }
    
    func search(query: String) async {
        guard !query.isEmpty else { return }

        currentQuery = query
        currentOffset = 0
        lastPaginationOffset = -1
        tracks.removeAll()
        
        await performSearch(isNewSearch: true)
    }
    
    func loadMoreIfNeeded() async {
        guard !isLoading && !isLoadingMorePages else { return }

        guard hasMoreResults else { return }

        guard currentOffset != lastPaginationOffset else { return }

        lastPaginationOffset = currentOffset
        await performSearch(isNewSearch: false)
    }
    
    private func performSearch(isNewSearch: Bool) async {
        if isNewSearch {
            isLoading = true
        } else {
            isLoadingMorePages = true
        }
        
        errorMessage = nil
        
        do {
            let result = try await repository.searchTracks(
                query: currentQuery,
                limit: pageSize,
                offset: currentOffset
            )

            let receivedTracksCount = result.tracks.count
            
            if isNewSearch {
                tracks = result.tracks
            } else {
                // Filter out duplicates before appending, itunes api bug for long lists
                let existingTrackIds = Set(tracks.map { $0.id })
                let newTracks = result.tracks.filter { !existingTrackIds.contains($0.id) }
                tracks.append(contentsOf: newTracks)
            }
            
            let hasResults = receivedTracksCount > 0

            let minimumThreshold = max(1, pageSize / 2)
            hasMoreResults = hasResults && receivedTracksCount >= minimumThreshold

            if !isNewSearch {
                currentOffset += receivedTracksCount
            }
            
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
        isLoadingMorePages = false
    }
}
