import Foundation
import Testing
@testable import FSAEInspectionChecklist

struct InspectionEventStoreTests {
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
