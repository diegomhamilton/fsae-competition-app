import Foundation

struct ValidationIssue: Equatable, Identifiable, Sendable {
    enum Code: Equatable, Sendable {
        case missingRequiredOutcome(stepID: String)
        case missingInspectorNote(stepID: String)
        case missingMeasurement(stepID: String)
        case invalidMeasurement(stepID: String, error: MeasurementValue.ValidationError)
        case missingRequiredEvidence(stepID: String)
    }

    let code: Code
    let message: String

    var id: String {
        switch code {
        case .missingRequiredOutcome(let stepID):
            "missingRequiredOutcome.\(stepID)"
        case .missingInspectorNote(let stepID):
            "missingInspectorNote.\(stepID)"
        case .missingMeasurement(let stepID):
            "missingMeasurement.\(stepID)"
        case .invalidMeasurement(let stepID, let error):
            "invalidMeasurement.\(stepID).\(error)"
        case .missingRequiredEvidence(let stepID):
            "missingRequiredEvidence.\(stepID)"
        }
    }
}

struct InspectionValidationService: Sendable {
    func validateStep(_ step: InspectionTestStep, result: StepResult) -> [ValidationIssue] {
        var issues: [ValidationIssue] = []

        issues.append(contentsOf: outcomeIssues(for: step, result: result))
        issues.append(contentsOf: inspectorNoteIssues(for: step, result: result))
        issues.append(contentsOf: measurementIssues(for: step, result: result))
        issues.append(contentsOf: evidenceIssues(for: step, result: result))

        return issues
    }

    private func outcomeIssues(for step: InspectionTestStep, result: StepResult) -> [ValidationIssue] {
        guard step.requiredOutcome, !result.outcome.satisfiesRequiredOutcome else {
            return []
        }

        return [
            ValidationIssue(
                code: .missingRequiredOutcome(stepID: step.id),
                message: "\(step.code) requires an outcome."
            )
        ]
    }

    private func inspectorNoteIssues(for step: InspectionTestStep, result: StepResult) -> [ValidationIssue] {
        guard result.outcome.requiresInspectorNote else {
            return []
        }

        let trimmedNotes = result.notes.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedNotes.isEmpty else {
            return []
        }

        return [
            ValidationIssue(
                code: .missingInspectorNote(stepID: step.id),
                message: "\(step.title) failed and requires inspector notes."
            )
        ]
    }

    private func measurementIssues(for step: InspectionTestStep, result: StepResult) -> [ValidationIssue] {
        guard step.type == .measurement, let range = step.measurementRange else {
            return []
        }

        let trimmedInput = result.measurementInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedInput.isEmpty else {
            return [
                ValidationIssue(
                    code: .missingMeasurement(stepID: step.id),
                    message: "\(step.title) requires a measurement in \(range.unit.symbol)."
                )
            ]
        }

        do {
            _ = try MeasurementValue(rawValue: trimmedInput, range: range)
            return []
        } catch let error as MeasurementValue.ValidationError {
            return [
                ValidationIssue(
                    code: .invalidMeasurement(stepID: step.id, error: error),
                    message: message(for: error, step: step, range: range)
                )
            ]
        } catch {
            return [
                ValidationIssue(
                    code: .invalidMeasurement(stepID: step.id, error: .nonNumericFormat),
                    message: message(for: .nonNumericFormat, step: step, range: range)
                )
            ]
        }
    }

    private func evidenceIssues(for step: InspectionTestStep, result: StepResult) -> [ValidationIssue] {
        guard step.requiresEvidence, result.evidenceAttachments.isEmpty else {
            return []
        }

        return [
            ValidationIssue(
                code: .missingRequiredEvidence(stepID: step.id),
                message: "\(step.title) requires evidence metadata."
            )
        ]
    }

    private func message(
        for error: MeasurementValue.ValidationError,
        step: InspectionTestStep,
        range: MeasurementRange
    ) -> String {
        switch error {
        case .nonNumericFormat:
            "Measurement for \(step.title) must be numeric."
        case .precisionExceeded:
            "Measurement for \(step.title) supports up to \(range.maximumFractionDigits) decimal places."
        case .outsideAllowedRange:
            "Measurement for \(step.title) must be between \(range.minimum) and \(range.maximum) \(range.unit.symbol)."
        }
    }
}

typealias ValidationService = InspectionValidationService
