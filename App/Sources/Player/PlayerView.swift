import SwiftUI

struct PlayerView: View {
    @Environment(\.colorScheme) private var colorScheme

    var songTitle: String = "Something"
    var artistName: String = "Artist"

    @State private var isPlaying: Bool = false
    @State private var currentTime: Double = 0
    @State private var totalDuration: Double = 200
    @State private var showOptionsSheet: Bool = false
    @State private var showAlbumSongList: Bool = false

    var body: some View {
            VStack(spacing: 0) {
                Spacer(minLength: 24)

                albumArtworkView
                    .padding(.bottom, 32)

                Spacer()

                songInfoView
                    .padding(.horizontal, 20)
                    .padding(.bottom, 12)

                timelineView
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)

                playbackControlsView
                    .padding(.bottom, 22)
            }.background(
                Color(.black)
                    .ignoresSafeArea(edges: .all)
            )
            .sheet(isPresented: $showOptionsSheet) {
                SongOptionsSheet(title: songTitle, artist: artistName) {
                    showOptionsSheet = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        showAlbumSongList = true
                    }
                }
            }
            .sheet(isPresented: $showAlbumSongList) {
                AlbumSongListView(albumTitle: "Album", artistName: artistName)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showOptionsSheet = true }) {
                    Image(systemName: SFSymbols.ellipsis)
                        .rotationEffect(.degrees(90))
                        .font(.title2)
                }
            }
        }
    }

    private var albumArtworkView: some View {
        RoundedRectangle(cornerRadius: 36, style: .continuous)
            .fill(Color(.white).opacity(0.1))
            .frame(width: 200, height: 200)
            .overlay(
                Image(.iconMusicNoteBig)
                    .renderingMode(.template)
                    .foregroundStyle(Color(.white))
            )
    }

    private var songInfoView: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(songTitle)
                .font(.system(size: 24, weight: .regular))
                .foregroundStyle(Color(.white))
            Text(artistName)
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(Color(.gray200))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var timelineView: some View {
        VStack(spacing: 8) {
            Slider(value: $currentTime, in: 0...max(totalDuration, 1))
                .tint(Color(.white))
            HStack {
                Text(formattedTime(currentTime))
                    .font(.system(size: 14, weight: .medium))
                Spacer()
                Text("-" + formattedTime(max(totalDuration - currentTime, 0)))
                    .font(.system(size: 14, weight: .regular))
            }.foregroundStyle(Color(.gray200))
        }
    }

    private var playbackControlsView: some View {
        HStack(spacing: 28) {
            Button(action: { currentTime = max(currentTime - 15, 0) }) {
                Image(systemName: SFSymbols.backward)
                    .font(.title)
            }

            Button(action: { isPlaying.toggle() }) {
                ZStack {
                    Circle()
                        .fill(Color(.white))
                        .frame(width: 64, height: 64)

                    Image(systemName: isPlaying ? SFSymbols.pause : SFSymbols.play)
                        .foregroundStyle(Color(.black))
                        .font(.title2.weight(.bold))
                }
            }

            Button(action: { currentTime = min(currentTime + 15, totalDuration) }) {
                Image(systemName: SFSymbols.forward)
                    .font(.title)
            }
        }
        .buttonStyle(.plain)
    }

    private func formattedTime(_ seconds: Double) -> String {
        let total = Int(seconds.rounded())
        return String(format: "%d:%02d", total/60, total%60)
    }
}

#Preview("Dark") {
    PlayerView()
        .preferredColorScheme(.dark)
}

#Preview("Light") {
    PlayerView()
        .preferredColorScheme(.light)
}
