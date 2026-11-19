import Foundation
import Testing
@testable import FSAEInspectionChecklist

@MainActor
struct FocusedDraftPersistenceTests {
    @Test("Rapid judge edits serialize whole-case saves and restore exactly the latest field values")
    func concurrentEditsPreserveLatestWholeCaseDraft() async throws {
        let root = try focusedTemporaryDirectory()
        defer { try? FileManager.default.removeItem(at: root) }
        let setup = try await focusedPersistenceSetup(root: root)
        var saves: [Task<Bool, Never>] = []

        for index in 0..<30 {
            let stepID = index.isMultiple(of: 2) ? "first-step" : "second-step"
            let note = "Judge input \(index) for \(stepID)"
            saves.append(Task {
                await setup.coordinator.saveStepDraft(
                    TestStepDraft(stepID: stepID, outcome: .pass, notes: note,
                                  confirmedAt: Date(timeIntervalSince1970: Double(index))),
                    testCaseID: "test-case"
                )
            })
        }
        for save in saves {
            #expect(await save.value)
        }

        let currentDraft = try #require(setup.coordinator.draftsByTestCaseID["test-case"])
        let restoredDraft = try #require(try await setup.store.draft(
            scope: setup.scope, testCaseID: "test-case", access: setup.access
        ))
        #expect(restoredDraft == currentDraft)
        #expect(restoredDraft.stepDraft(stepID: "first-step")?.draft.notes.hasPrefix("Judge input") == true)
        #expect(restoredDraft.stepDraft(stepID: "second-step")?.draft.notes.hasPrefix("Judge input") == true)
        #expect(restoredDraft.stepDraft(stepID: "first-step")?.draft.confirmedAt != nil)
        #expect(restoredDraft.stepDraft(stepID: "second-step")?.draft.confirmedAt != nil)
        #expect(!setup.coordinator.sessionContext.hasUnsavedDraft)
        #expect(setup.coordinator.failedDraftCaseIDs.isEmpty)
    }

    @Test("A failed save retains input and unsaved status until retry succeeds")
    func failedSaveRetainsDraftAndRetryClearsFailure() async throws {
        let root = try focusedTemporaryDirectory()
        defer { try? FileManager.default.removeItem(at: root) }
        let draftRoot = root.appending(path: "blocked-draft-root")
        try Data("A file cannot serve as the draft directory.".utf8).write(to: draftRoot)
        let setup = try await focusedPersistenceSetup(root: root, draftRoot: draftRoot)
        let draft = TestStepDraft(stepID: "first-step", outcome: .fail, notes: "Replace loose mounting bolt.", confirmedAt: Date(timeIntervalSince1970: 1_790_000_000))

        let firstSaveSucceeded = await setup.coordinator.saveStepDraft(draft, testCaseID: "test-case")
        #expect(!firstSaveSucceeded)
        #expect(setup.coordinator.sessionContext.hasUnsavedDraft)
        #expect(setup.coordinator.failedDraftCaseIDs == ["test-case"])
        let retained = try #require(setup.coordinator.draftsByTestCaseID["test-case"]?.stepDraft(stepID: "first-step")?.draft)
        #expect(retained.notes == draft.notes)
        #expect(retained.outcome == draft.outcome)
        #expect(retained.confirmedAt == nil)

        try FileManager.default.removeItem(at: draftRoot)
        #expect(await setup.coordinator.saveStepDraft(draft, testCaseID: "test-case"))
        #expect(!setup.coordinator.sessionContext.hasUnsavedDraft)
        #expect(setup.coordinator.failedDraftCaseIDs.isEmpty)
        let restored = try #require(try await setup.store.draft(scope: setup.scope, testCaseID: "test-case", access: setup.access))
        #expect(restored.stepDraft(stepID: "first-step")?.draft == draft)
    }

    @Test("Saving another test does not hide a failed draft that still needs retry")
    func otherSuccessfulSaveDoesNotClearFailure() async throws {
        let root = try focusedTemporaryDirectory()
        defer { try? FileManager.default.removeItem(at: root) }
        let setup = try await focusedPersistenceSetup(root: root)
        let persistence = TestCaseJSONPersistenceService(rootDirectory: root.appending(path: "drafts"))
        let blockedFile = await persistence.draftFileURL(context: setup.scope.persistenceContext, testCaseID: "test-case")
        try FileManager.default.createDirectory(at: blockedFile, withIntermediateDirectories: true)

        let firstSaved = await setup.coordinator.saveStepDraft(
            TestStepDraft(stepID: "first-step", outcome: .pass), testCaseID: "test-case"
        )
        #expect(!firstSaved)
        #expect(await setup.coordinator.saveStepDraft(
            TestStepDraft(stepID: "other-step", outcome: .pass), testCaseID: "other-case"
        ))
        #expect(setup.coordinator.sessionContext.hasUnsavedDraft)
        #expect(setup.coordinator.failedDraftCaseIDs == ["test-case"])

        try FileManager.default.removeItem(at: blockedFile)
        #expect(await setup.coordinator.retryFailedDraftSaves())
        #expect(!setup.coordinator.sessionContext.hasUnsavedDraft)
        #expect(setup.coordinator.failedDraftCaseIDs.isEmpty)
    }

    @Test("An unknown step cannot report a successful save")
    func unknownStepFailsWithoutDirtyingSession() async throws {
        let root = try focusedTemporaryDirectory()
        defer { try? FileManager.default.removeItem(at: root) }
        let setup = try await focusedPersistenceSetup(root: root)

        let saved = await setup.coordinator.saveStepDraft(TestStepDraft(stepID: "unknown", outcome: .pass), testCaseID: "test-case")
        #expect(!saved)
        #expect(!setup.coordinator.sessionContext.hasUnsavedDraft)
        #expect(setup.coordinator.failedDraftCaseIDs.isEmpty)
        #expect(setup.coordinator.draftsByTestCaseID["test-case"] == nil)
    }

    @Test("Global retry preserves whole-case values and reports failure until storage recovers")
    func globalRetryPreservesDraftAndVisibleFailure() async throws {
        let root = try focusedTemporaryDirectory()
        defer { try? FileManager.default.removeItem(at: root) }
        let draftRoot = root.appending(path: "blocked-draft-root")
        try Data("blocked".utf8).write(to: draftRoot)
        let setup = try await focusedPersistenceSetup(root: root, draftRoot: draftRoot)
        let first = TestStepDraft(stepID: "first-step", outcome: .fail, notes: "First distinct note.")
        let second = TestStepDraft(stepID: "second-step", outcome: .pass, notes: "Second distinct note.")
        _ = await setup.coordinator.saveStepDraft(first, testCaseID: "test-case")
        _ = await setup.coordinator.saveStepDraft(second, testCaseID: "test-case")

        let failedRetry = await setup.coordinator.retryFailedDraftSaves()
        #expect(!failedRetry)
        #expect(setup.coordinator.failedDraftCaseIDs == ["test-case"])
        #expect(setup.coordinator.sessionContext.hasUnsavedDraft)

        try FileManager.default.removeItem(at: draftRoot)
        #expect(await setup.coordinator.retryFailedDraftSaves())
        #expect(setup.coordinator.failedDraftCaseIDs.isEmpty)
        #expect(!setup.coordinator.sessionContext.hasUnsavedDraft)
        let restored = try #require(try await setup.store.draft(scope: setup.scope, testCaseID: "test-case", access: setup.access))
        #expect(restored.stepDraft(stepID: "first-step")?.draft == first)
        #expect(restored.stepDraft(stepID: "second-step")?.draft == second)
        #expect(restored.stepDraft(stepID: "first-step")?.draft.confirmedAt == nil)
    }
}

@MainActor
private func focusedPersistenceSetup(root: URL, draftRoot: URL? = nil) async throws -> (
    coordinator: InspectionExecutionCoordinator,
    store: InspectionEventStore,
    scope: InspectionSessionScope,
    access: InspectionEventUserAccess
) {
    let team = InspectionTeam(id: 42, school: "Solar Hawks", carNumber: "42", status: .ready,
                              currentStage: "Garage", lastSaved: "")
    let testCase = InspectionTestCase(id: "test-case", code: "TC", title: "Mounting", steps: [
        InspectionTestStep(id: "first-step", code: "1", displayOrder: 1, ruleReference: "T.1", title: "First",
                           type: .check, content: "Verify mounting.", requiredOutcome: true, requiresEvidence: false),
        InspectionTestStep(id: "second-step", code: "2", displayOrder: 2, ruleReference: "T.2", title: "Second",
                           type: .check, content: "Verify restraint.", requiredOutcome: true, requiresEvidence: false)
    ])
    let otherCase = InspectionTestCase(id: "other-case", code: "OTHER", displayOrder: 2, title: "Other test", steps: [
        InspectionTestStep(id: "other-step", code: "OTHER-1", ruleReference: "T.3", title: "Other step",
                           type: .check, content: "Verify other test.", requiredOutcome: true, requiresEvidence: false)
    ])
    let stage = InspectionStage(id: "garage", title: "Garage", displayOrder: 1, sections: [
        InspectionSection(id: "primary", title: "Primary", displayOrder: 1, testCases: [testCase, otherCase])
    ])
    let store = InspectionEventStore.appStore(
        eventID: "focus-event",
        teams: [team],
        stages: [stage],
        persistenceService: TestCaseJSONPersistenceService(rootDirectory: draftRoot ?? root.appending(path: "drafts")),
        teamCatalogService: LocalTeamCatalogService(rootDirectory: root.appending(path: "catalogs")),
        sessionCatalogService: LocalSessionCatalogService(rootDirectory: root.appending(path: "catalogs"))
    )
    let access = InspectionEventUserAccess.localJudgeAccess(eventID: "focus-event")
    let teamID = InspectionEventCoordinator.teamRecordID(team)
    let session = try await store.startSession(eventID: "focus-event", teamID: teamID,
                                              defaultStageID: stage.id, sessionID: "focus-session", access: access)
    let context = InspectionSessionContext(eventID: session.eventID, sessionID: session.id, team: team,
                                          activeStageID: stage.id, startedAt: session.startedAt, hasUnsavedDraft: false)
    let coordinator = InspectionExecutionCoordinator(sessionContext: context, stages: [stage], teams: [team], store: store, access: access)
    return (coordinator, store, InspectionSessionScope(eventID: session.eventID, teamID: teamID,
                                                     sessionID: session.id, stageID: stage.id), access)
}

private func focusedTemporaryDirectory() throws -> URL {
    let root = FileManager.default.temporaryDirectory.appending(path: "FocusedDraftPersistenceTests").appending(path: UUID().uuidString)
    try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
    return root
}
