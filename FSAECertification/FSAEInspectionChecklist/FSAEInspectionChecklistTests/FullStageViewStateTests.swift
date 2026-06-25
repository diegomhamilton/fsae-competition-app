import Foundation
import Testing
@testable import FSAEInspectionChecklist

@MainActor
struct FullStageViewStateTests {
    @Test("US-001/US-002 full stage state reports progress blockers and first invalid route")
    func us001Us002FullStageStateReportsProgressBlockersAndFirstInvalidRoute() {
        let stage = inspectionStage()
        let rainCase = stage.orderedSections[0].orderedTestCases[0]
        let egressCase = stage.orderedSections[0].orderedTestCases[1]
        let drafts = [
            rainCase.id: TestCaseDraft(
                testCase: rainCase,
                stepDrafts: [
                    TestStepDraft(stepID: "RT-07", outcome: .pass),
                    TestStepDraft(stepID: "RT-08", outcome: .pass)
                ]
            ),
            egressCase.id: TestCaseDraft(
                testCase: egressCase,
                stepDrafts: [
                    TestStepDraft(stepID: "EG-14", outcome: .pass, measurementInput: "5.40")
                ]
            )
        ]

        let viewState = FullStageViewState(stage: stage, draftsByTestCaseID: drafts)

        #expect(viewState.stageID == "06_rain")
        #expect(viewState.stageTitle == "Rain Test")
        #expect(viewState.testCaseCount == 2)
        #expect(viewState.stepCount == 3)
        #expect(viewState.completeStepCount == 1)
        #expect(viewState.blockerCount == 2)
        #expect(viewState.progressText == "1/3 complete")
        #expect(viewState.blockerText == "2 blockers")
        #expect(!viewState.canSubmit)
        #expect(viewState.validationSummary.blockerCount == 2)
        #expect(viewState.validationSummary.issues.map(\.stepID) == ["RT-08", "EG-14"])
        #expect(!viewState.canSubmit)
        #expect(viewState.validationSummary.firstBlockingRoute == FullStageBlockingRoute(
            stageID: "06_rain",
            testCaseID: "rain-rml",
            stepID: "RT-08",
            issueID: "missingRequiredEvidence.RT-08"
        ))
    }

    @Test("US-001 full stage state enables submit when service validation passes")
    func us001FullStageStateEnablesSubmitWhenServiceValidationPasses() {
        let stage = inspectionStage()
        let rainCase = stage.orderedSections[0].orderedTestCases[0]
        let egressCase = stage.orderedSections[0].orderedTestCases[1]
        let drafts = [
            rainCase.id: TestCaseDraft(
                testCase: rainCase,
                stepDrafts: [
                    TestStepDraft(stepID: "RT-07", outcome: .pass),
                    TestStepDraft(
                        stepID: "RT-08",
                        outcome: .pass,
                        evidenceAttachments: [evidenceAttachment()]
                    )
                ]
            ),
            egressCase.id: TestCaseDraft(
                testCase: egressCase,
                stepDrafts: [
                    TestStepDraft(stepID: "EG-14", outcome: .pass, measurementInput: "4.38")
                ]
            )
        ]

        let viewState = FullStageViewState(stage: stage, draftsByTestCaseID: drafts)

        #expect(viewState.canSubmit)
        #expect(viewState.validationSummary.blockerCount == 0)
        #expect(viewState.validationSummary.firstBlockingRoute == nil)
        #expect(viewState.progressFraction == 1)
        #expect(viewState.progressText == "3/3 complete")
        #expect(viewState.blockerText == "No blockers")
    }
}

private func inspectionStage() -> InspectionStage {
    InspectionStage(
        id: "06_rain",
        code: "06_rain",
        title: "Rain Test",
        displayOrder: 6,
        subtitle: "IMD validation and water spray procedure",
        sections: [
            InspectionSection(
                id: "rain.primary",
                title: "Rain Test Checks",
                displayOrder: 1,
                testCases: [
                    InspectionTestCase(
                        id: "rain-rml",
                        code: "RAIN-RML",
                        displayOrder: 1,
                        title: "Rain test RML behavior",
                        ruleReferences: ["RAIN.1"],
                        steps: [
                            inspectionStep(
                                id: "RT-07",
                                title: "Activate TS",
                                type: .action
                            ),
                            inspectionStep(
                                id: "RT-08",
                                title: "RML flashing",
                                requiresEvidence: true
                            )
                        ]
                    ),
                    InspectionTestCase(
                        id: "egress-case",
                        code: "EGRESS",
                        displayOrder: 2,
                        title: "Driver egress timing",
                        ruleReferences: ["VE.5"],
                        steps: [measurementStep()]
                    )
                ]
            )
        ]
    )
}

private func inspectionStep(
    id: String,
    title: String,
    type: InspectionTestStepType = .check,
    requiresEvidence: Bool = false
) -> InspectionTestStep {
    InspectionTestStep(
        id: id,
        code: id,
        ruleReference: "EV.6.1",
        title: title,
        type: type,
        content: "Test content for \(title).",
        requiredOutcome: true,
        requiresEvidence: requiresEvidence
    )
}

private func measurementStep() -> InspectionTestStep {
    InspectionTestStep(
        id: "EG-14",
        code: "EG-14",
        ruleReference: "VE.5",
        title: "Egress time",
        type: .measurement,
        content: "Measure elapsed egress time.",
        requiredOutcome: true,
        requiresEvidence: false,
        measurementRange: MeasurementRange(
            unit: .seconds,
            minimum: Decimal(string: "0.00")!,
            maximum: Decimal(string: "4.99")!,
            maximumFractionDigits: 2
        )
    )
}

private func evidenceAttachment() -> EvidenceAttachmentMetadata {
    EvidenceAttachmentMetadata(
        id: "rml-visible-photo",
        displayName: "RML visible photo",
        mediaType: .photo,
        source: .mockAttachment,
        createdAt: Date(timeIntervalSince1970: 1_780_000_000)
    )
}
