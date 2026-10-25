import Foundation
import Testing
@testable import FSAEInspectionChecklist

@MainActor
struct StageResultStatusTests {
    @Test("Queue status distinguishes unanswered input, draft values, and confirmed outcomes")
    func stepStatusesFollowConfirmation() {
        #expect(StageResultStatus.step(statusState(outcome: .pending), hasIssues: true) == .unanswered)
        #expect(StageResultStatus.step(statusState(outcome: .pass), hasIssues: true) == .draft)
        #expect(StageResultStatus.step(statusState(outcome: .pass, confirmedAt: .now), hasIssues: false) == .pass)
        #expect(StageResultStatus.step(statusState(outcome: .fail, notes: "Mounting loose.", confirmedAt: .now), hasIssues: false) == .fail)
        #expect(StageResultStatus.step(statusState(outcome: .notApplicable, confirmedAt: .now), hasIssues: false) == .exception)
        #expect(StageResultStatus.step(statusState(outcome: .pass, confirmedAt: .now), hasIssues: true) == .draft)
    }

    @Test("Confirmed evidence-only results share the Pass presentation without changing their outcome")
    func evidenceOnlyStatusUsesPassPresentation() {
        let step = InspectionTestStep(id: "photo", code: "P", ruleReference: "T.1", title: "Photo", type: .check,
                                      content: "Record evidence.", requiredOutcome: false, requiresEvidence: true)
        let state = InspectionTestCaseStepViewState(displayOrder: 1, step: step, inheritedSafetyBadges: [],
            outcome: .notApplicable, notes: "", measurementInput: "", evidenceAttachments: [], confirmedAt: .now)
        #expect(StageResultStatus.step(state, hasIssues: false) == .pass)
        #expect(state.outcome == .notApplicable)
        let testCase = InspectionTestCaseViewState(id: "case", code: "P", title: "Photo", ruleReferences: [], stepStates: [state])
        #expect(StageResultStatus.testCase(testCase, issues: []) == .pass)
    }

    @Test("Case status cannot be complete while another step remains an unconfirmed draft")
    func partialCaseRemainsDraft() {
        let first = statusState(id: "first", outcome: .pass, confirmedAt: .now)
        let second = statusState(id: "second", outcome: .pass)
        let state = InspectionTestCaseViewState(id: "case", code: "CASE", title: "Case", ruleReferences: [], stepStates: [first, second])
        let issue = FullStageValidationIssue(stageID: "stage", testCaseID: "case", testCaseCode: "CASE",
                                            stepID: "second", stepTitle: "second", message: "Confirm this result.",
                                            issueID: "unconfirmedResult.second")
        #expect(StageResultStatus.testCase(state, issues: [issue]) == .draft)
    }

    @Test("A confirmed failed step remains visible as Fail in the case overview")
    func failureIsNotConflatedWithIncompleteSave() {
        let state = InspectionTestCaseViewState(id: "case", code: "CASE", title: "Case", ruleReferences: [], stepStates: [
            statusState(id: "first", outcome: .pass, confirmedAt: .now),
            statusState(id: "second", outcome: .fail, notes: "Replace fastener.", confirmedAt: .now)
        ])
        #expect(StageResultStatus.testCase(state, issues: []) == .fail)
    }

    @Test("A confirmed failure remains prominent while other results in the same test are still drafts")
    func failureDominatesPartialCaseLabel() {
        let state = InspectionTestCaseViewState(id: "case", code: "CASE", title: "Case", ruleReferences: [], stepStates: [
            statusState(id: "first", outcome: .fail, notes: "Replace fastener.", confirmedAt: .now),
            statusState(id: "second", outcome: .pass)
        ])
        let issue = FullStageValidationIssue(stageID: "stage", testCaseID: "case", testCaseCode: "CASE",
                                            stepID: "second", stepTitle: "second", message: "Confirm this result.",
                                            issueID: "unconfirmedResult.second")
        #expect(StageResultStatus.testCase(state, issues: [issue]) == .fail)
        #expect(StageResultStatus.step(state.steps[1], hasIssues: true) == .draft)
    }

    @Test("Unresolved review flags remain explicit in the overview after a result is confirmed")
    func flaggedResultHasFlaggedStatus() {
        let state = statusState(outcome: .fail, notes: "Check mounting.", confirmedAt: .now, flaggedForReview: true)
        #expect(StageResultStatus.step(state, hasIssues: true) == .flagged)
        let testCase = InspectionTestCaseViewState(id: "case", code: "CASE", title: "Case", ruleReferences: [], stepStates: [state])
        let issue = FullStageValidationIssue(stageID: "stage", testCaseID: "case", testCaseCode: "CASE", stepID: state.id,
                                            stepTitle: state.step.title, message: "Resolve this flag before submission.", issueID: "flaggedIssue.\(state.id)")
        #expect(StageResultStatus.testCase(testCase, issues: [issue]) == .flagged)
    }
}

private func statusState(id: String = "step", outcome: InspectionOutcome, notes: String = "", confirmedAt: Date? = nil, flaggedForReview: Bool? = nil) -> InspectionTestCaseStepViewState {
    InspectionTestCaseStepViewState(displayOrder: 1, step: InspectionTestStep(
        id: id, code: id, ruleReference: "T.1", title: id, type: .check, content: "Verify mounting.",
        requiredOutcome: true, requiresEvidence: false
    ), inheritedSafetyBadges: [], outcome: outcome, notes: notes, measurementInput: "", evidenceAttachments: [], confirmedAt: confirmedAt, flaggedForReview: flaggedForReview)
}
