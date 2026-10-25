#if DEBUG
import SwiftUI
import UIKit

/// Isolated review fixtures: no judge session or persisted production draft is changed.
enum InspectionSnapshotScenario: String, CaseIterable {
    case queue, focus, ready, fail, measurement, evidence, review, details
    case longest
    case saving, confirmed, safety
    case autoAdvance = "auto-advance"
    case queueDrawer = "queue-drawer"
    case queueSupplies = "queue-supplies"
    case reviewIncomplete = "review-incomplete"
    case reviewReturn = "review-return"
    case reviewCorrection = "review-correction"
    case reviewFlagged = "review-flagged"
    case resolveFlag = "resolve-flag"
    case reviewSubmitted = "review-submitted"
    case submissionFailure = "submission-failure"
    case photoSources = "photo-sources"
    case evidenceReady = "evidence-ready"
    case flaggedFocus = "flagged-focus"
    case optionalNotes = "optional-notes"
    case measurementReady = "measurement-ready"
    case failInput = "fail-input"
    case secondaryActions = "secondary-actions"
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
    @State private var submitted = false
    private let stage: InspectionStage
    private let team = InspectionTeam(id: 13, school: "capiba", carNumber: "13", status: .ready,
                                      currentStage: "Garage Inspection", lastSaved: "")

    init(scenario: InspectionSnapshotScenario) {
        self.scenario = scenario
        let stage = InspectionSnapshotFixtures.stage(for: scenario)
        self.stage = stage
        _drafts = State(initialValue: InspectionSnapshotFixtures.drafts(for: scenario, stage: stage))
    }

    private var longestCase: InspectionTestCase? {
        stage.orderedSections.flatMap(\.orderedTestCases).max {
            ($0.orderedSteps.map { $0.content.count }.max() ?? 0) < ($1.orderedSteps.map { $0.content.count }.max() ?? 0)
        }
    }

    var body: some View {
        NavigationStack {
            FullStageView(
                team: team, stage: stage, draftsByTestCaseID: drafts,
                saveStepDraft: { draft, caseID in
                    guard let testCase = stage.orderedSections.flatMap(\.orderedTestCases).first(where: { $0.id == caseID }) else { return false }
                    var value = drafts[caseID] ?? TestCaseDraft(testCase: testCase)
                    var accepted = draft
                    if scenario == .saveFailure { accepted.confirmedAt = nil }
                    if value.stepDraft(stepID: accepted.stepID)?.draft != accepted { submitted = false }
                    value.updateStepDraft(accepted)
                    drafts[caseID] = value
                    return scenario != .saveFailure
                },
                latestDrafts: { drafts },
                initialTestCaseID: scenario == .longest ? longestCase?.id : scenario == .queue || scenario == .queueSupplies ? nil : "case-3",
                initialStepID: scenario == .longest ? longestCase?.orderedSteps.max(by: { $0.content.count < $1.content.count })?.id : "step-3",
                initialReview: [.review, .reviewIncomplete, .reviewReturn, .reviewCorrection, .reviewFlagged, .resolveFlag, .reviewSubmitted, .submissionFailure].contains(scenario),
                initialDetails: scenario == .details,
                initialQueue: scenario == .queueDrawer,
                initialDebugBadge: scenario == .debugBadge,
                hasSubmittedStage: submitted,
                submitStage: {
                    guard scenario != .submissionFailure else { return false }
                    let service = SubmissionSnapshotService(persistence: TestCaseJSONPersistenceService(rootDirectory: URL.temporaryDirectory.appending(path: "FSAESnapshotSubmission-\(UUID().uuidString)")))
                    do {
                        _ = try await service.createStageSnapshot(
                            context: InspectionPersistenceContext(eventID: "snapshot", teamID: "car-13", sessionID: "isolated", stageID: stage.id),
                            submissionID: UUID().uuidString,
                            drafts: stage.orderedSections.flatMap(\.orderedTestCases).compactMap { drafts[$0.id] },
                            preserveDrafts: true
                        )
                        submitted = true
                        return true
                    } catch { return false }
                }
            )
            .id(scenario == .evidenceReady ? drafts["case-3"]?.stepDraft(stepID: "step-3")?.draft.evidenceAttachments.count ?? 0 : 0)
        }
        .inspectionButtonStyle()
        .task {
            guard scenario == .evidenceReady else { return }
            let image = UIGraphicsImageRenderer(size: CGSize(width: 300, height: 200)).pngData { context in
                UIColor.systemBlue.setFill()
                context.fill(CGRect(x: 0, y: 0, width: 300, height: 200))
                NSString(string: "Isolated evidence fixture").draw(at: CGPoint(x: 20, y: 80), withAttributes: [.foregroundColor: UIColor.white, .font: UIFont.boldSystemFont(ofSize: 18)])
            }
            guard let attachment = try? await FocusedResultEvidenceStore.shared.storePhoto(image),
                  var value = drafts["case-3"],
                  var step = value.stepDraft(stepID: "step-3")?.draft else { return }
            step.evidenceAttachments = [attachment]
            value.updateStepDraft(step)
            drafts["case-3"] = value
        }
    }
}

enum InspectionSnapshotFixtures {
    static func stage(for scenario: InspectionSnapshotScenario) -> InspectionStage {
        if scenario == .longest,
           let url = Bundle.main.url(forResource: OfficialInspectionResource.body.fileName, withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let stage = try? InspectionContentService().decodeStage(data, resourceName: OfficialInspectionResource.body.fileName) {
            return stage
        }
        let titles = ["DRIVER HELMET", "FIRE EXTINGUISHERS", "ARM RESTRAINTS", "DRIVER SUIT", "GLOVES", "SHOES", "WET TIRES", "SPARE PARTS", "CHANGING PROCEDURE"]
        let cases = titles.enumerated().map { index, title in
            let number = index + 1
            let measured = (scenario == .measurement || scenario == .measurementReady) && number == 3
            let evidence = [.evidence, .evidenceReady, .photoSources].contains(scenario) && number == 3
            let step = InspectionTestStep(
                id: "step-\(number)", code: "G-\(number)", ruleReference: "T.13.8", title: title,
                type: measured ? .measurement : .check,
                content: measured ? "Measure the driver exit time. Record the elapsed time in seconds." : evidence ? "Record a clear photo of the installed arm restraints." : "Required for all drivers. Must be commercially manufactured. No label required.",
                requiredOutcome: !evidence, requiresEvidence: evidence,
                safetyBadges: scenario == .safety && number == 3 ? [.energized] : [],
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
            let reviewCompleted: [InspectionSnapshotScenario] = [.review, .reviewCorrection, .reviewFlagged, .resolveFlag, .reviewSubmitted, .submissionFailure]
            let passed = testCase.displayOrder < 3 || reviewCompleted.contains(scenario) || (testCase.displayOrder == 3 && [.ready, .saveFailure, .reviewReturn].contains(scenario))
            let failed = testCase.displayOrder == 3 && (scenario == .fail || scenario == .failInput || scenario == .flaggedFocus || scenario == .reviewFlagged || scenario == .resolveFlag)
            let confirmed = testCase.displayOrder < 3 || reviewCompleted.contains(scenario)
            values[testCase.id] = TestCaseDraft(testCase: testCase, stepDrafts: testCase.orderedSteps.map {
                TestStepDraft(stepID: $0.id, outcome: failed ? .fail : passed ? .pass : .pending,
                              notes: failed && scenario != .failInput ? "Right restraint attachment needs correction." : scenario == .reviewReturn && testCase.displayOrder == 3 ? "Judge note retained when returning." : "",
                              confirmedAt: confirmed ? Date(timeIntervalSince1970: 1_792_000_000) : nil,
                              flaggedForReview: [.flaggedFocus, .reviewFlagged, .resolveFlag].contains(scenario) && testCase.displayOrder == 3 ? true : nil)
            })
        }
        return values
    }
}
#endif
