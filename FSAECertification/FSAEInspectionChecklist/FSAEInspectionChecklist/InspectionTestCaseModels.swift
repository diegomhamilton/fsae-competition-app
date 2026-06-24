import Foundation

/// Immutable inspection content for one test case within a stage.
///
/// A test case groups ordered inspection steps with the rule references judges need
/// while executing that slice of a stage.
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

/// Mutable draft values for one inspection test step in the active app process.
///
/// The draft mirrors editable judge input only. It does not own immutable step
/// content, and it is intentionally small enough to hand between coordinator
/// routes without pulling in broader session state.
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

/// A read-only step definition paired with the current draft values for that step.
///
/// Parent test case drafts use this composition so views and coordinators can read
/// official step content and judge-entered values from one ordered collection.
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

/// Mutable draft aggregation for all steps in one active test case.
///
/// The draft keeps step order aligned with immutable test case content while
/// allowing a child test step route to edit a single `TestStepDraft` and return it
/// to the parent test case.
struct TestCaseDraft: Identifiable, Codable, Hashable, Sendable {
    let testCase: InspectionTestCase
    private(set) var steps: [ComposedTestStepDraft]

    init(testCase: InspectionTestCase, stepDrafts: [TestStepDraft] = []) {
        self.testCase = testCase

        // Index incoming drafts once so composition stays ordered by immutable
        // test case content, not by the caller's draft array order.
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

    mutating func updateStepDraft(_ draft: TestStepDraft) {
        guard let index = steps.firstIndex(where: { $0.id == draft.stepID }) else {
            return
        }

        steps[index].draft = draft
    }
}
