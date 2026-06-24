import Foundation

struct InspectionTestCase: Identifiable, Codable, Hashable, Sendable {
    let id: String
    let code: String
    let title: String
    let ruleReferences: [String]
    let steps: [InspectionTestStep]

    init(
        id: String,
        code: String,
        title: String,
        ruleReferences: [String] = [],
        steps: [InspectionTestStep]
    ) {
        self.id = id
        self.code = code
        self.title = title
        self.ruleReferences = ruleReferences
        self.steps = steps
    }

    var orderedSteps: [InspectionTestStep] {
        steps
    }

    var stepIDs: [String] {
        orderedSteps.map(\.id)
    }

    var allRuleReferences: [String] {
        var seenRuleReferences: Set<String> = []
        return (ruleReferences + orderedSteps.map(\.ruleReference)).filter { ruleReference in
            seenRuleReferences.insert(ruleReference).inserted
        }
    }
}

struct TestStepDraft: Codable, Hashable, Sendable {
    let stepID: String
    var outcome: InspectionOutcome
    var notes: String
    var measurementInput: String
    var measurementValue: MeasurementValue?
    var evidenceAttachments: [EvidenceAttachmentMetadata]

    init(
        stepID: String,
        outcome: InspectionOutcome = .pending,
        notes: String = "",
        measurementInput: String = "",
        measurementValue: MeasurementValue? = nil,
        evidenceAttachments: [EvidenceAttachmentMetadata] = []
    ) {
        self.stepID = stepID
        self.outcome = outcome
        self.notes = notes
        self.measurementInput = measurementInput
        self.measurementValue = measurementValue
        self.evidenceAttachments = evidenceAttachments
    }

    init(step: InspectionTestStep) {
        self.init(
            stepID: step.id,
            outcome: step.defaultOutcome,
            notes: step.defaultNote,
            evidenceAttachments: step.evidenceAttachments
        )
    }
}

struct ComposedTestStepDraft: Identifiable, Codable, Hashable, Sendable {
    let step: InspectionTestStep
    var draft: TestStepDraft

    var id: String {
        step.id
    }

    var isComplete: Bool {
        if step.requiredOutcome && !draft.outcome.satisfiesRequiredOutcome {
            return false
        }

        if step.requiredOutcome && step.type == .measurement && draft.measurementValue == nil {
            return false
        }

        if step.requiresEvidence && draft.evidenceAttachments.isEmpty {
            return false
        }

        return true
    }
}

struct InspectionTestCaseProgress: Codable, Hashable, Sendable {
    let completedStepCount: Int
    let totalStepCount: Int
    let blockerCount: Int

    var fractionComplete: Double {
        guard totalStepCount > 0 else {
            return 1
        }

        return Double(completedStepCount) / Double(totalStepCount)
    }
}

struct TestCaseDraft: Identifiable, Codable, Hashable, Sendable {
    let testCase: InspectionTestCase
    var steps: [ComposedTestStepDraft]

    init(testCase: InspectionTestCase, stepDrafts: [TestStepDraft] = []) {
        self.testCase = testCase

        let draftsByStepID = stepDrafts.reduce(into: [String: TestStepDraft]()) { result, draft in
            result[draft.stepID] = draft
        }
        steps = testCase.orderedSteps.map { step in
            ComposedTestStepDraft(
                step: step,
                draft: draftsByStepID[step.id] ?? TestStepDraft(step: step)
            )
        }
    }

    var id: String {
        testCase.id
    }

    var progress: InspectionTestCaseProgress {
        let completedStepCount = steps.filter(\.isComplete).count
        let totalStepCount = steps.count

        return InspectionTestCaseProgress(
            completedStepCount: completedStepCount,
            totalStepCount: totalStepCount,
            blockerCount: totalStepCount - completedStepCount
        )
    }

    func stepDraft(stepID: String) -> ComposedTestStepDraft? {
        steps.first { $0.id == stepID }
    }
}
