import SwiftUI
import Data

struct SongRow: View {

    let track: Track

    var body: some View {
        HStack(spacing: 16) {
            AsyncImage(url: track.artworkURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.white).opacity(0.1))
                    .overlay(
                        Image(.iconMusicNote)
                            .foregroundColor(.white)
                            .font(.title2)
                    )
            }
            .frame(width: 44, height: 44)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(track.title)
                    .foregroundColor(Color(.white))
                    .font(.system(size: 16, weight: .regular))
                Text(track.artist)
                    .foregroundColor(Color(.gray500))
                    .font(.system(size: 12, weight: .regular))
            }
            Spacer()
        }
        .background(Color(.black))
    }
}

#Preview("Light") {
    SongRow(track: .preview)
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    SongRow(track: .preview)
        .preferredColorScheme(.dark)
}
