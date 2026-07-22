//
//  AppCoordinator.swift
//  FSAEInspectionChecklist
//

import Combine

@MainActor
final class AppCoordinator: ObservableObject {
    @Published private(set) var route: AppCoordinatorRoute = .login
    @Published private(set) var selectedScreen: ProposedScreen = .sessionSelector
    let eventCoordinator: InspectionEventCoordinator

    init(
        eventID: String = "fsae-brasil-2026-technical-inspection",
        teams: [InspectionTeam] = MockInspectionData.teams,
        stages: [InspectionStage] = MockInspectionData.stages,
        store: InspectionEventStore? = nil
    ) {
        let eventStore = store ?? InspectionEventStore.appStore(
            eventID: eventID,
            teams: teams,
            stages: stages
        )
        eventCoordinator = InspectionEventCoordinator(
            eventID: eventID,
            teams: teams,
            stages: stages,
            store: eventStore
        )
    }

    func completeMockLogin() {
        route = .sessionSelector
        selectedScreen = .sessionSelector
    }

    @discardableResult
    func selectTeam(id teamID: Int) async -> Bool {
        guard await eventCoordinator.startOrResumeSession(for: teamID) else {
            selectedScreen = .sessionSelector
            return false
        }

        route = .inspection
        selectedScreen = .dashboard
        return true
    }

    func selectScreen(_ screen: ProposedScreen) {
        selectedScreen = ProposedScreen.topLevelJudgeLandmarks.contains(screen) ? screen : .stageChecklist
    }

    @discardableResult
    func openStage(id stageID: String) async -> Bool {
        guard let executionCoordinator = eventCoordinator.executionCoordinator,
              await executionCoordinator.openStage(id: stageID) else {
            return false
        }

        selectedScreen = .stageChecklist
        return true
    }

    @discardableResult
    func openTestCase(id testCaseID: String) -> Bool {
        guard eventCoordinator.executionCoordinator?.openTestCase(id: testCaseID) == true else {
            return false
        }

        selectedScreen = .stageChecklist
        return true
    }

    @discardableResult
    func openTestStep(id stepID: String) -> Bool {
        guard eventCoordinator.executionCoordinator?.openTestStep(id: stepID) == true else {
            return false
        }

        selectedScreen = .stageChecklist
        return true
    }

    func returnToActiveStage() {
        eventCoordinator.executionCoordinator?.returnToActiveStage()
        selectedScreen = .stageChecklist
    }

    func returnToActiveTestCase() {
        eventCoordinator.executionCoordinator?.returnToActiveTestCase()
        selectedScreen = .stageChecklist
    }

    @discardableResult
    func saveStepDraft(_ stepDraft: TestStepDraft, testCaseID: String) async -> Bool {
        guard let executionCoordinator = eventCoordinator.executionCoordinator else {
            return false
        }

        return await executionCoordinator.saveStepDraft(
            stepDraft,
            testCaseID: testCaseID
        )
    }

    @discardableResult
    func requestTeamSwitch(to targetTeamID: Int) -> Bool {
        guard eventCoordinator.executionCoordinator?.requestTeamSwitch(to: targetTeamID) == true else {
            return false
        }

        return true
    }

    @discardableResult
    func confirmTeamSwitch() async -> Bool {
        guard await eventCoordinator.confirmPendingTeamSwitch() else {
            return false
        }

        selectedScreen = .dashboard
        return true
    }

    func cancelTeamSwitch() {
        eventCoordinator.executionCoordinator?.cancelTeamSwitch()
    }

    func updateStages(_ stages: [InspectionStage]) {
        eventCoordinator.updateStages(stages)
        objectWillChange.send()
    }
}
