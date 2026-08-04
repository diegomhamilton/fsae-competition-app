//
//  InspectionEventCoordinator.swift
//  FSAEInspectionChecklist
//

import Combine
import Foundation

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
            await startSession(team: team, stageID: firstStageID)
            return true
        case .resumeSession(let team):
            let teamRecordID = Self.teamRecordID(team)
            if let session = try? await store.activeSession(
                eventID: eventID,
                teamID: teamRecordID,
                access: access
            ) {
                await openSession(team: team, session: session)
            } else {
                await startSession(team: team, stageID: stageID(titled: team.currentStage) ?? firstStageID)
            }
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

        let restoredTeams = await teams.asyncMap { record in
            let activeSession = try? await store.activeSession(
                eventID: eventID,
                teamID: record.id,
                access: access
            )
            return team(record: record, activeSession: activeSession)
        }
        sessionSelectionCoordinator.updateTeams(restoredTeams)
    }

    @discardableResult
    func createTeam(
        entry: LocalTeamCatalogEntry
    ) async throws -> InspectionTeam? {
        let record = try await store.createTeam(
            eventID: eventID,
            entry: entry,
            access: access
        )
        let teams = try await store.teams(eventID: eventID, access: access)
        let restoredTeams = await teams.asyncMap { record in
            let activeSession = try? await store.activeSession(
                eventID: eventID,
                teamID: record.id,
                access: access
            )
            return team(record: record, activeSession: activeSession)
        }
        sessionSelectionCoordinator.updateTeams(restoredTeams)
        return restoredTeams.first { $0.id == record.numericTeamID }
    }

    @discardableResult
    func completeActiveSession(endedAt: Date = Date()) async -> Bool {
        guard let executionCoordinator,
              executionCoordinator.canCompleteSession,
              let context = activeSession else {
            return false
        }

        let teamID = Self.teamRecordID(context.team)
        guard (try? await store.completeSession(
            eventID: eventID,
            teamID: teamID,
            sessionID: context.sessionID,
            endedAt: endedAt,
            access: access
        )) != nil else {
            return false
        }

        self.executionCoordinator = nil
        await restoreTeamCatalog()
        return true
    }

    #if DEBUG
    @discardableResult
    func markAllTestCasesPassedForDebug(at completedAt: Date = Date()) async -> Bool {
        guard let executionCoordinator else {
            return false
        }

        return await executionCoordinator.markAllTestCasesPassedForDebug(at: completedAt)
    }

    @discardableResult
    func markAllTestCasesIncompleteForDebug() async -> Bool {
        guard let executionCoordinator else {
            return false
        }

        return await executionCoordinator.markAllTestCasesIncompleteForDebug()
    }
    #endif

    @discardableResult
    func confirmPendingTeamSwitch() async -> Bool {
        guard let targetTeamID = executionCoordinator?.pendingSwitchTarget?.id else {
            return false
        }

        return await startOrResumeSession(for: targetTeamID)
    }

    private func startSession(team: InspectionTeam, stageID: String) async {
        let teamRecordID = Self.teamRecordID(team)
        let session = try? await store.startSession(
            eventID: eventID,
            teamID: teamRecordID,
            defaultStageID: stageID,
            access: access
        )
        guard let session else {
            return
        }

        await openSession(team: team, session: session)
    }

    private func openSession(team selectedTeam: InspectionTeam, session: InspectionSessionRecord) async {
        let sessionTeam = team(
            selectedTeam,
            session: session
        )
        let context = InspectionSessionContext(
            eventID: eventID,
            sessionID: session.id,
            team: sessionTeam,
            activeStageID: session.currentStageID,
            startedAt: session.startedAt,
            endedAt: session.endedAt,
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
    func team(
        record: InspectionEventTeamRecord,
        activeSession: InspectionSessionRecord?
    ) -> InspectionTeam {
        guard let activeSession else {
            return InspectionTeam(
                id: record.numericTeamID,
                school: record.displayName,
                carNumber: record.carNumber,
                status: .ready,
                currentStage: stages.sorted { $0.displayOrder < $1.displayOrder }.first?.title ?? "",
                lastSaved: "Not started"
            )
        }

        return team(
            InspectionTeam(
                id: record.numericTeamID,
                school: record.displayName,
                carNumber: record.carNumber,
                status: .ready,
                currentStage: "",
                lastSaved: ""
            ),
            session: activeSession
        )
    }

    func team(
        _ team: InspectionTeam,
        session: InspectionSessionRecord
    ) -> InspectionTeam {
        let stageTitle = stageTitle(id: session.currentStageID)
        return InspectionTeam(
            id: team.id,
            school: team.school,
            carNumber: team.carNumber,
            status: session.endedAt == nil ? .resumed : .ready,
            currentStage: session.endedAt == nil ? stageTitle : firstStageTitle,
            lastSaved: sessionSummary(session)
        )
    }

    var firstStageTitle: String {
        stages.sorted { $0.displayOrder < $1.displayOrder }.first?.title ?? ""
    }

    func stageTitle(id stageID: String) -> String {
        stages.first { $0.id == stageID }?.title ?? firstStageTitle
    }

    func sessionSummary(_ session: InspectionSessionRecord) -> String {
        if let endedAt = session.endedAt {
            return "Completed \(endedAt.formatted(date: .abbreviated, time: .shortened))"
        }

        if let lastSavedAt = session.lastSavedAt {
            return "Saved \(lastSavedAt.formatted(date: .abbreviated, time: .shortened))"
        }

        return "Started \(session.startedAt.formatted(date: .abbreviated, time: .shortened))"
    }
}

private extension InspectionEventTeamRecord {
    var numericTeamID: Int {
        Int(carNumber.filter(\.isNumber)) ?? abs(id.hashValue)
    }
}

private extension Array {
    func asyncMap<Transformed>(
        _ transform: (Element) async -> Transformed
    ) async -> [Transformed] {
        var transformed: [Transformed] = []
        transformed.reserveCapacity(count)
        for element in self {
            let value = await transform(element)
            transformed.append(value)
        }
        return transformed
    }
}
