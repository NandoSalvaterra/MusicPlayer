import SwiftUI

struct SplashView: View {

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            LinearGradient(
                stops: [
                    Gradient.Stop(color: .clear, location: 0.00),
                    Gradient.Stop(color: .clear, location: 0.49),
                    Gradient.Stop(color: Color(red: 0.11, green: 0.19, blue: 0.28), location: 1.00),
                ],
                startPoint: UnitPoint(x: 0.07, y: 1.16),
                endPoint: UnitPoint(x: 0.93, y: -0.04)
            )
            .ignoresSafeArea()

            Image(.iconSplash)
        }
    }
}

#Preview {
    SplashView()
}
