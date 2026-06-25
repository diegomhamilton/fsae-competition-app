import Foundation

nonisolated struct ValidationIssue: Equatable, Identifiable, Sendable {
    enum LocalizationKey: String, Equatable, Sendable {
        case missingRequiredOutcome = "inspection.validation.missingRequiredOutcome"
        case missingInspectorNote = "inspection.validation.missingInspectorNote"
        case missingMeasurement = "inspection.validation.missingMeasurement"
        case invalidMeasurementNonNumeric = "inspection.validation.invalidMeasurement.nonNumericFormat"
        case invalidMeasurementPrecision = "inspection.validation.invalidMeasurement.precisionExceeded"
        case invalidMeasurementRange = "inspection.validation.invalidMeasurement.outsideAllowedRange"
        case missingRequiredEvidence = "inspection.validation.missingRequiredEvidence"
    }

    enum Code: Equatable, Sendable {
        case missingRequiredOutcome(stepID: String)
        case missingInspectorNote(stepID: String)
        case missingMeasurement(stepID: String)
        case invalidMeasurement(stepID: String, error: MeasurementValue.ValidationError)
        case missingRequiredEvidence(stepID: String)
    }

    let code: Code
    let localizationKey: LocalizationKey
    let localizationArguments: [String: String]
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

nonisolated struct InspectionValidationService: Sendable {
    private let rules: [InspectionValidationRule]

    init(rules: [InspectionValidationRule] = .defaultRules) {
        self.rules = rules
    }

    func validateStep(_ step: InspectionTestStep, result: StepResult) -> [ValidationIssue] {
        rules.flatMap { rule in
            rule.validate(step, result: result)
        }
    }
}

nonisolated struct InspectionValidationRule: Sendable {
    let id: String
    private let handler: @Sendable (InspectionTestStep, StepResult) -> [ValidationIssue]

    init(
        id: String,
        handler: @escaping @Sendable (InspectionTestStep, StepResult) -> [ValidationIssue]
    ) {
        self.id = id
        self.handler = handler
    }

    func validate(_ step: InspectionTestStep, result: StepResult) -> [ValidationIssue] {
        handler(step, result)
    }
}

extension Array where Element == InspectionValidationRule {
    static let defaultRules: [InspectionValidationRule] = [
        .requiredOutcome,
        .failedOutcomeInspectorNote,
        .measurement,
        .evidence
    ]
}

private extension InspectionValidationRule {
    static let requiredOutcome = InspectionValidationRule(id: "requiredOutcome") { step, result in
        guard step.requiredOutcome, !result.outcome.satisfiesRequiredOutcome else {
            return []
        }

        return [
            ValidationIssue(
                code: .missingRequiredOutcome(stepID: step.id),
                localizationKey: .missingRequiredOutcome,
                localizationArguments: [
                    "stepID": step.id,
                    "stepCode": step.code,
                    "stepTitle": step.title
                ],
                message: "\(step.code) requires an outcome."
            )
        ]
    }

    static let failedOutcomeInspectorNote = InspectionValidationRule(id: "failedOutcomeInspectorNote") { step, result in
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
                localizationKey: .missingInspectorNote,
                localizationArguments: [
                    "stepID": step.id,
                    "stepCode": step.code,
                    "stepTitle": step.title
                ],
                message: "\(step.title) failed and requires inspector notes."
            )
        ]
    }

    static let measurement = InspectionValidationRule(id: "measurement") { step, result in
        guard step.type == .measurement, let range = step.measurementRange else {
            return []
        }

        let trimmedInput = result.measurementInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedInput.isEmpty else {
            return [
                ValidationIssue(
                    code: .missingMeasurement(stepID: step.id),
                    localizationKey: .missingMeasurement,
                    localizationArguments: measurementArguments(step: step, range: range),
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
                    localizationKey: localizationKey(for: error),
                    localizationArguments: measurementArguments(step: step, range: range),
                    message: message(for: error, step: step, range: range)
                )
            ]
        } catch {
            return [
                ValidationIssue(
                    code: .invalidMeasurement(stepID: step.id, error: .nonNumericFormat),
                    localizationKey: localizationKey(for: .nonNumericFormat),
                    localizationArguments: measurementArguments(step: step, range: range),
                    message: message(for: .nonNumericFormat, step: step, range: range)
                )
            ]
        }
    }

    static let evidence = InspectionValidationRule(id: "evidence") { step, result in
        guard let requirement = step.evidenceValidationRequirement,
              !requirement.isSatisfied(by: result.evidenceAttachments) else {
            return []
        }

        return [
            ValidationIssue(
                code: .missingRequiredEvidence(stepID: step.id),
                localizationKey: .missingRequiredEvidence,
                localizationArguments: [
                    "stepID": step.id,
                    "stepCode": step.code,
                    "stepTitle": step.title,
                    "minimumAttachmentCount": "\(requirement.minimumAttachmentCount)"
                ],
                message: "\(step.title) requires evidence metadata."
            )
        ]
    }
}

nonisolated struct EvidenceValidationRequirement: Equatable, Sendable {
    let minimumAttachmentCount: Int
    let requiredMediaTypeCounts: [EvidenceMediaType: Int]

    init(
        minimumAttachmentCount: Int = 1,
        requiredMediaTypeCounts: [EvidenceMediaType: Int] = [:]
    ) {
        self.minimumAttachmentCount = minimumAttachmentCount
        self.requiredMediaTypeCounts = requiredMediaTypeCounts
    }

    func isSatisfied(by attachments: [EvidenceAttachmentMetadata]) -> Bool {
        guard attachments.count >= minimumAttachmentCount else {
            return false
        }

        for (mediaType, requiredCount) in requiredMediaTypeCounts {
            let actualCount = attachments.filter { $0.mediaType == mediaType }.count
            guard actualCount >= requiredCount else {
                return false
            }
        }

        return true
    }
}

private extension InspectionTestStep {
    var evidenceValidationRequirement: EvidenceValidationRequirement? {
        guard requiresEvidence else {
            return nil
        }

        return EvidenceValidationRequirement(minimumAttachmentCount: 1)
    }
}

private func measurementArguments(
    step: InspectionTestStep,
    range: MeasurementRange
) -> [String: String] {
    [
        "stepID": step.id,
        "stepCode": step.code,
        "stepTitle": step.title,
        "unit": range.unit.symbol,
        "minimum": "\(range.minimum)",
        "maximum": "\(range.maximum)",
        "maximumFractionDigits": "\(range.maximumFractionDigits)"
    ]
}

private func localizationKey(
    for error: MeasurementValue.ValidationError
) -> ValidationIssue.LocalizationKey {
    switch error {
    case .nonNumericFormat:
        .invalidMeasurementNonNumeric
    case .precisionExceeded:
        .invalidMeasurementPrecision
    case .outsideAllowedRange:
        .invalidMeasurementRange
    }
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

typealias ValidationService = InspectionValidationService
