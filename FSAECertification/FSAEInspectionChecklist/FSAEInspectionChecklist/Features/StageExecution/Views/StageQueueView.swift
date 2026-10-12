import SwiftUI

struct StageQueueView: View {
    let team: InspectionTeam
    let stage: InspectionStage
    let draftsByTestCaseID: [String: TestCaseDraft]
    let focusedIssues: [FullStageValidationIssue]
    let hasActiveSelection: Bool
    var hasUnsavedDraft = false
    let startNext: () -> Void
    let continueTest: () -> Void
    let review: () -> Void
    let selectTestCase: (String) -> Void
    @State private var expandedSectionIDs: Set<String> = []
    @State private var initializedExpansion = false

    var body: some View {
        let testCases = stage.orderedSections.flatMap(\.orderedTestCases)
        let total = testCases.flatMap(\.orderedSteps).count
        let confirmed = total - Set(focusedIssues.filter { !$0.issueID.hasPrefix("flaggedIssue.") }.map(\.stepID)).count
        let hasDraft = !draftsByTestCaseID.isEmpty

        ScrollView {
            VStack(alignment: .leading) {
                StageOverviewHeader(team: team, confirmedCount: confirmed, totalCount: total)
                if total == 0 {
                    Text(StageOverviewStrings.noTests).foregroundStyle(Color.fsaeSecondaryText)
                } else if !focusedIssues.isEmpty {
                    StageOverviewPrimaryAction(
                        title: hasDraft ? StageOverviewStrings.resume : StageOverviewStrings.start,
                        symbol: "play.fill", identifier: "execution.start-next", action: startNext
                    )
                    .disabled(hasUnsavedDraft)
                } else {
                    StageOverviewPrimaryAction(
                        title: StageOverviewStrings.review, symbol: "checklist",
                        identifier: "execution.queue.review", action: review
                    )
                }

                HStack {
                    if hasActiveSelection {
                        Button(StageOverviewStrings.continueTest, systemImage: "arrow.left", action: continueTest)
                            .frame(minHeight: 48)
                            .accessibilityIdentifier("execution.queue.continue")
                    }
                    Spacer()
                    if !focusedIssues.isEmpty {
                        Button(StageOverviewStrings.review, systemImage: "checklist", action: review)
                            .frame(minHeight: 48)
                            .accessibilityIdentifier("execution.queue.review")
                    }
                }

                Text(StageOverviewStrings.chooseTest).font(.headline)
                ForEach(stage.orderedSections) { section in
                    StageQueueSectionView(
                        section: section,
                        draftsByTestCaseID: draftsByTestCaseID,
                        focusedIssues: focusedIssues,
                        isExpanded: expandedSectionIDs.contains(section.id),
                        toggleExpanded: {
                            if expandedSectionIDs.contains(section.id) {
                                expandedSectionIDs.remove(section.id)
                            } else {
                                expandedSectionIDs.insert(section.id)
                            }
                        },
                        selectTestCase: selectTestCase
                    )
                }
            }
            .padding()
        }
        .background(Color.fsaeBackground)
        .onAppear {
            guard !initializedExpansion else { return }
            initializedExpansion = true
            #if DEBUG
            if InspectionSnapshotScenario.current?.rawValue == "queue-supplies", let last = stage.orderedSections.last {
                expandedSectionIDs.insert(last.id)
                return
            }
            #endif
            if let first = stage.orderedSections.first { expandedSectionIDs.insert(first.id) }
        }
    }
}
