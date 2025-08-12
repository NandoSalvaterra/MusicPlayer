import SwiftUI

struct Song: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let artist: String
}

struct SongListView: View {
    let songs: [Song] = (0..<20).map { _ in Song(title: "Something", artist: "Artist") }

    @State private var searchText = ""
    @State private var selectedSong: Song? = nil
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        List {
            ForEach(songs) { song in
                SongRow(title: song.title, artist: song.artist)
                    .onTapGesture { selectedSong = song }
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
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: LocalizedStrings.search)
        .scrollDismissesKeyboard(.immediately)
        .navigationDestination(item: $selectedSong) { song in
            PlayerView(title: song.title, artist: song.artist)
        }
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
