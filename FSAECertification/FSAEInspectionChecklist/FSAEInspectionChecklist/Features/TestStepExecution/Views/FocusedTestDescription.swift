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
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(Array(state.step.content.components(separatedBy: "\n\n").enumerated()), id: \.offset) { _, paragraph in
                        Text(paragraph)
                            .font(.title2)
                            .foregroundStyle(Color.fsaeText)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
        .padding(.vertical, 8)
        .accessibilityIdentifier("execution.description")
    }
}
