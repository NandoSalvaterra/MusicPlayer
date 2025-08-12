import SwiftUI

struct SongListView: View {
    let songs = Array(repeating: (title: "Something", artist: "Artist"), count: 20)
    @State private var searchText = ""
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        List {
            ForEach(songs.indices, id: \.self) { index in
                SongRow(title: songs[index].title, artist: songs[index].artist)
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
