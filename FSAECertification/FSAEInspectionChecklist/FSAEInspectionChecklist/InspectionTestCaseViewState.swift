import Foundation

struct InspectionTestCaseViewState: Identifiable, Equatable, Sendable {
    let id: String
    let code: String
    let title: String
    let ruleReferences: [String]
    let steps: [InspectionTestCaseStepViewState]

    init(
        id: String,
        code: String,
        title: String,
        ruleReferences: [String],
        stepStates: [InspectionTestCaseStepViewState]
    ) {
        self.id = id
        self.code = code
        self.title = title
        self.ruleReferences = ruleReferences
        self.steps = stepStates.sorted { lhs, rhs in
            if lhs.displayOrder == rhs.displayOrder {
                lhs.step.code < rhs.step.code
            } else {
                lhs.displayOrder < rhs.displayOrder
            }
        }
    }

    var validationSummary: InspectionTestCaseValidationSummary {
        InspectionTestCaseValidationSummary(steps: steps)
    }

    var progressSummary: InspectionTestCaseProgressSummary {
        InspectionTestCaseProgressSummary(
            totalStepCount: steps.count,
            completeStepCount: steps.filter(\.isComplete).count,
            blockedStepCount: validationSummary.blockerCount
        )
    }
}

extension InspectionTestCaseViewState {
    init(testCase: InspectionTestCase) {
        self.init(testCase: testCase, draft: TestCaseDraft(testCase: testCase))
    }

    init(
        testCase: InspectionTestCase,
        draft: TestCaseDraft
    ) {
        self.init(
            id: testCase.id,
            code: testCase.code,
            title: testCase.title,
            ruleReferences: testCase.allRuleReferences,
            stepStates: testCase.orderedSteps.map { step in
                let draft = draft.stepDraft(stepID: step.id)?.draft ?? TestStepDraft(step: step)
                return InspectionTestCaseStepViewState(
                    displayOrder: step.displayOrder,
                    step: step,
                    outcome: draft.outcome,
                    notes: draft.notes,
                    measurementInput: draft.measurementInput,
                    evidenceAttachmentCount: draft.evidenceAttachments.count
                )
            }
        )
    }
}

struct InspectionTestCaseStepViewState: Identifiable, Equatable, Sendable {
    let displayOrder: Int
    let step: InspectionTestStep
    let outcome: InspectionOutcome
    let notes: String
    let measurementInput: String
    let evidenceAttachmentCount: Int

    var id: String {
        step.id
    }

    var validationIssues: [InspectionTestCaseValidationIssue] {
        InspectionTestCaseValidationIssue.issues(for: self)
    }

    var isComplete: Bool {
        validationIssues.isEmpty && (!step.requiredOutcome || outcome.satisfiesRequiredOutcome)
    }

    var status: InspectionTestCaseStepStatus {
        if !validationIssues.isEmpty {
            return .blocked
        }

        return isComplete ? .complete : .pending
    }
}

enum InspectionTestCaseStepStatus: Equatable, Sendable {
    case blocked
    case complete
    case pending
}

struct InspectionTestCaseValidationSummary: Equatable, Sendable {
    let issues: [InspectionTestCaseValidationIssue]

    init(steps: [InspectionTestCaseStepViewState]) {
        issues = steps.flatMap(\.validationIssues)
    }

    var blockerCount: Int {
        issues.count
    }

    var firstBlockingStepID: String? {
        issues.first?.stepID
    }

    var isPassing: Bool {
        issues.isEmpty
    }
}

struct InspectionTestCaseProgressSummary: Equatable, Sendable {
    let totalStepCount: Int
    let completeStepCount: Int
    let blockedStepCount: Int

    var pendingStepCount: Int {
        max(totalStepCount - completeStepCount - blockedStepCount, 0)
    }

    var fractionComplete: Double {
        guard totalStepCount > 0 else {
            return 0
        }

        return Double(completeStepCount) / Double(totalStepCount)
    }
}

struct InspectionTestCaseValidationIssue: Identifiable, Equatable, Sendable {
    enum Code: Equatable, Sendable {
        case missingRequiredOutcome
        case missingInspectorNote
        case missingRequiredEvidence
        case missingMeasurement
        case invalidMeasurement
    }

    let stepID: String
    let stepTitle: String
    let code: Code

    var id: String {
        "\(stepID).\(code.identifierSuffix)"
    }

    static func issues(for state: InspectionTestCaseStepViewState) -> [Self] {
        var issues: [Self] = []

        if state.step.requiredOutcome && !state.outcome.satisfiesRequiredOutcome {
            issues.append(
                Self(
                    stepID: state.id,
                    stepTitle: state.step.title,
                    code: .missingRequiredOutcome
                )
            )
        }

        if state.outcome.requiresInspectorNote && state.notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            issues.append(
                Self(
                    stepID: state.id,
                    stepTitle: state.step.title,
                    code: .missingInspectorNote
                )
            )
        }

        if state.step.requiresEvidence && state.evidenceAttachmentCount == 0 {
            issues.append(
                Self(
                    stepID: state.id,
                    stepTitle: state.step.title,
                    code: .missingRequiredEvidence
                )
            )
        }

        if state.step.type == .measurement, let range = state.step.measurementRange {
            let trimmedInput = state.measurementInput.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmedInput.isEmpty {
                issues.append(
                    Self(
                        stepID: state.id,
                        stepTitle: state.step.title,
                        code: .missingMeasurement
                    )
                )
            } else if (try? MeasurementValue(rawValue: trimmedInput, range: range)) == nil {
                issues.append(
                    Self(
                        stepID: state.id,
                        stepTitle: state.step.title,
                        code: .invalidMeasurement
                    )
                )
            }
        }

        return issues
    }
}

private extension InspectionTestCaseValidationIssue.Code {
    var identifierSuffix: String {
        switch self {
        case .missingRequiredOutcome: "missingRequiredOutcome"
        case .missingInspectorNote: "missingInspectorNote"
        case .missingRequiredEvidence: "missingRequiredEvidence"
        case .missingMeasurement: "missingMeasurement"
        case .invalidMeasurement: "invalidMeasurement"
        }
    }
}

enum InspectionTestCaseStrings: Equatable {
    case title
    case validationSummary
    case stepStatus

    func key(for stepID: String) -> String {
        switch self {
        case .title: "inspection.testCase.\(stepID).title"
        case .validationSummary: key
        case .stepStatus: "inspection.testCase.\(stepID).stepStatus"
        }
    }

    var key: String {
        switch self {
        case .title: "inspection.testCase.title"
        case .validationSummary: "inspection.testCase.validationSummary"
        case .stepStatus: "inspection.testCase.stepStatus"
        }
    }
}
