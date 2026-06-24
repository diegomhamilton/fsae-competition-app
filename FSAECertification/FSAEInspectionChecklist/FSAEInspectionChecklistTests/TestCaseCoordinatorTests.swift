import Foundation
import Testing
@testable import FSAEInspectionChecklist

@MainActor
struct TestCaseCoordinatorTests {
    @Test("OpenSpec Open test case from stage selects parent draft")
    func openTestCaseFromStageSelectsParentDraft() {
        let coordinator = TestCaseCoordinator(stageContext: stageContext())

        let didOpen = coordinator.openTestCase(id: "rain-rml")

        #expect(didOpen)
        #expect(coordinator.route == .testCase(testCaseID: "rain-rml"))
        #expect(coordinator.activeTestCaseDraft?.testCase.title == "Rain test RML behavior")
        #expect(coordinator.activeTestCaseDraft?.testCase.stepIDs == ["RT-07", "RT-08"])
        #expect(coordinator.activeTestCaseDraft?.testCase.allRuleReferences == ["RAIN.1", "EV.6.1"])
        #expect(coordinator.activeStepDraft == nil)
    }

    @Test("OpenSpec Open test step from test case uses active draft values")
    func openTestStepFromTestCaseUsesActiveDraftValues() throws {
        let coordinator = TestCaseCoordinator(stageContext: stageContext())

        #expect(coordinator.openTestCase(id: "rain-rml"))
        #expect(coordinator.openTestStep(id: "RT-08"))

        let draft = try #require(coordinator.activeStepDraft)
        #expect(coordinator.route == .testStep(testCaseID: "rain-rml", stepID: "RT-08"))
        #expect(draft.stepID == "RT-08")
        #expect(draft.outcome == .pending)
        #expect(draft.notes == "Photo required if visibility is disputed.")
        #expect(draft.evidenceAttachments.isEmpty)
    }

    @Test("US-003 US-004 coordinator applies edits to active step draft")
    func coordinatorAppliesEditsToActiveStepDraft() throws {
        let coordinator = TestCaseCoordinator(stageContext: stageContext())
        let evidence = evidenceAttachment()

        #expect(coordinator.openTestCase(id: "egress-case"))
        #expect(coordinator.openTestStep(id: "EG-14"))

        coordinator.applyOutcome(.fail)
        coordinator.applyNotes("Driver exceeded target time.")
        coordinator.applyMeasurementInput("4.38")
        coordinator.applyEvidenceAttachments([evidence])

        let stepDraft = try #require(coordinator.activeStepDraft)
        let parentStepDraft = try #require(coordinator.activeTestCaseDraft?.stepDraft(stepID: "EG-14")?.draft)

        #expect(stepDraft.outcome == .fail)
        #expect(stepDraft.notes == "Driver exceeded target time.")
        #expect(stepDraft.measurementInput == "4.38")
        #expect(stepDraft.measurementValue?.formattedValue == "4.38 s")
        #expect(stepDraft.evidenceAttachments == [evidence])
        #expect(parentStepDraft.outcome == .pending)
        #expect(parentStepDraft.measurementInput == "")
    }

    @Test("OpenSpec edited step draft returns to parent test case")
    func editedStepDraftReturnsToParentTestCase() throws {
        let coordinator = TestCaseCoordinator(stageContext: stageContext())
        let evidence = evidenceAttachment()

        #expect(coordinator.openTestCase(id: "rain-rml"))
        #expect(coordinator.openTestStep(id: "RT-08"))
        coordinator.applyOutcome(.pass)
        coordinator.applyNotes("RML visible after TS activation.")
        coordinator.applyEvidenceAttachments([evidence])

        #expect(coordinator.returnToTestCase())

        let parentDraft = try #require(coordinator.activeTestCaseDraft)
        let returnedStep = try #require(parentDraft.stepDraft(stepID: "RT-08")?.draft)
        #expect(coordinator.route == .testCase(testCaseID: "rain-rml"))
        #expect(coordinator.activeStepDraft == nil)
        #expect(returnedStep.outcome == .pass)
        #expect(returnedStep.notes == "RML visible after TS activation.")
        #expect(returnedStep.evidenceAttachments == [evidence])
        #expect(coordinator.persistedDraft(testCaseID: "rain-rml") == parentDraft)

        #expect(coordinator.openTestStep(id: "RT-08"))
        #expect(coordinator.activeStepDraft == returnedStep)
    }
}

private func stageContext() -> TestCaseListContext {
    TestCaseListContext(
        stageID: 6,
        stageTitle: "Rain Test",
        testCases: [
            InspectionTestCase(
                id: "rain-rml",
                code: "RAIN-RML",
                title: "Rain test RML behavior",
                ruleReferences: ["RAIN.1"],
                steps: [
                    inspectionStep(
                        id: "RT-07",
                        title: "Activate TS",
                        type: .action,
                        defaultOutcome: .pass
                    ),
                    inspectionStep(
                        id: "RT-08",
                        title: "RML flashing",
                        requiresEvidence: true,
                        defaultNote: "Photo required if visibility is disputed."
                    )
                ]
            ),
            InspectionTestCase(
                id: "egress-case",
                code: "EGRESS",
                title: "Driver egress timing",
                ruleReferences: ["VE.5"],
                steps: [measurementStep()]
            )
        ]
    )
}

private func inspectionStep(
    id: String,
    title: String,
    type: InspectionTestStepType = .check,
    requiresEvidence: Bool = false,
    defaultOutcome: InspectionOutcome = .pending,
    defaultNote: String = ""
) -> InspectionTestStep {
    InspectionTestStep(
        id: id,
        code: id,
        ruleReference: "EV.6.1",
        title: title,
        type: type,
        content: "Test content for \(title).",
        requiredOutcome: true,
        requiresEvidence: requiresEvidence,
        defaultOutcome: defaultOutcome,
        defaultNote: defaultNote
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
