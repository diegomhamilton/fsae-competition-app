import Foundation

/// Immutable inspection content for one test case within a stage.
///
/// A test case groups ordered inspection steps with the rule references judges need
/// while executing that slice of a stage.
struct InspectionTestCase: Identifiable, Codable, Hashable, Sendable {
    let id: String
    let code: String
    let displayOrder: Int
    let title: String
    let ruleReferences: [String]
    let safetyBadges: [InspectionSafetyBadge]
    let steps: [InspectionTestStep]

    init(
        id: String,
        code: String,
        displayOrder: Int = 0,
        title: String,
        ruleReferences: [String] = [],
        safetyBadges: [InspectionSafetyBadge] = [],
        steps: [InspectionTestStep]
    ) {
        self.id = id
        self.code = code
        self.displayOrder = displayOrder
        self.title = title
        self.ruleReferences = ruleReferences
        self.safetyBadges = safetyBadges
        self.steps = steps
    }

    var orderedSteps: [InspectionTestStep] {
        steps.sorted { lhs, rhs in
            if lhs.displayOrder == rhs.displayOrder {
                lhs.code < rhs.code
            } else {
                lhs.displayOrder < rhs.displayOrder
            }
        }
    }

    var stepIDs: [String] {
        orderedSteps.map(\.id)
    }

    var allRuleReferences: [String] {
        var seenRuleReferences: Set<String> = []
        return (ruleReferences + orderedSteps.map(\.ruleReference)).filter { ruleReference in
            guard !ruleReference.isEmpty else {
                return false
            }

            seenRuleReferences.insert(ruleReference).inserted
        }
    }
}

extension InspectionTestCase {
    private enum CodingKeys: String, CodingKey {
        case id
        case itemID = "itemId"
        case code
        case displayOrder
        case title
        case ruleReference = "ruleRef"
        case ruleReferences
        case badges
        case safetyBadges
        case steps
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let decodedID = try container.decodeIfPresent(String.self, forKey: .id)
            ?? container.decode(String.self, forKey: .itemID)
        let decodedCode = try container.decodeIfPresent(String.self, forKey: .code) ?? decodedID
        let decodedRuleReferences = try container.decodeIfPresent([String].self, forKey: .ruleReferences)
            ?? container.decodeIfPresent(String.self, forKey: .ruleReference).map { [$0] }
            ?? []
        let decodedBadges = try container.decodeIfPresent([InspectionSafetyBadge].self, forKey: .safetyBadges)
            ?? container.decodeIfPresent([InspectionSafetyBadge].self, forKey: .badges)
            ?? []
        let decodedTitle = try container.decode(String.self, forKey: .title)

        id = decodedID
        code = decodedCode
        displayOrder = try container.decode(Int.self, forKey: .displayOrder)
        title = decodedTitle
        ruleReferences = decodedRuleReferences
        safetyBadges = decodedBadges
        steps = try container.decode([DecodedInspectionStep].self, forKey: .steps).enumerated().map { index, rawStep in
            rawStep.step(
                fallbackDisplayOrder: index + 1,
                testCaseID: decodedID,
                testCaseCode: decodedCode,
                testCaseTitle: decodedTitle,
                ruleReference: decodedRuleReferences.first ?? "",
                safetyBadges: decodedBadges
            )
        }
    }
}

private struct DecodedInspectionStep: Decodable {
    let id: String?
    let code: String?
    let displayOrder: Int?
    let ruleReference: String?
    let title: String?
    let type: InspectionTestStepType
    let content: String
    let requiredOutcome: Bool?
    let requiresEvidence: Bool?
    let safetyBadges: [InspectionSafetyBadge]?
    let defaultOutcome: InspectionOutcome?
    let defaultNote: String?
    let measurementRange: MeasurementRange?
    let evidenceAttachments: [EvidenceAttachmentMetadata]?

    private enum CodingKeys: String, CodingKey {
        case id
        case code
        case displayOrder
        case ruleReference
        case title
        case type
        case content
        case requiredOutcome
        case requiresEvidence
        case safetyBadges
        case defaultOutcome
        case defaultNote
        case measurementRange
        case evidenceAttachments
    }

    func step(
        fallbackDisplayOrder: Int,
        testCaseID: String,
        testCaseCode: String,
        testCaseTitle: String,
        ruleReference inheritedRuleReference: String,
        safetyBadges inheritedSafetyBadges: [InspectionSafetyBadge]
    ) -> InspectionTestStep {
        let stableDisplayOrder = displayOrder ?? fallbackDisplayOrder

        InspectionTestStep(
            id: id ?? "\(testCaseID).step.\(stableDisplayOrder)",
            code: code ?? "\(testCaseCode)-\(stableDisplayOrder)",
            displayOrder: stableDisplayOrder,
            ruleReference: ruleReference ?? inheritedRuleReference,
            title: title ?? "\(testCaseTitle) Step \(stableDisplayOrder)",
            type: type,
            content: content,
            requiredOutcome: requiredOutcome ?? true,
            requiresEvidence: requiresEvidence ?? false,
            safetyBadges: safetyBadges ?? inheritedSafetyBadges,
            defaultOutcome: defaultOutcome ?? .pending,
            defaultNote: defaultNote ?? "",
            measurementRange: measurementRange,
            evidenceAttachments: evidenceAttachments ?? []
        )
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
    private var standaloneStepDrafts: [TestStepDraft]

    init(testCase: InspectionTestCase, stepDrafts: [TestStepDraft] = []) {
        self.testCase = testCase
        standaloneStepDrafts = []

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

    init(testCaseID: String, stepDrafts: [TestStepDraft] = []) {
        testCase = InspectionTestCase(
            id: testCaseID,
            code: testCaseID,
            title: testCaseID,
            steps: []
        )
        steps = []
        standaloneStepDrafts = stepDrafts
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

    var aggregate: TestCaseDraftAggregate {
        TestCaseDraftAggregate(stepDrafts: allStepDrafts)
    }

    func validationSummary(for testCase: InspectionTestCase) -> TestCaseDraftValidationSummary {
        let service = InspectionValidationService()
        let draftsByStepID = allStepDrafts.reduce(into: [String: TestStepDraft]()) { result, draft in
            result[draft.stepID] = draft
        }
        let issues = testCase.orderedSteps.flatMap { step in
            let draft = draftsByStepID[step.id] ?? TestStepDraft(step: step)
            return service.validateStep(
                step,
                result: StepResult(
                    outcome: draft.outcome,
                    notes: draft.notes,
                    measurementInput: draft.measurementInput,
                    measurementValue: draft.measurementValue,
                    evidenceAttachments: draft.evidenceAttachments
                )
            )
        }

        return TestCaseDraftValidationSummary(issues: issues)
    }

    func progress(for testCase: InspectionTestCase) -> InspectionTestCaseProgressSummary {
        let summary = validationSummary(for: testCase)
        let draftsByStepID = allStepDrafts.reduce(into: [String: TestStepDraft]()) { result, draft in
            result[draft.stepID] = draft
        }
        let completeCount = testCase.orderedSteps.filter { step in
            guard !summary.issues.contains(where: { $0.stepID == step.id }) else {
                return false
            }

            let draft = draftsByStepID[step.id] ?? TestStepDraft(step: step)
            return !step.requiredOutcome || draft.outcome.satisfiesRequiredOutcome
        }.count

        return InspectionTestCaseProgressSummary(
            totalStepCount: testCase.orderedSteps.count,
            completeStepCount: completeCount,
            blockedStepCount: summary.blockerCount
        )
    }

    private var allStepDrafts: [TestStepDraft] {
        steps.map(\.draft) + standaloneStepDrafts
    }
}

struct TestCaseDraftAggregate: Equatable, Sendable {
    let outcomesByStepID: [String: InspectionOutcome]
    let notesByStepID: [String: String]
    let measurementsByStepID: [String: MeasurementValue]
    let evidenceAttachmentsByStepID: [String: [EvidenceAttachmentMetadata]]
    let failedStepIDs: [String]

    init(stepDrafts: [TestStepDraft]) {
        outcomesByStepID = stepDrafts.reduce(into: [:]) { result, draft in
            result[draft.stepID] = draft.outcome
        }
        notesByStepID = stepDrafts.reduce(into: [:]) { result, draft in
            result[draft.stepID] = draft.notes
        }
        measurementsByStepID = stepDrafts.reduce(into: [:]) { result, draft in
            result[draft.stepID] = draft.measurementValue
        }
        evidenceAttachmentsByStepID = stepDrafts.reduce(into: [:]) { result, draft in
            result[draft.stepID] = draft.evidenceAttachments
        }
        failedStepIDs = stepDrafts.filter { $0.outcome == .fail }.map(\.stepID)
    }
}

struct TestCaseDraftValidationSummary: Equatable, Sendable {
    let issues: [ValidationIssue]

    var blockerCount: Int {
        issues.count
    }

    var firstBlockingStepID: String? {
        issues.first?.stepID
    }
}

private extension ValidationIssue {
    var stepID: String {
        switch code {
        case .missingRequiredOutcome(let stepID),
                .missingInspectorNote(let stepID),
                .missingMeasurement(let stepID),
                .invalidMeasurement(let stepID, _),
                .missingRequiredEvidence(let stepID):
            stepID
        }
    }
}
