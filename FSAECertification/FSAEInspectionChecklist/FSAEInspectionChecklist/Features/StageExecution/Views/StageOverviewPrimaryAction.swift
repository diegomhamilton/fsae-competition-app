import SwiftUI

struct StageOverviewPrimaryAction: View {
    let title: String
    let symbol: String
    let identifier: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: symbol).frame(maxWidth: .infinity, minHeight: 56)
        }
        .buttonStyle(.borderedProminent)
        .tint(Color.fsaePrimary)
        .controlSize(.large)
        .accessibilityIdentifier(identifier)
    }
}
