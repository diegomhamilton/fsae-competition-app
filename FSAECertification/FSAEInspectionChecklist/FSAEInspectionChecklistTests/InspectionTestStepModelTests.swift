import Foundation
import Testing
@testable import FSAEInspectionChecklist

@MainActor
struct InspectionTestStepModelTests {
    @Test("US-002 decodes an inspection test step with default outcome, evidence requirement, and safety metadata")
    func us002DecodesInspectionTestStepWithDefaultOutcomeEvidenceAndSafetyMetadata() throws {
        let json = """
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
        """

        let step = try JSONDecoder().decode(InspectionTestStep.self, from: Data(json.utf8))

        #expect(step.id == "RT-08")
        #expect(step.code == "RT-08")
        #expect(step.ruleReference == "EV.6.1")
        #expect(step.title == "RML flashing")
        #expect(step.type == .check)
        #expect(step.defaultOutcome == .pending)
        #expect(step.requiredOutcome)
        #expect(step.requiresEvidence)
        #expect(step.defaultNote == "Photo required if visibility is disputed.")
        #expect(step.safetyBadges == [.energized])
    }

    @Test("Energized badge derivation preserves explicit badges and accessibility text")
    func energizedBadgeDerivationPreservesExplicitBadgesAndAccessibilityText() {
        let testCase = InspectionTestCase(
            id: "EV101",
            code: "EV101",
            displayOrder: 100,
            title: "IMD SHUTDOWN TEST",
            ruleReferences: ["EV.7.6 / EV.5.11"],
            safetyBadges: [.energized],
            steps: [
                InspectionTestStep(
                    id: "EV101.1",
                    code: "EV101-1",
                    displayOrder: 1,
                    ruleReference: "EV.7.6",
                    title: "Measure response",
                    type: .measurement,
                    content: "Measure response under energized conditions.",
                    requiredOutcome: true,
                    requiresEvidence: false
                )
            ]
        )

        #expect(testCase.derivedSafetyBadges == [.energized])
        #expect(testCase.displaySafetyBadges == [.energized])
        #expect(InspectionSafetyBadge.energized.displayName == "CAUTION: ENERGIZED")
        #expect(InspectionSafetyBadge.energized.accessibilityLabel == "Caution, energized dynamic test step")
    }

    @Test("US-002 inspection outcomes model required completion and failed-note policy")
    func us002InspectionOutcomeModelsSubmissionAndFailedNotePolicy() {
        #expect(InspectionOutcome.pass.satisfiesRequiredOutcome)
        #expect(InspectionOutcome.fail.satisfiesRequiredOutcome)
        #expect(InspectionOutcome.notApplicable.satisfiesRequiredOutcome)
        #expect(!InspectionOutcome.pending.satisfiesRequiredOutcome)

        #expect(!InspectionOutcome.pass.requiresInspectorNote)
        #expect(InspectionOutcome.fail.requiresInspectorNote)
        #expect(!InspectionOutcome.notApplicable.requiresInspectorNote)
        #expect(!InspectionOutcome.pending.requiresInspectorNote)

        #expect(InspectionOutcome.pass.displayName == "Pass")
        #expect(InspectionOutcome.fail.displayName == "Fail")
        #expect(InspectionOutcome.notApplicable.displayName == "N/A")
        #expect(InspectionOutcome.pending.displayName == "Pending")
    }

    @Test("US-003 measurement values accept valid input and reject non-numeric, over-precision, and out-of-range input")
    func us003MeasurementValueAcceptsValidValuesAndRejectsInvalidValues() throws {
        let range = MeasurementRange(
            unit: .seconds,
            minimum: Decimal(string: "0.00")!,
            maximum: Decimal(string: "4.99")!,
            maximumFractionDigits: 2
        )

        let measurement = try MeasurementValue(rawValue: "4.38", range: range)

        #expect(measurement.value == Decimal(string: "4.38")!)
        #expect(measurement.unit == .seconds)
        #expect(measurement.formattedValue == "4.38 s")

        #expect(throws: MeasurementValue.ValidationError.nonNumericFormat) {
            try MeasurementValue(rawValue: "fast", range: range)
        }
        #expect(throws: MeasurementValue.ValidationError.precisionExceeded) {
            try MeasurementValue(rawValue: "4.999", range: range)
        }
        #expect(throws: MeasurementValue.ValidationError.outsideAllowedRange) {
            try MeasurementValue(rawValue: "5.40", range: range)
        }
    }

    @Test("US-003 measurement values accept inclusive bounds")
    func us003MeasurementValueAcceptsInclusiveBounds() throws {
        let range = MeasurementRange(
            unit: .seconds,
            minimum: Decimal(string: "0.00")!,
            maximum: Decimal(string: "4.99")!,
            maximumFractionDigits: 2
        )

        let minimum = try MeasurementValue(rawValue: "0.00", range: range)
        let maximum = try MeasurementValue(rawValue: "4.99", range: range)

        #expect(minimum.value == Decimal(string: "0.00")!)
        #expect(minimum.unit == .seconds)
        #expect(maximum.value == Decimal(string: "4.99")!)
        #expect(maximum.unit == .seconds)
    }

    @Test("US-003 measurement values trim padded numeric input before parsing")
    func us003MeasurementValueTrimsPaddedNumericInput() throws {
        let range = MeasurementRange(
            unit: .seconds,
            minimum: Decimal(string: "0.00")!,
            maximum: Decimal(string: "4.99")!,
            maximumFractionDigits: 2
        )

        let measurement = try MeasurementValue(rawValue: " \n4.38\t ", range: range)

        #expect(measurement.value == Decimal(string: "4.38")!)
        #expect(measurement.formattedValue == "4.38 s")
    }

    @Test("US-004 evidence metadata stores attachment display data for required proof")
    func us004EvidenceMetadataStoresAttachmentDisplayDataForRequiredProof() {
        let createdAt = Date(timeIntervalSince1970: 1_780_000_000)
        let metadata = EvidenceAttachmentMetadata(
            id: "rml-visible-photo",
            displayName: "RML visible photo",
            mediaType: .photo,
            source: .mockAttachment,
            createdAt: createdAt
        )

        #expect(metadata.id == "rml-visible-photo")
        #expect(metadata.displayName == "RML visible photo")
        #expect(metadata.mediaType == .photo)
        #expect(metadata.source == .mockAttachment)
        #expect(metadata.createdAt == createdAt)
        #expect(metadata.accessibilityValue == "Attachment RML visible photo added")
    }

    @Test("Accessibility identifier helpers build stable identifiers without localized labels")
    func accessibilityIdentifierHelpersBuildStableIdentifiersWithoutLocalizedLabels() {
        #expect(
            InspectionAccessibilityIdentifier.testStepRow(stepID: "RT-08").rawValue
                == "inspection.testStep.RT-08.row"
        )
        #expect(
            InspectionAccessibilityIdentifier.testStepOutcome(stepID: "RT-08", outcome: .fail).rawValue
                == "inspection.testStep.RT-08.outcome.fail"
        )
        #expect(
            InspectionAccessibilityIdentifier.measurementField(stepID: "EG-14").rawValue
                == "inspection.testStep.EG-14.measurement"
        )
        #expect(
            InspectionAccessibilityIdentifier.evidenceAction(stepID: "RT-08").rawValue
                == "inspection.testStep.RT-08.evidence.action"
        )
        #expect(
            InspectionAccessibilityIdentifier.doneAction(stepID: "RT-08").rawValue
                == "inspection.testStep.RT-08.done"
        )
        #expect(
            InspectionAccessibilityIdentifier.sessionSelectorTeamRow(teamID: 13).rawValue
                == "inspection.sessionSelector.team.13.row"
        )
        #expect(
            InspectionAccessibilityIdentifier.sessionSelectorTeamStatus(teamID: 13).rawValue
                == "inspection.sessionSelector.team.13.status"
        )
        #expect(
            InspectionAccessibilityIdentifier.sessionSelectorTeamResumeIndicator(teamID: 13).rawValue
                == "inspection.sessionSelector.team.13.resume"
        )
        #expect(
            InspectionAccessibilityIdentifier.sessionSelectorTeamBlockedIndicator(teamID: 13).rawValue
                == "inspection.sessionSelector.team.13.blocked"
        )
        #expect(
            InspectionAccessibilityIdentifier.activeTeamDashboardSwitchTeamAction(teamID: 13).rawValue
                == "inspection.dashboard.team.13.switchTeam"
        )
        #expect(
            InspectionAccessibilityIdentifier.activeTeamDashboardOpenCurrentStageAction(teamID: 13, stageID: "06_rain").rawValue
                == "inspection.dashboard.team.13.stage.06_rain.openCurrent"
        )
        #expect(
            InspectionAccessibilityIdentifier.activeTeamDashboardStageRow(teamID: 13, stageID: "06_rain").rawValue
                == "inspection.dashboard.team.13.stage.06_rain.row"
        )
        #expect(
            InspectionAccessibilityIdentifier.activeTeamDashboardStageStatus(teamID: 13, stageID: "06_rain").rawValue
                == "inspection.dashboard.team.13.stage.06_rain.status"
        )
        #expect(
            InspectionAccessibilityIdentifier.teamSwitchCancelAction(currentTeamID: 13, targetTeamID: 15).rawValue
                == "inspection.teamSwitch.current.13.target.15.cancel"
        )
        #expect(
            InspectionAccessibilityIdentifier.teamSwitchConfirmAction(currentTeamID: 13, targetTeamID: 15).rawValue
                == "inspection.teamSwitch.current.13.target.15.confirm"
        )
    }

    @Test("Localizable string key helpers return structured keys for test step views")
    func localizableStringKeyHelpersReturnStructuredKeysForStepViews() {
        #expect(InspectionTestStepStrings.title.key == "inspection.testStep.title")
        #expect(InspectionTestStepStrings.title.key(for: "RT-08") == "inspection.testStep.RT-08.title")
        #expect(InspectionTestStepStrings.notesPlaceholder.key == "inspection.testStep.notes.placeholder")
        #expect(
            InspectionTestStepStrings.notesPlaceholder.key(for: "RT-08")
                == "inspection.testStep.RT-08.notes.placeholder"
        )
        #expect(InspectionTestStepStrings.evidenceRequired.key == "inspection.testStep.evidence.required")
        #expect(
            InspectionTestStepStrings.measurementError(.outsideAllowedRange).key
                == "inspection.testStep.measurement.error.outsideAllowedRange"
        )
    }
}
