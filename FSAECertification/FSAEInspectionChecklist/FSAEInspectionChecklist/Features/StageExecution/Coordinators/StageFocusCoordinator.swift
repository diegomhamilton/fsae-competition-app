//
//  StageFocusCoordinator.swift
//  FSAEInspectionChecklist
//

import Foundation
import Observation

/// Keeps the judge's place while moving between the queue, one test, and review.
/// Drafts remain owned by InspectionExecutionCoordinator and are never copied here.
@MainActor
@Observable
final class StageFocusCoordinator {
    private enum Strings {
        static let confirmationRequired = "Confirm this result."
        static let evidenceRequired = "Add a photo before confirming this result."
        static let flagRequiresReview = "Resolve this flag before submission."
    }

    enum Mode: Equatable {
        case queue
        case focus
        case review
    }

    private struct Selection: Equatable {
        let testCaseID: String
        let stepID: String
    }

    let stage: InspectionStage
    private(set) var mode: Mode = .queue
    private(set) var selectedTestCaseID: String?
    private(set) var activeStepID: String?
    private(set) var isEditingFromReview = false
    private var reviewReturnSelection: Selection?
    private let evidenceAvailable: (EvidenceAttachmentMetadata) -> Bool

    init(
        stage: InspectionStage,
        evidenceAvailable: @escaping (EvidenceAttachmentMetadata) -> Bool = {
            FocusedResultEvidenceStore.localAssetAvailable($0)
        }
    ) {
        self.stage = stage
        self.evidenceAvailable = evidenceAvailable
    }

    var orderedTestCases: [InspectionTestCase] {
        stage.orderedSections.flatMap(\.orderedTestCases)
    }

    var activeTestCase: InspectionTestCase? {
        orderedTestCases.first { $0.id == selectedTestCaseID }
    }

    var activeStep: InspectionTestStep? {
        activeTestCase?.orderedSteps.first { $0.id == activeStepID }
    }

    var hasReviewReturnPoint: Bool {
        reviewReturnSelection != nil
    }

    var hasActiveSelection: Bool {
        selection != nil
    }

    /// Resume the first incomplete or unconfirmed result in official order.
    /// A fully completed stage opens review and keeps its last test as the return point.
    @discardableResult
    func startNext(draftsByTestCaseID: [String: TestCaseDraft]) -> Bool {
        for testCase in orderedTestCases {
            if let firstIncomplete = stepStates(for: testCase, drafts: draftsByTestCaseID).first(where: { !isConfirmed($0) }) {
                select(Selection(testCaseID: testCase.id, stepID: firstIncomplete.id))
                return true
            }
        }

        guard let lastCase = orderedTestCases.last(where: { !$0.orderedSteps.isEmpty }),
              let lastStep = lastCase.orderedSteps.last else {
            return false
        }
        select(Selection(testCaseID: lastCase.id, stepID: lastStep.id))
        showReview()
        return true
    }

    @discardableResult
    func selectTestCase(
        id testCaseID: String,
        stepID: String? = nil,
        draftsByTestCaseID: [String: TestCaseDraft]
    ) -> Bool {
        guard let testCase = orderedTestCases.first(where: { $0.id == testCaseID }) else {
            return false
        }
        let chosenStep: InspectionTestStep?
        if let stepID {
            chosenStep = testCase.orderedSteps.first { $0.id == stepID }
        } else {
            let firstIncompleteID = stepStates(for: testCase, drafts: draftsByTestCaseID)
                .first(where: { !isConfirmed($0) })?.id
            chosenStep = testCase.orderedSteps.first { $0.id == firstIncompleteID } ?? testCase.orderedSteps.first
        }
        guard let chosenStep else {
            return false
        }
        select(Selection(testCaseID: testCase.id, stepID: chosenStep.id))
        return true
    }

    @discardableResult
    func selectStep(id stepID: String) -> Bool {
        guard let testCase = activeTestCase,
              testCase.orderedSteps.contains(where: { $0.id == stepID }) else {
            return false
        }
        activeStepID = stepID
        return true
    }

    func showQueue() {
        mode = .queue
    }

    func showReview() {
        if mode != .review && !isEditingFromReview, let selection {
            reviewReturnSelection = selection
        }
        isEditingFromReview = false
        mode = .review
    }

    /// Returning from queue preserves the selection; returning from review restores
    /// the original selection even when another result was edited during that review.
    @discardableResult
    func backToTest() -> Bool {
        let continuingReviewEdit = mode == .queue && isEditingFromReview
        let target = mode == .review ? reviewReturnSelection : selection
        guard let target else {
            mode = .queue
            return false
        }
        select(target)
        isEditingFromReview = continuingReviewEdit
        return true
    }

    @discardableResult
    func editResult(testCaseID: String, stepID: String) -> Bool {
        guard let testCase = orderedTestCases.first(where: { $0.id == testCaseID }),
              testCase.orderedSteps.contains(where: { $0.id == stepID }) else {
            return false
        }
        select(Selection(testCaseID: testCaseID, stepID: stepID))
        isEditingFromReview = true
        return true
    }

    func returnToReview() {
        isEditingFromReview = false
        mode = .review
    }

    /// Call only after the result component confirms that the current save succeeded.
    /// The coordinator also checks the persisted fields before moving the judge's place.
    @discardableResult
    func advanceAfterSave(draftsByTestCaseID: [String: TestCaseDraft]) -> Bool {
        guard mode == .focus,
              let testCase = activeTestCase,
              let currentStepIndex = testCase.orderedSteps.firstIndex(where: { $0.id == activeStepID }) else {
            return false
        }
        let states = stepStates(for: testCase, drafts: draftsByTestCaseID)
        guard let currentState = states.first(where: { $0.id == activeStepID }), isConfirmed(currentState) else {
            return false
        }

        if isEditingFromReview {
            returnToReview()
            return true
        }

        let steps = testCase.orderedSteps
        if steps.indices.contains(currentStepIndex + 1) {
            activeStepID = steps[currentStepIndex + 1].id
            return true
        }
        if let earlierIncomplete = states.first(where: { !isConfirmed($0) }) {
            activeStepID = earlierIncomplete.id
            return true
        }

        guard let caseIndex = orderedTestCases.firstIndex(where: { $0.id == testCase.id }) else {
            return false
        }
        let laterCases = orderedTestCases.dropFirst(caseIndex + 1)
        if let nextCase = laterCases.first(where: { !$0.orderedSteps.isEmpty }) {
            return selectTestCase(id: nextCase.id, draftsByTestCaseID: draftsByTestCaseID)
        }
        showReview()
        return true
    }

    /// Focus mode requires evidence and explicit confirmation. Existing broad validation
    /// still supports deferred evidence; this gate belongs to the new execution flow.
    func focusedValidationIssues(draftsByTestCaseID: [String: TestCaseDraft]) -> [FullStageValidationIssue] {
        orderedTestCases.flatMap { testCase in
            stepStates(for: testCase, drafts: draftsByTestCaseID).flatMap { state in
                let issues = focusedStepIssues(for: state)
                var focusedIssues = issues.map { issue in
                    FullStageValidationIssue(
                        stageID: stage.id,
                        testCaseID: testCase.id,
                        testCaseCode: testCase.code,
                        stepID: issue.stepID,
                        stepTitle: issue.stepTitle,
                        message: issue.code == .missingRequiredEvidence ? Strings.evidenceRequired : issue.localizedMessage,
                        issueID: issue.id
                    )
                }
                if issues.isEmpty && state.confirmedAt == nil {
                    focusedIssues.append(FullStageValidationIssue(
                        stageID: stage.id,
                        testCaseID: testCase.id,
                        testCaseCode: testCase.code,
                        stepID: state.id,
                        stepTitle: state.step.title,
                        message: Strings.confirmationRequired,
                        issueID: "unconfirmedResult.\(state.id)"
                    ))
                }
                if state.flaggedForReview == true {
                    focusedIssues.append(FullStageValidationIssue(
                        stageID: stage.id,
                        testCaseID: testCase.id,
                        testCaseCode: testCase.code,
                        stepID: state.id,
                        stepTitle: state.step.title,
                        message: Strings.flagRequiresReview,
                        issueID: "flaggedIssue.\(state.id)"
                    ))
                }
                return focusedIssues
            }
        }
    }

    private var selection: Selection? {
        guard let selectedTestCaseID, let activeStepID else {
            return nil
        }
        return Selection(testCaseID: selectedTestCaseID, stepID: activeStepID)
    }

    private func select(_ target: Selection) {
        selectedTestCaseID = target.testCaseID
        activeStepID = target.stepID
        isEditingFromReview = false
        mode = .focus
    }

    private func stepStates(for testCase: InspectionTestCase, drafts: [String: TestCaseDraft]) -> [InspectionTestCaseStepViewState] {
        InspectionTestCaseViewState(
            testCase: testCase,
            draft: drafts[testCase.id] ?? TestCaseDraft(testCase: testCase)
        ).steps
    }

    private func isConfirmed(_ state: InspectionTestCaseStepViewState) -> Bool {
        state.isComplete && state.confirmedAt != nil && focusedStepIssues(for: state).isEmpty
    }

    private func focusedStepIssues(for state: InspectionTestCaseStepViewState) -> [InspectionTestCaseValidationIssue] {
        var issues = state.validationIssues
        if state.step.type == .measurement && state.step.measurementRange == nil {
            let input = state.measurementInput.trimmingCharacters(in: .whitespacesAndNewlines)
            if input.isEmpty {
                issues.append(InspectionTestCaseValidationIssue(stepID: state.id, stepTitle: state.step.title, code: .missingMeasurement))
            } else if Decimal(string: input, locale: Locale(identifier: "en_US_POSIX")) == nil {
                issues.append(InspectionTestCaseValidationIssue(stepID: state.id, stepTitle: state.step.title, code: .invalidMeasurement))
            }
        }
        if state.step.requiresEvidence && !state.evidenceAttachments.contains(where: evidenceAvailable) {
            issues.append(InspectionTestCaseValidationIssue(stepID: state.id, stepTitle: state.step.title, code: .missingRequiredEvidence))
        }
        return issues
    }
}
