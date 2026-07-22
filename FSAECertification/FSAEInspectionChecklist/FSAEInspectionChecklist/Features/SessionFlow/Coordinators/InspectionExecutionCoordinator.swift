//
//  InspectionExecutionCoordinator.swift
//  FSAEInspectionChecklist
//

import Combine

@MainActor
final class InspectionExecutionCoordinator: ObservableObject {
    @Published private(set) var sessionContext: InspectionSessionContext
    @Published var stageNavigationPath: [StageNavigationRoute] = []
    @Published private(set) var pendingSwitchTarget: InspectionTeam?
    @Published private(set) var draftsByStageID: [String: [String: TestCaseDraft]]
    let teams: [InspectionTeam]
    private let stageModels: [InspectionStage]
    private let store: InspectionEventStore
    private let access: InspectionEventUserAccess

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

    var draftsByTestCaseID: [String: TestCaseDraft] {
        draftsByStageID[sessionContext.activeStageID] ?? [:]
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
        guard let targetTeam = teams.first(where: { $0.id == targetTeamID }),
              targetTeam.id != sessionContext.team.id else {
            return false
        }

        pendingSwitchTarget = targetTeam
        return true
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
        guard let target = testCaseAndStage(id: testCaseID) else {
            return false
        }

        var stageDrafts = draftsByStageID[target.stageID] ?? [:]
        var testCaseDraft = stageDrafts[testCaseID] ?? TestCaseDraft(testCase: target.testCase)
        testCaseDraft.updateStepDraft(stepDraft)
        stageDrafts[testCaseID] = testCaseDraft
        draftsByStageID[target.stageID] = stageDrafts
        sessionContext.hasUnsavedDraft = true

        do {
            _ = try await store.saveDraft(
                testCaseDraft,
                scope: scope(stageID: target.stageID),
                access: access
            )
            sessionContext.hasUnsavedDraft = false
            return true
        } catch {
            return false
        }
    }

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
