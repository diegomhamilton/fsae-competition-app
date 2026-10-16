import SwiftUI

struct StageReviewView: View {
    let team: InspectionTeam
    let stage: InspectionStage
    let draftsByTestCaseID: [String: TestCaseDraft]
    let focusedIssues: [FullStageValidationIssue]
    let presentation: StageOverviewPresentation
    let editResult: (String, String) -> Void

    var body: some View {
        let total = stage.orderedSections.flatMap(\.orderedTestCases).flatMap(\.orderedSteps).count
        let confirmed = total - Set(focusedIssues.filter { !$0.issueID.hasPrefix("flaggedIssue.") }.map(\.stepID)).count

        RestoringOverviewScroll(savedOffset: presentation.reviewOffset,
            rememberOffset: presentation.rememberReviewOffset) {
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
                            isUpdated: presentation.lastCorrectedCaseID == testCase.id,
                            editResult: { editResult(testCase.id, $0) }
                        )
                        .id(testCase.id)

                    }
                }
        }
        .background(Color.fsaeBackground)
        .accessibilityIdentifier("execution.review.results")
        .task(id: presentation.lastCorrectedCaseID) {
            guard let corrected = presentation.lastCorrectedCaseID else { return }
            #if DEBUG
            if ProcessInfo.processInfo.arguments.contains("-inspection-review-position") { return }
            #endif
            do { try await Task.sleep(for: .seconds(3)) } catch { return }
            if presentation.lastCorrectedCaseID == corrected { presentation.lastCorrectedCaseID = nil }
        }
    }
}
