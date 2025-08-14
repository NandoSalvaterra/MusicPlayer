import SwiftUI
import Data

struct AlbumSongListView: View {
    let track: Track
    let onTrackSelected: (Track) -> Void
    @State private var viewModel = AlbumSongListViewModel()
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack {
            Text(track.album ?? "")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(Color(.white))
                .padding(.top, 26)

            List {
                ForEach(viewModel.tracks) { track in
                    SongRow(track: track)
                        .onTapGesture { 
                            onTrackSelected(track)
                            dismiss()
                        }
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color(.black))
                }
            }
            .background(Color(.black))
            .scrollContentBackground(.hidden)
            .listStyle(.plain)
        }
        .background(Color(.black))
        .overlay {
            LoadingOverlay(
                isVisible: viewModel.isLoading && viewModel.tracks.isEmpty,
                message: LocalizedStrings.loadingSongs
            )
        }
        .errorAlert(
            errorMessage: $viewModel.errorMessage,
            title: LocalizedStrings.unableToLoadSongs,
            primaryButtonTitle: LocalizedStrings.tryAgain,
            primaryAction: {
                Task {
                    await viewModel.loadAlbumTracks(albumId: track.albumId)
                }
            },
            secondaryButtonTitle: LocalizedStrings.cancel
        )
        .task(id: track.albumId) {
            await viewModel.loadAlbumTracks(albumId: track.albumId)
        }
        .onDisappear {
            viewModel.cancelCurrentRequest()
        }
    }
}

#Preview("Dark") {
    NavigationStack {
        AlbumSongListView(track: Track.preview) { track in
            print("Selected track: \(track.title)")
        }
    }
    .preferredColorScheme(.dark)
}

#Preview("Light") {
    NavigationStack {
        AlbumSongListView(track: Track.preview) { track in
            print("Selected track: \(track.title)")
        }
    }
    .preferredColorScheme(.light)
}
