import Foundation
import Data

extension Track {
    static var preview: Track {
        Track(
            id: 1,
            title: "Bohemian Rhapsody",
            artist: "Queen",
            album: "A Night at the Opera",
            duration: 355,
            trackNumber: 11,
            discNumber: 1,
            artworkURL: URL(string: "https://is1-ssl.mzstatic.com/image/thumb/Music115/v4/6f/0b/c3/6f0bc3c6-f3b8-1b8a-8e9b-7b6f4c7a5c4a/mzi.gqvuqgzx.jpg/100x100bb.jpg"),
            previewURL: URL(string: "https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview115/v4/40/64/66/40646668-82fe-e7f4-6e09-1194fb0ced89/mzaf_7480774833552227899.plus.aac.p.m4a"),
            genre: "Rock"
        )
    }
    
    static var previewList: [Track] {
        [
            Track(
                id: 3,
                title: "Stairway to Heaven",
                artist: "Led Zeppelin",
                album: "Led Zeppelin IV",
                duration: 482,
                trackNumber: 8,
                discNumber: 1,
                artworkURL: URL(string: "https://is1-ssl.mzstatic.com/image/thumb/Music115/v4/6f/0b/c3/6f0bc3c6-f3b8-1b8a-8e9b-7b6f4c7a5c4a/mzi.gqvuqgzx.jpg/100x100bb.jpg"),
                previewURL: URL(string: "https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview115/v4/40/64/66/40646668-82fe-e7f4-6e09-1194fb0ced89/mzaf_7480774833552227899.plus.aac.p.m4a"),
                genre: "Rock"
            ),
            Track(
                id: 4,
                title: "Hotel California",
                artist: "Eagles",
                album: "Hotel California",
                duration: 391,
                trackNumber: 1,
                discNumber: 1,
                artworkURL: URL(string: "https://is1-ssl.mzstatic.com/image/thumb/Music115/v4/6f/0b/c3/6f0bc3c6-f3b8-1b8a-8e9b-7b6f4c7a5c4a/mzi.gqvuqgzx.jpg/100x100bb.jpg"),
                previewURL: URL(string: "https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview115/v4/40/64/66/40646668-82fe-e7f4-6e09-1194fb0ced89/mzaf_7480774833552227899.plus.aac.p.m4a"),
                genre: "Rock"
            ),
            Track(
                id: 5,
                title: "Sweet Child O' Mine",
                artist: "Guns N' Roses",
                album: "Appetite for Destruction",
                duration: 356,
                trackNumber: 3,
                discNumber: 1,
                artworkURL: URL(string: "https://is1-ssl.mzstatic.com/image/thumb/Music115/v4/6f/0b/c3/6f0bc3c6-f3b8-1b8a-8e9b-7b6f4c7a5c4a/mzi.gqvuqgzx.jpg/100x100bb.jpg"),
                previewURL: nil,
                genre: "Rock"
            )
        ]
    }
}

extension Album {
    // MARK: - Preview Data
    static var preview: Album {
        Album(
            id: 1,
            name: "A Night at the Opera",
            artist: "Queen",
            artworkURL: URL(string: "https://is1-ssl.mzstatic.com/image/thumb/Music115/v4/6f/0b/c3/6f0bc3c6-f3b8-1b8a-8e9b-7b6f4c7a5c4a/mzi.gqvuqgzx.jpg/100x100bb.jpg"),
            trackCount: 12,
            discCount: 1,
            releaseDate: ISO8601DateFormatter().date(from: "1975-11-21T00:00:00Z"),
            genre: "Rock"
        )
    }
    
    static var previewList: [Album] {
        [
            Album(
                id: 2,
                name: "Led Zeppelin IV",
                artist: "Led Zeppelin",
                artworkURL: URL(string: "https://is1-ssl.mzstatic.com/image/thumb/Music115/v4/6f/0b/c3/6f0bc3c6-f3b8-1b8a-8e9b-7b6f4c7a5c4a/mzi.gqvuqgzx.jpg/100x100bb.jpg"),
                trackCount: 8,
                discCount: 1,
                releaseDate: ISO8601DateFormatter().date(from: "1971-11-08T00:00:00Z"),
                genre: "Rock"
            ),
            Album(
                id: 3,
                name: "Hotel California",
                artist: "Eagles",
                artworkURL: URL(string: "https://is1-ssl.mzstatic.com/image/thumb/Music115/v4/6f/0b/c3/6f0bc3c6-f3b8-1b8a-8e9b-7b6f4c7a5c4a/mzi.gqvuqgzx.jpg/100x100bb.jpg"),
                trackCount: 9,
                discCount: 1,
                releaseDate: ISO8601DateFormatter().date(from: "1976-12-08T00:00:00Z"),
                genre: "Rock"
            )
        ]
    }
}
