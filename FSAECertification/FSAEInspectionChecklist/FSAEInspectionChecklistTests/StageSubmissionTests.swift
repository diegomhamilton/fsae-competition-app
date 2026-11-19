import Foundation
import Testing
@testable import FSAEInspectionChecklist

@MainActor
struct StageSubmissionTests {
    @Test("Final stage write failure preserves the original draft after case snapshots were written")
    func partialSubmissionPreservesDrafts() async throws {
        // Arrange
        let root = try Fixtures.temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: root) }
        let context = Fixtures.context
        let submissionID = "fail-at-stage"
        let blockedDirectory = root
            .appending(path: "events/event/teams/car-42/sessions/session/submissions/\(submissionID)")
        let persistence = TestCaseJSONPersistenceService(
            rootDirectory: root,
            fileManager: StageWriteFailingFileManager(blocking: blockedDirectory)
        )
        let service = SubmissionSnapshotService(persistence: persistence)
        let draft = Fixtures.draft(confirmed: true)
        _ = try await persistence.saveDraft(draft, context: context)

        // Act
        var didFail = false
        do {
            _ = try await service.createStageSnapshot(
                context: context,
                submissionID: submissionID,
                drafts: [draft],
                preserveDrafts: true
            )
        } catch {
            didFail = true
        }
        let restoredDraft = try await persistence.loadDraft(context: context, testCaseID: draft.id)
        let caseSnapshot = try await persistence.loadSubmittedTestCaseSnapshot(
            context: context, submissionID: submissionID, testCaseID: draft.id
        )
        let stageSnapshot = try await persistence.loadSubmittedStageSnapshot(
            context: context, submissionID: submissionID
        )

        // Assert
        #expect(didFail)
        #expect(restoredDraft == draft)
        #expect(caseSnapshot?.stepDrafts == draft.stepDrafts)
        #expect(stageSnapshot == nil)
    }

    @Test("Draft-preserving submission keeps the first immutable stage snapshot when an ID is repeated")
    func repeatedSubmissionCannotOverwriteResults() async throws {
        // Arrange
        let root = try Fixtures.temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: root) }
        let persistence = TestCaseJSONPersistenceService(rootDirectory: root)
        let service = SubmissionSnapshotService(persistence: persistence)
        let draft = Fixtures.draft(confirmed: true)
        _ = try await persistence.saveDraft(draft, context: Fixtures.context)

        // Act
        let first = try await service.createStageSnapshot(
            context: Fixtures.context,
            submissionID: "once",
            drafts: [draft],
            preserveDrafts: true
        )
        await #expect(throws: SubmissionSnapshotError.submissionAlreadyExists("once")) {
            _ = try await service.createStageSnapshot(
                context: Fixtures.context,
                submissionID: "once",
                drafts: [Fixtures.draft(confirmed: true, notes: "Attempted overwrite")],
                preserveDrafts: true
            )
        }
        let snapshot = try await persistence.loadSubmittedStageSnapshot(context: Fixtures.context, submissionID: "once")
        let restoredDraft = try await persistence.loadDraft(context: Fixtures.context, testCaseID: draft.id)

        // Assert
        #expect(snapshot?.testCases.first?.stepDrafts == first.snapshot.testCases.first?.stepDrafts)
        #expect(restoredDraft == draft)
    }

    @Test(
        "Stage submission rejects unconfirmed input, missing local evidence, and unsaved results",
        arguments: ["confirmation", "evidence", "unsaved", "flag"]
    )
    func incompleteResultsCannotSubmit(blocker: String) async throws {
        // Arrange
        let root = try Fixtures.temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: root) }
        let harness = Fixtures.harness(root: root, requiresEvidence: blocker == "evidence")
        var draft = Fixtures.draft(confirmed: blocker != "confirmation", requiresEvidence: blocker == "evidence")
        if blocker == "flag" {
            var flagged = draft.stepDrafts[0]
            flagged.flaggedForReview = true
            draft.updateStepDraft(flagged)
        }
        _ = await harness.coordinator.saveStepDraft(draft.stepDrafts[0], testCaseID: draft.id)
        if blocker == "unsaved" { harness.coordinator.markUnsavedDraft(true) }

        // Act
        let submitted = await harness.coordinator.submitActiveStage(
            submissionID: "blocked", evidenceAvailable: { _ in false }
        )
        let snapshot = try await harness.persistence.loadSubmittedStageSnapshot(
            context: Fixtures.context, submissionID: "blocked"
        )

        // Assert
        #expect(!submitted)
        #expect(snapshot == nil)
        #expect(harness.coordinator.stageSubmissionError != nil)
        #expect(!harness.coordinator.isSubmittingStage)
        #expect(harness.coordinator.lastStageSubmission == nil)
    }

    @Test("Editing a submitted result clears success and requires confirmation before resubmitting")
    func correctionRequiresNewSubmission() async throws {
        let root = try Fixtures.temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: root) }
        let harness = Fixtures.harness(root: root)
        var draft = Fixtures.draft(confirmed: true)
        #expect(await harness.coordinator.saveStepDraft(draft.stepDrafts[0], testCaseID: draft.id))
        #expect(await harness.coordinator.submitActiveStage(submissionID: "original"))
        var correctedStep = draft.stepDrafts[0]
        correctedStep.notes = "Corrected judge note"
        correctedStep.confirmedAt = nil
        draft.updateStepDraft(correctedStep)
        #expect(await harness.coordinator.saveStepDraft(draft.stepDrafts[0], testCaseID: draft.id))
        #expect(harness.coordinator.lastStageSubmission == nil)
        #expect(!(await harness.coordinator.submitActiveStage(submissionID: "unconfirmed")))
        correctedStep.confirmedAt = Date(timeIntervalSince1970: 1_800_000_001)
        draft.updateStepDraft(correctedStep)
        #expect(await harness.coordinator.saveStepDraft(draft.stepDrafts[0], testCaseID: draft.id))
        #expect(await harness.coordinator.submitActiveStage(submissionID: "corrected"))
        let original = try await harness.persistence.loadSubmittedStageSnapshot(context: Fixtures.context, submissionID: "original")
        let corrected = try await harness.persistence.loadSubmittedStageSnapshot(context: Fixtures.context, submissionID: "corrected")
        #expect(original?.testCases.first?.stepDrafts.first?.notes == "Judge result")
        #expect(corrected?.testCases.first?.stepDrafts.first?.notes == "Corrected judge note")
    }

    @Test("A stage with no steps cannot submit")
    func emptyStageCannotSubmit() async throws {
        let root = try Fixtures.temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: root) }
        let harness = Fixtures.harness(root: root, empty: true)
        #expect(!(await harness.coordinator.submitActiveStage(submissionID: "empty")))
        #expect(harness.coordinator.lastStageSubmission == nil)
    }

    @Test("Successful stage submission persists a snapshot and retains session, selection, and drafts")
    func successfulSubmissionKeepsTheJudgeContext() async throws {
        // Arrange
        let root = try Fixtures.temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: root) }
        let harness = Fixtures.harness(root: root)
        let draft = Fixtures.draft(confirmed: true)
        let saved = await harness.coordinator.saveStepDraft(draft.stepDrafts[0], testCaseID: draft.id)
        #expect(saved)
        #expect(harness.coordinator.openTestCase(id: draft.id))
        #expect(harness.coordinator.openTestStep(id: "check"))
        let selection = harness.coordinator.stageNavigationPath

        // Act
        let submitted = await harness.coordinator.submitActiveStage(submissionID: "final-stage")
        let snapshot = try await harness.persistence.loadSubmittedStageSnapshot(
            context: Fixtures.context, submissionID: "final-stage"
        )
        let restoredDraft = try await harness.persistence.loadDraft(context: Fixtures.context, testCaseID: draft.id)
        let session = try await harness.store.session(
            eventID: "event", teamID: "car-42", sessionID: "session", access: Fixtures.access
        )

        // Assert
        #expect(submitted)
        #expect(snapshot?.testCases.first?.stepDrafts == draft.stepDrafts)
        #expect(harness.coordinator.lastStageSubmission?.submissionID == "final-stage")
        #expect(harness.coordinator.stageSubmissionError == nil)
        #expect(!harness.coordinator.isSubmittingStage)
        #expect(harness.coordinator.stageNavigationPath == selection)
        #expect(harness.coordinator.sessionContext.endedAt == nil)
        #expect(session.endedAt == nil)
        #expect(session.status == .inProgress)
        #expect(restoredDraft == draft)
        #expect(harness.coordinator.draftsByTestCaseID[draft.id] == draft)
    }
}

@MainActor
private enum Fixtures {
    struct Harness {
        let store: InspectionEventStore
        let persistence: TestCaseJSONPersistenceService
        let coordinator: InspectionExecutionCoordinator
    }

    static var context: InspectionPersistenceContext {
        InspectionPersistenceContext(eventID: "event", teamID: "car-42", sessionID: "session", stageID: "garage")
    }

    static var access: InspectionEventUserAccess {
        .localJudgeAccess(eventID: "event")
    }

    static func temporaryDirectory() throws -> URL {
        let root = URL.temporaryDirectory.appending(path: "StageSubmissionTests-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        return root
    }

    static func testCase(requiresEvidence: Bool = false) -> InspectionTestCase {
        InspectionTestCase(id: "restraints", code: "G-01", title: "Arm restraints", steps: [
            InspectionTestStep(id: "check", code: "G-01-1", displayOrder: 1, ruleReference: "IN.1",
                               title: "Check restraints", type: .check, content: "Check fit.",
                               requiredOutcome: true, requiresEvidence: requiresEvidence)
        ])
    }

    static func draft(confirmed: Bool, requiresEvidence: Bool = false, notes: String = "Judge result") -> TestCaseDraft {
        TestCaseDraft(testCase: testCase(requiresEvidence: requiresEvidence), stepDrafts: [
            TestStepDraft(stepID: "check", outcome: .pass, notes: notes,
                          confirmedAt: confirmed ? Date(timeIntervalSince1970: 1_800_000_000) : nil)
        ])
    }

    static func harness(root: URL, requiresEvidence: Bool = false, empty: Bool = false) -> Harness {
        let team = InspectionTeam(id: 42, school: "Capiba", carNumber: "42", status: .resumed,
                                  currentStage: "Garage", lastSaved: "Saved")
        let stage = InspectionStage(id: "garage", title: "Garage", displayOrder: 1, sections: [
            InspectionSection(id: "safety", title: "Safety", displayOrder: 1,
                              testCases: empty ? [] : [testCase(requiresEvidence: requiresEvidence)])
        ])
        let persistence = TestCaseJSONPersistenceService(rootDirectory: root)
        let store = InspectionEventStore(
            events: [InspectionEventDefinition(id: "event", name: "Inspection", stageIDs: [stage.id])],
            teams: [InspectionEventTeamRecord(id: "car-42", eventID: "event", displayName: "Capiba", carNumber: "42")],
            sessions: [InspectionSessionRecord(id: "session", eventID: "event", teamID: "car-42",
                                               judgeUserID: "local-judge", currentStageID: "garage", startedAt: .now)],
            persistenceService: persistence,
            teamCatalogService: LocalTeamCatalogService(rootDirectory: root),
            sessionCatalogService: LocalSessionCatalogService(rootDirectory: root)
        )
        let coordinator = InspectionExecutionCoordinator(
            sessionContext: InspectionSessionContext(eventID: "event", sessionID: "session", team: team,
                                                     activeStageID: "garage", startedAt: .now,
                                                     endedAt: nil, hasUnsavedDraft: false),
            stages: [stage], teams: [team], store: store, access: access
        )
        return Harness(store: store, persistence: persistence, coordinator: coordinator)
    }
}

/// A deterministic failure at the final stage directory, after case writes succeed.
/// Its only extra state is immutable; FileManager already handles its own synchronization.
nonisolated private final class StageWriteFailingFileManager: FileManager, @unchecked Sendable {
    private let blockedDirectory: URL

    init(blocking directory: URL) {
        blockedDirectory = directory.standardizedFileURL
        super.init()
    }

    override func createDirectory(
        at url: URL,
        withIntermediateDirectories createIntermediates: Bool,
        attributes: [FileAttributeKey: Any]? = nil
    ) throws {
        if url.standardizedFileURL.path == blockedDirectory.path {
            throw NSError(domain: "StageSubmissionTests", code: 1)
        }
        try super.createDirectory(at: url, withIntermediateDirectories: createIntermediates, attributes: attributes)
    }
}
