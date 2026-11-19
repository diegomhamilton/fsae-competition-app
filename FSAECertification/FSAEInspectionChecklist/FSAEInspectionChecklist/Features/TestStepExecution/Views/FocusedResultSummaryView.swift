import SwiftUI

struct FocusedResultSummaryView: View {
    let form: FocusedResultForm
    let testCaseID: String
    let editTransition: Namespace.ID
    let edit: () -> Void
    let viewEvidence: () -> Void

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                if form.draft.flaggedForReview == true {
                    Label(FocusedResultStrings.flaggedForReview, systemImage: "flag.fill")
                        .font(.callout).foregroundStyle(Color.fsaeAmber)
                        .accessibilityIdentifier("execution.result.flagged")
                }
                if form.step.requiredOutcome {
                    Label(form.draft.outcome.displayName, systemImage: form.draft.outcome == .fail ? "xmark.circle.fill" : "checkmark.circle.fill")
                        .font(.title2.bold())
                        .foregroundStyle(form.draft.outcome.color)
                        .accessibilityIdentifier(InspectionAccessibilityIdentifier.testCaseStepStatus(testCaseID: testCaseID, stepID: form.step.id).rawValue)
                }
                if let value = form.draft.measurementValue {
                    Text(value.formattedValue).font(.title2.bold())
                } else if form.step.type == .measurement {
                    Text(form.draft.measurementInput).font(.title2.bold())
                }
                if form.draft.evidenceAttachments.contains(where: { $0.localRelativePath != nil }) {
                    Button(FocusedResultStrings.viewPhotos, systemImage: "photo", action: viewEvidence)
                        .font(.callout)
                }
            }
            Spacer(minLength: 0)
            if form.step.requiredOutcome || form.step.type == .measurement {
                Button(action: edit) {
                    Label(FocusedResultStrings.edit, systemImage: "pencil")
                        .labelStyle(.iconOnly)
                        .font(.title3)
                        .frame(width: 48, height: 48)
                        .contentShape(.circle)
                }
                .buttonStyle(.plain)
                .buttonBorderShape(.circle)
                .matchedGeometryEffect(id: "result-edit", in: editTransition)
                .accessibilityIdentifier("execution.result.edit")
            }
        }
        .padding(16)
        .glassEffect(.regular.tint((form.draft.outcome.color).opacity(0.18)), in: .rect(cornerRadius: 24))
    }
}
