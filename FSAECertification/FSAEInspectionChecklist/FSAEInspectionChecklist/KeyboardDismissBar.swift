import SwiftUI

struct KeyboardDismissBar: View {
    let title: String
    let dismiss: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Divider()
            HStack {
                Spacer()
                Button(title, action: dismiss)
                    .font(.body.weight(.semibold))
                    .buttonStyle(.plain)
                    .foregroundStyle(Color.fsaePrimary)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(.regularMaterial)
        }
    }
}
