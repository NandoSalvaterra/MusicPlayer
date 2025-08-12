import SwiftUI

struct SongOptionsSheet: View {
    let title: String
    let artist: String
    var onOpenAlbum: () -> Void = {}

    var body: some View {
        VStack(spacing: 0) {

            VStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 18, weight: .bold))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color(.white))
                Text(artist)
                    .font(.system(size: 14, weight: .medium))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color(.gray200))
            }
            .padding(.top, 32)

            Button(action: onOpenAlbum) {
                HStack(spacing: 16) {
                        Image(.iconAlbum)
                        .renderingMode(.template)
                        .tint(Color(.black))

                    Text(LocalizedStrings.openAlbum)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(Color(.white))

                    Spacer()
                }.padding(.vertical, 18)
            }
            .buttonStyle(.plain)
            .padding(.top, 24)
            .padding(.leading, 32)

            Spacer()
        }
        .presentationDragIndicator(.visible)
        .presentationDetents([.height(180)])
    }
}

#Preview("Dark") {
        SongOptionsSheet(title: "Something", artist: "Artist") {}
            .preferredColorScheme(.dark)
}

#Preview("Light") {
        SongOptionsSheet(title: "Something", artist: "Artist") {}
            .preferredColorScheme(.light)
}
