import Foundation

/// Stage/list context that can open a single test case without owning app/session flow.
struct TestCaseListContext: Equatable, Sendable {
    let stageID: Int
    let stageTitle: String
    let testCases: [InspectionTestCase]

    func testCase(id: String) -> InspectionTestCase? {
        testCases.first { $0.id == id }
    }
}

/// Narrow coordinator route state for the Test Case Slice.
enum TestCaseCoordinatorRoute: Equatable, Sendable {
    case stageList
    case testCase(testCaseID: String)
    case testStep(testCaseID: String, stepID: String)
}

/// Coordinates test case and test step selection plus active draft handoff.
///
/// This coordinator deliberately stops at the test-case boundary: it does not own
/// team/session routing, validation, submission, persistence, or full app flow.
@MainActor
final class TestCaseCoordinator {
    let stageContext: TestCaseListContext
    private var draftsByTestCaseID: [String: TestCaseDraft]

    private(set) var route: TestCaseCoordinatorRoute = .stageList
    private(set) var activeTestCaseDraft: TestCaseDraft?
    private(set) var activeStepDraft: TestStepDraft?

    init(stageContext: TestCaseListContext, drafts: [TestCaseDraft] = []) {
        self.stageContext = stageContext
        draftsByTestCaseID = drafts.reduce(into: [String: TestCaseDraft]()) { result, draft in
            result[draft.id] = draft
        }
    }

    @discardableResult
    func openTestCase(id testCaseID: String) -> Bool {
        guard let testCase = stageContext.testCase(id: testCaseID) else {
            return false
        }

        activeTestCaseDraft = draftsByTestCaseID[testCaseID] ?? TestCaseDraft(testCase: testCase)
        activeStepDraft = nil
        route = .testCase(testCaseID: testCaseID)
        return true
    }

    @discardableResult
    func openTestStep(id stepID: String) -> Bool {
        guard let activeTestCaseDraft,
              let composedDraft = activeTestCaseDraft.stepDraft(stepID: stepID) else {
            return false
        }

        activeStepDraft = composedDraft.draft
        route = .testStep(testCaseID: activeTestCaseDraft.id, stepID: stepID)
        return true
    }

    func applyOutcome(_ outcome: InspectionOutcome) {
        activeStepDraft?.outcome = outcome
    }

    func applyNotes(_ notes: String) {
        activeStepDraft?.notes = notes
    }

    func applyMeasurementInput(_ input: String) {
        guard var draft = activeStepDraft,
              let step = activeStep(for: draft.stepID) else {
            activeStepDraft?.measurementInput = input
            activeStepDraft?.measurementValue = nil
            return
        }

        let measurementInput = step.measurementInput(from: input)
        draft.measurementInput = measurementInput.rawValue
        draft.measurementValue = measurementInput.measurementValue
        activeStepDraft = draft
    }

    func applyEvidenceAttachments(_ attachments: [EvidenceAttachmentMetadata]) {
        activeStepDraft?.evidenceAttachments = attachments
    }

    @discardableResult
    func returnToTestCase() -> Bool {
        guard var testCaseDraft = activeTestCaseDraft,
              let stepDraft = activeStepDraft else {
            return false
        }

        testCaseDraft.updateStepDraft(stepDraft)
        activeTestCaseDraft = testCaseDraft
        draftsByTestCaseID[testCaseDraft.id] = testCaseDraft
        activeStepDraft = nil
        route = .testCase(testCaseID: testCaseDraft.id)
        return true
    }

    func persistedDraft(testCaseID: String) -> TestCaseDraft? {
        draftsByTestCaseID[testCaseID]
    }

    private func activeStep(for stepID: String) -> InspectionTestStep? {
        activeTestCaseDraft?.testCase.orderedSteps.first { $0.id == stepID }
    }
}
