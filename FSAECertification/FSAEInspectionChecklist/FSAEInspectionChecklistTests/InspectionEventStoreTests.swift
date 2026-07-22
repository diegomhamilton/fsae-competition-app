import Foundation
import Testing
@testable import FSAEInspectionChecklist

struct InspectionEventStoreTests {
    @Test("TASK#10.4 local team catalog persists created teams by event")
    func localTeamCatalogPersistsCreatedTeamsByEvent() async throws {
        let rootDirectory = try temporaryStoreDirectory()
        defer { try? FileManager.default.removeItem(at: rootDirectory) }
        let catalog = LocalTeamCatalogService(rootDirectory: rootDirectory)
        let created = InspectionEventTeamRecord(
            id: "car-101",
            eventID: "event-2026",
            displayName: "Local Team",
            carNumber: "101"
        )

        try await catalog.saveTeams([created], eventID: "event-2026")
        let restored = try await catalog.loadTeams(eventID: "event-2026")

        #expect(restored == [created])
        #expect(try await catalog.loadTeams(eventID: "event-2027").isEmpty)
    }

    @Test("TASK#10.4 store creates locally entered teams and grants local judge access")
    func storeCreatesLocalTeamsAndGrantsLocalJudgeAccess() async throws {
        let rootDirectory = try temporaryStoreDirectory()
        defer { try? FileManager.default.removeItem(at: rootDirectory) }
        let store = InspectionEventStore(
            events: [event(id: "event-2026")],
            teams: [],
            persistenceService: TestCaseJSONPersistenceService(rootDirectory: rootDirectory),
            teamCatalogService: LocalTeamCatalogService(rootDirectory: rootDirectory)
        )
        let access = InspectionEventUserAccess.localJudgeAccess(eventID: "event-2026")

        #expect(try await store.teams(eventID: "event-2026", access: access).isEmpty)

        let created = try await store.createTeam(
            eventID: "event-2026",
            entry: LocalTeamCatalogEntry(displayName: "UFPE Racing", carNumber: "28"),
            access: access
        )
        let visibleTeams = try await store.teams(eventID: "event-2026", access: access)
        let relaunchedStore = InspectionEventStore(
            events: [event(id: "event-2026")],
            teams: [],
            persistenceService: TestCaseJSONPersistenceService(rootDirectory: rootDirectory),
            teamCatalogService: LocalTeamCatalogService(rootDirectory: rootDirectory)
        )
        let restoredTeams = try await relaunchedStore.teams(eventID: "event-2026", access: access)

        #expect(created.id == "car-28")
        #expect(created.displayName == "UFPE Racing")
        #expect(visibleTeams == [created])
        #expect(restoredTeams == [created])
    }

    @Test("TASK#10.5 local session catalog persists started and ended timestamps")
    func localSessionCatalogPersistsStartedAndEndedTimestamps() async throws {
        let rootDirectory = try temporaryStoreDirectory()
        defer { try? FileManager.default.removeItem(at: rootDirectory) }
        let catalog = LocalSessionCatalogService(rootDirectory: rootDirectory)
        let startedAt = Date(timeIntervalSince1970: 1_780_010_000)
        let endedAt = Date(timeIntervalSince1970: 1_780_013_600)
        let completed = InspectionSessionRecord(
            id: "session-42",
            eventID: "event-2026",
            teamID: "car-042",
            judgeUserID: "judge-a",
            status: .submitted,
            currentStageID: "rain",
            startedAt: startedAt,
            endedAt: endedAt,
            lastSavedAt: Date(timeIntervalSince1970: 1_780_011_200)
        )

        try await catalog.saveSessions([completed], eventID: "event-2026", teamID: "car-042")
        let restored = try await catalog.loadSessions(eventID: "event-2026", teamID: "car-042")

        #expect(restored == [completed])
        #expect(restored.first?.startedAt == startedAt)
        #expect(restored.first?.endedAt == endedAt)
        #expect(try await catalog.loadSessions(eventID: "event-2026", teamID: "car-099").isEmpty)
    }

    @Test("TASK#10.5 store restores active session after relaunch and preserves start timestamp")
    func storeRestoresActiveSessionAfterRelaunchAndPreservesStartTimestamp() async throws {
        let rootDirectory = try temporaryStoreDirectory()
        defer { try? FileManager.default.removeItem(at: rootDirectory) }
        let startTime = Date(timeIntervalSince1970: 1_780_020_000)
        let saveTime = Date(timeIntervalSince1970: 1_780_020_900)
        let access = access(teamID: "car-042")
        let firstLaunch = InspectionEventStore(
            events: [event(id: "event-2026")],
            teams: [team(id: "car-042", eventID: "event-2026", carNumber: "42")],
            persistenceService: TestCaseJSONPersistenceService(rootDirectory: rootDirectory),
            teamCatalogService: LocalTeamCatalogService(rootDirectory: rootDirectory),
            sessionCatalogService: LocalSessionCatalogService(rootDirectory: rootDirectory)
        )

        let started = try await firstLaunch.startSession(
            eventID: "event-2026",
            teamID: "car-042",
            defaultStageID: "garage",
            sessionID: "session-active",
            startedAt: startTime,
            access: access
        )
        try await firstLaunch.saveDraft(
            try completedStoreDraft(notes: "Rain stage progress saved."),
            scope: InspectionSessionScope(
                eventID: "event-2026",
                teamID: "car-042",
                sessionID: started.id,
                stageID: "rain"
            ),
            updatedAt: saveTime,
            access: access
        )

        let relaunched = InspectionEventStore(
            events: [event(id: "event-2026")],
            teams: [team(id: "car-042", eventID: "event-2026", carNumber: "42")],
            persistenceService: TestCaseJSONPersistenceService(rootDirectory: rootDirectory),
            teamCatalogService: LocalTeamCatalogService(rootDirectory: rootDirectory),
            sessionCatalogService: LocalSessionCatalogService(rootDirectory: rootDirectory)
        )
        let activeSession = try #require(await relaunched.activeSession(
            eventID: "event-2026",
            teamID: "car-042",
            access: access
        ))

        #expect(activeSession.id == "session-active")
        #expect(activeSession.startedAt == startTime)
        #expect(activeSession.endedAt == nil)
        #expect(activeSession.currentStageID == "rain")
        #expect(activeSession.lastSavedAt == saveTime)
    }

    @Test("TASK#10.5 completing session records endedAt and removes active session")
    func completingSessionRecordsEndedAtAndRemovesActiveSession() async throws {
        let rootDirectory = try temporaryStoreDirectory()
        defer { try? FileManager.default.removeItem(at: rootDirectory) }
        let startTime = Date(timeIntervalSince1970: 1_780_030_000)
        let endTime = Date(timeIntervalSince1970: 1_780_033_600)
        let store = InspectionEventStore(
            events: [event(id: "event-2026")],
            teams: [team(id: "car-042", eventID: "event-2026", carNumber: "42")],
            persistenceService: TestCaseJSONPersistenceService(rootDirectory: rootDirectory),
            sessionCatalogService: LocalSessionCatalogService(rootDirectory: rootDirectory)
        )
        let access = access(teamID: "car-042")

        let started = try await store.startSession(
            eventID: "event-2026",
            teamID: "car-042",
            defaultStageID: "garage",
            sessionID: "session-complete",
            startedAt: startTime,
            access: access
        )
        let completed = try await store.completeSession(
            eventID: "event-2026",
            teamID: "car-042",
            sessionID: started.id,
            endedAt: endTime,
            access: access
        )
        let relaunched = InspectionEventStore(
            events: [event(id: "event-2026")],
            teams: [team(id: "car-042", eventID: "event-2026", carNumber: "42")],
            persistenceService: TestCaseJSONPersistenceService(rootDirectory: rootDirectory),
            sessionCatalogService: LocalSessionCatalogService(rootDirectory: rootDirectory)
        )
        let sessions = try await relaunched.sessions(eventID: "event-2026", teamID: "car-042", access: access)

        #expect(completed.status == .submitted)
        #expect(completed.startedAt == startTime)
        #expect(completed.endedAt == endTime)
        #expect(try await relaunched.activeSession(eventID: "event-2026", teamID: "car-042", access: access) == nil)
        #expect(sessions.first?.endedAt == endTime)
    }

    @Test("US-001 scopes event, team, and session queries by user access")
    func scopesQueriesByEventTeamSessionAndAccess() async throws {
        let rootDirectory = try temporaryStoreDirectory()
        defer { try? FileManager.default.removeItem(at: rootDirectory) }
        let store = InspectionEventStore(
            events: [
                event(id: "event-2026"),
                event(id: "event-2027")
            ],
            teams: [
                team(id: "car-042", eventID: "event-2026", carNumber: "42"),
                team(id: "car-099", eventID: "event-2026", carNumber: "99"),
                team(id: "car-007", eventID: "event-2027", carNumber: "7")
            ],
            sessions: [
                session(id: "session-a", eventID: "event-2026", teamID: "car-042"),
                session(id: "session-b", eventID: "event-2026", teamID: "car-099"),
                session(id: "session-c", eventID: "event-2027", teamID: "car-007")
            ],
            persistenceService: TestCaseJSONPersistenceService(rootDirectory: rootDirectory)
        )
        let access = InspectionEventUserAccess(
            userID: "judge-a",
            permittedEventIDs: ["event-2026"],
            permittedTeamIDsByEventID: ["event-2026": ["car-042"]]
        )

        let visibleEvents = await store.events(access: access)
        let visibleTeams = try await store.teams(eventID: "event-2026", access: access)
        let visibleSessions = try await store.sessions(
            eventID: "event-2026",
            teamID: "car-042",
            access: access
        )

        #expect(visibleEvents.map(\.id) == ["event-2026"])
        #expect(visibleTeams.map(\.id) == ["car-042"])
        #expect(visibleSessions.map(\.id) == ["session-a"])
        await #expect(throws: InspectionEventStoreError.accessDenied(
            userID: "judge-a",
            eventID: "event-2026",
            teamID: "car-099"
        )) {
            try await store.sessions(eventID: "event-2026", teamID: "car-099", access: access)
        }
    }

    @Test("US-006 prevents draft leakage across team access scopes")
    func preventsDraftLeakageAcrossTeamAccessScopes() async throws {
        let rootDirectory = try temporaryStoreDirectory()
        defer { try? FileManager.default.removeItem(at: rootDirectory) }
        let store = InspectionEventStore(
            events: [event(id: "event-2026")],
            teams: [
                team(id: "car-042", eventID: "event-2026", carNumber: "42"),
                team(id: "car-099", eventID: "event-2026", carNumber: "99")
            ],
            sessions: [
                session(id: "session-a", eventID: "event-2026", teamID: "car-042"),
                session(id: "session-b", eventID: "event-2026", teamID: "car-099")
            ],
            persistenceService: TestCaseJSONPersistenceService(rootDirectory: rootDirectory)
        )
        let teamAAccess = access(teamID: "car-042")
        let teamBAccess = access(teamID: "car-099")
        let teamAScope = InspectionSessionScope(
            eventID: "event-2026",
            teamID: "car-042",
            sessionID: "session-a",
            stageID: "garage"
        )
        let teamBScope = InspectionSessionScope(
            eventID: "event-2026",
            teamID: "car-099",
            sessionID: "session-b",
            stageID: "garage"
        )

        try await store.saveDraft(
            try completedStoreDraft(notes: "Team 42 saved this."),
            scope: teamAScope,
            updatedAt: Date(timeIntervalSince1970: 1_780_001_000),
            access: teamAAccess
        )
        try await store.saveDraft(
            try completedStoreDraft(notes: "Team 99 saved this."),
            scope: teamBScope,
            updatedAt: Date(timeIntervalSince1970: 1_780_001_100),
            access: teamBAccess
        )

        let teamADraft = try await store.draft(
            scope: teamAScope,
            testCaseID: "garage-main",
            access: teamAAccess
        )
        let teamBDraft = try await store.draft(
            scope: teamBScope,
            testCaseID: "garage-main",
            access: teamBAccess
        )

        #expect(teamADraft?.aggregate.notesByStepID["G-02"] == "Team 42 saved this.")
        #expect(teamBDraft?.aggregate.notesByStepID["G-02"] == "Team 99 saved this.")
        await #expect(throws: InspectionEventStoreError.accessDenied(
            userID: "judge-a",
            eventID: "event-2026",
            teamID: "car-099"
        )) {
            _ = try await store.draft(
                scope: teamBScope,
                testCaseID: "garage-main",
                access: teamAAccess
            )
        }
    }

    @Test("US-006 serializes async draft mutations through the actor store")
    func serializesAsyncDraftMutationsThroughActorStore() async throws {
        let rootDirectory = try temporaryStoreDirectory()
        defer { try? FileManager.default.removeItem(at: rootDirectory) }
        let store = InspectionEventStore(
            events: [event(id: "event-2026")],
            teams: [
                team(id: "car-042", eventID: "event-2026", carNumber: "42"),
                team(id: "car-099", eventID: "event-2026", carNumber: "99")
            ],
            sessions: [
                session(id: "session-a", eventID: "event-2026", teamID: "car-042"),
                session(id: "session-b", eventID: "event-2026", teamID: "car-099")
            ],
            persistenceService: TestCaseJSONPersistenceService(rootDirectory: rootDirectory)
        )
        let teamAScope = InspectionSessionScope(
            eventID: "event-2026",
            teamID: "car-042",
            sessionID: "session-a",
            stageID: "garage"
        )
        let teamBScope = InspectionSessionScope(
            eventID: "event-2026",
            teamID: "car-099",
            sessionID: "session-b",
            stageID: "garage"
        )

        try await withThrowingTaskGroup(of: Void.self) { group in
            group.addTask {
                try await store.saveDraft(
                    try completedStoreDraft(notes: "Concurrent team A note."),
                    scope: teamAScope,
                    updatedAt: Date(timeIntervalSince1970: 1_780_001_200),
                    access: access(teamID: "car-042")
                )
            }
            group.addTask {
                try await store.saveDraft(
                    try completedStoreDraft(notes: "Concurrent team B note."),
                    scope: teamBScope,
                    updatedAt: Date(timeIntervalSince1970: 1_780_001_300),
                    access: access(teamID: "car-099")
                )
            }
            try await group.waitForAll()
        }

        let teamAFiles = try await store.draftFiles(scope: teamAScope, access: access(teamID: "car-042"))
        let teamBFiles = try await store.draftFiles(scope: teamBScope, access: access(teamID: "car-099"))
        let teamASession = try await store.session(
            eventID: "event-2026",
            teamID: "car-042",
            sessionID: "session-a",
            access: access(teamID: "car-042")
        )
        let teamBSession = try await store.session(
            eventID: "event-2026",
            teamID: "car-099",
            sessionID: "session-b",
            access: access(teamID: "car-099")
        )

        #expect(teamAFiles.map(\.testCaseID) == ["garage-main"])
        #expect(teamBFiles.map(\.testCaseID) == ["garage-main"])
        #expect(teamAFiles.first?.stepDrafts.first(where: { $0.stepID == "G-02" })?.notes == "Concurrent team A note.")
        #expect(teamBFiles.first?.stepDrafts.first(where: { $0.stepID == "G-02" })?.notes == "Concurrent team B note.")
        #expect(teamASession.lastSavedAt == Date(timeIntervalSince1970: 1_780_001_200))
        #expect(teamBSession.lastSavedAt == Date(timeIntervalSince1970: 1_780_001_300))
    }
}

private func event(id: String) -> InspectionEventDefinition {
    InspectionEventDefinition(
        id: id,
        name: "FSAE \(id)",
        stageIDs: ["garage", "body", "chassis", "ev", "egress", "rain"]
    )
}

private func team(
    id: String,
    eventID: String,
    carNumber: String
) -> InspectionEventTeamRecord {
    InspectionEventTeamRecord(
        id: id,
        eventID: eventID,
        displayName: "Team \(carNumber)",
        carNumber: carNumber
    )
}

private func session(
    id: String,
    eventID: String,
    teamID: String
) -> InspectionSessionRecord {
    InspectionSessionRecord(
        id: id,
        eventID: eventID,
        teamID: teamID,
        judgeUserID: "judge-a",
        currentStageID: "garage",
        startedAt: Date(timeIntervalSince1970: 1_780_000_000)
    )
}

private func access(teamID: String) -> InspectionEventUserAccess {
    InspectionEventUserAccess(
        userID: "judge-a",
        permittedEventIDs: ["event-2026"],
        permittedTeamIDsByEventID: ["event-2026": [teamID]]
    )
}

private func temporaryStoreDirectory() throws -> URL {
    let directory = FileManager.default.temporaryDirectory
        .appendingPathComponent("FSAEInspectionChecklistTests")
        .appendingPathComponent(UUID().uuidString)
        .appendingPathComponent("Application Support")
        .appendingPathComponent("FSAEInspectionChecklist")
    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    return directory
}

private func completedStoreDraft(notes: String) throws -> TestCaseDraft {
    let measurementRange = MeasurementRange(
        unit: .seconds,
        minimum: storeDecimal("0.00"),
        maximum: storeDecimal("4.99"),
        maximumFractionDigits: 2
    )
    let testCase = InspectionTestCase(
        id: "garage-main",
        code: "G-MAIN",
        displayOrder: 10,
        title: "Garage inspection basics",
        ruleReferences: ["IN.4.1"],
        steps: [
            storeInspectionStep(id: "G-01", displayOrder: 10, title: "Accumulator container closed"),
            storeInspectionStep(
                id: "G-02",
                displayOrder: 20,
                type: .measurement,
                title: "Egress timing check",
                measurementRange: measurementRange
            ),
            storeInspectionStep(
                id: "G-03",
                displayOrder: 30,
                title: "Brake over-travel evidence",
                requiresEvidence: true
            )
        ]
    )

    return TestCaseDraft(
        testCase: testCase,
        stepDrafts: [
            TestStepDraft(stepID: "G-01", outcome: .pass),
            TestStepDraft(
                stepID: "G-02",
                outcome: .pass,
                notes: notes,
                measurementInput: "4.38",
                measurementValue: try MeasurementValue(rawValue: "4.38", range: measurementRange)
            ),
            TestStepDraft(
                stepID: "G-03",
                outcome: .pass,
                evidenceAttachments: [
                    EvidenceAttachmentMetadata(
                        id: "garage-photo",
                        displayName: "Brake over-travel switch photo",
                        mediaType: .photo,
                        source: .mockAttachment,
                        createdAt: Date(timeIntervalSince1970: 1_780_000_000)
                    )
                ]
            )
        ]
    )
}

private func storeInspectionStep(
    id: String,
    displayOrder: Int,
    type: InspectionTestStepType = .check,
    title: String,
    requiresEvidence: Bool = false,
    measurementRange: MeasurementRange? = nil
) -> InspectionTestStep {
    InspectionTestStep(
        id: id,
        code: id,
        displayOrder: displayOrder,
        ruleReference: "IN.4.1",
        title: title,
        type: type,
        content: "Validate \(title).",
        requiredOutcome: true,
        requiresEvidence: requiresEvidence,
        measurementRange: measurementRange
    )
}

private func storeDecimal(_ rawValue: String) -> Decimal {
    Decimal(string: rawValue, locale: Locale(identifier: "en_US_POSIX")) ?? 0
}
