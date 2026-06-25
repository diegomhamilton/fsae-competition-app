import Foundation
import Testing
@testable import FSAEInspectionChecklist

struct SubmissionSnapshotServiceTests {
    @Test("US-002 creates a submitted stage snapshot from test case drafts")
    func createsStageSnapshotFromDrafts() async throws {
        let rootDirectory = try temporaryApplicationSupportDirectory()
        defer { try? FileManager.default.removeItem(at: rootDirectory) }
        let persistence = TestCaseJSONPersistenceService(rootDirectory: rootDirectory)
        let service = SubmissionSnapshotService(persistence: persistence)
        let context = InspectionPersistenceContext(
            eventID: "event-2026",
            teamID: "car-042",
            sessionID: "session-a",
            stageID: "garage"
        )
        let submittedAt = Date(timeIntervalSince1970: 1_780_001_000)
        let draft = try completedSubmissionDraft(notes: "Garage inspection accepted.")

        let result = try await service.createStageSnapshot(
            context: context,
            submissionID: "submission-001",
            drafts: [draft],
            submittedAt: submittedAt
        )

        #expect(result.snapshot.schemaVersion == SubmittedStageSnapshotFile.currentSchemaVersion)
        #expect(result.snapshot.submissionID == "submission-001")
        #expect(result.snapshot.eventID == "event-2026")
        #expect(result.snapshot.teamID == "car-042")
        #expect(result.snapshot.sessionID == "session-a")
        #expect(result.snapshot.stageID == "garage")
        #expect(result.snapshot.submittedAt == submittedAt)
        #expect(result.snapshot.testCases.map(\.testCaseID) == ["garage-main"])
        #expect(result.snapshot.testCases.first?.stepDrafts == draft.stepDrafts)
        #expect(result.testCaseSnapshotURLs.count == 1)
        #expect(FileManager.default.fileExists(atPath: result.stageSnapshotURL.path))
    }

    @Test("US-007 refuses to overwrite an existing submitted stage snapshot")
    func submittedStageSnapshotsAreImmutable() async throws {
        let rootDirectory = try temporaryApplicationSupportDirectory()
        defer { try? FileManager.default.removeItem(at: rootDirectory) }
        let service = SubmissionSnapshotService(
            persistence: TestCaseJSONPersistenceService(rootDirectory: rootDirectory)
        )
        let context = InspectionPersistenceContext(
            eventID: "event-2026",
            teamID: "car-042",
            sessionID: "session-a",
            stageID: "garage"
        )

        _ = try await service.createStageSnapshot(
            context: context,
            submissionID: "submission-001",
            drafts: [try completedSubmissionDraft(notes: "Original submission.")]
        )

        await #expect(throws: SubmissionSnapshotError.submissionAlreadyExists("submission-001")) {
            _ = try await service.createStageSnapshot(
                context: context,
                submissionID: "submission-001",
                drafts: [try completedSubmissionDraft(notes: "Attempted correction.")]
            )
        }
    }

    @Test("US-006 places submitted snapshots in the active team folder")
    func placesSnapshotsUnderTeamSubmissionFolder() async throws {
        let rootDirectory = try temporaryApplicationSupportDirectory()
        defer { try? FileManager.default.removeItem(at: rootDirectory) }
        let persistence = TestCaseJSONPersistenceService(rootDirectory: rootDirectory)
        let service = SubmissionSnapshotService(persistence: persistence)
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

        let teamAResult = try await service.createStageSnapshot(
            context: teamAContext,
            submissionID: "submission-001",
            drafts: [try completedSubmissionDraft(notes: "Team 42 accepted.")]
        )
        let teamBResult = try await service.createStageSnapshot(
            context: teamBContext,
            submissionID: "submission-001",
            drafts: [try completedSubmissionDraft(notes: "Team 99 accepted.")]
        )

        #expect(teamAResult.stageSnapshotURL.path.hasSuffix("/events/event-2026/teams/car-042/sessions/session-a/submissions/submission-001/stage-snapshot.json"))
        #expect(teamBResult.stageSnapshotURL.path.hasSuffix("/events/event-2026/teams/car-099/sessions/session-a/submissions/submission-001/stage-snapshot.json"))
        #expect(teamAResult.stageSnapshotURL != teamBResult.stageSnapshotURL)
        #expect(teamAResult.snapshot.testCases.first?.stepDrafts.first(where: { $0.stepID == "G-02" })?.notes == "Team 42 accepted.")
        #expect(teamBResult.snapshot.testCases.first?.stepDrafts.first(where: { $0.stepID == "G-02" })?.notes == "Team 99 accepted.")
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

private func completedSubmissionDraft(notes: String) throws -> TestCaseDraft {
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
            submissionStep(id: "G-01", displayOrder: 10, title: "Accumulator container closed"),
            submissionStep(
                id: "G-02",
                displayOrder: 20,
                type: .measurement,
                title: "Egress timing check",
                measurementRange: measurementRange
            ),
            submissionStep(
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

private func submissionStep(
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
