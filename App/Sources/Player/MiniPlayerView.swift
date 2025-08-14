import SwiftUI
import Data

struct MiniPlayerView: View {
    private let audioManager = GlobalAudioManager.shared
    
    var body: some View {
        if let currentTrack = audioManager.currentTrack {
            VStack(spacing: 0) {
                ProgressView(value: audioManager.currentTime, total: max(audioManager.duration, 1))
                    .progressViewStyle(LinearProgressViewStyle(tint: Color(.white)))
                    .scaleEffect(y: 0.5)
                
                HStack(spacing: 12) {
                    AsyncImage(url: currentTrack.artworkURL) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(.white).opacity(0.1))
                            .overlay(
                                Image(.iconMusicNote)
                                    .foregroundColor(Color(.white))
                                    .font(.title2)
                            )
                    }
                    .frame(width: 40, height: 40)
                    .clipShape(RoundedRectangle(cornerRadius: 4))

                    VStack(alignment: .leading, spacing: 2) {
                        Text(currentTrack.title)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color(.white))
                            .lineLimit(1)
                        
                        Text(currentTrack.artist)
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(Color(.gray200))
                            .lineLimit(1)
                    }
                    
                    Spacer()

                    Button(action: {
                        if audioManager.isPlaying {
                            audioManager.pause()
                        } else {
                            audioManager.play()
                        }
                    }) {
                        Image(systemName: audioManager.isPlaying ? SFSymbols.pause : SFSymbols.play)
                            .font(.title2)
                            .foregroundColor(Color(.white))
                    }
                    .disabled(audioManager.isLoading)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color(.black))
            }
            .background(Color(.black))
        }
    }
}

#Preview {
    VStack {
        Spacer()
        MiniPlayerView()
    }
    .background(Color.gray)
}
