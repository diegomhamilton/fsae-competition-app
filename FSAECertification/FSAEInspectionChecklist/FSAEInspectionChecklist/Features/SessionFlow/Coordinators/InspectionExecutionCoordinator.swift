//
//  InspectionExecutionCoordinator.swift
//  FSAEInspectionChecklist
//

import Combine
import Foundation

@MainActor
final class InspectionExecutionCoordinator: ObservableObject {
    @Published private(set) var sessionContext: InspectionSessionContext
    @Published var stageNavigationPath: [StageNavigationRoute] = []
    @Published private(set) var pendingSwitchTarget: InspectionTeam?
    @Published private(set) var draftsByStageID: [String: [String: TestCaseDraft]]
    @Published private(set) var failedDraftCaseIDsByStageID: [String: Set<String>] = [:]
    let teams: [InspectionTeam]
    private let stageModels: [InspectionStage]
    private let store: InspectionEventStore
    private let access: InspectionEventUserAccess
    private var draftSaveTask: Task<Bool, Never>?
    private var latestDraftSaveTokens: [InspectionSessionScope: [String: UUID]] = [:]
    private var unsavedTestCaseIDs: [InspectionSessionScope: Set<String>] = [:]

    init(
        sessionContext: InspectionSessionContext,
        stages: [InspectionStage],
        teams: [InspectionTeam],
        store: InspectionEventStore,
        access: InspectionEventUserAccess,
        draftsByStageID: [String: [String: TestCaseDraft]] = [:],
        draftsByTestCaseID: [String: TestCaseDraft] = [:]
    ) {
        self.sessionContext = sessionContext
        self.stageModels = stages
        self.teams = teams
        self.store = store
        self.access = access
        var stageDrafts = draftsByStageID
        if !draftsByTestCaseID.isEmpty {
            stageDrafts[sessionContext.activeStageID, default: [:]].merge(draftsByTestCaseID) { _, new in
                new
            }
        }
        self.draftsByStageID = stageDrafts
    }

    var stages: [FullStageViewState] {
        stageModels.map { stage in
            FullStageViewState(
                stage: stage,
                draftsByTestCaseID: draftsByStageID[stage.id] ?? [:]
            )
        }
    }

    var sessionBlockerCount: Int {
        stages.map(\.blockerCount).reduce(0, +)
    }

    var canCompleteSession: Bool {
        sessionBlockerCount == 0
    }

    var draftsByTestCaseID: [String: TestCaseDraft] {
        draftsByStageID[sessionContext.activeStageID] ?? [:]
    }

    var failedDraftCaseIDs: Set<String> {
        failedDraftCaseIDsByStageID[sessionContext.activeStageID] ?? []
    }

    var activeTeam: InspectionTeam {
        sessionContext.team
    }

    var activeStage: InspectionStage? {
        stage(id: sessionContext.activeStageID)
    }

    var activeTestCase: InspectionTestCase? {
        guard let testCaseID = activeTestCaseID else {
            return nil
        }

        return testCase(id: testCaseID)
    }

    var activeStep: InspectionTestStep? {
        guard case .testStep(_, let stepID) = stageNavigationPath.last else {
            return nil
        }

        return activeTestCase?.orderedSteps.first { $0.id == stepID }
    }

    var activeTestCaseDraft: TestCaseDraft? {
        guard let activeTestCase else {
            return nil
        }

        return draft(for: activeTestCase)
    }

    var activeStepDraft: TestStepDraft? {
        guard let activeStep else {
            return nil
        }

        return activeTestCaseDraft?.stepDraft(stepID: activeStep.id)?.draft
    }

    func draft(for testCase: InspectionTestCase) -> TestCaseDraft {
        draftsByTestCaseID[testCase.id] ?? TestCaseDraft(testCase: testCase)
    }

    private var activeTestCaseID: String? {
        stageNavigationPath.last?.testCaseID
    }

    func markUnsavedDraft(_ hasUnsavedDraft: Bool) {
        sessionContext.hasUnsavedDraft = hasUnsavedDraft
    }

    @discardableResult
    func openStage(id stageID: String) async -> Bool {
        guard stage(id: stageID) != nil else {
            return false
        }

        sessionContext.activeStageID = stageID
        stageNavigationPath.removeAll()
        await restoreDraftsForActiveStage()
        return true
    }

    @discardableResult
    func openTestCase(id testCaseID: String) -> Bool {
        guard testCase(id: testCaseID) != nil else {
            return false
        }

        stageNavigationPath = [.testCase(testCaseID: testCaseID)]
        return true
    }

    @discardableResult
    func openTestStep(id stepID: String) -> Bool {
        guard let testCase = activeTestCase ?? testCase(containingStepID: stepID),
              testCase.orderedSteps.contains(where: { $0.id == stepID }) else {
            return false
        }

        stageNavigationPath = [
            .testCase(testCaseID: testCase.id),
            .testStep(testCaseID: testCase.id, stepID: stepID)
        ]
        return true
    }

    @discardableResult
    func requestTeamSwitch(to targetTeamID: Int) -> Bool {
        // Team switching is intentionally disabled for the Task 10.6 PR.
        return false
    }

    func cancelTeamSwitch() {
        pendingSwitchTarget = nil
    }

    func returnToActiveStage() {
        stageNavigationPath.removeAll()
    }

    func returnToActiveTestCase() {
        guard let testCaseID = activeTestCaseID else {
            returnToActiveStage()
            return
        }

        stageNavigationPath = [.testCase(testCaseID: testCaseID)]
    }

    func restoreDraftsForActiveStage() async {
        await restoreDrafts(for: sessionContext.activeStageID)
    }

    func restoreDraftsForAllStages() async {
        for stage in stageModels {
            await restoreDrafts(for: stage.id)
        }
    }

    private func restoreDrafts(for stageID: String) async {
        do {
            let draftFiles = try await store.draftFiles(
                scope: scope(stageID: stageID),
                access: access
            )
            draftsByStageID[stageID] = draftFiles.reduce(into: draftsByStageID[stageID] ?? [:]) { result, file in
                result[file.testCaseID] = file.draft
            }
        } catch {
            return
        }
    }

    @discardableResult
    func saveStepDraft(_ stepDraft: TestStepDraft, testCaseID: String) async -> Bool {
        guard let target = testCaseAndStage(id: testCaseID),
              target.testCase.orderedSteps.contains(where: { $0.id == stepDraft.stepID }) else {
            return false
        }

        var stageDrafts = draftsByStageID[target.stageID] ?? [:]
        var testCaseDraft = stageDrafts[testCaseID] ?? TestCaseDraft(testCase: target.testCase)
        testCaseDraft.updateStepDraft(stepDraft)
        stageDrafts[testCaseID] = testCaseDraft
        draftsByStageID[target.stageID] = stageDrafts
        return await persistDraft(testCaseDraft, stageID: target.stageID, attemptedStep: stepDraft)
    }

    /// Retries the current whole-case values, including edits made after a failed
    /// write. Recovery never manufactures an explicit result confirmation.
    @discardableResult
    func retryFailedDraftSaves() async -> Bool {
        let stageID = sessionContext.activeStageID
        guard let activeStage = stage(id: stageID) else { return false }
        let failedIDs = failedDraftCaseIDsByStageID[stageID] ?? []
        var allSucceeded = true
        for testCase in activeStage.orderedSections.flatMap(\.orderedTestCases) where failedIDs.contains(testCase.id) {
            guard let currentDraft = draftsByStageID[stageID]?[testCase.id] else {
                allSucceeded = false
                continue
            }
            let saved = await persistDraft(currentDraft, stageID: stageID)
            allSucceeded = saved && allSucceeded
        }
        return allSucceeded && (failedDraftCaseIDsByStageID[stageID] ?? []).isEmpty
    }

    private func persistDraft(_ draftSnapshot: TestCaseDraft, stageID: String, attemptedStep: TestStepDraft? = nil) async -> Bool {
        let testCaseID = draftSnapshot.id
        sessionContext.hasUnsavedDraft = true

        // Capture the complete case and its scope before suspension. Chaining writes
        // prevents rapid edits from persisting an older whole-case snapshot last.
        let saveScope = scope(stageID: stageID)
        let saveToken = UUID()
        latestDraftSaveTokens[saveScope, default: [:]][testCaseID] = saveToken
        unsavedTestCaseIDs[saveScope, default: []].insert(testCaseID)
        let previousSave = draftSaveTask
        let saveTask = Task { [store, access] in
            if let previousSave {
                _ = await previousSave.value
            }
            do {
                _ = try await store.saveDraft(draftSnapshot, scope: saveScope, access: access)
                return true
            } catch {
                return false
            }
        }
        draftSaveTask = saveTask
        let saved = await saveTask.value

        if !saved, let attemptedStep, attemptedStep.confirmedAt != nil,
           var currentCaseDraft = draftsByStageID[stageID]?[testCaseID],
           currentCaseDraft.stepDraft(stepID: attemptedStep.stepID)?.draft == attemptedStep {
            // A failed confirmation must stay editable, without losing judge input
            // or clearing a newer result that arrived while this write was pending.
            var unconfirmedDraft = attemptedStep
            unconfirmedDraft.confirmedAt = nil
            currentCaseDraft.updateStepDraft(unconfirmedDraft)
            draftsByStageID[stageID]?[testCaseID] = currentCaseDraft
        }

        // Only the newest successful write for this case can clear its dirty state.
        // A success elsewhere must not hide a failed save that still needs retry.
        if latestDraftSaveTokens[saveScope]?[testCaseID] == saveToken {
            if saved {
                unsavedTestCaseIDs[saveScope]?.remove(testCaseID)
                latestDraftSaveTokens[saveScope]?.removeValue(forKey: testCaseID)
                failedDraftCaseIDsByStageID[stageID]?.remove(testCaseID)
            } else {
                failedDraftCaseIDsByStageID[stageID, default: []].insert(testCaseID)
            }
        }
        sessionContext.hasUnsavedDraft = unsavedTestCaseIDs.values.contains { !$0.isEmpty }
        return saved
    }

    #if DEBUG
    @discardableResult
    func markAllTestCasesPassedForDebug(at completedAt: Date = Date()) async -> Bool {
        var nextDraftsByStageID = draftsByStageID

        for stage in stageModels {
            var stageDrafts = nextDraftsByStageID[stage.id] ?? [:]
            for testCase in stage.orderedSections.flatMap(\.orderedTestCases) {
                let stepDrafts = testCase.orderedSteps.map { step in
                    TestStepDraft.debugPassingDraft(step: step, completedAt: completedAt)
                }
                let testCaseDraft = TestCaseDraft(testCase: testCase, stepDrafts: stepDrafts)
                stageDrafts[testCase.id] = testCaseDraft
            }
            nextDraftsByStageID[stage.id] = stageDrafts
        }

        draftsByStageID = nextDraftsByStageID
        sessionContext.hasUnsavedDraft = true

        for (stageID, stageDrafts) in nextDraftsByStageID {
            for draft in stageDrafts.values {
                do {
                    _ = try await store.saveDraft(
                        draft,
                        scope: scope(stageID: stageID),
                        access: access
                    )
                } catch {
                    return false
                }
            }
        }

        sessionContext.hasUnsavedDraft = false
        return canCompleteSession
    }

    @discardableResult
    func markAllTestCasesIncompleteForDebug() async -> Bool {
        var nextDraftsByStageID = draftsByStageID

        for stage in stageModels {
            var stageDrafts = nextDraftsByStageID[stage.id] ?? [:]
            for testCase in stage.orderedSections.flatMap(\.orderedTestCases) {
                let testCaseDraft = TestCaseDraft(testCase: testCase)
                stageDrafts[testCase.id] = testCaseDraft
            }
            nextDraftsByStageID[stage.id] = stageDrafts
        }

        draftsByStageID = nextDraftsByStageID
        sessionContext.hasUnsavedDraft = true

        for (stageID, stageDrafts) in nextDraftsByStageID {
            for draft in stageDrafts.values {
                do {
                    _ = try await store.saveDraft(
                        draft,
                        scope: scope(stageID: stageID),
                        access: access
                    )
                } catch {
                    return false
                }
            }
        }

        sessionContext.hasUnsavedDraft = false
        return !canCompleteSession
    }
    #endif

    private func stage(id stageID: String) -> InspectionStage? {
        stageModels.first { $0.id == stageID }
    }

    private func testCase(id testCaseID: String) -> InspectionTestCase? {
        activeStage?.orderedSections
            .flatMap(\.orderedTestCases)
            .first { $0.id == testCaseID }
    }

    private func testCase(containingStepID stepID: String) -> InspectionTestCase? {
        activeStage?.orderedSections
            .flatMap(\.orderedTestCases)
            .first { testCase in
                testCase.orderedSteps.contains { $0.id == stepID }
            }
    }

    private func testCaseAndStage(id testCaseID: String) -> (stageID: String, testCase: InspectionTestCase)? {
        if let activeStage,
           let testCase = testCase(id: testCaseID, in: activeStage) {
            return (activeStage.id, testCase)
        }

        for stage in stageModels {
            if let testCase = testCase(id: testCaseID, in: stage) {
                return (stage.id, testCase)
            }
        }

        return nil
    }

    private func testCase(id testCaseID: String, in stage: InspectionStage) -> InspectionTestCase? {
        stage.orderedSections
            .flatMap(\.orderedTestCases)
            .first { $0.id == testCaseID }
    }

    private func scope(stageID: String) -> InspectionSessionScope {
        InspectionSessionScope(
            eventID: sessionContext.eventID,
            teamID: InspectionEventCoordinator.teamRecordID(sessionContext.team),
            sessionID: sessionContext.sessionID,
            stageID: stageID
        )
    }
}

#if DEBUG
private extension TestStepDraft {
    static func debugPassingDraft(step: InspectionTestStep, completedAt: Date) -> TestStepDraft {
        let measurementInput = step.measurementRange.map { range in
            NSDecimalNumber(decimal: range.minimum).stringValue
        } ?? ""
        let measurementValue = step.measurementRange.flatMap { range in
            try? MeasurementValue(rawValue: measurementInput, range: range)
        }
        return TestStepDraft(
            stepID: step.id,
            outcome: .pass,
            measurementInput: measurementInput,
            measurementValue: measurementValue,
            evidenceAttachments: [],
            confirmedAt: completedAt
        )
    }
}
#endif
