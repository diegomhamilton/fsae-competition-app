import SwiftUI

struct StageReviewCaseView: View {
    let state: InspectionTestCaseViewState
    let issues: [FullStageValidationIssue]
    let editResult: (String) -> Void

    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .firstTextBaseline) {
                Text(state.title).font(.headline)
                Spacer()
                StageResultBadge(status: StageResultStatus.testCase(state, issues: issues))
                if state.steps.count == 1, let step = state.steps.first {
                    Button(StageOverviewStrings.edit, systemImage: "pencil") { editResult(step.id) }
                        .labelStyle(.iconOnly).frame(minWidth: 48, minHeight: 48)
                        .accessibilityIdentifier("execution.review.edit.\(step.id)")
                }
            }
            ForEach(state.steps) { step in
                if state.steps.count > 1 || !step.notes.isEmpty || !step.measurementInput.isEmpty
                    || !step.evidenceAttachments.isEmpty || step.flaggedForReview == true {
                    StageReviewStepRow(
                    state: step,
                    status: StageResultStatus.step(step, hasIssues: issues.contains { $0.stepID == step.id }),
                    showTitle: state.steps.count > 1,
                    showsEdit: state.steps.count > 1,
                    edit: { editResult(step.id) }
                    )
                }
                if state.steps.count > 1 && state.steps.last?.id != step.id {
                    Divider()
                }
            }
        }
        .padding()
        .background(Color.fsaeSurface, in: .rect(cornerRadius: 16))
        .accessibilityIdentifier("execution.review.case.\(state.id)")
    }
}
