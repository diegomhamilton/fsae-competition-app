import Foundation
import Testing
@testable import FSAEInspectionChecklist

@MainActor
struct InspectionTestCaseModelTests {
    @Test("US-002 decodes an inspection test case with ordered steps and rule references")
    func us002DecodesInspectionTestCaseWithOrderedStepsAndRuleReferences() throws {
        let json = """
        {
          "id": "rain-rml",
          "code": "RAIN-RML",
          "title": "Rain test RML visibility",
          "ruleReferences": ["EV.6.1"],
          "steps": [
            {
              "id": "RT-07",
              "code": "RT-07",
              "ruleReference": "Rain 7",
              "title": "Activate TS",
              "type": "action",
              "content": "Instruct the ESO to activate the tractive system.",
              "requiredOutcome": true,
              "requiresEvidence": false,
              "safetyBadges": [],
              "defaultOutcome": "pass",
              "defaultNote": "",
              "measurementRange": null,
              "evidenceAttachments": []
            },
            {
              "id": "RT-08",
              "code": "RT-08",
              "ruleReference": "EV.6.1",
              "title": "RML flashing",
              "type": "check",
              "content": "Verify the RML is flashing after TS activation.",
              "requiredOutcome": true,
              "requiresEvidence": true,
              "safetyBadges": ["energized"],
              "defaultOutcome": "pending",
              "defaultNote": "Photo required if visibility is disputed.",
              "measurementRange": null,
              "evidenceAttachments": []
            }
          ]
        }
        """

        let testCase = try JSONDecoder().decode(InspectionTestCase.self, from: Data(json.utf8))

        #expect(testCase.id == "rain-rml")
        #expect(testCase.code == "RAIN-RML")
        #expect(testCase.title == "Rain test RML visibility")
        #expect(testCase.stepIDs == ["RT-07", "RT-08"])
        #expect(testCase.orderedSteps.map(\.title) == ["Activate TS", "RML flashing"])
        #expect(testCase.allRuleReferences == ["EV.6.1", "Rain 7"])
        #expect(testCase.orderedSteps[1].safetyBadges == [.energized])
    }

    @Test("US-002 composes test case draft state in content order with stable step IDs")
    func us002ComposesDraftStateInContentOrderWithStableStepIDs() {
        let testCase = makeTestCase()
        let drafts = [
            TestStepDraft(stepID: "RT-08", outcome: .fail, notes: "RML did not flash."),
            TestStepDraft(stepID: "RT-07", outcome: .pass)
        ]

        let draft = TestCaseDraft(testCase: testCase, stepDrafts: drafts)

        #expect(draft.id == "rain-rml")
        #expect(draft.steps.map(\.id) == ["RT-07", "RT-08", "EG-14"])
        #expect(draft.stepDraft(stepID: "RT-08")?.draft.outcome == .fail)
        #expect(draft.stepDraft(stepID: "RT-08")?.draft.notes == "RML did not flash.")
        #expect(draft.stepDraft(stepID: "EG-14")?.draft.outcome == .pending)
    }

    @Test("US-002 test case progress is derived from composed step draft state")
    func us002ProgressIsDerivedFromComposedStepDraftState() throws {
        let testCase = makeTestCase()
        let range = makeMeasurementRange()
        let measurement = try MeasurementValue(rawValue: "4.38", range: range)

        let partialDraft = TestCaseDraft(
            testCase: testCase,
            stepDrafts: [
                TestStepDraft(stepID: "RT-07", outcome: .pass),
                TestStepDraft(stepID: "RT-08", outcome: .pass),
                TestStepDraft(
                    stepID: "EG-14",
                    outcome: .pass,
                    measurementInput: "4.38",
                    measurementValue: measurement
                )
            ]
        )

        #expect(partialDraft.progress.completedStepCount == 2)
        #expect(partialDraft.progress.totalStepCount == 3)
        #expect(partialDraft.progress.blockerCount == 1)
        #expect(partialDraft.progress.fractionComplete == 2.0 / 3.0)

        let completeDraft = TestCaseDraft(
            testCase: testCase,
            stepDrafts: [
                TestStepDraft(stepID: "RT-07", outcome: .pass),
                TestStepDraft(
                    stepID: "RT-08",
                    outcome: .pass,
                    evidenceAttachments: [makeEvidenceAttachment()]
                ),
                TestStepDraft(
                    stepID: "EG-14",
                    outcome: .pass,
                    measurementInput: "4.38",
                    measurementValue: measurement
                )
            ]
        )

        #expect(completeDraft.progress.completedStepCount == 3)
        #expect(completeDraft.progress.blockerCount == 0)
        #expect(completeDraft.progress.fractionComplete == 1)
    }

    @Test("US-002 failed notes remain draft data and do not block model progress in TASK 5.3")
    func us002FailedNotesRemainDraftDataWithoutValidationServiceRules() {
        let step = InspectionTestStep(
            id: "RT-08",
            code: "RT-08",
            ruleReference: "EV.6.1",
            title: "RML flashing",
            type: .check,
            content: "Verify the RML is flashing after TS activation.",
            requiredOutcome: true,
            requiresEvidence: false
        )
        let testCase = InspectionTestCase(
            id: "rain-rml",
            code: "RAIN-RML",
            title: "Rain test RML visibility",
            steps: [step]
        )

        let draft = TestCaseDraft(
            testCase: testCase,
            stepDrafts: [TestStepDraft(stepID: "RT-08", outcome: .fail, notes: "")]
        )

        #expect(draft.progress.completedStepCount == 1)
        #expect(draft.progress.blockerCount == 0)
        #expect(draft.stepDraft(stepID: "RT-08")?.draft.notes == "")
    }

    private func makeTestCase() -> InspectionTestCase {
        InspectionTestCase(
            id: "rain-rml",
            code: "RAIN-RML",
            title: "Rain test RML visibility",
            ruleReferences: ["EV.6.1"],
            steps: [
                InspectionTestStep(
                    id: "RT-07",
                    code: "RT-07",
                    ruleReference: "Rain 7",
                    title: "Activate TS",
                    type: .action,
                    content: "Instruct the ESO to activate the tractive system.",
                    requiredOutcome: true,
                    requiresEvidence: false
                ),
                InspectionTestStep(
                    id: "RT-08",
                    code: "RT-08",
                    ruleReference: "EV.6.1",
                    title: "RML flashing",
                    type: .check,
                    content: "Verify the RML is flashing after TS activation.",
                    requiredOutcome: true,
                    requiresEvidence: true
                ),
                InspectionTestStep(
                    id: "EG-14",
                    code: "EG-14",
                    ruleReference: "VE.5",
                    title: "Egress time",
                    type: .measurement,
                    content: "Measure elapsed egress time.",
                    requiredOutcome: true,
                    requiresEvidence: false,
                    measurementRange: makeMeasurementRange()
                )
            ]
        )
    }

    private func makeMeasurementRange() -> MeasurementRange {
        MeasurementRange(
            unit: .seconds,
            minimum: Decimal(string: "0.00")!,
            maximum: Decimal(string: "4.99")!,
            maximumFractionDigits: 2
        )
    }

    private func makeEvidenceAttachment() -> EvidenceAttachmentMetadata {
        EvidenceAttachmentMetadata(
            id: "rml-visible-photo",
            displayName: "RML visible photo",
            mediaType: .photo,
            source: .mockAttachment,
            createdAt: Date(timeIntervalSince1970: 1_780_000_000)
        )
    }
}
