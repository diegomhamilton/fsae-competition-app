import Foundation
import Testing
@testable import FSAEInspectionChecklist

@MainActor
struct InspectionValidationServiceTests {
    private let service = InspectionValidationService()

    @Test("US-002 blocks submission when a required outcome is missing")
    func us002BlocksMissingRequiredOutcome() {
        let step = inspectionStep(id: "RT-08", title: "RML flashing", requiredOutcome: true)

        let issues = service.validateStep(step, result: StepResult(outcome: .pending))

        #expect(issues.map(\.code) == [.missingRequiredOutcome(stepID: "RT-08")])
        #expect(issues.map(\.localizationKey) == [.missingRequiredOutcome])
        #expect(issues.first?.localizationArguments["stepCode"] == "RT-08")
        #expect(issues.first?.localizationArguments["stepTitle"] == "RML flashing")
        #expect(issues.map(\.message) == ["RT-08 requires an outcome."])
        #expect(issues.map(\.id) == ["missingRequiredOutcome.RT-08"])
    }

    @Test("US-002 requires non-whitespace notes for failed outcomes")
    func us002RequiresNonWhitespaceNotesForFailedOutcomes() {
        let step = inspectionStep(id: "RML", title: "RML flashing")

        let blankIssues = service.validateStep(step, result: StepResult(outcome: .fail, notes: " \n\t "))
        let notedIssues = service.validateStep(step, result: StepResult(outcome: .fail, notes: "RML did not flash."))

        #expect(blankIssues.map(\.code) == [.missingInspectorNote(stepID: "RML")])
        #expect(blankIssues.map(\.localizationKey) == [.missingInspectorNote])
        #expect(blankIssues.first?.localizationArguments["stepID"] == "RML")
        #expect(blankIssues.map(\.message) == ["RML flashing failed and requires inspector notes."])
        #expect(notedIssues.isEmpty)
    }

    @Test("US-003 blocks missing measurement input")
    func us003BlocksMissingMeasurementInput() {
        let step = measurementStep()

        let issues = service.validateStep(step, result: StepResult(outcome: .pass, measurementInput: " "))

        #expect(issues.map(\.code) == [.missingMeasurement(stepID: "EG-14")])
        #expect(issues.map(\.localizationKey) == [.missingMeasurement])
        #expect(issues.first?.localizationArguments["unit"] == "s")
        #expect(issues.map(\.message) == ["Egress time requires a measurement in s."])
    }

    @Test("US-003 validates measurement input through MeasurementValue")
    func us003ValidatesMeasurementInputThroughMeasurementValue() {
        let step = measurementStep()

        let nonNumeric = service.validateStep(step, result: StepResult(outcome: .pass, measurementInput: "fast"))
        let tooPrecise = service.validateStep(step, result: StepResult(outcome: .pass, measurementInput: "4.999"))
        let outOfRange = service.validateStep(step, result: StepResult(outcome: .pass, measurementInput: "5.40"))
        let valid = service.validateStep(step, result: StepResult(outcome: .pass, measurementInput: "4.38"))

        #expect(nonNumeric.map(\.code) == [.invalidMeasurement(stepID: "EG-14", error: .nonNumericFormat)])
        #expect(nonNumeric.map(\.localizationKey) == [.invalidMeasurementNonNumeric])
        #expect(nonNumeric.map(\.message) == ["Measurement for Egress time must be numeric."])
        #expect(tooPrecise.map(\.code) == [.invalidMeasurement(stepID: "EG-14", error: .precisionExceeded)])
        #expect(tooPrecise.map(\.localizationKey) == [.invalidMeasurementPrecision])
        #expect(tooPrecise.first?.localizationArguments["maximumFractionDigits"] == "2")
        #expect(
            tooPrecise.map(\.message)
                == ["Measurement for Egress time supports up to 2 decimal places."]
        )
        #expect(outOfRange.map(\.code) == [.invalidMeasurement(stepID: "EG-14", error: .outsideAllowedRange)])
        #expect(outOfRange.map(\.localizationKey) == [.invalidMeasurementRange])
        #expect(outOfRange.first?.localizationArguments["minimum"] == "0")
        #expect(outOfRange.first?.localizationArguments["maximum"] == "4.99")
        #expect(outOfRange.map(\.message) == ["Measurement for Egress time must be between 0 and 4.99 s."])
        #expect(valid.isEmpty)
    }

    @Test("TASK#10.6 does not block submission when required evidence metadata is missing")
    func task1006DoesNotBlockMissingRequiredEvidenceMetadata() {
        let step = inspectionStep(id: "RT-08", title: "RML flashing", requiresEvidence: true)
        let evidence = EvidenceAttachmentMetadata(
            id: "rml-visible-photo",
            displayName: "RML visible photo",
            mediaType: .photo,
            source: .mockAttachment,
            createdAt: Date(timeIntervalSince1970: 1_780_000_000)
        )

        let missingIssues = service.validateStep(step, result: StepResult(outcome: .pass))
        let validIssues = service.validateStep(
            step,
            result: StepResult(outcome: .pass, evidenceAttachments: [evidence])
        )

        #expect(missingIssues.isEmpty)
        #expect(validIssues.isEmpty)
    }

    @Test("US-004 evidence requirements can express counts by media type")
    func us004EvidenceRequirementSupportsMediaTypeCounts() {
        let requirement = EvidenceValidationRequirement(
            minimumAttachmentCount: 2,
            requiredMediaTypeCounts: [.photo: 1, .signature: 1]
        )
        let photo = evidence(id: "rml-photo", mediaType: .photo)
        let signature = evidence(id: "judge-signature", mediaType: .signature)
        let note = evidence(id: "inspector-note", mediaType: .note)

        #expect(!requirement.isSatisfied(by: []))
        #expect(!requirement.isSatisfied(by: [photo, note]))
        #expect(requirement.isSatisfied(by: [photo, signature]))
    }

    @Test("US-002/US-003/US-004 returns issues in deterministic summary order")
    func us002Us003Us004ReturnsIssuesInDeterministicSummaryOrder() {
        let step = measurementStep(id: "EG-14", title: "Egress time", requiresEvidence: true)

        let issues = service.validateStep(
            step,
            result: StepResult(outcome: .pending, measurementInput: "5.40")
        )

        #expect(issues.map(\.code) == [
            .missingRequiredOutcome(stepID: "EG-14"),
            .invalidMeasurement(stepID: "EG-14", error: .outsideAllowedRange)
        ])
        #expect(issues.map(\.localizationKey) == [
            .missingRequiredOutcome,
            .invalidMeasurementRange
        ])
    }
}

private func inspectionStep(
    id: String,
    title: String,
    requiredOutcome: Bool = true,
    requiresEvidence: Bool = false
) -> InspectionTestStep {
    InspectionTestStep(
        id: id,
        code: id,
        ruleReference: "EV.6.1",
        title: title,
        type: .check,
        content: "Test content for \(title).",
        requiredOutcome: requiredOutcome,
        requiresEvidence: requiresEvidence
    )
}

private func measurementStep(
    id: String = "EG-14",
    title: String = "Egress time",
    requiresEvidence: Bool = false
) -> InspectionTestStep {
    InspectionTestStep(
        id: id,
        code: id,
        ruleReference: "VE.5",
        title: title,
        type: .measurement,
        content: "Measure elapsed egress time.",
        requiredOutcome: true,
        requiresEvidence: requiresEvidence,
        measurementRange: MeasurementRange(
            unit: .seconds,
            minimum: Decimal(string: "0.00")!,
            maximum: Decimal(string: "4.99")!,
            maximumFractionDigits: 2
        )
    )
}

private func evidence(
    id: String,
    mediaType: EvidenceMediaType
) -> EvidenceAttachmentMetadata {
    EvidenceAttachmentMetadata(
        id: id,
        displayName: id,
        mediaType: mediaType,
        source: .mockAttachment,
        createdAt: Date(timeIntervalSince1970: 1_780_000_000)
    )
}
