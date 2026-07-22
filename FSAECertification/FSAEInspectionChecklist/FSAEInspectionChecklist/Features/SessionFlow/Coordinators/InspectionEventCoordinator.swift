//
//  InspectionEventCoordinator.swift
//  FSAEInspectionChecklist
//

import Combine

@MainActor
final class InspectionEventCoordinator: ObservableObject {
    let eventID: String
    @Published private(set) var sessionSelectionCoordinator: SessionSelectionCoordinator
    @Published private(set) var executionCoordinator: InspectionExecutionCoordinator?
    @Published private(set) var stages: [InspectionStage]
    private let store: InspectionEventStore
    private var access: InspectionEventUserAccess

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
            draftsByStageID: executionCoordinator?.draftsByStageID ?? [:],
            draftsByTestCaseID: executionCoordinator?.draftsByTestCaseID ?? [:]
        )
    }

    func restoreTeamCatalog() async {
        guard let teams = try? await store.teams(eventID: eventID, access: access) else {
            return
        }

        sessionSelectionCoordinator.updateTeams(teams.map { team(record: $0) })
    }

    @discardableResult
    func createTeam(
        displayName: String,
        carNumber: String
    ) async throws -> InspectionTeam? {
        let record = try await store.createTeam(
            eventID: eventID,
            displayName: displayName,
            carNumber: carNumber,
            access: access
        )
        let teams = try await store.teams(eventID: eventID, access: access)
            .map { team(record: $0) }
        sessionSelectionCoordinator.updateTeams(teams)
        return teams.first { $0.id == record.numericTeamID }
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
        await coordinator.restoreDraftsForAllStages()
        executionCoordinator = coordinator
    }

    private var firstStageID: String {
        stages.sorted { $0.displayOrder < $1.displayOrder }.first?.id ?? ""
    }

    private func stageID(titled title: String) -> String? {
        stages.first { $0.title == title }?.id
    }

    nonisolated static func teamRecordID(_ team: InspectionTeam) -> String {
        InspectionEventStore.localTeamID(carNumber: team.carNumber)
    }

    nonisolated static func sessionID(eventID: String, team: InspectionTeam) -> String {
        "\(eventID)-\(teamRecordID(team))-local"
    }
}

private extension InspectionEventCoordinator {
    func team(record: InspectionEventTeamRecord) -> InspectionTeam {
        InspectionTeam(
            id: record.numericTeamID,
            school: record.displayName,
            carNumber: record.carNumber,
            status: .ready,
            currentStage: stages.sorted { $0.displayOrder < $1.displayOrder }.first?.title ?? "",
            lastSaved: "Not started"
        )
    }
}

private extension InspectionEventTeamRecord {
    var numericTeamID: Int {
        Int(carNumber.filter(\.isNumber)) ?? abs(id.hashValue)
    }
}
