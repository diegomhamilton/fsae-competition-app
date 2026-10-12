import SwiftUI

struct FocusedResultSummaryView: View {
    let form: FocusedResultForm
    let testCaseID: String
    let edit: () -> Void
    let viewEvidence: () -> Void

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading) {
                if form.draft.flaggedForReview == true {
                    Label(FocusedResultStrings.flaggedForReview, systemImage: "flag.fill")
                        .font(.callout)
                        .foregroundStyle(Color.fsaeAmber)
                        .accessibilityIdentifier("execution.result.flagged")
                }
                if form.step.requiredOutcome {
                    Label(form.draft.outcome.displayName, systemImage: form.draft.outcome == .fail ? "xmark.circle.fill" : "checkmark.circle.fill")
                        .font(.headline)
                        .foregroundStyle(form.draft.outcome.color)
                        .accessibilityIdentifier(InspectionAccessibilityIdentifier.testCaseStepStatus(testCaseID: testCaseID, stepID: form.step.id).rawValue)
                }
                if let value = form.draft.measurementValue {
                    Text(value.formattedValue).font(.headline)
                } else if form.step.type == .measurement {
                    Text(form.draft.measurementInput).font(.headline)
                }
                if !form.draft.notes.isEmpty {
                    Text(form.draft.notes).font(.callout).lineLimit(2)
                }
                if form.draft.evidenceAttachments.contains(where: { $0.localRelativePath != nil }) {
                    Button(FocusedResultStrings.viewPhotos, systemImage: "photo", action: viewEvidence)
                        .font(.callout)
                }
            }
            Spacer()
            Button(FocusedResultStrings.edit, systemImage: "pencil", action: edit)
                .labelStyle(.iconOnly)
                .frame(minWidth: 48, minHeight: 48)
                .accessibilityIdentifier("execution.result.edit")
        }
    }
}
