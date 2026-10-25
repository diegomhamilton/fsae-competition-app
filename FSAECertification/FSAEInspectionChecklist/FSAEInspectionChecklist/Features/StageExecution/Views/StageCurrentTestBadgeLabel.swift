import SwiftUI

struct StageCurrentTestBadgeLabel: View {
    var body: some View {
        Text(StageOverviewStrings.currentTest)
            .font(.caption.bold())
            .foregroundStyle(Color.fsaePrimary)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .fixedSize(horizontal: true, vertical: false)
    }
}
