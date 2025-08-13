import Foundation
import Data

@Observable
@MainActor
final class SongListViewModel {

    var tracks: [Track] = []
    var isLoading = false
    var errorMessage: String?
    var searchText = ""

    private let defaultSearchQuery = "Nirvana"
    private let repository: MusicRepositoryProtocol

    init(repository: MusicRepositoryProtocol = MusicRepository()) {
        self.repository = repository
    }
    
    func loadInitialData() async {
        guard tracks.isEmpty else { return }
        await search(query: defaultSearchQuery)
    }
    
    func refresh() async {
        let query = searchText.isEmpty ? defaultSearchQuery : searchText
        await search(query: query)
    }
    
    func search(query: String) async {
        guard !query.isEmpty else { return }
        
        isLoading = true
        errorMessage = nil
        do {
            let result = try await repository.searchTracks(
                query: query,
                limit: 50,
                offset: 0
            )
            
            tracks = result.tracks
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }
}
