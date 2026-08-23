import Foundation
import Testing
@testable import FSAEInspectionChecklist

struct TestCaseJSONPersistenceServiceTests {
    @Test("US-001 stores one in-progress test case JSON under scoped Application Support folders")
    func storesOneDraftFilePerScopedTestCase() async throws {
        let rootDirectory = try temporaryApplicationSupportDirectory()
        defer { try? FileManager.default.removeItem(at: rootDirectory) }
        let service = TestCaseJSONPersistenceService(rootDirectory: rootDirectory)
        let context = InspectionPersistenceContext(
            eventID: "event-2026",
            teamID: "car-042",
            sessionID: "session-a",
            stageID: "garage"
        )
        let updatedAt = Date(timeIntervalSince1970: 1_780_000_100)
        let draft = try completedDraft(notes: "All required garage checks captured.")

        let fileURL = try await service.saveDraft(draft, context: context, updatedAt: updatedAt)
        let decodedFile = try await service.loadDraftFile(context: context, testCaseID: draft.id)

        #expect(fileURL.path.hasSuffix("/events/event-2026/teams/car-042/sessions/session-a/drafts/garage/garage-main.json"))
        #expect(FileManager.default.fileExists(atPath: fileURL.path))
        #expect(decodedFile?.schemaVersion == TestCaseDraftFile.currentSchemaVersion)
        #expect(decodedFile?.eventID == "event-2026")
        #expect(decodedFile?.teamID == "car-042")
        #expect(decodedFile?.sessionID == "session-a")
        #expect(decodedFile?.stageID == "garage")
        #expect(decodedFile?.testCaseID == "garage-main")
        #expect(decodedFile?.updatedAt == updatedAt)
        #expect(decodedFile?.stepDrafts == draft.stepDrafts)
    }

    @Test("US-001 restores draft values after service recreation")
    func restoresDraftValuesAfterRelaunch() async throws {
        let rootDirectory = try temporaryApplicationSupportDirectory()
        defer { try? FileManager.default.removeItem(at: rootDirectory) }
        let context = InspectionPersistenceContext(
            eventID: "event-2026",
            teamID: "car-042",
            sessionID: "session-a",
            stageID: "garage"
        )
        let originalService = TestCaseJSONPersistenceService(rootDirectory: rootDirectory)
        let draft = try completedDraft(notes: "Brake over-travel switch photographed.")

        _ = try await originalService.saveDraft(draft, context: context)

        let relaunchedService = TestCaseJSONPersistenceService(rootDirectory: rootDirectory)
        let restoredDraft = try await relaunchedService.loadDraft(context: context, testCaseID: draft.id)

        #expect(restoredDraft?.id == draft.id)
        #expect(restoredDraft?.stepDrafts == draft.stepDrafts)
        #expect(restoredDraft?.aggregate.notesByStepID["G-02"] == "Brake over-travel switch photographed.")
        #expect(restoredDraft?.aggregate.evidenceAttachmentsByStepID["G-03"]?.map(\.id) == ["garage-photo"])
    }

    @Test("US-001 keeps same test case identifiers isolated by team and session folders")
    func keepsDraftsIsolatedByTeamAndSession() async throws {
        let rootDirectory = try temporaryApplicationSupportDirectory()
        defer { try? FileManager.default.removeItem(at: rootDirectory) }
        let service = TestCaseJSONPersistenceService(rootDirectory: rootDirectory)
        let teamAContext = InspectionPersistenceContext(
            eventID: "event-2026",
            teamID: "car-042",
            sessionID: "session-a",
            stageID: "garage"
        )
        let teamBContext = InspectionPersistenceContext(
            eventID: "event-2026",
            teamID: "car-099",
            sessionID: "session-b",
            stageID: "garage"
        )

        _ = try await service.saveDraft(try completedDraft(notes: "Team 42 note."), context: teamAContext)
        _ = try await service.saveDraft(try completedDraft(notes: "Team 99 note."), context: teamBContext)

        let teamADraft = try await service.loadDraft(context: teamAContext, testCaseID: "garage-main")
        let teamBDraft = try await service.loadDraft(context: teamBContext, testCaseID: "garage-main")
        let teamAURL = await service.draftFileURL(context: teamAContext, testCaseID: "garage-main")
        let teamBURL = await service.draftFileURL(context: teamBContext, testCaseID: "garage-main")

        #expect(teamADraft?.aggregate.notesByStepID["G-02"] == "Team 42 note.")
        #expect(teamBDraft?.aggregate.notesByStepID["G-02"] == "Team 99 note.")
        #expect(teamAURL != teamBURL)
        #expect(teamAURL.path.contains("/teams/car-042/sessions/session-a/"))
        #expect(teamBURL.path.contains("/teams/car-099/sessions/session-b/"))
    }

    @Test("US-001 sanitizes colon characters in path-scoped identifiers")
    func sanitizesColonCharactersInPathScopedIdentifiers() async throws {
        let rootDirectory = try temporaryApplicationSupportDirectory()
        defer { try? FileManager.default.removeItem(at: rootDirectory) }
        let service = TestCaseJSONPersistenceService(rootDirectory: rootDirectory)
        let context = InspectionPersistenceContext(
            eventID: "event:2026",
            teamID: "car:042",
            sessionID: "session:a",
            stageID: "garage:main"
        )

        let fileURL = await service.draftFileURL(context: context, testCaseID: "test:case")

        #expect(fileURL.path.hasSuffix("/events/event_2026/teams/car_042/sessions/session_a/drafts/garage_main/test_case.json"))
        #expect(!fileURL.lastPathComponent.contains(":"))
    }

    @Test("US-001 exposes team-specific submissions folder without mixing team contexts")
    func exposesTeamSpecificSubmissionsFolder() async throws {
        let rootDirectory = try temporaryApplicationSupportDirectory()
        defer { try? FileManager.default.removeItem(at: rootDirectory) }
        let service = TestCaseJSONPersistenceService(rootDirectory: rootDirectory)
        let teamAContext = InspectionPersistenceContext(
            eventID: "event-2026",
            teamID: "car-042",
            sessionID: "session-a",
            stageID: "garage"
        )
        let teamBContext = InspectionPersistenceContext(
            eventID: "event-2026",
            teamID: "car-099",
            sessionID: "session-a",
            stageID: "garage"
        )

        let teamADirectory = await service.submissionsDirectoryURL(context: teamAContext)
        let teamBDirectory = await service.submissionsDirectoryURL(context: teamBContext)

        #expect(teamADirectory.path.hasSuffix("/events/event-2026/teams/car-042/sessions/session-a/submissions"))
        #expect(teamBDirectory.path.hasSuffix("/events/event-2026/teams/car-099/sessions/session-a/submissions"))
        #expect(teamADirectory != teamBDirectory)
    }

    @Test("US-001 writes submitted test case snapshots under team folders and clears stale drafts")
    func writesSubmittedTestCaseSnapshotAndClearsDraft() async throws {
        let rootDirectory = try temporaryApplicationSupportDirectory()
        defer { try? FileManager.default.removeItem(at: rootDirectory) }
        let service = TestCaseJSONPersistenceService(rootDirectory: rootDirectory)
        let context = InspectionPersistenceContext(
            eventID: "event-2026",
            teamID: "car-042",
            sessionID: "session-a",
            stageID: "garage"
        )
        let submittedAt = Date(timeIntervalSince1970: 1_780_000_200)
        let draft = try completedDraft(notes: "Submitted garage inspection.")

        let draftURL = try await service.saveDraft(draft, context: context)
        let snapshotURL = try await service.saveSubmittedTestCaseSnapshot(
            draft,
            context: context,
            submissionID: "submission-001",
            submittedAt: submittedAt,
            recheckReferences: ["recheck-garage-main"]
        )
        let restoredDraft = try await service.loadDraft(context: context, testCaseID: draft.id)
        let submittedSnapshot = try await service.loadSubmittedTestCaseSnapshot(
            context: context,
            submissionID: "submission-001",
            testCaseID: draft.id
        )

        #expect(snapshotURL.path.hasSuffix("/events/event-2026/teams/car-042/sessions/session-a/submissions/submission-001/test-cases/garage-main.json"))
        #expect(FileManager.default.fileExists(atPath: snapshotURL.path))
        #expect(!FileManager.default.fileExists(atPath: draftURL.path))
        #expect(restoredDraft == nil)
        #expect(submittedSnapshot?.schemaVersion == SubmittedTestCaseSnapshotFile.currentSchemaVersion)
        #expect(submittedSnapshot?.submissionID == "submission-001")
        #expect(submittedSnapshot?.eventID == "event-2026")
        #expect(submittedSnapshot?.teamID == "car-042")
        #expect(submittedSnapshot?.sessionID == "session-a")
        #expect(submittedSnapshot?.stageID == "garage")
        #expect(submittedSnapshot?.testCaseID == "garage-main")
        #expect(submittedSnapshot?.submittedAt == submittedAt)
        #expect(submittedSnapshot?.stepDrafts == draft.stepDrafts)
        #expect(submittedSnapshot?.recheckReferences == ["recheck-garage-main"])
    }

    @Test("TASK#10.7 reset cleanup removes active drafts without deleting submitted history")
    func resetCleanupRemovesActiveDraftsWithoutDeletingSubmittedHistory() async throws {
        let rootDirectory = try temporaryApplicationSupportDirectory()
        defer { try? FileManager.default.removeItem(at: rootDirectory) }
        let service = TestCaseJSONPersistenceService(rootDirectory: rootDirectory)
        let context = InspectionPersistenceContext(
            eventID: "event-2026",
            teamID: "car-042",
            sessionID: "session-active",
            stageID: "garage"
        )
        let draft = try completedDraft(notes: "Keep the submitted execution, clear only this draft.")

        _ = try await service.saveDraft(draft, context: context)
        _ = try await service.saveSubmittedTestCaseSnapshot(
            draft,
            context: context,
            submissionID: "submission-preserved",
            removeDraft: false
        )

        try await service.clearDraftsForSession(context: context)

        #expect(try await service.loadDraftFiles(context: context).isEmpty)
        #expect(try await service.loadSubmittedTestCaseSnapshot(
            context: context,
            submissionID: "submission-preserved",
            testCaseID: draft.id
        ) != nil)
    }

    @Test("US-001 keeps submitted snapshots isolated by team-specific submission folders")
    func keepsSubmittedSnapshotsIsolatedByTeamFolder() async throws {
        let rootDirectory = try temporaryApplicationSupportDirectory()
        defer { try? FileManager.default.removeItem(at: rootDirectory) }
        let service = TestCaseJSONPersistenceService(rootDirectory: rootDirectory)
        let teamAContext = InspectionPersistenceContext(
            eventID: "event-2026",
            teamID: "car-042",
            sessionID: "session-a",
            stageID: "garage"
        )
        let teamBContext = InspectionPersistenceContext(
            eventID: "event-2026",
            teamID: "car-099",
            sessionID: "session-a",
            stageID: "garage"
        )

        _ = try await service.saveSubmittedTestCaseSnapshot(
            try completedDraft(notes: "Team 42 submitted."),
            context: teamAContext,
            submissionID: "submission-001"
        )
        _ = try await service.saveSubmittedTestCaseSnapshot(
            try completedDraft(notes: "Team 99 submitted."),
            context: teamBContext,
            submissionID: "submission-001"
        )

        let teamASnapshot = try await service.loadSubmittedTestCaseSnapshot(
            context: teamAContext,
            submissionID: "submission-001",
            testCaseID: "garage-main"
        )
        let teamBSnapshot = try await service.loadSubmittedTestCaseSnapshot(
            context: teamBContext,
            submissionID: "submission-001",
            testCaseID: "garage-main"
        )
        let teamAURL = await service.submittedTestCaseFileURL(
            context: teamAContext,
            submissionID: "submission-001",
            testCaseID: "garage-main"
        )
        let teamBURL = await service.submittedTestCaseFileURL(
            context: teamBContext,
            submissionID: "submission-001",
            testCaseID: "garage-main"
        )
        let teamARechecksURL = await service.rechecksDirectoryURL(context: teamAContext)
        let teamBRechecksURL = await service.rechecksDirectoryURL(context: teamBContext)

        #expect(teamASnapshot?.stepDrafts.first(where: { $0.stepID == "G-02" })?.notes == "Team 42 submitted.")
        #expect(teamBSnapshot?.stepDrafts.first(where: { $0.stepID == "G-02" })?.notes == "Team 99 submitted.")
        #expect(teamAURL.path.contains("/teams/car-042/sessions/session-a/submissions/submission-001/"))
        #expect(teamBURL.path.contains("/teams/car-099/sessions/session-a/submissions/submission-001/"))
        #expect(teamAURL != teamBURL)
        #expect(teamARechecksURL.path.hasSuffix("/events/event-2026/teams/car-042/sessions/session-a/rechecks"))
        #expect(teamBRechecksURL.path.hasSuffix("/events/event-2026/teams/car-099/sessions/session-a/rechecks"))
        #expect(teamARechecksURL != teamBRechecksURL)
    }

    @Test("US-001 writes immutable stage submission snapshots beside submitted test cases")
    func writesStageSubmissionSnapshotInTeamSubmissionFolder() async throws {
        let rootDirectory = try temporaryApplicationSupportDirectory()
        defer { try? FileManager.default.removeItem(at: rootDirectory) }
        let service = TestCaseJSONPersistenceService(rootDirectory: rootDirectory)
        let context = InspectionPersistenceContext(
            eventID: "event-2026",
            teamID: "car-042",
            sessionID: "session-a",
            stageID: "garage"
        )
        let submittedAt = Date(timeIntervalSince1970: 1_780_000_300)
        let draft = try completedDraft(notes: "Stage submitted.")
        _ = try await service.saveSubmittedTestCaseSnapshot(
            draft,
            context: context,
            submissionID: "submission-001",
            submittedAt: submittedAt
        )
        let loadedTestCaseSnapshot = try await service.loadSubmittedTestCaseSnapshot(
            context: context,
            submissionID: "submission-001",
            testCaseID: draft.id
        )
        let testCaseSnapshot = try #require(loadedTestCaseSnapshot)

        let stageURL = try await service.saveSubmittedStageSnapshot(
            submissionID: "submission-001",
            context: context,
            submittedAt: submittedAt,
            testCases: [testCaseSnapshot],
            validationSummary: testCaseSnapshot.validationSummary,
            recheckReferences: ["recheck-garage-main"]
        )
        let stageSnapshot = try await service.loadSubmittedStageSnapshot(
            context: context,
            submissionID: "submission-001"
        )

        #expect(stageURL.path.hasSuffix("/events/event-2026/teams/car-042/sessions/session-a/submissions/submission-001/stage-snapshot.json"))
        #expect(FileManager.default.fileExists(atPath: stageURL.path))
        #expect(stageSnapshot?.schemaVersion == SubmittedStageSnapshotFile.currentSchemaVersion)
        #expect(stageSnapshot?.submissionID == "submission-001")
        #expect(stageSnapshot?.stageID == "garage")
        #expect(stageSnapshot?.submittedAt == submittedAt)
        #expect(stageSnapshot?.testCases.map(\.testCaseID) == ["garage-main"])
        #expect(stageSnapshot?.recheckReferences == ["recheck-garage-main"])
    }
}

private func temporaryApplicationSupportDirectory() throws -> URL {
    let directory = FileManager.default.temporaryDirectory
        .appendingPathComponent("FSAEInspectionChecklistTests")
        .appendingPathComponent(UUID().uuidString)
        .appendingPathComponent("Application Support")
        .appendingPathComponent("FSAEInspectionChecklist")
    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    return directory
}

private func completedDraft(notes: String) throws -> TestCaseDraft {
    let measurementRange = MeasurementRange(
        unit: .seconds,
        minimum: decimal("0.00"),
        maximum: decimal("4.99"),
        maximumFractionDigits: 2
    )
    let testCase = InspectionTestCase(
        id: "garage-main",
        code: "G-MAIN",
        displayOrder: 10,
        title: "Garage inspection basics",
        ruleReferences: ["IN.4.1"],
        steps: [
            inspectionStep(id: "G-01", displayOrder: 10, title: "Accumulator container closed"),
            inspectionStep(
                id: "G-02",
                displayOrder: 20,
                type: .measurement,
                title: "Egress timing check",
                measurementRange: measurementRange
            ),
            inspectionStep(
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

private func inspectionStep(
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

private func decimal(_ rawValue: String) -> Decimal {
    Decimal(string: rawValue, locale: Locale(identifier: "en_US_POSIX")) ?? 0
}
