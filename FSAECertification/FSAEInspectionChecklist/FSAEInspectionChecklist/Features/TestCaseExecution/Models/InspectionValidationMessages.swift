import Foundation

extension InspectionTestCaseValidationIssue {
    private enum Strings {
        static let outcome = "Select an outcome before submission."
        static let notes = "Failed outcomes require judge notes."
        static let evidence = "Add the required photo evidence."
        static let measurement = "Measurement value is required."
        static let invalidMeasurement = "Measurement is outside the allowed format or range."
    }
    var localizedMessage: String {
        switch code {
        case .missingRequiredOutcome: Strings.outcome
        case .missingInspectorNote: Strings.notes
        case .missingRequiredEvidence: Strings.evidence
        case .missingMeasurement: Strings.measurement
        case .invalidMeasurement: Strings.invalidMeasurement
        }
    }
}
