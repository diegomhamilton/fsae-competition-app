import SwiftUI

extension View {
    /// Shared appearance using the native button's interaction and accessibility behavior.
    func inspectionButtonStyle(tint: Color = .fsaePrimary) -> some View {
        buttonStyle(.glass(.regular.tint(tint.opacity(0.18))))
            .buttonBorderShape(.roundedRectangle(radius: 24))
            .controlSize(.large)
            .tint(tint)
    }
}
