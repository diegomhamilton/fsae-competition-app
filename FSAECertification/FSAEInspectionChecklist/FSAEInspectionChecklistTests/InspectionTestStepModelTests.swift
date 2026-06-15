import XCTest
@testable import FSAEInspectionChecklist

final class InspectionTestStepModelTests: XCTestCase {
    func testUS002CheckStepCapturesRuleEvidenceAndPendingOutcome() {
        let step = InspectionTestStep(
            id: "RT-08",
            code: "RT-08",
            ruleReference: "EV.6.1",
            title: "RML flashing",
            type: .check,
            content: "Verify the RML is flashing after TS activation.",
            requiredOutcome: true,
            requiresEvidence: true,
            safetyBadges: [.energized]
        )

        XCTAssertEqual(step.id, "RT-08")
        XCTAssertEqual(step.code, "RT-08")
        XCTAssertEqual(step.ruleReference, "EV.6.1")
        XCTAssertEqual(step.type, .check)
        XCTAssertTrue(step.requiredOutcome)
        XCTAssertTrue(step.requiresEvidence)
        XCTAssertEqual(step.safetyBadges, [.energized])
        XCTAssertEqual(step.defaultOutcome, .pending)
    }

    func testInspectionOutcomeExposesDisplayAndValidationSemantics() {
        XCTAssertEqual(InspectionOutcome.pass.displayName, "Pass")
        XCTAssertEqual(InspectionOutcome.fail.displayName, "Fail")
        XCTAssertEqual(InspectionOutcome.notApplicable.displayName, "N/A")
        XCTAssertEqual(InspectionOutcome.pending.displayName, "Pending")

        XCTAssertTrue(InspectionOutcome.pass.satisfiesRequiredOutcome)
        XCTAssertTrue(InspectionOutcome.fail.satisfiesRequiredOutcome)
        XCTAssertTrue(InspectionOutcome.notApplicable.satisfiesRequiredOutcome)
        XCTAssertFalse(InspectionOutcome.pending.satisfiesRequiredOutcome)

        XCTAssertTrue(InspectionOutcome.fail.requiresInspectorNote)
        XCTAssertFalse(InspectionOutcome.pass.requiresInspectorNote)
    }

    func testUS003MeasurementValueAcceptsRangeAndPrecision() throws {
        let range = MeasurementRange(
            unit: .seconds,
            minimum: Decimal(string: "0.00")!,
            maximum: Decimal(string: "4.99")!,
            maximumFractionDigits: 2
        )

        let measurement = try MeasurementValue(rawValue: "4.38", range: range)

        XCTAssertEqual(measurement.value, Decimal(string: "4.38")!)
        XCTAssertEqual(measurement.unit, .seconds)
        XCTAssertEqual(measurement.formattedValue, "4.38 s")
        XCTAssertTrue(range.contains(measurement))
    }

    func testUS003MeasurementValueRejectsInvalidFormatsPrecisionAndRange() {
        let range = MeasurementRange(
            unit: .seconds,
            minimum: Decimal(string: "0.00")!,
            maximum: Decimal(string: "4.99")!,
            maximumFractionDigits: 2
        )

        XCTAssertThrowsError(try MeasurementValue(rawValue: "fast", range: range)) { error in
            XCTAssertEqual(error as? MeasurementValue.ValidationError, .nonNumericFormat)
        }
        XCTAssertThrowsError(try MeasurementValue(rawValue: "4.999", range: range)) { error in
            XCTAssertEqual(error as? MeasurementValue.ValidationError, .precisionExceeded)
        }
        XCTAssertThrowsError(try MeasurementValue(rawValue: "5.40", range: range)) { error in
            XCTAssertEqual(error as? MeasurementValue.ValidationError, .outsideAllowedRange)
        }
    }

    func testUS004EvidenceMetadataTracksRequiredAttachmentIdentity() {
        let metadata = EvidenceAttachmentMetadata(
            id: "rml-visible-photo",
            displayName: "RML visible photo",
            mediaType: .photo,
            source: .mockAttachment,
            createdAt: Date(timeIntervalSince1970: 0)
        )

        XCTAssertEqual(metadata.id, "rml-visible-photo")
        XCTAssertEqual(metadata.displayName, "RML visible photo")
        XCTAssertEqual(metadata.mediaType, .photo)
        XCTAssertEqual(metadata.source, .mockAttachment)
        XCTAssertEqual(metadata.accessibilityValue, "Attachment RML visible photo added")
    }

    func testAccessibilityIdentifierHelpersDoNotDependOnLocalizedLabels() {
        XCTAssertEqual(
            InspectionAccessibilityIdentifier.testStepRow(stepID: "RT-08").rawValue,
            "inspection.testStep.RT-08.row"
        )
        XCTAssertEqual(
            InspectionAccessibilityIdentifier.testStepOutcome(stepID: "RT-08", outcome: .fail).rawValue,
            "inspection.testStep.RT-08.outcome.fail"
        )
        XCTAssertEqual(
            InspectionAccessibilityIdentifier.measurementField(stepID: "EG-14").rawValue,
            "inspection.testStep.EG-14.measurement"
        )
        XCTAssertEqual(
            InspectionAccessibilityIdentifier.evidenceAction(stepID: "RT-08").rawValue,
            "inspection.testStep.RT-08.evidence.action"
        )
    }

    func testLocalizableStringKeyHelpersReturnStableKeys() {
        XCTAssertEqual(
            InspectionTestStepStrings.title.key(for: "RT-08"),
            "inspection.testStep.RT-08.title"
        )
        XCTAssertEqual(
            InspectionTestStepStrings.notesPlaceholder.key(for: "RT-08"),
            "inspection.testStep.RT-08.notes.placeholder"
        )
        XCTAssertEqual(
            InspectionTestStepStrings.measurementError(.outsideAllowedRange).key,
            "inspection.testStep.measurement.error.outsideAllowedRange"
        )
        XCTAssertEqual(
            InspectionTestStepStrings.evidenceRequired.key,
            "inspection.testStep.evidence.required"
        )
    }
}
