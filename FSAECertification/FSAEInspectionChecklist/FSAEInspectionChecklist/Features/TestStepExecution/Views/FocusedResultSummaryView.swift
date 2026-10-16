import SwiftUI

struct FocusedResultSummaryView: View {
    let form: FocusedResultForm
    let testCaseID: String
    let edit: () -> Void
    let viewEvidence: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading) {
                if form.draft.flaggedForReview == true {
                    Label(FocusedResultStrings.flaggedForReview, systemImage: "flag.fill")
                        .font(.callout)
                        .foregroundStyle(Color.fsaeAmber)
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
            if form.step.requiredOutcome || form.step.type == .measurement {
            Button(FocusedResultStrings.change, systemImage: "pencil", action: edit)
                .labelStyle(.titleAndIcon)
                .frame(minWidth: 48, minHeight: 48)
                .accessibilityIdentifier("execution.result.edit")
            }
        }
    }
}
