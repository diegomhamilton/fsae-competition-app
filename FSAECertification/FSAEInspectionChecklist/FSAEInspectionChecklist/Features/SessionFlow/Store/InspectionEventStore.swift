//
//  InspectionEventStore.swift
//  FSAEInspectionChecklist
//

import Foundation

nonisolated struct InspectionEventDefinition: Identifiable, Codable, Hashable, Sendable {
    let id: String
    let name: String
    let stageIDs: [String]

    init(
        id: String,
        name: String,
        stageIDs: [String]
    ) {
        self.id = id
        self.name = name
        self.stageIDs = stageIDs
    }
}

nonisolated struct InspectionEventTeamRecord: Identifiable, Codable, Hashable, Sendable {
    let id: String
    let eventID: String
    let displayName: String
    let carNumber: String

    init(
        id: String,
        eventID: String,
        displayName: String,
        carNumber: String
    ) {
        self.id = id
        self.eventID = eventID
        self.displayName = displayName
        self.carNumber = carNumber
    }
}

nonisolated enum LocalTeamCatalogValidationError: Error, Equatable, Sendable {
    case missingDisplayName
    case missingCarNumber
    case carNumberMatchesDisplayName
}

nonisolated struct LocalTeamCatalogEntry: Equatable, Hashable, Sendable {
    let displayName: String
    let carNumber: String

    init(displayName: String, carNumber: String) {
        self.displayName = displayName
        self.carNumber = carNumber
    }
}

nonisolated enum InspectionEventSessionStatus: String, Codable, Hashable, Sendable {
    case inProgress
    case blocked
    case submitted
}

nonisolated struct InspectionSessionRecord: Identifiable, Codable, Hashable, Sendable {
    let id: String
    let eventID: String
    let teamID: String
    let judgeUserID: String
    let status: InspectionEventSessionStatus
    let currentStageID: String
    let startedAt: Date
    let endedAt: Date?
    let lastSavedAt: Date?

    init(
        id: String,
        eventID: String,
        teamID: String,
        judgeUserID: String,
        status: InspectionEventSessionStatus = .inProgress,
        currentStageID: String,
        startedAt: Date,
        endedAt: Date? = nil,
        lastSavedAt: Date? = nil
    ) {
        self.id = id
        self.eventID = eventID
        self.teamID = teamID
        self.judgeUserID = judgeUserID
        self.status = status
        self.currentStageID = currentStageID
        self.startedAt = startedAt
        self.endedAt = endedAt
        self.lastSavedAt = lastSavedAt
    }

    func markingSaved(stageID: String, at savedAt: Date) -> InspectionSessionRecord {
        InspectionSessionRecord(
            id: id,
            eventID: eventID,
            teamID: teamID,
            judgeUserID: judgeUserID,
            status: status,
            currentStageID: stageID,
            startedAt: startedAt,
            endedAt: endedAt,
            lastSavedAt: savedAt
        )
    }

    func markingCompleted(at endedAt: Date) -> InspectionSessionRecord {
        InspectionSessionRecord(
            id: id,
            eventID: eventID,
            teamID: teamID,
            judgeUserID: judgeUserID,
            status: .submitted,
            currentStageID: currentStageID,
            startedAt: startedAt,
            endedAt: endedAt,
            lastSavedAt: lastSavedAt
        )
    }
}

nonisolated struct InspectionSessionScope: Codable, Hashable, Sendable {
    let eventID: String
    let teamID: String
    let sessionID: String
    let stageID: String

    init(
        eventID: String,
        teamID: String,
        sessionID: String,
        stageID: String
    ) {
        self.eventID = eventID
        self.teamID = teamID
        self.sessionID = sessionID
        self.stageID = stageID
    }

    var persistenceContext: InspectionPersistenceContext {
        InspectionPersistenceContext(
            eventID: eventID,
            teamID: teamID,
            sessionID: sessionID,
            stageID: stageID
        )
    }
}

nonisolated struct InspectionEventUserAccess: Codable, Hashable, Sendable {
    let userID: String
    let permittedEventIDs: Set<String>
    let permittedTeamIDsByEventID: [String: Set<String>]
    let permitsAllTeamsForPermittedEvents: Bool

    init(
        userID: String,
        permittedEventIDs: Set<String>,
        permittedTeamIDsByEventID: [String: Set<String>],
        permitsAllTeamsForPermittedEvents: Bool = false
    ) {
        self.userID = userID
        self.permittedEventIDs = permittedEventIDs
        self.permittedTeamIDsByEventID = permittedTeamIDsByEventID
        self.permitsAllTeamsForPermittedEvents = permitsAllTeamsForPermittedEvents
    }

    func permits(eventID: String) -> Bool {
        permittedEventIDs.contains(eventID)
    }

    func permits(eventID: String, teamID: String) -> Bool {
        guard permits(eventID: eventID) else {
            return false
        }

        if permitsAllTeamsForPermittedEvents {
            return true
        }

        return permittedTeamIDsByEventID[eventID]?.contains(teamID) == true
    }
}

nonisolated enum InspectionEventStoreError: Error, Equatable, Sendable {
    case accessDenied(userID: String, eventID: String, teamID: String?)
    case eventNotFound(String)
    case teamNotFound(eventID: String, teamID: String)
    case sessionNotFound(eventID: String, teamID: String, sessionID: String)
    case sessionNotActive(eventID: String, teamID: String, sessionID: String)
}

actor InspectionEventStore {
    private var eventsByID: [String: InspectionEventDefinition]
    private var teamsByEventID: [String: [InspectionEventTeamRecord]]
    private var sessionsByKey: [SessionKey: InspectionSessionRecord]
    private let persistenceService: TestCaseJSONPersistenceService
    private let teamCatalogService: LocalTeamCatalogService
    private let sessionCatalogService: LocalSessionCatalogService

    init(
        events: [InspectionEventDefinition],
        teams: [InspectionEventTeamRecord],
        sessions: [InspectionSessionRecord] = [],
        persistenceService: TestCaseJSONPersistenceService = TestCaseJSONPersistenceService(),
        teamCatalogService: LocalTeamCatalogService = LocalTeamCatalogService(),
        sessionCatalogService: LocalSessionCatalogService = LocalSessionCatalogService()
    ) {
        eventsByID = Dictionary(uniqueKeysWithValues: events.map { ($0.id, $0) })
        self.teamCatalogService = teamCatalogService
        self.sessionCatalogService = sessionCatalogService
        var teamsByEvent = Dictionary(grouping: teams, by: \.eventID)
        for event in events {
            let persistedTeams = (try? teamCatalogService.loadTeams(eventID: event.id)) ?? []
            teamsByEvent[event.id, default: []].append(contentsOf: persistedTeams)
        }
        teamsByEventID = teamsByEvent.mapValues { records in
            Array(Dictionary(uniqueKeysWithValues: records.map { ($0.id, $0) }).values)
        }
        var restoredSessions = sessions
        for event in events {
            for team in teamsByEventID[event.id, default: []] {
                let persistedSessions = (try? sessionCatalogService.loadSessions(
                    eventID: event.id,
                    teamID: team.id
                )) ?? []
                restoredSessions.append(contentsOf: persistedSessions)
            }
        }
        sessionsByKey = Dictionary(
            uniqueKeysWithValues: restoredSessions.map { session in
                (SessionKey(session), session)
            }
        )
        self.persistenceService = persistenceService
    }

    func events(access: InspectionEventUserAccess) -> [InspectionEventDefinition] {
        eventsByID.values
            .filter { access.permits(eventID: $0.id) }
            .sorted { $0.name < $1.name }
    }

    func teams(
        eventID: String,
        access: InspectionEventUserAccess
    ) throws -> [InspectionEventTeamRecord] {
        try requireEvent(eventID)
        try requireAccess(access, eventID: eventID)

        return teamsByEventID[eventID, default: []]
            .filter { access.permits(eventID: eventID, teamID: $0.id) }
            .sorted { lhs, rhs in
                if lhs.carNumber == rhs.carNumber {
                    lhs.displayName < rhs.displayName
                } else {
                    lhs.carNumber < rhs.carNumber
                }
            }
    }

    @discardableResult
    func createTeam(
        eventID: String,
        entry: LocalTeamCatalogEntry,
        access: InspectionEventUserAccess
    ) throws -> InspectionEventTeamRecord {
        try requireEvent(eventID)
        try requireAccess(access, eventID: eventID)

        let trimmedDisplayName = entry.displayName
        let trimmedCarNumber = entry.carNumber

        guard !trimmedDisplayName.isEmpty else {
            throw LocalTeamCatalogValidationError.missingDisplayName
        }
        guard !trimmedCarNumber.isEmpty else {
            throw LocalTeamCatalogValidationError.missingCarNumber
        }
        guard trimmedDisplayName.caseInsensitiveCompare(trimmedCarNumber) != .orderedSame else {
            throw LocalTeamCatalogValidationError.carNumberMatchesDisplayName
        }

        let record = InspectionEventTeamRecord(
            id: Self.localTeamID(carNumber: trimmedCarNumber),
            eventID: eventID,
            displayName: trimmedDisplayName,
            carNumber: trimmedCarNumber
        )
        var eventTeams = teamsByEventID[eventID, default: []]
        if let existingIndex = eventTeams.firstIndex(where: { $0.id == record.id }) {
            eventTeams[existingIndex] = record
        } else {
            eventTeams.append(record)
        }
        teamsByEventID[eventID] = eventTeams
        try teamCatalogService.saveTeams(eventTeams, eventID: eventID)
        return record
    }

    func sessions(
        eventID: String,
        teamID: String,
        access: InspectionEventUserAccess
    ) throws -> [InspectionSessionRecord] {
        try requireTeam(eventID: eventID, teamID: teamID)
        try requireAccess(access, eventID: eventID, teamID: teamID)

        return sessionsByKey.values
            .filter { $0.eventID == eventID && $0.teamID == teamID }
            .sorted { lhs, rhs in
                let lhsSavedAt = lhs.lastSavedAt ?? lhs.startedAt
                let rhsSavedAt = rhs.lastSavedAt ?? rhs.startedAt
                return lhsSavedAt > rhsSavedAt
            }
    }

    func completedSessions(
        eventID: String,
        teamID: String,
        access: InspectionEventUserAccess
    ) throws -> [InspectionSessionRecord] {
        try sessions(eventID: eventID, teamID: teamID, access: access)
            .filter { $0.status == .submitted && $0.endedAt != nil }
            .sorted { lhs, rhs in
                let lhsEndedAt = lhs.endedAt ?? lhs.startedAt
                let rhsEndedAt = rhs.endedAt ?? rhs.startedAt
                if lhsEndedAt == rhsEndedAt {
                    return lhs.id < rhs.id
                }
                return lhsEndedAt > rhsEndedAt
            }
    }

    func session(
        eventID: String,
        teamID: String,
        sessionID: String,
        access: InspectionEventUserAccess
    ) throws -> InspectionSessionRecord {
        try requireAccess(access, eventID: eventID, teamID: teamID)

        let key = SessionKey(eventID: eventID, teamID: teamID, sessionID: sessionID)
        guard let session = sessionsByKey[key] else {
            throw InspectionEventStoreError.sessionNotFound(
                eventID: eventID,
                teamID: teamID,
                sessionID: sessionID
            )
        }

        return session
    }

    func activeSession(
        eventID: String,
        teamID: String,
        access: InspectionEventUserAccess
    ) throws -> InspectionSessionRecord? {
        try requireTeam(eventID: eventID, teamID: teamID)
        try requireAccess(access, eventID: eventID, teamID: teamID)

        return sessionsByKey.values
            .filter { session in
                session.eventID == eventID
                    && session.teamID == teamID
                    && session.endedAt == nil
                    && session.status != .submitted
            }
            .sorted { lhs, rhs in
                let lhsSavedAt = lhs.lastSavedAt ?? lhs.startedAt
                let rhsSavedAt = rhs.lastSavedAt ?? rhs.startedAt
                return lhsSavedAt > rhsSavedAt
            }
            .first
    }

    func startSession(
        eventID: String,
        teamID: String,
        defaultStageID: String,
        sessionID: String = UUID().uuidString,
        startedAt: Date = Date(),
        access: InspectionEventUserAccess
    ) throws -> InspectionSessionRecord {
        try requireTeam(eventID: eventID, teamID: teamID)
        try requireAccess(access, eventID: eventID, teamID: teamID)

        if let activeSession = try activeSession(eventID: eventID, teamID: teamID, access: access) {
            return activeSession
        }

        let session = InspectionSessionRecord(
            id: sessionID,
            eventID: eventID,
            teamID: teamID,
            judgeUserID: access.userID,
            currentStageID: defaultStageID,
            startedAt: startedAt
        )
        sessionsByKey[SessionKey(session)] = session
        try persistSessions(eventID: eventID, teamID: teamID)
        return session
    }

    @discardableResult
    func completeSession(
        eventID: String,
        teamID: String,
        sessionID: String,
        endedAt: Date = Date(),
        access: InspectionEventUserAccess
    ) throws -> InspectionSessionRecord {
        try requireAccess(access, eventID: eventID, teamID: teamID)

        let key = SessionKey(eventID: eventID, teamID: teamID, sessionID: sessionID)
        guard let session = sessionsByKey[key] else {
            throw InspectionEventStoreError.sessionNotFound(
                eventID: eventID,
                teamID: teamID,
                sessionID: sessionID
            )
        }

        let completedSession = session.markingCompleted(at: endedAt)
        sessionsByKey[key] = completedSession
        try persistSessions(eventID: eventID, teamID: teamID)
        return completedSession
    }

    func resetActiveSession(
        eventID: String,
        teamID: String,
        sessionID: String,
        access: InspectionEventUserAccess
    ) async throws {
        try requireAccess(access, eventID: eventID, teamID: teamID)

        let key = SessionKey(eventID: eventID, teamID: teamID, sessionID: sessionID)
        guard let session = sessionsByKey[key] else {
            throw InspectionEventStoreError.sessionNotFound(
                eventID: eventID,
                teamID: teamID,
                sessionID: sessionID
            )
        }
        guard session.endedAt == nil, session.status != .submitted else {
            throw InspectionEventStoreError.sessionNotActive(
                eventID: eventID,
                teamID: teamID,
                sessionID: sessionID
            )
        }

        let context = InspectionPersistenceContext(
            eventID: eventID,
            teamID: teamID,
            sessionID: sessionID,
            stageID: session.currentStageID
        )
        try await persistenceService.clearDraftsForSession(context: context)

        sessionsByKey.removeValue(forKey: key)
        do {
            try persistSessions(eventID: eventID, teamID: teamID)
        } catch {
            sessionsByKey[key] = session
            throw error
        }
    }

    @discardableResult
    func saveDraft(
        _ draft: TestCaseDraft,
        scope: InspectionSessionScope,
        updatedAt: Date = Date(),
        recheckReferences: [String] = [],
        access: InspectionEventUserAccess
    ) async throws -> TestCaseDraftFile {
        try requireSession(scope: scope, access: access)

        _ = try await persistenceService.saveDraft(
            draft,
            context: scope.persistenceContext,
            updatedAt: updatedAt,
            recheckReferences: recheckReferences
        )

        let key = SessionKey(scope: scope)
        if let session = sessionsByKey[key] {
            sessionsByKey[key] = session.markingSaved(stageID: scope.stageID, at: updatedAt)
            try persistSessions(eventID: scope.eventID, teamID: scope.teamID)
        }

        guard let draftFile = try await persistenceService.loadDraftFile(
            context: scope.persistenceContext,
            testCaseID: draft.id
        ) else {
            throw InspectionEventStoreError.sessionNotFound(
                eventID: scope.eventID,
                teamID: scope.teamID,
                sessionID: scope.sessionID
            )
        }

        return draftFile
    }

    func draft(
        scope: InspectionSessionScope,
        testCaseID: String,
        access: InspectionEventUserAccess
    ) async throws -> TestCaseDraft? {
        try requireSession(scope: scope, access: access)

        return try await persistenceService.loadDraft(
            context: scope.persistenceContext,
            testCaseID: testCaseID
        )
    }

    func draftFiles(
        scope: InspectionSessionScope,
        access: InspectionEventUserAccess
    ) async throws -> [TestCaseDraftFile] {
        try requireSession(scope: scope, access: access)

        return try await persistenceService.loadDraftFiles(context: scope.persistenceContext)
            .sorted { lhs, rhs in
                if lhs.updatedAt == rhs.updatedAt {
                    lhs.testCaseID < rhs.testCaseID
                } else {
                    lhs.updatedAt > rhs.updatedAt
                }
            }
    }

    private func requireEvent(_ eventID: String) throws {
        guard eventsByID[eventID] != nil else {
            throw InspectionEventStoreError.eventNotFound(eventID)
        }
    }

    private func persistSessions(
        eventID: String,
        teamID: String
    ) throws {
        let sessions = sessionsByKey.values
            .filter { $0.eventID == eventID && $0.teamID == teamID }
        try sessionCatalogService.saveSessions(sessions, eventID: eventID, teamID: teamID)
    }

    private func requireTeam(eventID: String, teamID: String) throws {
        try requireEvent(eventID)

        guard teamsByEventID[eventID, default: []].contains(where: { $0.id == teamID }) else {
            throw InspectionEventStoreError.teamNotFound(eventID: eventID, teamID: teamID)
        }
    }

    private func requireSession(
        scope: InspectionSessionScope,
        access: InspectionEventUserAccess
    ) throws {
        try requireAccess(access, eventID: scope.eventID, teamID: scope.teamID)

        let key = SessionKey(scope: scope)
        guard sessionsByKey[key] != nil else {
            throw InspectionEventStoreError.sessionNotFound(
                eventID: scope.eventID,
                teamID: scope.teamID,
                sessionID: scope.sessionID
            )
        }
    }

    private func requireAccess(
        _ access: InspectionEventUserAccess,
        eventID: String,
        teamID: String? = nil
    ) throws {
        if let teamID {
            guard access.permits(eventID: eventID, teamID: teamID) else {
                throw InspectionEventStoreError.accessDenied(
                    userID: access.userID,
                    eventID: eventID,
                    teamID: teamID
                )
            }
        } else {
            guard access.permits(eventID: eventID) else {
                throw InspectionEventStoreError.accessDenied(
                    userID: access.userID,
                    eventID: eventID,
                    teamID: nil
                )
            }
        }
    }

    nonisolated static func localTeamID(carNumber: String) -> String {
        let normalized = carNumber
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
            .replacingOccurrences(of: "/", with: "-")
            .replacingOccurrences(of: ":", with: "-")
            .replacingOccurrences(of: " ", with: "-")
        return "car-\(normalized)"
    }
}

private struct SessionKey: Hashable, Sendable {
    let eventID: String
    let teamID: String
    let sessionID: String

    init(
        eventID: String,
        teamID: String,
        sessionID: String
    ) {
        self.eventID = eventID
        self.teamID = teamID
        self.sessionID = sessionID
    }

    init(_ session: InspectionSessionRecord) {
        self.init(eventID: session.eventID, teamID: session.teamID, sessionID: session.id)
    }

    init(scope: InspectionSessionScope) {
        self.init(eventID: scope.eventID, teamID: scope.teamID, sessionID: scope.sessionID)
    }
}
