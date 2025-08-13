import SwiftUI

struct LoadingView: View {
    let message: String?
    
    init(message: String? = nil) {
        self.message = message
    }
    
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: Color(.white)))
                .scaleEffect(1.2)
            
            if let message = message {
                Text(message)
                    .foregroundColor(Color(.white))
                    .font(.system(size: 16, weight: .medium))
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.black))
    }
}

struct LoadingOverlay: View {
    let isVisible: Bool
    let message: String?
    
    init(isVisible: Bool, message: String? = nil) {
        self.isVisible = isVisible
        self.message = message
    }
    
    var body: some View {
        Group {
            if isVisible {
                LoadingView(message: message)
            }
        }
    }
}

#Preview("Loading Only") {
    LoadingView()
}

#Preview("Loading with Message") {
    LoadingView(message: LocalizedStrings.loadingSongs)
}
