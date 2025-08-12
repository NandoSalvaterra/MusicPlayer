import SwiftUI

struct SongRow: View {

    let title: String
    let artist: String

    var body: some View {
        HStack(spacing: 16) {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.white).opacity(0.1))
                .frame(width: 44, height: 44)
                .overlay(
                    Image(.iconMusicNote)
                        .foregroundColor(.white)
                        .font(.title2)
                )
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .foregroundColor(Color(.white))
                    .font(.system(size: 16, weight: .regular))
                Text(artist)
                    .foregroundColor(Color(.gray500))
                    .font(.system(size: 12, weight: .regular))
            }
            Spacer()
        }
        .background(Color(.black))
    }
}

#Preview("Light") {
    SongRow(title: "Something", artist: "Artist")
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    SongRow(title: "Something", artist: "Artist")
        .preferredColorScheme(.dark)
}
