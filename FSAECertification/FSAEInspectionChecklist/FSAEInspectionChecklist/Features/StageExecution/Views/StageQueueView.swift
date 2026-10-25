import SwiftUI

struct StageQueueView: View {
    let team: InspectionTeam
    let stage: InspectionStage
    let draftsByTestCaseID: [String: TestCaseDraft]
    let focusedIssues: [FullStageValidationIssue]
    var hasUnsavedDraft = false
    let presentation: StageOverviewPresentation
    let selectedTestCaseID: String?
    let startNext: () -> Void
    let review: () -> Void
    let selectTestCase: (String) -> Void

    var body: some View {
        let testCases = stage.orderedSections.flatMap(\.orderedTestCases)
        let total = testCases.flatMap(\.orderedSteps).count
        let confirmed = total - Set(focusedIssues.filter { !$0.issueID.hasPrefix("flaggedIssue.") }.map(\.stepID)).count
        let hasDraft = selectedTestCaseID != nil || !draftsByTestCaseID.isEmpty

        RestoringOverviewScroll(savedOffset: presentation.queueOffset,
            rememberOffset: presentation.rememberQueueOffset, revealID: presentation.queueRevealID) {
                StageOverviewHeader(team: team, confirmedCount: confirmed, totalCount: total)
                if total == 0 {
                    Text(StageOverviewStrings.noTests).foregroundStyle(Color.fsaeSecondaryText)
                } else if confirmed < total {
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
                    Spacer()
                    if !focusedIssues.isEmpty {
                        Button(StageOverviewStrings.review, systemImage: "checklist", action: review)
                            .frame(minHeight: 48)
                            .accessibilityIdentifier("execution.queue.review")
                    }
                }

                Text(StageOverviewStrings.testSections).font(.headline)
                ForEach(stage.orderedSections) { section in
                    StageQueueSectionView(
                        section: section,
                        draftsByTestCaseID: draftsByTestCaseID,
                        focusedIssues: focusedIssues,
                        isExpanded: presentation.expandedSectionIDs.contains(section.id),
                        currentTestCaseID: selectedTestCaseID,
                        toggleExpanded: { presentation.toggleSection(section.id) },
                        selectTestCase: selectTestCase
                    )
                }
        }
        .background(Color.fsaeBackground)
        .onAppear { prepareQueue() }
        .onChange(of: selectedTestCaseID) { _, _ in prepareQueue() }
    }

    private func prepareQueue() {
        let section = stage.orderedSections.first { section in
            section.orderedTestCases.contains { $0.id == selectedTestCaseID }
        }
        presentation.prepareQueue(testCaseID: selectedTestCaseID, sectionID: section?.id)
        #if DEBUG
        if InspectionSnapshotScenario.current?.rawValue == "queue-supplies", let last = stage.orderedSections.last {
            presentation.expandedSectionIDs = [last.id]
        }
        #endif
    }
}
