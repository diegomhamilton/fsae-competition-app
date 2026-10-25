import SwiftUI

struct StageCurrentTestBadge: View {
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    var body: some View {
        if reduceTransparency {
            StageCurrentTestBadgeLabel()
                .background(Color.fsaeSurface, in: .capsule)
        } else {
            StageCurrentTestBadgeLabel()
                .glassEffect(.regular.tint(Color.fsaePrimary.opacity(0.12)), in: .capsule)
        }
    }
}
