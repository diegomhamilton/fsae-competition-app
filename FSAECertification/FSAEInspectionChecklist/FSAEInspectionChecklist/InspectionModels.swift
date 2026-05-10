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

struct InspectionStage: Identifiable, Hashable {
    let id: Int
    let title: String
    let subtitle: String
    let progress: Double
    let requiredOpenItems: Int
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
        InspectionTeam(id: 12, school: "Michigan Racing", carNumber: "42E", status: .resumed, currentStage: "EV Inspection", lastSaved: "Saved 2 min ago"),
        InspectionTeam(id: 28, school: "Cal Poly Racing", carNumber: "18E", status: .ready, currentStage: "Garage Inspection", lastSaved: "Not started"),
        InspectionTeam(id: 41, school: "RIT Electric", carNumber: "77E", status: .blocked, currentStage: "Rain Test", lastSaved: "Needs evidence")
    ]

    static let stages: [InspectionStage] = [
        InspectionStage(id: 1, title: "Garage Inspection", subtitle: "Driver equipment, wet tires, extinguishers", progress: 1.0, requiredOpenItems: 0),
        InspectionStage(id: 2, title: "Body Inspection", subtitle: "Bodywork, harness, visibility, driver fit", progress: 0.86, requiredOpenItems: 1),
        InspectionStage(id: 3, title: "Chassis Inspection", subtitle: "Structure, suspension, brakes, SES items", progress: 0.64, requiredOpenItems: 3),
        InspectionStage(id: 4, title: "EV Inspection", subtitle: "Accumulator, charger, shutdown circuit", progress: 0.31, requiredOpenItems: 12),
        InspectionStage(id: 5, title: "Egress Test", subtitle: "Driver exit procedure and timing", progress: 0.18, requiredOpenItems: 4),
        InspectionStage(id: 6, title: "Rain Test", subtitle: "IMD validation and water spray procedure", progress: 0.0, requiredOpenItems: 8)
    ]

    static let steps: [InspectionStep] = [
        InspectionStep(id: 1, code: "RT-01", ruleReference: "IN.4.1", title: "PPE verified", type: .precondition, content: "All accompanying members must be using PPE before energized work begins.", outcome: .pass, requiresEvidence: false, note: "ESO and two team members present."),
        InspectionStep(id: 2, code: "RT-07", ruleReference: "Rain 7", title: "Activate TS", type: .action, content: "Instruct the ESO to activate the tractive system.", outcome: .pass, requiresEvidence: false, note: ""),
        InspectionStep(id: 3, code: "RT-08", ruleReference: "EV.6.1", title: "RML flashing", type: .check, content: "Verify the RML is flashing after TS activation.", outcome: .pending, requiresEvidence: true, note: "Photo required if visibility is disputed."),
        InspectionStep(id: 4, code: "EG-14", ruleReference: "VE.5", title: "Egress time", type: .measurement, content: "Measure elapsed egress time. Required: less than 5 seconds.", outcome: .pending, requiresEvidence: false, note: "Target range: 0.00s to 4.99s."),
        InspectionStep(id: 5, code: "EG-21", ruleReference: "IN.13.3.1", title: "Wristband handling", type: .context, content: "Place the tallest-driver wristband on the correct driver; do not hand it to the team.", outcome: .notApplicable, requiresEvidence: false, note: "Context note visible inline.")
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
