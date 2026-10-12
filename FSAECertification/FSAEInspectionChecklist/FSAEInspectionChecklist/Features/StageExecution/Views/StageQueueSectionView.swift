import SwiftUI

struct StageQueueSectionView: View {
    let section: InspectionSection
    let draftsByTestCaseID: [String: TestCaseDraft]
    let focusedIssues: [FullStageValidationIssue]
    let isExpanded: Bool
    let toggleExpanded: () -> Void
    let selectTestCase: (String) -> Void

    var body: some View {
        VStack(alignment: .leading) {
            Button(action: toggleExpanded) {
                HStack {
                    VStack(alignment: .leading) {
                        Text(InspectionSectionDisplayText(rawTitle: section.title).title)
                            .font(.headline)
                        Text(StageOverviewStrings.sectionCount(section.testCases.count))
                            .font(.caption)
                            .foregroundStyle(Color.fsaeSecondaryText)
                    }
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                }
                .frame(minHeight: 56)
            }
            .buttonStyle(.plain)
            .foregroundStyle(Color.fsaeText)
            .accessibilityValue(isExpanded ? StageOverviewStrings.expanded : StageOverviewStrings.collapsed)
            .accessibilityIdentifier("execution.queue.section.\(section.id)")

            if isExpanded {
                ForEach(section.orderedTestCases) { testCase in
                    let state = InspectionTestCaseViewState(testCase: testCase,
                        draft: draftsByTestCaseID[testCase.id] ?? TestCaseDraft(testCase: testCase))
                    StageQueueTestRow(
                        state: state,
                        status: StageResultStatus.testCase(state, issues: focusedIssues.filter { $0.testCaseID == testCase.id }),
                        select: { selectTestCase(testCase.id) }
                    )
                }
            }
        }
        .padding()
        .background(Color.fsaeSurface, in: .rect(cornerRadius: 16))
    }
}
