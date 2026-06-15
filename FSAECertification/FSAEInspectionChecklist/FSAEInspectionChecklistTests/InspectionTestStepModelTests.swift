import Foundation
import Testing
@testable import FSAEInspectionChecklist

struct InspectionTestStepModelTests {
    @Test("US-002 decodes an inspection test step with outcome, evidence requirement, and safety metadata")
    func us002DecodesInspectionTestStepWithOutcomeEvidenceAndSafetyMetadata() throws {
        let json = """
        {
          "id": "RT-08",
          "code": "RT-08",
          "ruleReference": "EV.6.1",
          "title": "RML flashing",
          "type": "check",
          "content": "Verify the RML is flashing after TS activation.",
          "outcome": "pending",
          "isRequired": true,
          "evidenceRequirement": {
            "isRequired": true,
            "minimumAttachmentCount": 1
          },
          "safetyBadges": ["energized"]
        }
        """

        let step = try JSONDecoder().decode(InspectionTestStep.self, from: Data(json.utf8))

        #expect(step.id == "RT-08")
        #expect(step.code == "RT-08")
        #expect(step.ruleReference == "EV.6.1")
        #expect(step.title == "RML flashing")
        #expect(step.type == .check)
        #expect(step.outcome == .pending)
        #expect(step.isRequired)
        #expect(step.evidenceRequirement.isRequired)
        #expect(step.evidenceRequirement.minimumAttachmentCount == 1)
        #expect(step.safetyBadges == [.energized])
    }

    @Test("US-002 inspection outcomes model required completion and failed-note policy")
    func us002InspectionOutcomeModelsSubmissionAndFailedNotePolicy() {
        #expect(InspectionOutcome.pass.satisfiesRequiredOutcome)
        #expect(InspectionOutcome.fail.satisfiesRequiredOutcome)
        #expect(InspectionOutcome.notApplicable.satisfiesRequiredOutcome)
        #expect(!InspectionOutcome.pending.satisfiesRequiredOutcome)

        #expect(!InspectionOutcome.pass.requiresInspectorNote(whenFailedNotesAreRequired: true))
        #expect(InspectionOutcome.fail.requiresInspectorNote(whenFailedNotesAreRequired: true))
        #expect(!InspectionOutcome.fail.requiresInspectorNote(whenFailedNotesAreRequired: false))

        #expect(InspectionOutcome.pass.localizationKey == "inspection.outcome.pass")
        #expect(InspectionOutcome.fail.localizationKey == "inspection.outcome.fail")
        #expect(InspectionOutcome.notApplicable.localizationKey == "inspection.outcome.notApplicable")
        #expect(InspectionOutcome.pending.localizationKey == "inspection.outcome.pending")
    }

    @Test("US-003 measurement values accept valid input and reject non-numeric, over-precision, and out-of-range input")
    func us003MeasurementValueAcceptsValidValuesAndRejectsInvalidValues() throws {
        let rule = MeasurementRule(
            unit: .seconds,
            minimum: Decimal(string: "0.00")!,
            maximum: Decimal(string: "4.99")!,
            precision: 2
        )

        let measurement = try MeasurementValue(rawValue: "4.38", rule: rule)

        #expect(measurement.decimalValue == Decimal(string: "4.38")!)
        #expect(measurement.unit == .seconds)
        #expect(measurement.formattedValue == "4.38 seconds")

        #expect(throws: MeasurementValue.ValidationError.nonNumericFormat) {
            try MeasurementValue(rawValue: "fast", rule: rule)
        }
        #expect(throws: MeasurementValue.ValidationError.precisionExceeded) {
            try MeasurementValue(rawValue: "4.999", rule: rule)
        }
        #expect(throws: MeasurementValue.ValidationError.outsideValidRange) {
            try MeasurementValue(rawValue: "5.40", rule: rule)
        }
    }

    @Test("US-004 evidence metadata satisfies required proof and removed metadata no longer counts")
    func us004EvidenceMetadataSatisfiesAndUnsatisfiesEvidenceRequirements() {
        let capturedAt = Date(timeIntervalSince1970: 1_780_000_000)
        let metadata = EvidenceAttachmentMetadata(
            id: "rml-visible-photo",
            filename: "IMG_2042.jpg",
            displayName: "RML visible photo",
            contentType: "image/jpeg",
            capturedBy: "A. Maia",
            capturedAt: capturedAt
        )
        let requirement = EvidenceRequirement(isRequired: true, minimumAttachmentCount: 1)

        #expect(metadata.id == "rml-visible-photo")
        #expect(metadata.accessibilityLabel == "RML visible photo, image/jpeg, captured by A. Maia")
        #expect(!requirement.isSatisfied(by: []))
        #expect(requirement.isSatisfied(by: [metadata]))
        #expect(!requirement.isSatisfied(by: [metadata.removed()]))
    }

    @Test("Accessibility identifier helpers build stable identifiers without localized labels")
    func accessibilityIdentifierHelpersBuildStableIdentifiersWithoutLocalizedLabels() {
        #expect(
            InspectionAccessibilityIdentifier.testStepRow(stepID: "RT-08").rawValue
                == "inspection.testStep.RT-08.row"
        )
        #expect(
            InspectionAccessibilityIdentifier.outcomeControl(stepID: "RT-08", outcome: .fail).rawValue
                == "inspection.testStep.RT-08.outcome.fail"
        )
        #expect(
            InspectionAccessibilityIdentifier.measurementField(stepID: "EG-14").rawValue
                == "inspection.testStep.EG-14.measurement.value"
        )
        #expect(
            InspectionAccessibilityIdentifier.evidenceButton(stepID: "RT-08").rawValue
                == "inspection.testStep.RT-08.evidence.add"
        )
        #expect(
            InspectionAccessibilityIdentifier.doneButton(stepID: "RT-08").rawValue
                == "inspection.testStep.RT-08.done"
        )
    }

    @Test("Localizable string key helpers return structured keys for test step views")
    func localizableStringKeyHelpersReturnStructuredKeysForStepViews() {
        #expect(InspectionStepStrings.title(stepID: "RT-08").key == "inspection.testStep.RT-08.title")
        #expect(InspectionStepStrings.outcome(.pass).key == "inspection.outcome.pass")
        #expect(InspectionStepStrings.outcome(.fail).key == "inspection.outcome.fail")
        #expect(InspectionStepStrings.evidenceRequired.key == "inspection.testStep.evidence.required")
        #expect(InspectionStepStrings.measurementUnit(.seconds).key == "inspection.measurement.unit.seconds")
        #expect(InspectionStepStrings.safetyBadge(.energized).key == "inspection.safetyBadge.energized")
    }
}
