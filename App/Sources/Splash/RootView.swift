import SwiftUI

struct RootView: View {
    @State private var showSplash: Bool = true

    var body: some View {
        ZStack {
            if showSplash {
                SplashView()
                    .transition(.opacity)
                    .zIndex(1)
            } else {
                NavigationStack {
                    SongListView()
                }
                .tint(.primary)
                .transition(.opacity)
                .zIndex(0)
            }
        }
        .ignoresSafeArea()
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                withAnimation(.easeInOut(duration: 0.45)) {
                    showSplash = false
                }
            }
        }
    }
}

#Preview {
    RootView()
}
