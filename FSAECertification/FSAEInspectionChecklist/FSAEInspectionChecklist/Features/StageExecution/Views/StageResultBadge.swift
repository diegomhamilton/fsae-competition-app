import SwiftUI

struct StageResultBadge: View {
    let status: StageResultStatus

    var body: some View {
        Label(status.title, systemImage: status.symbol)
            .font(.caption)
            .foregroundStyle(status.color)
            .accessibilityElement(children: .combine)
    }
}
