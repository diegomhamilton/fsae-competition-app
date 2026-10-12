import SwiftUI

struct FocusedTestDescription: View {
    let state: InspectionTestCaseStepViewState
    var showsTypeBadge = false

    var body: some View {
        VStack(alignment: .leading) {
            ForEach(state.safetyBadges, id: \.self) { badge in
                Label(badge.displayName, systemImage: "exclamationmark.triangle.fill")
                    .font(.headline)
                    .foregroundStyle(Color.fsaeRed)
                    .accessibilityLabel(badge.accessibilityLabel)
                    .accessibilityIdentifier("execution.safety-warning.\(state.id)")
            }
            HStack(alignment: .top) {
                #if DEBUG
                if showsTypeBadge {
                    StatusPill(text: state.step.type.label, color: state.step.type.color)
                        .accessibilityIdentifier("execution.debug-type-badge")
                }
                #endif
                Text(state.step.content)
                    .font(.body)
                    .foregroundStyle(Color.fsaeText)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.vertical)
        .accessibilityIdentifier("execution.description")
    }
}
