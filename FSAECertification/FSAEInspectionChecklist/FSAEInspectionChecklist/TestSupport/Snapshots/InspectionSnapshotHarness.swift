#if DEBUG
import SwiftUI

/// Isolated review fixtures: no judge session or persisted production draft is changed.
enum InspectionSnapshotScenario: String, CaseIterable {
    case queue, focus, ready, fail, measurement, evidence, review, details
    case saveFailure = "save-failure"
    case multiStep = "multi-step"
    case debugBadge = "debug-badge"

    static var current: Self? {
        let arguments = ProcessInfo.processInfo.arguments
        guard let index = arguments.firstIndex(of: "-inspection-snapshot"),
              arguments.indices.contains(index + 1) else { return nil }
        return Self(rawValue: arguments[index + 1])
    }
}

struct InspectionSnapshotHarness: View {
    let scenario: InspectionSnapshotScenario
    @State private var drafts: [String: TestCaseDraft]
    private let stage: InspectionStage
    private let team = InspectionTeam(id: 13, school: "capiba", carNumber: "13", status: .ready,
                                      currentStage: "Garage Inspection", lastSaved: "")

    init(scenario: InspectionSnapshotScenario) {
        self.scenario = scenario
        let stage = InspectionSnapshotFixtures.stage(for: scenario)
        self.stage = stage
        _drafts = State(initialValue: InspectionSnapshotFixtures.drafts(for: scenario, stage: stage))
    }

    var body: some View {
        NavigationStack {
            FullStageView(
                team: team, stage: stage, draftsByTestCaseID: drafts,
                updateStepDraft: { draft, caseID in
                    guard let testCase = stage.orderedSections.flatMap(\.orderedTestCases).first(where: { $0.id == caseID }) else { return }
                    var value = drafts[caseID] ?? TestCaseDraft(testCase: testCase)
                    value.updateStepDraft(draft)
                    drafts[caseID] = value
                },
                initialTestCaseID: scenario == .queue ? nil : "case-3",
                initialStepID: "step-3",
                initialReview: scenario == .review,
                initialDetails: scenario == .details,
                initialDebugBadge: scenario == .debugBadge
            )
        }
    }
}

enum InspectionSnapshotFixtures {
    static func stage(for scenario: InspectionSnapshotScenario) -> InspectionStage {
        let titles = ["DRIVER HELMET", "FIRE EXTINGUISHERS", "ARM RESTRAINTS", "DRIVER SUIT", "GLOVES", "SHOES", "WET TIRES", "SPARE PARTS", "CHANGING PROCEDURE"]
        let cases = titles.enumerated().map { index, title in
            let number = index + 1
            let measured = scenario == .measurement && number == 3
            let evidence = scenario == .evidence && number == 3
            let step = InspectionTestStep(
                id: "step-\(number)", code: "G-\(number)", ruleReference: "T.13.8", title: title,
                type: measured ? .measurement : .check,
                content: measured ? "Measure the driver exit time. Record the elapsed time in seconds." : evidence ? "Record a clear photo of the installed arm restraints." : "Required for all drivers. Must be commercially manufactured. No label required.",
                requiredOutcome: !evidence, requiresEvidence: evidence,
                measurementRange: measured ? MeasurementRange(unit: .seconds, minimum: 0, maximum: 5, maximumFractionDigits: 2) : nil
            )
            var steps = [step]
            if scenario == .multiStep && number == 3 {
                steps.append(InspectionTestStep(id: "step-3b", code: "G-3B", displayOrder: 1,
                    ruleReference: "T.13.8", title: "Check release", type: .check,
                    content: "Verify the driver can release both arm restraints without assistance.",
                    requiredOutcome: true, requiresEvidence: false))
            }
            return InspectionTestCase(id: "case-\(number)", code: "GAR-\(number)", displayOrder: number,
                                      title: measured ? "DRIVER EGRESS" : title, ruleReferences: ["T.13.8"], steps: steps)
        }
        return InspectionStage(id: "snapshot-garage", title: "Garage Inspection", displayOrder: 1,
            sections: [InspectionSection(id: "drivers", title: "Driver equipment", displayOrder: 1, testCases: Array(cases.prefix(6))),
                       InspectionSection(id: "supplies", title: "Tires and supplies", displayOrder: 2, testCases: Array(cases.suffix(3)))])
    }

    static func drafts(for scenario: InspectionSnapshotScenario, stage: InspectionStage) -> [String: TestCaseDraft] {
        var values: [String: TestCaseDraft] = [:]
        for testCase in stage.orderedSections.flatMap(\.orderedTestCases) {
            let passed = testCase.displayOrder < 3 || scenario == .review || (testCase.displayOrder == 3 && (scenario == .ready || scenario == .saveFailure))
            let failed = testCase.displayOrder == 3 && scenario == .fail
            values[testCase.id] = TestCaseDraft(testCase: testCase, stepDrafts: testCase.orderedSteps.map {
                TestStepDraft(stepID: $0.id, outcome: failed ? .fail : passed ? .pass : .pending,
                              notes: failed ? "Right restraint attachment needs correction." : "")
            })
        }
        return values
    }
}
#endif
