import SwiftUI

struct InspectionTeam: Identifiable, Hashable {
    let id: Int
    let school: String
    let carNumber: String
    let status: SessionStatus
    let currentStage: String
    let lastSaved: String
}

enum SessionStatus: String, Hashable {
    case ready = "Ready"
    case resumed = "Resume"
    case blocked = "Blocked"

    var color: Color {
        switch self {
        case .ready: .fsaeGreen
        case .resumed: .fsaeBlue
        case .blocked: .fsaeAmber
        }
    }
}

struct InspectionStage: Identifiable, Codable, Hashable, Sendable {
    let id: String
    let code: String
    let title: String
    let displayOrder: Int
    let subtitle: String
    let progress: Double
    let requiredOpenItems: Int
    let sections: [InspectionSection]

    init(
        id: String,
        code: String? = nil,
        title: String,
        displayOrder: Int,
        subtitle: String = "",
        progress: Double = 0,
        requiredOpenItems: Int = 0,
        sections: [InspectionSection] = []
    ) {
        self.id = id
        self.code = code ?? id
        self.title = title
        self.displayOrder = displayOrder
        self.subtitle = subtitle
        self.progress = progress
        self.requiredOpenItems = requiredOpenItems
        self.sections = sections
    }

    init(
        id: Int,
        title: String,
        subtitle: String,
        progress: Double,
        requiredOpenItems: Int
    ) {
        self.init(
            id: String(id),
            code: String(id),
            title: title,
            displayOrder: id,
            subtitle: subtitle,
            progress: progress,
            requiredOpenItems: requiredOpenItems,
            sections: []
        )
    }

    var orderedSections: [InspectionSection] {
        sections.sorted { lhs, rhs in
            if lhs.displayOrder == rhs.displayOrder {
                lhs.title < rhs.title
            } else {
                lhs.displayOrder < rhs.displayOrder
            }
        }
    }

    var sectionIDs: [String] {
        orderedSections.map(\.id)
    }
}

extension InspectionStage {
    private enum CodingKeys: String, CodingKey {
        case id
        case code
        case title
        case displayOrder
        case subtitle
        case progress
        case requiredOpenItems
        case sections
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let decodedCode = try container.decode(String.self, forKey: .code)

        id = try container.decodeIfPresent(String.self, forKey: .id) ?? decodedCode
        code = decodedCode
        title = try container.decode(String.self, forKey: .title)
        displayOrder = try container.decode(Int.self, forKey: .displayOrder)
        subtitle = try container.decodeIfPresent(String.self, forKey: .subtitle) ?? ""
        progress = try container.decodeIfPresent(Double.self, forKey: .progress) ?? 0
        requiredOpenItems = try container.decodeIfPresent(Int.self, forKey: .requiredOpenItems) ?? 0
        sections = try container.decode([InspectionSection].self, forKey: .sections)
    }
}

struct InspectionSection: Identifiable, Codable, Hashable, Sendable {
    let id: String
    let title: String
    let displayOrder: Int
    let testCases: [InspectionTestCase]

    init(
        id: String,
        title: String,
        displayOrder: Int,
        testCases: [InspectionTestCase]
    ) {
        self.id = id
        self.title = title
        self.displayOrder = displayOrder
        self.testCases = testCases
    }

    var orderedTestCases: [InspectionTestCase] {
        testCases.sorted { lhs, rhs in
            if lhs.displayOrder == rhs.displayOrder {
                lhs.code < rhs.code
            } else {
                lhs.displayOrder < rhs.displayOrder
            }
        }
    }

    var testCaseIDs: [String] {
        orderedTestCases.map(\.id)
    }
}

extension InspectionSection {
    private enum CodingKeys: String, CodingKey {
        case id
        case title
        case displayOrder
        case testCases
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decode(String.self, forKey: .title)
        displayOrder = try container.decode(Int.self, forKey: .displayOrder)
        id = try container.decodeIfPresent(String.self, forKey: .id)
            ?? "\(displayOrder).\(title.stableInspectionIdentifierComponent)"
        testCases = try container.decode([InspectionTestCase].self, forKey: .testCases)
    }
}

extension String {
    var stableInspectionIdentifierComponent: String {
        let allowed = CharacterSet.alphanumerics
        return lowercased()
            .unicodeScalars
            .map { allowed.contains($0) ? Character($0) : "-" }
            .reduce(into: "") { result, character in
                if character == "-", result.last == "-" {
                    return
                }
                result.append(character)
            }
            .trimmingCharacters(in: CharacterSet(charactersIn: "-"))
    }
}

struct InspectionStep: Identifiable, Hashable {
    let id: Int
    let code: String
    let ruleReference: String
    let title: String
    let type: StepType
    let content: String
    let outcome: StepOutcome
    let requiresEvidence: Bool
    let note: String
}

enum StepType: String, CaseIterable, Hashable {
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

enum StepOutcome: String, Hashable {
    case pass = "Pass"
    case fail = "Fail"
    case notApplicable = "N/A"
    case pending = "Pending"

    var color: Color {
        switch self {
        case .pass: .fsaeGreen
        case .fail: .fsaeRed
        case .notApplicable: .fsaeGray
        case .pending: .fsaeAmber
        }
    }
}

enum MockInspectionData {
    static let teams: [InspectionTeam] = [
        InspectionTeam(id: 12, school: "IF1 Racing", carNumber: "1", status: .resumed, currentStage: "EV Inspection", lastSaved: "Saved 2 min ago"),
        InspectionTeam(id: 28, school: "Capibarib-E Racing", carNumber: "13", status: .ready, currentStage: "Garage Inspection", lastSaved: "Not started"),
        InspectionTeam(id: 41, school: "EVolt Racing UFRPE", carNumber: "15", status: .blocked, currentStage: "Rain Test", lastSaved: "Needs evidence")
    ]

    static let stages: [InspectionStage] = [
        InspectionStage(id: 1, title: "Garage Inspection", subtitle: "Driver equipment, wet tires, extinguishers", progress: 1.0, requiredOpenItems: 0),
        InspectionStage(id: 2, title: "Body Inspection", subtitle: "Bodywork, harness, visibility, driver fit", progress: 0.86, requiredOpenItems: 1),
        InspectionStage(id: 3, title: "Chassis Inspection", subtitle: "Structure, suspension, brakes, SES items", progress: 0.64, requiredOpenItems: 3),
        InspectionStage(id: 4, title: "EV Inspection", subtitle: "Accumulator, charger, shutdown circuit", progress: 0.31, requiredOpenItems: 12),
        InspectionStage(id: 5, title: "Egress Test", subtitle: "Driver exit procedure and timing", progress: 0.18, requiredOpenItems: 4),
        InspectionStage(id: 6, title: "Rain Test", subtitle: "IMD validation and water spray procedure", progress: 0.0, requiredOpenItems: 8)
    ]

    static let steps: [InspectionTestStep] = [
        InspectionTestStep(id: "RT-01", code: "RT-01", ruleReference: "IN.4.1", title: "PPE verified", type: .precondition, content: "All accompanying members must be using PPE before energized work begins.", requiredOutcome: true, requiresEvidence: false, defaultOutcome: .pass, defaultNote: "ESO and two team members present."),
        InspectionTestStep(id: "RT-07", code: "RT-07", ruleReference: "Rain 7", title: "Activate TS", type: .action, content: "Instruct the ESO to activate the tractive system.", requiredOutcome: true, requiresEvidence: false, defaultOutcome: .pass),
        InspectionTestStep(id: "RT-08", code: "RT-08", ruleReference: "EV.6.1", title: "RML flashing", type: .check, content: "Verify the RML is flashing after TS activation.", requiredOutcome: true, requiresEvidence: true, defaultOutcome: .pending, defaultNote: "Photo required if visibility is disputed."),
        InspectionTestStep(id: "EG-14", code: "EG-14", ruleReference: "VE.5", title: "Egress time", type: .measurement, content: "Measure elapsed egress time. Required: less than 5 seconds.", requiredOutcome: true, requiresEvidence: false, defaultOutcome: .pending, defaultNote: "Target range: 0.00s to 4.99s.", measurementRange: MeasurementRange(unit: .seconds, minimum: Decimal(string: "0.00")!, maximum: Decimal(string: "4.99")!, maximumFractionDigits: 2)),
        InspectionTestStep(id: "EG-21", code: "EG-21", ruleReference: "IN.13.3.1", title: "Wristband handling", type: .context, content: "Place the tallest-driver wristband on the correct driver; do not hand it to the team.", requiredOutcome: false, requiresEvidence: false, defaultOutcome: .notApplicable, defaultNote: "Context note visible inline.")
    ]

    static let testCases: [InspectionTestCaseViewState] = [
        InspectionTestCaseViewState(
            id: "rain-rml",
            code: "RAIN-RML",
            title: "Rain test RML behavior",
            ruleReferences: ["EV.6.1", "IN.11.3"],
            stepStates: [
                InspectionTestCaseStepViewState(
                    displayOrder: 30,
                    step: steps[2],
                    inheritedSafetyBadges: [],
                    outcome: steps[2].defaultOutcome,
                    notes: steps[2].defaultNote,
                    measurementInput: "",
                    evidenceAttachmentCount: steps[2].evidenceAttachments.count
                ),
                InspectionTestCaseStepViewState(
                    displayOrder: 10,
                    step: steps[0],
                    inheritedSafetyBadges: [],
                    outcome: steps[0].defaultOutcome,
                    notes: steps[0].defaultNote,
                    measurementInput: "",
                    evidenceAttachmentCount: steps[0].evidenceAttachments.count
                ),
                InspectionTestCaseStepViewState(
                    displayOrder: 20,
                    step: steps[1],
                    inheritedSafetyBadges: [],
                    outcome: steps[1].defaultOutcome,
                    notes: steps[1].defaultNote,
                    measurementInput: "",
                    evidenceAttachmentCount: steps[1].evidenceAttachments.count
                ),
                InspectionTestCaseStepViewState(
                    displayOrder: 40,
                    step: steps[3],
                    inheritedSafetyBadges: [],
                    outcome: steps[3].defaultOutcome,
                    notes: steps[3].defaultNote,
                    measurementInput: "5.40",
                    evidenceAttachmentCount: steps[3].evidenceAttachments.count
                )
            ]
        )
    ]
}

extension Color {
    static let fsaePrimary = Color(red: 0.08, green: 0.28, blue: 0.62)
    static let fsaeRed = Color(red: 0.72, green: 0.09, blue: 0.11)
    static let fsaeGreen = Color(red: 0.07, green: 0.46, blue: 0.31)
    static let fsaeBlue = Color(red: 0.1, green: 0.29, blue: 0.55)
    static let fsaeAmber = Color(red: 0.76, green: 0.48, blue: 0.1)
    static let fsaeGray = Color(red: 0.36, green: 0.39, blue: 0.44)
    static let fsaeBackground = Color(red: 0.96, green: 0.96, blue: 0.94)
    static let fsaeSurface = Color.white
    static let fsaeText = Color(red: 0.1, green: 0.11, blue: 0.13)
    static let fsaeSecondaryText = Color(red: 0.36, green: 0.39, blue: 0.44)
    static let fsaeBorder = Color.black.opacity(0.1)
}
