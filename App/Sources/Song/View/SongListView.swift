import SwiftUI
import Data

struct SongListView: View {
    @State private var viewModel = SongListViewModel()
    @State private var selectedTrack: Track?
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        List {
            ForEach(viewModel.tracks) { track in
                SongRow(track: track)
                    .onTapGesture { selectedTrack = track }
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color(.black))
            }
        }
        .listStyle(.plain)
        .background(Color(.black))
        .scrollContentBackground(.hidden)
        .navigationTitle(LocalizedStrings.songs)
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(Color(.black), for: .navigationBar)
        .toolbarColorScheme(colorScheme, for: .navigationBar)
        .searchable(text: $viewModel.searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: LocalizedStrings.search)
        .onSubmit(of: .search) {
            Task {
                await viewModel.search(query: viewModel.searchText)
            }
        }
        .scrollDismissesKeyboard(.immediately)
        .navigationDestination(item: $selectedTrack) { track in
            PlayerView(track: track)
        }
        .task {
            await viewModel.loadInitialData()
        }
        .refreshable {
            await viewModel.refresh()
        }
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
                    await viewModel.refresh()
                }
            },
            secondaryButtonTitle: LocalizedStrings.cancel
        )
    }
}

#Preview("Light") {
    NavigationStack {
        SongListView()
    }.preferredColorScheme(.light)
}

#Preview("Dark") {
    NavigationStack {
        SongListView()
    }.preferredColorScheme(.dark)
}
