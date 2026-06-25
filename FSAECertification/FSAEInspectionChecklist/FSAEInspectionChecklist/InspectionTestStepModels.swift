import Foundation
import SwiftUI

nonisolated struct InspectionTestStep: Identifiable, Codable, Hashable, Sendable {
    let id: String
    let code: String
    let displayOrder: Int
    let ruleReference: String
    let title: String
    let type: InspectionTestStepType
    let content: String
    let requiredOutcome: Bool
    let requiresEvidence: Bool
    let safetyBadges: [InspectionSafetyBadge]
    let defaultOutcome: InspectionOutcome
    let defaultNote: String
    let measurementRange: MeasurementRange?
    let evidenceAttachments: [EvidenceAttachmentMetadata]

    init(
        id: String,
        code: String,
        displayOrder: Int = 0,
        ruleReference: String,
        title: String,
        type: InspectionTestStepType,
        content: String,
        requiredOutcome: Bool,
        requiresEvidence: Bool,
        safetyBadges: [InspectionSafetyBadge] = [],
        defaultOutcome: InspectionOutcome = .pending,
        defaultNote: String = "",
        measurementRange: MeasurementRange? = nil,
        evidenceAttachments: [EvidenceAttachmentMetadata] = []
    ) {
        self.id = id
        self.code = code
        self.displayOrder = displayOrder
        self.ruleReference = ruleReference
        self.title = title
        self.type = type
        self.content = content
        self.requiredOutcome = requiredOutcome
        self.requiresEvidence = requiresEvidence
        self.safetyBadges = safetyBadges
        self.defaultOutcome = defaultOutcome
        self.defaultNote = defaultNote
        self.measurementRange = measurementRange
        self.evidenceAttachments = evidenceAttachments
    }
}

extension InspectionTestStep {
    private enum CodingKeys: String, CodingKey {
        case id
        case code
        case displayOrder
        case ruleReference
        case title
        case type
        case content
        case requiredOutcome
        case requiresEvidence
        case safetyBadges
        case defaultOutcome
        case defaultNote
        case measurementRange
        case evidenceAttachments
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(String.self, forKey: .id)
        code = try container.decode(String.self, forKey: .code)
        displayOrder = try container.decodeIfPresent(Int.self, forKey: .displayOrder) ?? 0
        ruleReference = try container.decode(String.self, forKey: .ruleReference)
        title = try container.decode(String.self, forKey: .title)
        type = try container.decode(InspectionTestStepType.self, forKey: .type)
        content = try container.decode(String.self, forKey: .content)
        requiredOutcome = try container.decodeIfPresent(Bool.self, forKey: .requiredOutcome) ?? true
        requiresEvidence = try container.decodeIfPresent(Bool.self, forKey: .requiresEvidence) ?? false
        safetyBadges = try container.decodeIfPresent([InspectionSafetyBadge].self, forKey: .safetyBadges) ?? []
        defaultOutcome = try container.decodeIfPresent(InspectionOutcome.self, forKey: .defaultOutcome) ?? .pending
        defaultNote = try container.decodeIfPresent(String.self, forKey: .defaultNote) ?? ""
        measurementRange = try container.decodeIfPresent(MeasurementRange.self, forKey: .measurementRange)
        evidenceAttachments = try container.decodeIfPresent([EvidenceAttachmentMetadata].self, forKey: .evidenceAttachments) ?? []
    }
}

/// Step-scoped parse result for raw measurement input entered by a judge.
///
/// Keeping this helper near `InspectionTestStep` keeps measurement range knowledge
/// with the step definition instead of duplicating it in coordinators.
nonisolated struct InspectionStepMeasurementInput: Equatable, Sendable {
    let rawValue: String
    let measurementValue: MeasurementValue?
}

extension InspectionTestStep {
    func measurementInput(from input: String) -> InspectionStepMeasurementInput {
        InspectionStepMeasurementInput(
            rawValue: input,
            measurementValue: measurementRange.flatMap { range in
                try? MeasurementValue(rawValue: input, range: range)
            }
        )
    }
}

nonisolated enum InspectionTestStepType: String, Codable, CaseIterable, Hashable, Sendable {
    case check
    case measurement
    case precondition
    case action
    case context

    var label: String {
        rawValue.capitalized
    }

    var symbol: String {
        switch self {
        case .check: "checkmark.seal"
        case .measurement: "ruler"
        case .precondition: "exclamationmark.shield"
        case .action: "hand.tap"
        case .context: "info.circle"
        }
    }

    var color: Color {
        switch self {
        case .check: .fsaeGreen
        case .measurement: .fsaeBlue
        case .precondition: .fsaeAmber
        case .action: .fsaeRed
        case .context: .fsaeGray
        }
    }
}

extension InspectionTestStepType {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)

        guard let stepType = Self(rawValue: rawValue) else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Unsupported inspection step type: \(rawValue)"
            )
        }

        self = stepType
    }
}

nonisolated enum InspectionSafetyBadge: String, Codable, Hashable, Sendable {
    case energized

    var displayName: String {
        switch self {
        case .energized: "CAUTION: ENERGIZED"
        }
    }

    var accessibilityLabel: String {
        switch self {
        case .energized: "Caution, energized dynamic test step"
        }
    }
}

extension Collection where Element == InspectionSafetyBadge {
    func merging(_ badges: [InspectionSafetyBadge]) -> [InspectionSafetyBadge] {
        var merged: [InspectionSafetyBadge] = []
        for badge in self {
            if !merged.contains(badge) {
                merged.append(badge)
            }
        }

        for badge in badges {
            if !merged.contains(badge) {
                merged.append(badge)
            }
        }

        return merged
    }
}

extension InspectionSafetyBadge {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)

        switch rawValue {
        case Self.energized.rawValue, Self.energized.displayName:
            self = .energized
        default:
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Unsupported inspection safety badge: \(rawValue)"
            )
        }
    }
}

nonisolated enum InspectionOutcome: String, Codable, CaseIterable, Hashable, Sendable {
    case pass
    case fail
    case notApplicable
    case pending

    var displayName: String {
        switch self {
        case .pass: "Pass"
        case .fail: "Fail"
        case .notApplicable: "N/A"
        case .pending: "Pending"
        }
    }

    var satisfiesRequiredOutcome: Bool {
        self != .pending
    }

    var requiresInspectorNote: Bool {
        self == .fail
    }

    var color: Color {
        switch self {
        case .pass: .fsaeGreen
        case .fail: .fsaeRed
        case .notApplicable: .fsaeGray
        case .pending: .fsaeAmber
        }
    }
}

nonisolated struct MeasurementRange: Codable, Hashable, Sendable {
    let unit: MeasurementUnit
    let minimum: Decimal
    let maximum: Decimal
    let maximumFractionDigits: Int

    func contains(_ measurement: MeasurementValue) -> Bool {
        measurement.unit == unit && measurement.value >= minimum && measurement.value <= maximum
    }
}

nonisolated struct MeasurementValue: Codable, Hashable, Sendable {
    enum ValidationError: Error, Equatable, Sendable {
        case nonNumericFormat
        case precisionExceeded
        case outsideAllowedRange
    }

    let value: Decimal
    let unit: MeasurementUnit

    init(rawValue: String, range: MeasurementRange) throws {
        let trimmedValue = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let decimal = Decimal(string: trimmedValue, locale: Locale(identifier: "en_US_POSIX")) else {
            throw ValidationError.nonNumericFormat
        }

        let fractionDigitCount = trimmedValue.split(separator: ".", omittingEmptySubsequences: false).dropFirst().first?.count ?? 0
        guard fractionDigitCount <= range.maximumFractionDigits else {
            throw ValidationError.precisionExceeded
        }

        self.value = decimal
        self.unit = range.unit

        guard range.contains(self) else {
            throw ValidationError.outsideAllowedRange
        }
    }

    var formattedValue: String {
        "\(NSDecimalNumber(decimal: value).stringValue) \(unit.symbol)"
    }
}

nonisolated enum MeasurementUnit: String, Codable, Hashable, Sendable {
    case seconds

    var symbol: String {
        switch self {
        case .seconds: "s"
        }
    }
}

nonisolated struct EvidenceAttachmentMetadata: Identifiable, Codable, Hashable, Sendable {
    let id: String
    let displayName: String
    let mediaType: EvidenceMediaType
    let source: EvidenceAttachmentSource
    let createdAt: Date

    var accessibilityValue: String {
        "Attachment \(displayName) added"
    }
}

nonisolated enum EvidenceMediaType: String, Codable, Hashable, Sendable {
    case photo
    case signature
    case note
}

nonisolated enum EvidenceAttachmentSource: String, Codable, Hashable, Sendable {
    case mockAttachment
}

nonisolated struct InspectionAccessibilityIdentifier: RawRepresentable, Equatable, Hashable, Sendable {
    let rawValue: String

    init(rawValue: String) {
        self.rawValue = rawValue
    }

    static func testStepRow(stepID: String) -> Self {
        Self(rawValue: "inspection.testStep.\(stepID).row")
    }

    static func testStepOutcome(stepID: String, outcome: InspectionOutcome) -> Self {
        Self(rawValue: "inspection.testStep.\(stepID).outcome.\(outcome.rawValue)")
    }

    static func measurementField(stepID: String) -> Self {
        Self(rawValue: "inspection.testStep.\(stepID).measurement")
    }

    static func evidenceAction(stepID: String) -> Self {
        Self(rawValue: "inspection.testStep.\(stepID).evidence.action")
    }

    static func notesField(stepID: String) -> Self {
        Self(rawValue: "inspection.testStep.\(stepID).notes")
    }

    static func doneAction(stepID: String) -> Self {
        Self(rawValue: "inspection.testStep.\(stepID).done")
    }

    static func testCaseValidationSummary(testCaseID: String) -> Self {
        Self(rawValue: "inspection.testCase.\(testCaseID).validation.summary")
    }

    static func testCaseStageSummary(stageID: String) -> Self {
        Self(rawValue: "inspection.stage.\(stageID).summary")
    }

    static func testCaseStageValidationSummary(stageID: String) -> Self {
        Self(rawValue: "inspection.stage.\(stageID).validation.summary")
    }

    static func testCaseStageSubmitAction(stageID: String) -> Self {
        Self(rawValue: "inspection.stage.\(stageID).submit")
    }

    static func testCaseStageBlockedSubmitAction(stageID: String) -> Self {
        Self(rawValue: "inspection.stage.\(stageID).submit.blocked")
    }

    static func testCaseStageSection(stageID: String, sectionID: String) -> Self {
        Self(rawValue: "inspection.stage.\(stageID).section.\(sectionID)")
    }

    static func testCaseStageRow(stageID: String, testCaseID: String) -> Self {
        Self(rawValue: "inspection.stage.\(stageID).testCase.\(testCaseID).row")
    }

    static func testCaseStageStatus(stageID: String, testCaseID: String) -> Self {
        Self(rawValue: "inspection.stage.\(stageID).testCase.\(testCaseID).status")
    }

    static func testCaseStageEnergizedBadge(stageID: String, testCaseID: String) -> Self {
        Self(rawValue: "inspection.stage.\(stageID).testCase.\(testCaseID).badge.energized")
    }

    static func testCaseStepRow(testCaseID: String, stepID: String) -> Self {
        Self(rawValue: "inspection.testCase.\(testCaseID).step.\(stepID).row")
    }

    static func testCaseStepOpenAction(testCaseID: String, stepID: String) -> Self {
        Self(rawValue: "inspection.testCase.\(testCaseID).step.\(stepID).open")
    }

    static func testCaseStepStatus(testCaseID: String, stepID: String) -> Self {
        Self(rawValue: "inspection.testCase.\(testCaseID).step.\(stepID).status")
    }

    static func testCaseNotesField(testCaseID: String, stepID: String) -> Self {
        Self(rawValue: "inspection.testCase.\(testCaseID).step.\(stepID).notes")
    }

    static func testCaseEvidenceAction(testCaseID: String, stepID: String) -> Self {
        Self(rawValue: "inspection.testCase.\(testCaseID).step.\(stepID).evidence.action")
    }

    static func testCaseKeyboardDismissAction(testCaseID: String) -> Self {
        Self(rawValue: "inspection.testCase.\(testCaseID).keyboard.dismiss")
    }

    static func stageSection(stageID: String, sectionID: String) -> Self {
        Self(rawValue: "inspection.stage.\(stageID).section.\(sectionID)")
    }

    static func stageTestCaseRow(stageID: String, testCaseID: String) -> Self {
        Self(rawValue: "inspection.stage.\(stageID).testCase.\(testCaseID).row")
    }
}

enum InspectionTestStepStrings: Equatable {
    case title
    case notesPlaceholder
    case measurementError(MeasurementValue.ValidationError)
    case evidenceRequired

    func key(for stepID: String) -> String {
        switch self {
        case .title: "inspection.testStep.\(stepID).title"
        case .notesPlaceholder: "inspection.testStep.\(stepID).notes.placeholder"
        case .measurementError, .evidenceRequired: key
        }
    }

    var key: String {
        switch self {
        case .title: "inspection.testStep.title"
        case .notesPlaceholder: "inspection.testStep.notes.placeholder"
        case .measurementError(.nonNumericFormat): "inspection.testStep.measurement.error.nonNumericFormat"
        case .measurementError(.precisionExceeded): "inspection.testStep.measurement.error.precisionExceeded"
        case .measurementError(.outsideAllowedRange): "inspection.testStep.measurement.error.outsideAllowedRange"
        case .evidenceRequired: "inspection.testStep.evidence.required"
        }
    }
}
