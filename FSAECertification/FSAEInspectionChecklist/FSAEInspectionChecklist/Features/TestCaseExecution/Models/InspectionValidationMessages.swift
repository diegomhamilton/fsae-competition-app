import Foundation

extension InspectionTestCaseValidationIssue {
    private enum Strings {
        static var outcome: String { "Select an outcome before submission.".inspectionLocalized }
        static var notes: String { "Failed outcomes require judge notes.".inspectionLocalized }
        static var evidence: String { "Add the required photo evidence.".inspectionLocalized }
        static var measurement: String { "Measurement value is required.".inspectionLocalized }
        static var invalidMeasurement: String { "Measurement is outside the allowed format or range.".inspectionLocalized }
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
