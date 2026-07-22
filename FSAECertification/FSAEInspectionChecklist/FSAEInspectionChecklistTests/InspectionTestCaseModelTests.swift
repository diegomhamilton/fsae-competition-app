import Foundation
import Testing
@testable import FSAEInspectionChecklist

@MainActor
struct InspectionTestCaseModelTests {
    @Test("US-002 opening a test case exposes identity, order, ordered steps, and rule references")
    func us002OpenTestCaseFromStageExposesOrderedStepsAndRuleReferences() throws {
        let testCase = InspectionTestCase(
            id: "rain-rml",
            code: "RAIN-RML",
            displayOrder: 20,
            title: "Rain test RML behavior",
            ruleReferences: ["EV.6.1", "IN.11.3"],
            steps: [
                inspectionStep(id: "RT-08", displayOrder: 30, ruleReference: "EV.6.1", title: "RML flashing"),
                inspectionStep(id: "RT-01", displayOrder: 10, ruleReference: "IN.4.1", title: "PPE verified"),
                inspectionStep(id: "RT-07", displayOrder: 20, ruleReference: "Rain 7", title: "Activate TS")
            ]
        )

        #expect(testCase.id == "rain-rml")
        #expect(testCase.code == "RAIN-RML")
        #expect(testCase.displayOrder == 20)
        #expect(testCase.title == "Rain test RML behavior")
        #expect(testCase.ruleReferences == ["EV.6.1", "IN.11.3"])
        #expect(testCase.orderedSteps.map(\.id) == ["RT-01", "RT-07", "RT-08"])
        #expect(testCase.orderedSteps.map(\.ruleReference) == ["IN.4.1", "Rain 7", "EV.6.1"])
    }

    @Test("US-002 decoded test steps inherit parent rule reference when omitted")
    func us002DecodedTestStepsInheritParentRuleReferenceWhenOmitted() throws {
        let json = """
        {
          "id": "rain-rml",
          "code": "RAIN-RML",
          "displayOrder": 20,
          "title": "Rain test RML behavior",
          "ruleReferences": ["RAIN.1"],
          "steps": [
            {
              "id": "RT-08",
              "code": "RT-08",
              "displayOrder": 10,
              "title": "RML flashing",
              "type": "check",
              "content": "Verify the RML is flashing after TS activation."
            }
          ]
        }
        """

        let testCase = try JSONDecoder().decode(InspectionTestCase.self, from: Data(json.utf8))

        #expect(testCase.ruleReferences == ["RAIN.1"])
        #expect(testCase.orderedSteps.map(\.ruleReference) == ["RAIN.1"])
        #expect(testCase.allRuleReferences == ["RAIN.1"])
    }

    @Test("US-002 decoded ruleRef array preserves discrete rule references")
    func us002DecodedRuleRefArrayPreservesDiscreteRuleReferences() throws {
        let json = """
        {
          "id": "accumulator-attachments",
          "code": "EV41",
          "displayOrder": 41,
          "title": "Accumulator attachment check",
          "ruleRef": ["EV.8.3", "EV.8.4.1", "IN.4.4"],
          "steps": [
            {
              "id": "EV41-1",
              "code": "EV41-1",
              "displayOrder": 1,
              "title": "Check attachment rules",
              "type": "check",
              "content": "Verify the accumulator attachment rule references are available individually."
            }
          ]
        }
        """

        let testCase = try JSONDecoder().decode(InspectionTestCase.self, from: Data(json.utf8))

        #expect(testCase.ruleReferences == ["EV.8.3", "EV.8.4.1", "IN.4.4"])
        #expect(testCase.orderedSteps.map(\.ruleReference) == ["EV.8.3"])
        #expect(testCase.allRuleReferences == ["EV.8.3", "EV.8.4.1", "IN.4.4"])
    }

    @Test("US-002 test case draft aggregates child outcomes, notes, measurements, and evidence")
    func us002TestCaseDraftAggregatesChildStepDrafts() throws {
        let measurementRange = egressMeasurementRange()
        let measurement = try MeasurementValue(rawValue: "4.38", range: measurementRange)
        let evidence = evidenceAttachment(id: "rml-visible-photo")

        let draft = TestCaseDraft(
            testCaseID: "rain-rml",
            stepDrafts: [
                TestStepDraft(
                    stepID: "RT-08",
                    outcome: .fail,
                    notes: "RML did not flash after TS activation.",
                    evidenceAttachments: [evidence]
                ),
                TestStepDraft(
                    stepID: "EG-14",
                    outcome: .pass,
                    measurementInput: "4.38",
                    measurementValue: measurement
                )
            ]
        )

        let aggregate = draft.aggregate

        #expect(aggregate.outcomesByStepID["RT-08"] == InspectionOutcome.fail)
        #expect(aggregate.notesByStepID["RT-08"] == "RML did not flash after TS activation.")
        #expect(aggregate.measurementsByStepID["EG-14"] == measurement)
        #expect(aggregate.evidenceAttachmentsByStepID["RT-08"] == [evidence])
        #expect(aggregate.failedStepIDs == ["RT-08"])
    }

    @Test("US-002/US-003/US-004 validation blockers count missing outcomes, notes, measurements, and evidence")
    func us002Us003Us004BlockerCountsIncludeAllInvalidStepDrafts() {
        let testCase = InspectionTestCase(
            id: "blocked-case",
            code: "BLOCKED",
            displayOrder: 1,
            title: "Blocked submission examples",
            ruleReferences: ["EV.6.1", "VE.5"],
            steps: [
                inspectionStep(id: "RT-08", displayOrder: 10, title: "RML flashing", requiresEvidence: true),
                inspectionStep(
                    id: "EG-14",
                    displayOrder: 20,
                    type: .measurement,
                    title: "Egress time",
                    measurementRange: egressMeasurementRange()
                ),
                inspectionStep(id: "BP-01", displayOrder: 30, title: "Brake pedal travel"),
                inspectionStep(id: "NF-01", displayOrder: 40, title: "Notes required")
            ]
        )
        let draft = TestCaseDraft(
            testCaseID: testCase.id,
            stepDrafts: [
                TestStepDraft(stepID: "RT-08", outcome: .pass),
                TestStepDraft(stepID: "EG-14", outcome: .pass, measurementInput: "5.40"),
                TestStepDraft(stepID: "BP-01", outcome: .pending),
                TestStepDraft(stepID: "NF-01", outcome: .fail, notes: "")
            ]
        )

        let summary = draft.validationSummary(for: testCase)

        #expect(summary.blockerCount == 4)
        let expectedIssueCodes: [ValidationIssue.Code] = [
            .missingRequiredEvidence(stepID: "RT-08"),
            .invalidMeasurement(stepID: "EG-14", error: .outsideAllowedRange),
            .missingRequiredOutcome(stepID: "BP-01"),
            .missingInspectorNote(stepID: "NF-01")
        ]
        #expect(summary.issues.map(\.code) == expectedIssueCodes)
        #expect(summary.firstBlockingStepID == "RT-08")
    }

    @Test("US-003 valid measurements make a test case step complete")
    func us003ValidMeasurementContributesToTestCaseProgress() throws {
        let measurementRange = egressMeasurementRange()
        let testCase = InspectionTestCase(
            id: "egress",
            code: "EGRESS",
            displayOrder: 50,
            title: "Egress test",
            ruleReferences: ["VE.5"],
            steps: [
                inspectionStep(
                    id: "EG-14",
                    displayOrder: 10,
                    type: .measurement,
                    title: "Egress time",
                    measurementRange: measurementRange
                )
            ]
        )
        let draft = TestCaseDraft(
            testCaseID: testCase.id,
            stepDrafts: [
                TestStepDraft(
                    stepID: "EG-14",
                    outcome: .pass,
                    measurementInput: "4.38",
                    measurementValue: try MeasurementValue(rawValue: "4.38", range: measurementRange)
                )
            ]
        )

        let progress = draft.progress(for: testCase)

        #expect(progress.totalStepCount == 1)
        #expect(progress.completeStepCount == 1)
        #expect(progress.blockedStepCount == 0)
        #expect(progress.pendingStepCount == 0)
        #expect(progress.fractionComplete == 1.0)
    }

    @Test("US-004 removing required evidence makes the test case blocked again")
    func us004RemovingRequiredEvidenceMakesTestCaseProgressBlocked() {
        let testCase = InspectionTestCase(
            id: "rain-rml",
            code: "RAIN-RML",
            displayOrder: 20,
            title: "Rain test RML behavior",
            ruleReferences: ["EV.6.1"],
            steps: [
                inspectionStep(id: "RT-08", displayOrder: 10, title: "RML flashing", requiresEvidence: true)
            ]
        )
        let draft = TestCaseDraft(
            testCaseID: testCase.id,
            stepDrafts: [
                TestStepDraft(stepID: "RT-08", outcome: .pass, evidenceAttachments: [])
            ]
        )

        let progress = draft.progress(for: testCase)
        let summary = draft.validationSummary(for: testCase)

        #expect(progress.totalStepCount == 1)
        #expect(progress.completeStepCount == 0)
        #expect(progress.blockedStepCount == 1)
        #expect(progress.pendingStepCount == 0)
        #expect(summary.blockerCount == 1)
        let expectedIssueCodes: [ValidationIssue.Code] = [.missingRequiredEvidence(stepID: "RT-08")]
        #expect(summary.issues.map(\.code) == expectedIssueCodes)
    }
}

private func inspectionStep(
    id: String,
    displayOrder: Int,
    type: InspectionTestStepType = .check,
    ruleReference: String = "EV.6.1",
    title: String,
    requiredOutcome: Bool = true,
    requiresEvidence: Bool = false,
    measurementRange: MeasurementRange? = nil
) -> InspectionTestStep {
    InspectionTestStep(
        id: id,
        code: id,
        displayOrder: displayOrder,
        ruleReference: ruleReference,
        title: title,
        type: type,
        content: "Test content for \(title).",
        requiredOutcome: requiredOutcome,
        requiresEvidence: requiresEvidence,
        measurementRange: measurementRange
    )
}

private func egressMeasurementRange() -> MeasurementRange {
    MeasurementRange(
        unit: .seconds,
        minimum: decimal("0.00"),
        maximum: decimal("4.99"),
        maximumFractionDigits: 2
    )
}

private func evidenceAttachment(id: String) -> EvidenceAttachmentMetadata {
    EvidenceAttachmentMetadata(
        id: id,
        displayName: "RML visible photo",
        mediaType: .photo,
        source: .mockAttachment,
        createdAt: Date(timeIntervalSince1970: 1_780_000_000)
    )
}

private func decimal(_ rawValue: String) -> Decimal {
    Decimal(string: rawValue, locale: Locale(identifier: "en_US_POSIX")) ?? 0
}
