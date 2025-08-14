import Foundation
import Data

@Observable
@MainActor
final class AlbumSongListViewModel {
    var tracks: [Track] = []
    var isLoading = false
    var errorMessage: String?
    
    private let repository: MusicRepositoryProtocol
    private var currentTask: Task<Void, Never>?
    
    init(repository: MusicRepositoryProtocol = MusicRepository()) {
        self.repository = repository
    }
    
    func loadAlbumTracks(albumId: Int?) async {
        guard let albumId = albumId else { return }
        currentTask?.cancel()

        guard !isLoading else { return }
        
        currentTask = Task {
            await performLoadAlbumTracks(albumId: albumId)
        }
        
        await currentTask?.value
    }
    
    private func performLoadAlbumTracks(albumId: Int) async {
        isLoading = true
        errorMessage = nil
        
        do {
            tracks = try await repository.getAlbumTracks(albumId: albumId)
        } catch {
            if !Task.isCancelled {
                if let urlError = error as? URLError, urlError.code == .cancelled {

                } else {
                    errorMessage = error.localizedDescription
                }
            }
        }

        if !Task.isCancelled {
            isLoading = false
        }
    }
    
    func cancelCurrentRequest() {
        currentTask?.cancel()
        currentTask = nil
        isLoading = false
    }
}
