import SwiftUI

struct StageResultBadge: View {
    let status: StageResultStatus
    var textStyle: Font = .caption

    var body: some View {
        Label(status.title, systemImage: status.symbol)
            .font(textStyle)
            .foregroundStyle(status.color)
            .accessibilityElement(children: .combine)
    }
}
