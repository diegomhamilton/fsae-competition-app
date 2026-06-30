//
//  InspectionExecutionCoordinator.swift
//  FSAEInspectionChecklist
//

import Combine

@MainActor
final class InspectionExecutionCoordinator: ObservableObject {
    @Published private(set) var sessionContext: InspectionSessionContext
    @Published private(set) var route: InspectionExecutionRoute = .dashboard
    @Published private(set) var pendingSwitchTarget: InspectionTeam?
    @Published private(set) var draftsByTestCaseID: [String: TestCaseDraft]
    let stages: [InspectionStage]
    let teams: [InspectionTeam]
    private let store: InspectionEventStore
    private let access: InspectionEventUserAccess

    init(
        sessionContext: InspectionSessionContext,
        stages: [InspectionStage],
        teams: [InspectionTeam],
        store: InspectionEventStore,
        access: InspectionEventUserAccess,
        draftsByTestCaseID: [String: TestCaseDraft] = [:]
    ) {
        self.sessionContext = sessionContext
        self.stages = stages
        self.teams = teams
        self.store = store
        self.access = access
        self.draftsByTestCaseID = draftsByTestCaseID
    }

    var activeTeam: InspectionTeam {
        sessionContext.team
    }

    var activeStage: InspectionStage? {
        stage(id: sessionContext.activeStageID)
    }

    var activeTestCase: InspectionTestCase? {
        let testCaseID: String
        switch route {
        case .testCase(_, let routedTestCaseID),
             .testStep(_, let routedTestCaseID, _):
            testCaseID = routedTestCaseID
        default:
            return nil
        }

        return testCase(id: testCaseID)
    }

    var activeStep: InspectionTestStep? {
        guard case .testStep(_, _, let stepID) = route else {
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

    func markUnsavedDraft(_ hasUnsavedDraft: Bool) {
        sessionContext.hasUnsavedDraft = hasUnsavedDraft
    }

    @discardableResult
    func openStage(id stageID: String) async -> Bool {
        guard stage(id: stageID) != nil else {
            return false
        }

        sessionContext.activeStageID = stageID
        route = .stage(stageID: stageID)
        await restoreDraftsForActiveStage()
        return true
    }

    @discardableResult
    func openTestCase(id testCaseID: String) -> Bool {
        guard testCase(id: testCaseID) != nil else {
            return false
        }

        route = .testCase(stageID: sessionContext.activeStageID, testCaseID: testCaseID)
        return true
    }

    @discardableResult
    func openTestStep(id stepID: String) -> Bool {
        guard let testCase = activeTestCase ?? testCase(containingStepID: stepID),
              testCase.orderedSteps.contains(where: { $0.id == stepID }) else {
            return false
        }

        route = .testStep(
            stageID: sessionContext.activeStageID,
            testCaseID: testCase.id,
            stepID: stepID
        )
        return true
    }

    @discardableResult
    func requestTeamSwitch(to targetTeamID: Int) -> Bool {
        guard let targetTeam = teams.first(where: { $0.id == targetTeamID }),
              targetTeam.id != sessionContext.team.id else {
            return false
        }

        pendingSwitchTarget = targetTeam
        route = .teamSwitchConfirmation(
            currentTeamID: sessionContext.team.id,
            targetTeamID: targetTeam.id
        )
        return true
    }

    func cancelTeamSwitch() {
        pendingSwitchTarget = nil
        route = .dashboard
    }

    func restoreDraftsForActiveStage() async {
        do {
            let draftFiles = try await store.draftFiles(
                scope: activeScope,
                access: access
            )
            draftsByTestCaseID = draftFiles.reduce(into: [:]) { result, file in
                result[file.testCaseID] = file.draft
            }
        } catch {
            draftsByTestCaseID = [:]
        }
    }

    @discardableResult
    func saveStepDraft(_ stepDraft: TestStepDraft, testCaseID: String) async -> Bool {
        guard let testCase = testCase(id: testCaseID) else {
            return false
        }

        var testCaseDraft = draft(for: testCase)
        testCaseDraft.updateStepDraft(stepDraft)
        draftsByTestCaseID[testCaseID] = testCaseDraft
        sessionContext.hasUnsavedDraft = true

        do {
            _ = try await store.saveDraft(
                testCaseDraft,
                scope: activeScope,
                access: access
            )
            sessionContext.hasUnsavedDraft = false
            return true
        } catch {
            return false
        }
    }

    private func stage(id stageID: String) -> InspectionStage? {
        stages.first { $0.id == stageID }
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

    private var activeScope: InspectionSessionScope {
        InspectionSessionScope(
            eventID: sessionContext.eventID,
            teamID: InspectionEventCoordinator.teamRecordID(sessionContext.team),
            sessionID: sessionContext.sessionID,
            stageID: sessionContext.activeStageID
        )
    }
}

