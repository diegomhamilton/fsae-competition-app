import SwiftUI

struct StageReviewView: View {
    let team: InspectionTeam
    let stage: InspectionStage
    let draftsByTestCaseID: [String: TestCaseDraft]
    let focusedIssues: [FullStageValidationIssue]
    let editResult: (String, String) -> Void

    var body: some View {
        let total = stage.orderedSections.flatMap(\.orderedTestCases).flatMap(\.orderedSteps).count
        let confirmed = total - Set(focusedIssues.filter { !$0.issueID.hasPrefix("flaggedIssue.") }.map(\.stepID)).count

        ScrollView {
            VStack(alignment: .leading) {
                StageOverviewHeader(team: team, confirmedCount: confirmed, totalCount: total)
                if focusedIssues.isEmpty && total > 0 {
                    Label(StageOverviewStrings.ready, systemImage: "checkmark.circle.fill")
                        .font(.headline)
                        .foregroundStyle(Color.fsaeGreen)
                    Text(StageOverviewStrings.readyDescription)
                        .font(.callout)
                        .foregroundStyle(Color.fsaeSecondaryText)
                } else if !focusedIssues.isEmpty {
                    StageReviewIssuesView(issues: focusedIssues, editResult: editResult)
                }

                Text(StageOverviewStrings.results).font(.title2).bold().padding(.top)
                if total == 0 {
                    Text(StageOverviewStrings.noTests).foregroundStyle(Color.fsaeSecondaryText)
                }
                ForEach(stage.orderedSections) { section in
                    Text(InspectionSectionDisplayText(rawTitle: section.title).title).font(.headline).padding(.top)
                    ForEach(section.orderedTestCases) { testCase in
                        let state = InspectionTestCaseViewState(testCase: testCase,
                            draft: draftsByTestCaseID[testCase.id] ?? TestCaseDraft(testCase: testCase))
                        StageReviewCaseView(
                            state: state,
                            issues: focusedIssues.filter { $0.testCaseID == testCase.id },
                            editResult: { editResult(testCase.id, $0) }
                        )
                    }
                }
            }
            .padding()
        }
        .background(Color.fsaeBackground)
        .accessibilityIdentifier("execution.review.results")
    }
}
