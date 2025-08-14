import SwiftUI
import Data

struct SongListView: View {
    @State private var viewModel = SongListViewModel()
    @State private var selectedTrack: Track?
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: 0) {
            List {
            ForEach(viewModel.tracks) { track in
                SongRow(track: track)
                    .onTapGesture { selectedTrack = track }
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color(.black))
                    .onAppear {
                        let totalCount = viewModel.tracks.count
                        if let currentIndex = viewModel.tracks.firstIndex(of: track),
                           currentIndex >= totalCount - 3, // Trigger on last 3 items
                           !viewModel.isLoadingMorePages && !viewModel.isLoading {
                            Task {
                                await viewModel.loadMoreIfNeeded()
                            }
                        }
                    }
            }

            if viewModel.isLoadingMorePages {
                HStack(spacing: 12) {
                    Spacer()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.0)
                    Text(LocalizedStrings.loadingSongs)
                        .foregroundColor(.white)
                        .font(.system(size: 14, weight: .medium))
                    Spacer()
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color(.black))
                .padding(.vertical, 16)
            }
            }
            .listStyle(.plain)
            .background(Color(.black))
            .scrollContentBackground(.hidden)
            .searchable(text: $viewModel.searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: LocalizedStrings.search)
            .onSubmit(of: .search) {
                guard !viewModel.isLoadingMorePages else { return }
                Task {
                    await viewModel.search(query: viewModel.searchText)
                }
            }
            .scrollDismissesKeyboard(.immediately)
            .task {
                // Load initial data with Nirvana search on app start
                guard viewModel.tracks.isEmpty else { return }
                await viewModel.search(query: "Nirvana")
            }
            .refreshable {
                guard !viewModel.isLoadingMorePages else {
                    return
                }
                await viewModel.refresh()
            }
            .overlay {
                LoadingOverlay(
                    isVisible: viewModel.isLoading && viewModel.tracks.isEmpty,
                    message: LocalizedStrings.loadingSongs
                )
            }
            
            MiniPlayerView()
        }
        .navigationTitle(LocalizedStrings.songs)
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(Color(.black), for: .navigationBar)
        .toolbarColorScheme(colorScheme, for: .navigationBar)
        .navigationDestination(item: $selectedTrack) { track in
            PlayerView(track: track)
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
