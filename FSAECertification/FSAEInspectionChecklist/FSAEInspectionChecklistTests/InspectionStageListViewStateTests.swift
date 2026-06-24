import Foundation
import Testing
@testable import FSAEInspectionChecklist

@MainActor
struct InspectionStageListViewStateTests {
    @Test("inspection-data stage list view state orders sections and test cases")
    func inspectionDataStageListViewStateOrdersSectionsAndTestCases() {
        let stage = InspectionStage(
            id: "stage",
            title: "Stage",
            displayOrder: 1,
            sections: [
                section(id: "section-b", title: "Second Section", displayOrder: 2, testCases: [
                    testCase(id: "B2", displayOrder: 2),
                    testCase(id: "B1", displayOrder: 1)
                ]),
                section(id: "section-a", title: "First Section", displayOrder: 1, testCases: [
                    testCase(id: "A1", displayOrder: 1)
                ])
            ]
        )

        let viewState = InspectionStageListViewState(stage: stage)

        #expect(viewState.sections.map(\.id) == ["section-a", "section-b"])
        #expect(viewState.sections[1].rows.map(\.id) == ["B1", "B2"])
        #expect(viewState.testCaseCount == 3)
    }

    @Test("inspection-data stage list rows expose progress, blocker summary, and status text")
    func inspectionDataStageListRowsExposeProgressBlockerSummaryAndStatusText() {
        let caseUnderTest = testCase(id: "EV101", displayOrder: 1, stepCount: 2)
        let draft = TestCaseDraft(
            testCase: caseUnderTest,
            stepDrafts: [
                TestStepDraft(stepID: "EV101.1", outcome: .pass),
                TestStepDraft(stepID: "EV101.2", outcome: .pending)
            ]
        )

        let row = InspectionStageTestCaseRowState(
            stageID: "04_ev",
            testCase: caseUnderTest,
            draft: draft
        )

        #expect(row.progressText == "1/2 complete")
        #expect(row.blockerSummary == "1 blocker")
        #expect(row.status.displayName == "Blocked")
    }

    @Test("inspection-data stage list rows preserve explicit safety badges and rules")
    func inspectionDataStageListRowsPreserveExplicitSafetyBadgesAndRules() {
        let caseUnderTest = testCase(
            id: "EV101",
            displayOrder: 1,
            ruleReferences: ["EV.8.1"],
            safetyBadges: [.energized]
        )
        let row = InspectionStageTestCaseRowState(
            stageID: "04_ev",
            testCase: caseUnderTest,
            draft: TestCaseDraft(testCase: caseUnderTest)
        )

        #expect(row.code == "EV101")
        #expect(row.ruleReferences == ["EV.8.1"])
        #expect(row.safetyBadges == [.energized])
    }
}

private func section(
    id: String,
    title: String,
    displayOrder: Int,
    testCases: [InspectionTestCase]
) -> InspectionSection {
    InspectionSection(
        id: id,
        title: title,
        displayOrder: displayOrder,
        testCases: testCases
    )
}

private func testCase(
    id: String,
    displayOrder: Int,
    stepCount: Int = 1,
    ruleReferences: [String] = ["EV.6.1"],
    safetyBadges: [InspectionSafetyBadge] = []
) -> InspectionTestCase {
    InspectionTestCase(
        id: id,
        code: id,
        displayOrder: displayOrder,
        title: "\(id) title",
        ruleReferences: ruleReferences,
        safetyBadges: safetyBadges,
        steps: (1...stepCount).map { index in
            InspectionTestStep(
                id: "\(id).\(index)",
                code: "\(id)-\(index)",
                displayOrder: index,
                ruleReference: ruleReferences.first ?? "",
                title: "\(id) step \(index)",
                type: .check,
                content: "Inspect \(id) step \(index).",
                requiredOutcome: true,
                requiresEvidence: false
            )
        }
    )
}
