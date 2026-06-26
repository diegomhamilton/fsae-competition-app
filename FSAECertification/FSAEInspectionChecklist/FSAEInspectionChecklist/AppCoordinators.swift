import Combine
import Foundation

enum AppCoordinatorRoute: Equatable {
    case login
    case sessionSelector
    case inspection
}

struct InspectionSessionContext: Equatable {
    let eventID: String
    let sessionID: String
    var team: InspectionTeam
    var activeStageID: String
    var hasUnsavedDraft: Bool
}

enum SessionSelectionRoute: Equatable {
    case roster
    case startNewSession(teamID: Int)
    case resumeSession(teamID: Int)
    case blocked(teamID: Int)
}

enum SessionSelectionIntent: Equatable {
    case startNewSession(InspectionTeam)
    case resumeSession(InspectionTeam)
    case blocked(InspectionTeam)
}

enum InspectionExecutionRoute: Equatable {
    case dashboard
    case stage(stageID: String)
    case testCase(stageID: String, testCaseID: String)
    case testStep(stageID: String, testCaseID: String, stepID: String)
    case teamSwitchConfirmation(currentTeamID: Int, targetTeamID: Int)
}

@MainActor
final class AppCoordinator: ObservableObject {
    @Published private(set) var route: AppCoordinatorRoute = .login
    @Published private(set) var selectedScreen: ProposedScreen = .sessionSelector
    let eventCoordinator: InspectionEventCoordinator

    init(
        eventID: String = "fsae-brasil-2026-technical-inspection",
        teams: [InspectionTeam] = MockInspectionData.teams,
        stages: [InspectionStage] = MockInspectionData.stages
    ) {
        eventCoordinator = InspectionEventCoordinator(
            eventID: eventID,
            teams: teams,
            stages: stages
        )
    }

    func completeMockLogin() {
        route = .sessionSelector
        selectedScreen = .sessionSelector
    }

    @discardableResult
    func selectTeam(id teamID: Int) -> Bool {
        guard eventCoordinator.startOrResumeSession(for: teamID) else {
            selectedScreen = .sessionSelector
            return false
        }

        route = .inspection
        selectedScreen = .dashboard
        return true
    }

    func selectScreen(_ screen: ProposedScreen) {
        selectedScreen = screen
    }

    @discardableResult
    func openStage(id stageID: String) -> Bool {
        guard eventCoordinator.executionCoordinator?.openStage(id: stageID) == true else {
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

        selectedScreen = .testCase
        return true
    }

    @discardableResult
    func openTestStep(id stepID: String) -> Bool {
        guard eventCoordinator.executionCoordinator?.openTestStep(id: stepID) == true else {
            return false
        }

        selectedScreen = .stepDetail
        return true
    }

    @discardableResult
    func requestTeamSwitch(to targetTeamID: Int) -> Bool {
        guard eventCoordinator.executionCoordinator?.requestTeamSwitch(to: targetTeamID) == true else {
            return false
        }

        return true
    }

    @discardableResult
    func confirmTeamSwitch() -> Bool {
        guard eventCoordinator.confirmPendingTeamSwitch() else {
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

@MainActor
final class InspectionEventCoordinator: ObservableObject {
    let eventID: String
    @Published private(set) var sessionSelectionCoordinator: SessionSelectionCoordinator
    @Published private(set) var executionCoordinator: InspectionExecutionCoordinator?
    @Published private(set) var stages: [InspectionStage]

    init(
        eventID: String,
        teams: [InspectionTeam],
        stages: [InspectionStage]
    ) {
        self.eventID = eventID
        self.stages = stages
        sessionSelectionCoordinator = SessionSelectionCoordinator(teams: teams)
    }

    var activeSession: InspectionSessionContext? {
        executionCoordinator?.sessionContext
    }

    var activeTeam: InspectionTeam? {
        activeSession?.team
    }

    @discardableResult
    func startOrResumeSession(for teamID: Int) -> Bool {
        guard let intent = sessionSelectionCoordinator.selectTeam(id: teamID) else {
            return false
        }

        switch intent {
        case .blocked:
            return false
        case .startNewSession(let team):
            openSession(team: team, stageID: firstStageID)
            return true
        case .resumeSession(let team):
            openSession(team: team, stageID: stageID(titled: team.currentStage) ?? firstStageID)
            return true
        }
    }

    func updateStages(_ stages: [InspectionStage]) {
        self.stages = stages

        guard var context = activeSession else {
            return
        }

        if !stages.contains(where: { $0.id == context.activeStageID }) {
            context.activeStageID = firstStageID
        }

        executionCoordinator = InspectionExecutionCoordinator(
            sessionContext: context,
            stages: stages,
            teams: sessionSelectionCoordinator.teams
        )
    }

    @discardableResult
    func confirmPendingTeamSwitch() -> Bool {
        guard let targetTeamID = executionCoordinator?.pendingSwitchTarget?.id else {
            return false
        }

        return startOrResumeSession(for: targetTeamID)
    }

    private func openSession(team: InspectionTeam, stageID: String) {
        let context = InspectionSessionContext(
            eventID: eventID,
            sessionID: "\(eventID)-team-\(team.id)",
            team: team,
            activeStageID: stageID,
            hasUnsavedDraft: false
        )
        executionCoordinator = InspectionExecutionCoordinator(
            sessionContext: context,
            stages: stages,
            teams: sessionSelectionCoordinator.teams
        )
    }

    private var firstStageID: String {
        stages.sorted { $0.displayOrder < $1.displayOrder }.first?.id ?? ""
    }

    private func stageID(titled title: String) -> String? {
        stages.first { $0.title == title }?.id
    }
}

@MainActor
final class SessionSelectionCoordinator: ObservableObject {
    @Published private(set) var teams: [InspectionTeam]
    @Published private(set) var selectedTeamID: Int?
    @Published private(set) var route: SessionSelectionRoute = .roster

    init(teams: [InspectionTeam]) {
        self.teams = teams
    }

    func team(id teamID: Int) -> InspectionTeam? {
        teams.first { $0.id == teamID }
    }

    @discardableResult
    func selectTeam(id teamID: Int) -> SessionSelectionIntent? {
        guard let team = team(id: teamID) else {
            return nil
        }

        selectedTeamID = teamID

        switch team.status {
        case .ready:
            route = .startNewSession(teamID: teamID)
            return .startNewSession(team)
        case .resumed:
            route = .resumeSession(teamID: teamID)
            return .resumeSession(team)
        case .blocked:
            route = .blocked(teamID: teamID)
            return .blocked(team)
        }
    }
}

@MainActor
final class InspectionExecutionCoordinator: ObservableObject {
    @Published private(set) var sessionContext: InspectionSessionContext
    @Published private(set) var route: InspectionExecutionRoute = .dashboard
    @Published private(set) var pendingSwitchTarget: InspectionTeam?
    let stages: [InspectionStage]
    let teams: [InspectionTeam]

    init(
        sessionContext: InspectionSessionContext,
        stages: [InspectionStage],
        teams: [InspectionTeam]
    ) {
        self.sessionContext = sessionContext
        self.stages = stages
        self.teams = teams
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

    func markUnsavedDraft(_ hasUnsavedDraft: Bool) {
        sessionContext.hasUnsavedDraft = hasUnsavedDraft
    }

    @discardableResult
    func openStage(id stageID: String) -> Bool {
        guard stage(id: stageID) != nil else {
            return false
        }

        sessionContext.activeStageID = stageID
        route = .stage(stageID: stageID)
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
}
