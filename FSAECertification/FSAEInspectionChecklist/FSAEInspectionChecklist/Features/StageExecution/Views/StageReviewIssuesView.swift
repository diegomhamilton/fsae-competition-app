import SwiftUI

struct StageReviewIssuesView: View {
    let issues: [FullStageValidationIssue]
    let editResult: (String, String) -> Void

    var body: some View {
        VStack(alignment: .leading) {
            Label(StageOverviewStrings.resolve, systemImage: "exclamationmark.circle")
                .font(.headline)
                .foregroundStyle(Color.fsaeRed)
            ForEach(issues) { issue in
                Button {
                    editResult(issue.testCaseID, issue.stepID)
                } label: {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(issue.stepTitle).font(.headline)
                            Text(issue.message).font(.callout).foregroundStyle(Color.fsaeSecondaryText)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .frame(minHeight: 56)
                }
                .buttonStyle(.plain)
                .foregroundStyle(Color.fsaeText)
                .padding(.vertical)
                .accessibilityIdentifier("execution.review.issue.\(issue.id)")
            }
        }
        .padding()
        .background(Color.fsaeSurface, in: .rect(cornerRadius: 16))
    }
}
