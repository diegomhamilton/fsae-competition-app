import SwiftUI

/// Overview status distinguishes editable draft values from an explicitly confirmed result.
enum StageResultStatus: Equatable {
    case unanswered
    case draft
    case pass
    case fail
    case exception
    case flagged

    static func step(_ state: InspectionTestCaseStepViewState, hasIssues: Bool) -> Self {
        if state.flaggedForReview == true { return .flagged }
        if state.confirmedAt != nil && !hasIssues {
            if state.outcome == .fail { return .fail }
            if state.step.requiredOutcome && state.outcome == .notApplicable { return .exception }
            return .pass
        }
        let original = TestStepDraft(step: state.step)
        let hasInput = state.outcome != original.outcome || state.notes != original.notes
            || state.measurementInput != original.measurementInput
            || state.evidenceAttachments != original.evidenceAttachments
            || state.confirmedAt != nil
        return hasInput ? .draft : .unanswered
    }

    static func testCase(_ state: InspectionTestCaseViewState, issues: [FullStageValidationIssue]) -> Self {
        let scopedStatuses = state.steps.map { stepState in
            step(stepState, hasIssues: issues.contains { $0.stepID == stepState.id })
        }
        guard !scopedStatuses.isEmpty else { return .unanswered }
        if scopedStatuses.contains(.flagged) { return .flagged }
        if scopedStatuses.contains(.fail) { return .fail }
        if scopedStatuses.allSatisfy({ $0 == .unanswered }) { return .unanswered }
        if scopedStatuses.contains(.unanswered) || scopedStatuses.contains(.draft) { return .draft }
        if scopedStatuses.contains(.exception) { return .exception }
        return .pass
    }

    var title: String {
        switch self {
        case .unanswered: StageOverviewStrings.unanswered
        case .draft: StageOverviewStrings.draft
        case .pass: StageOverviewStrings.passed
        case .fail: StageOverviewStrings.failed
        case .exception: StageOverviewStrings.exception
        case .flagged: StageOverviewStrings.flagged
        }
    }

    var symbol: String {
        switch self {
        case .unanswered: "circle"
        case .draft: "square.and.pencil"
        case .pass: "checkmark.circle.fill"
        case .fail: "xmark.circle.fill"
        case .exception: "minus.circle.fill"
        case .flagged: "flag.fill"
        }
    }

    var color: Color {
        switch self {
        case .unanswered, .exception: .fsaeGray
        case .draft: .fsaePrimary
        case .pass: .fsaeGreen
        case .fail: .fsaeRed
        case .flagged: .fsaeAmber
        }
    }
}
