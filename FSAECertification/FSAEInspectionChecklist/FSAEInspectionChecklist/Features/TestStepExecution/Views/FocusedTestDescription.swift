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
                // Authored line breaks define requirements without splitting decimals or rule references.
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(Array(state.step.content.components(separatedBy: .newlines).filter { !$0.isEmpty }.enumerated()), id: \.offset) { _, paragraph in
                        HStack(alignment: .firstTextBaseline, spacing: 8) {
                            Text("•").accessibilityHidden(true)
                            Text(paragraph)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .font(.title2)
                        .foregroundStyle(Color.fsaeText)
                        .accessibilityElement(children: .combine)
                    }
                }
            }
        }
        .padding(.vertical, 8)
        .accessibilityIdentifier("execution.description")
    }
}
