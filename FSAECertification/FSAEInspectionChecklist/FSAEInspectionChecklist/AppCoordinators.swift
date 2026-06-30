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
        selectedScreen = screen
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

@MainActor
final class InspectionEventCoordinator: ObservableObject {
    let eventID: String
    @Published private(set) var sessionSelectionCoordinator: SessionSelectionCoordinator
    @Published private(set) var executionCoordinator: InspectionExecutionCoordinator?
    @Published private(set) var stages: [InspectionStage]
    private let store: InspectionEventStore
    private let access: InspectionEventUserAccess

    init(
        eventID: String,
        teams: [InspectionTeam],
        stages: [InspectionStage],
        store: InspectionEventStore? = nil,
        access: InspectionEventUserAccess? = nil
    ) {
        self.eventID = eventID
        self.stages = stages
        self.store = store ?? InspectionEventStore.appStore(
            eventID: eventID,
            teams: teams,
            stages: stages
        )
        self.access = access ?? InspectionEventUserAccess.appAccess(
            eventID: eventID,
            teams: teams
        )
        sessionSelectionCoordinator = SessionSelectionCoordinator(teams: teams)
    }

    var activeSession: InspectionSessionContext? {
        executionCoordinator?.sessionContext
    }

    var activeTeam: InspectionTeam? {
        activeSession?.team
    }

    @discardableResult
    func startOrResumeSession(for teamID: Int) async -> Bool {
        guard let intent = sessionSelectionCoordinator.selectTeam(id: teamID) else {
            return false
        }

        switch intent {
        case .blocked:
            return false
        case .startNewSession(let team):
            await openSession(team: team, stageID: firstStageID)
            return true
        case .resumeSession(let team):
            await openSession(team: team, stageID: stageID(titled: team.currentStage) ?? firstStageID)
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
            teams: sessionSelectionCoordinator.teams,
            store: store,
            access: access,
            draftsByTestCaseID: executionCoordinator?.draftsByTestCaseID ?? [:]
        )
    }

    @discardableResult
    func confirmPendingTeamSwitch() async -> Bool {
        guard let targetTeamID = executionCoordinator?.pendingSwitchTarget?.id else {
            return false
        }

        return await startOrResumeSession(for: targetTeamID)
    }

    private func openSession(team: InspectionTeam, stageID: String) async {
        let sessionID = Self.sessionID(eventID: eventID, team: team)
        let teamRecordID = Self.teamRecordID(team)
        let session = try? await store.startSession(
            eventID: eventID,
            teamID: teamRecordID,
            defaultStageID: stageID,
            sessionID: sessionID,
            access: access
        )
        let context = InspectionSessionContext(
            eventID: eventID,
            sessionID: session?.id ?? sessionID,
            team: team,
            activeStageID: session?.currentStageID ?? stageID,
            hasUnsavedDraft: false
        )
        let coordinator = InspectionExecutionCoordinator(
            sessionContext: context,
            stages: stages,
            teams: sessionSelectionCoordinator.teams,
            store: store,
            access: access
        )
        await coordinator.restoreDraftsForActiveStage()
        executionCoordinator = coordinator
    }

    private var firstStageID: String {
        stages.sorted { $0.displayOrder < $1.displayOrder }.first?.id ?? ""
    }

    private func stageID(titled title: String) -> String? {
        stages.first { $0.title == title }?.id
    }

    nonisolated static func teamRecordID(_ team: InspectionTeam) -> String {
        "car-\(team.carNumber)"
    }

    nonisolated static func sessionID(eventID: String, team: InspectionTeam) -> String {
        "\(eventID)-\(teamRecordID(team))-local"
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

extension InspectionEventStore {
    static func appStore(
        eventID: String,
        teams: [InspectionTeam],
        stages: [InspectionStage],
        persistenceService: TestCaseJSONPersistenceService = TestCaseJSONPersistenceService()
    ) -> InspectionEventStore {
        InspectionEventStore(
            events: [
                InspectionEventDefinition(
                    id: eventID,
                    name: "FSAE Brasil Technical Inspection",
                    stageIDs: stages.map(\.id)
                )
            ],
            teams: teams.map { team in
                InspectionEventTeamRecord(
                    id: InspectionEventCoordinator.teamRecordID(team),
                    eventID: eventID,
                    displayName: team.school,
                    carNumber: team.carNumber
                )
            },
            persistenceService: persistenceService
        )
    }
}

extension InspectionEventUserAccess {
    static func appAccess(
        eventID: String,
        teams: [InspectionTeam],
        userID: String = "local-judge"
    ) -> InspectionEventUserAccess {
        InspectionEventUserAccess(
            userID: userID,
            permittedEventIDs: [eventID],
            permittedTeamIDsByEventID: [
                eventID: Set(teams.map(InspectionEventCoordinator.teamRecordID))
            ]
        )
    }
}
