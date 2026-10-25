import SwiftUI

struct StageReviewCaseView: View {
    let state: InspectionTestCaseViewState
    let issues: [FullStageValidationIssue]
    var isUpdated = false
    let editResult: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if state.steps.count == 1, let step = state.steps.first {
                Button { editResult(step.id) } label: {
                    VStack(alignment: .leading, spacing: 12) {
                        header
                        resultDetails(step)
                    }
                    .frame(maxWidth: .infinity, minHeight: 88, alignment: .leading).padding(20)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("execution.review.edit.\(step.id)")
                StageReviewEvidenceView(attachments: step.evidenceAttachments, stepID: step.id)
            } else {
                header.padding(20)
                ForEach(state.steps) { step in
                    Button { editResult(step.id) } label: {
                        VStack(alignment: .leading, spacing: 12) {
                            Text(step.step.title).font(.title3.bold())
                            StageResultBadge(status: StageResultStatus.step(step, hasIssues: issues.contains { $0.stepID == step.id }), textStyle: .title3)
                            resultDetails(step)
                        }
                        .frame(maxWidth: .infinity, minHeight: 72, alignment: .leading).padding(20)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain).accessibilityIdentifier("execution.review.edit.\(step.id)")
                    StageReviewEvidenceView(attachments: step.evidenceAttachments, stepID: step.id)
                }
            }
        }
        .foregroundStyle(Color.fsaeText)
        .background(Color.fsaeSurface, in: .rect(cornerRadius: 24))
        .accessibilityIdentifier("execution.review.case.\(state.id)")
    }
    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(state.title).font(.title2.bold())
            HStack {
                StageResultBadge(status: StageResultStatus.testCase(state, issues: issues), textStyle: .title3)
                if isUpdated {
                    Label(StageOverviewStrings.updated, systemImage: "checkmark.circle.fill")
                        .font(.caption.bold()).foregroundStyle(Color.fsaeGreen)
                }
            }
        }
    }
    @ViewBuilder private func resultDetails(_ step: InspectionTestCaseStepViewState) -> some View {
        if step.flaggedForReview == true {
            Label(step.outcome.displayName, systemImage: step.outcome == .fail ? "xmark.circle.fill" : "checkmark.circle.fill")
                .font(.title3).foregroundStyle(step.outcome.color)
        }
        if !step.measurementInput.isEmpty {
            Text("\(step.measurementInput) \(step.step.measurementRange?.unit.symbol ?? "")").font(.title2)
        }
        if !step.notes.isEmpty { Text(StageOverviewStrings.notes(step.notes)).font(.title3) }
    }
}
