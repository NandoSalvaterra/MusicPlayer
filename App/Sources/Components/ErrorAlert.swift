import SwiftUI

struct ErrorAlert: ViewModifier {

    @Binding var errorMessage: String?

    let title: String
    let primaryButtonTitle: String
    let primaryAction: (() -> Void)?
    let secondaryButtonTitle: String?
    let secondaryAction: (() -> Void)?
    
    init(
        errorMessage: Binding<String?>,
        title: String = LocalizedStrings.error,
        primaryButtonTitle: String = LocalizedStrings.ok,
        primaryAction: (() -> Void)? = nil,
        secondaryButtonTitle: String? = nil,
        secondaryAction: (() -> Void)? = nil
    ) {
        self._errorMessage = errorMessage
        self.title = title
        self.primaryButtonTitle = primaryButtonTitle
        self.primaryAction = primaryAction
        self.secondaryButtonTitle = secondaryButtonTitle
        self.secondaryAction = secondaryAction
    }
    
    func body(content: Content) -> some View {
        content
            .alert(title, isPresented: .constant(errorMessage != nil)) {
                Button(primaryButtonTitle) {
                    primaryAction?()
                    errorMessage = nil
                }
                
                if let secondaryButtonTitle = secondaryButtonTitle {
                    Button(secondaryButtonTitle) {
                        secondaryAction?()
                        errorMessage = nil
                    }
                }
            } message: {
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                }
            }
    }
}

extension View {
    func errorAlert(
        errorMessage: Binding<String?>,
        title: String = LocalizedStrings.error,
        primaryButtonTitle: String = LocalizedStrings.ok,
        primaryAction: (() -> Void)? = nil,
        secondaryButtonTitle: String? = nil,
        secondaryAction: (() -> Void)? = nil
    ) -> some View {
        modifier(ErrorAlert(
            errorMessage: errorMessage,
            title: title,
            primaryButtonTitle: primaryButtonTitle,
            primaryAction: primaryAction,
            secondaryButtonTitle: secondaryButtonTitle,
            secondaryAction: secondaryAction
        ))
    }
}

struct ErrorBanner: View {
    let message: String
    let onDismiss: () -> Void
    let onRetry: (() -> Void)?
    
    init(message: String, onDismiss: @escaping () -> Void, onRetry: (() -> Void)? = nil) {
        self.message = message
        self.onDismiss = onDismiss
        self.onRetry = onRetry
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: SFSymbols.errorTriangle)
                .foregroundColor(.red)
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(LocalizedStrings.error)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(message)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
            
            HStack(spacing: 8) {
                if let onRetry = onRetry {
                    Button(LocalizedStrings.retry) {
                        onRetry()
                    }
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.blue)
                }
                
                Button(LocalizedStrings.dismiss) {
                    onDismiss()
                }
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white)
            }
        }
        .padding(16)
        .background(Color(.systemGray6).opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.red.opacity(0.3), lineWidth: 1)
        )
    }
}
