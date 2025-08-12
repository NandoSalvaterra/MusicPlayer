import SwiftUI

struct AlbumSongListView: View {

    let albumTitle: String
    let songs: [Song] = (0..<15).map { index in Song(title: "Song \(index + 1)", artist: "Artist") }

    @State private var selectedSong: Song? = nil
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack {
            Text(albumTitle)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(Color(.white))
                .padding(.top, 26)

            List {
                ForEach(songs) { song in
                    SongRow(title: song.title, artist: song.artist)
                        .onTapGesture { selectedSong = song }
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color(.black))
                }
            }
            .background(Color(.black))
            .scrollContentBackground(.hidden)
            .listStyle(.plain)
        }.background(Color(.black))
    }
}

#Preview("Dark") {
    AlbumSongListView(albumTitle: "Album Title")
        .preferredColorScheme(.dark)
}

#Preview("Light") {
    AlbumSongListView(albumTitle: "Album Title")
        .preferredColorScheme(.light)
}
