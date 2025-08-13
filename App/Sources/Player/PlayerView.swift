import SwiftUI
import Data

struct PlayerView: View {
    @Environment(\.colorScheme) private var colorScheme

    @State private var audioManager = AudioPlayerManager()
    @State private var showOptionsSheet: Bool = false
    @State private var showAlbumSongList: Bool = false
    @State private var isUserDraggingSlider = false
    @State private var currentSliderValue: Double = 0

    let track: Track

    var songTitle: String {
        track.title
    }

    var artistName: String {
        track.artist
    }

    init(track: Track) {
        self.track = track
    }

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
//              AlbumSongListView(albumTitle: "Album")
//                .presentationDetents([.large])
//                 .presentationDragIndicator(.visible)
        }
        .onAppear {
            guard let previewURL = track.previewURL else { return }
            audioManager.loadTrack(url: previewURL)
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
        AsyncImage(url: track.artworkURL) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
        } placeholder: {
            RoundedRectangle(cornerRadius: 36, style: .continuous)
                .fill(Color(.white).opacity(0.1))
                .overlay(
                    Image(.iconMusicNoteBig)
                        .renderingMode(.template)
                        .foregroundStyle(Color(.white))
                )
        }
        .frame(width: 200, height: 200)
        .clipShape(RoundedRectangle(cornerRadius: 36, style: .continuous))
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
            Slider(
                value: Binding(
                    get: {
                        isUserDraggingSlider ? currentSliderValue : audioManager.currentTime
                    },
                    set: { newValue in
                        currentSliderValue = newValue
                    }
                ),
                in: 0...max(audioManager.duration, 1),
                onEditingChanged: { editing in
                    if editing {
                        isUserDraggingSlider = true
                    } else {
                        audioManager.seek(to: currentSliderValue)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            isUserDraggingSlider = false
                        }
                    }
                }
            )
            .tint(Color(.white))

            HStack {
                Text(formattedTime(isUserDraggingSlider ? currentSliderValue : audioManager.currentTime))
                    .font(.system(size: 14, weight: .medium))
                Spacer()
                Text("-" + formattedTime(max(audioManager.duration - (isUserDraggingSlider ? currentSliderValue : audioManager.currentTime), 0)))
                    .font(.system(size: 14, weight: .regular))
            }.foregroundStyle(Color(.gray200))
        }
    }

    private var playbackControlsView: some View {
        HStack(spacing: 28) {
            Button(action: {
                audioManager.seek(to: max(audioManager.currentTime - 15, 0))
            }) {
                Image(systemName: SFSymbols.backward)
                    .font(.title)
            }

            Button(action: {
                if audioManager.isPlaying {
                    audioManager.pause()
                } else {
                    audioManager.play()
                }
            }) {
                Circle()
                    .fill(Color(.white))
                    .frame(width: 64, height: 64)
                    .overlay(
                        Image(systemName: audioManager.isPlaying ? SFSymbols.pause : SFSymbols.play)
                            .foregroundStyle(Color(.black))
                            .font(.title2.weight(.bold))
                    )
            }
            .disabled(audioManager.isLoading)

            Button(action: {
                audioManager.seek(to: min(audioManager.currentTime + 15, audioManager.duration))
            }) {
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
    PlayerView(track: .preview)
        .preferredColorScheme(.dark)
}

#Preview("Light") {
    PlayerView(track: .preview)
        .preferredColorScheme(.light)
}
