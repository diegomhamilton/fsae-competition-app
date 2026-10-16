import Foundation
import Testing
@testable import FSAEInspectionChecklist

@MainActor
struct StageFocusCoordinatorTests {
    @Test("Advancement transitions occur once after confirmation and never after a failed gate")
    func transitionRequiresConfirmedResult() throws {
        let stage = focusStage()
        let coordinator = StageFocusCoordinator(stage: stage)
        #expect(coordinator.selectTestCase(id: "first", stepID: "first-1", draftsByTestCaseID: [:]))
        #expect(!coordinator.advanceAfterSave(draftsByTestCaseID: [:]))
        #expect(coordinator.advanceSequence == 0)
        let testCase = try #require(coordinator.activeTestCase)
        let draft = TestCaseDraft(testCase: testCase, stepDrafts: [
            TestStepDraft(stepID: "first-1", outcome: .pass, confirmedAt: .now)
        ])
        #expect(coordinator.advanceAfterSave(draftsByTestCaseID: ["first": draft]))
        #expect(coordinator.activeStepID == "first-2")
        #expect(coordinator.advanceSequence == 1)
        #expect(!coordinator.advanceAfterSave(draftsByTestCaseID: ["first": draft]))
        #expect(coordinator.advanceSequence == 1)
    }

    @Test("Judge starts the first incomplete step in official section, case and step order")
    func resumeFirstIncompleteInOfficialOrder() throws {
        let stage = focusStage()
        let coordinator = StageFocusCoordinator(stage: stage)
        let firstCase = try #require(coordinator.orderedTestCases.first)
        let drafts = [firstCase.id: TestCaseDraft(testCase: firstCase, stepDrafts: [
            TestStepDraft(stepID: "first-1", outcome: .pass, confirmedAt: .now)
        ])]

        #expect(coordinator.mode == .queue)
        #expect(coordinator.startNext(draftsByTestCaseID: drafts))
        #expect(coordinator.selectedTestCaseID == "first")
        #expect(coordinator.activeStepID == "first-2")
        #expect(coordinator.mode == .focus)
    }

    @Test("Judge advances to the next step and next test only after a complete result")
    func advanceFollowsOfficialOrderAndKeepsInvalidInputInPlace() throws {
        let coordinator = StageFocusCoordinator(stage: focusStage())
        #expect(coordinator.startNext(draftsByTestCaseID: [:]))
        #expect(!coordinator.advanceAfterSave(draftsByTestCaseID: [:]))
        #expect(coordinator.activeStepID == "first-1")

        let firstCase = try #require(coordinator.activeTestCase)
        var drafts = [firstCase.id: TestCaseDraft(testCase: firstCase, stepDrafts: [
            TestStepDraft(stepID: "first-1", outcome: .pass, confirmedAt: .now)
        ])]
        #expect(coordinator.advanceAfterSave(draftsByTestCaseID: drafts))
        #expect(coordinator.activeStepID == "first-2")

        drafts[firstCase.id]?.updateStepDraft(TestStepDraft(stepID: "first-2", outcome: .pass, confirmedAt: .now))
        #expect(coordinator.advanceAfterSave(draftsByTestCaseID: drafts))
        #expect(coordinator.selectedTestCaseID == "second")
        #expect(coordinator.activeStepID == "second-1")
    }

    @Test("Early review and queue both return the judge to the exact previous test and step")
    func reviewAndQueueRestoreExactSelection() {
        let coordinator = StageFocusCoordinator(stage: focusStage())
        #expect(coordinator.selectTestCase(id: "first", stepID: "first-2", draftsByTestCaseID: [:]))
        coordinator.showReview()
        #expect(coordinator.hasReviewReturnPoint)
        #expect(coordinator.backToTest())
        #expect(coordinator.selectedTestCaseID == "first")
        #expect(coordinator.activeStepID == "first-2")

        coordinator.showQueue()
        #expect(coordinator.mode == .queue)
        #expect(coordinator.backToTest())
        #expect(coordinator.activeStepID == "first-2")

        #expect(coordinator.selectTestCase(id: "second", draftsByTestCaseID: [:]))
        coordinator.showQueue()
        coordinator.showReview()
        #expect(coordinator.backToTest())
        #expect(coordinator.selectedTestCaseID == "second")
        #expect(coordinator.activeStepID == "second-1")
    }

    @Test("Automatic review after the last test has an explicit return to that last test")
    func automaticReviewReturnsToLastTest() throws {
        let coordinator = StageFocusCoordinator(stage: focusStage())
        #expect(coordinator.selectTestCase(id: "last", draftsByTestCaseID: [:]))
        let testCase = try #require(coordinator.activeTestCase)
        let drafts = [testCase.id: TestCaseDraft(testCase: testCase, stepDrafts: [
            TestStepDraft(stepID: "last-1", outcome: .pass, confirmedAt: .now)
        ])]

        #expect(coordinator.advanceAfterSave(draftsByTestCaseID: drafts))
        #expect(coordinator.mode == .review)
        #expect(coordinator.backToTest())
        #expect(coordinator.selectedTestCaseID == "last")
        #expect(coordinator.activeStepID == "last-1")
    }

    @Test("Editing a result from review returns to review and preserves its original return point")
    func reviewCorrectionReturnsToReview() throws {
        let coordinator = StageFocusCoordinator(stage: focusStage())
        #expect(coordinator.selectTestCase(id: "first", stepID: "first-2", draftsByTestCaseID: [:]))
        coordinator.showReview()
        #expect(coordinator.editResult(testCaseID: "second", stepID: "second-1"))
        #expect(coordinator.isEditingFromReview)
        coordinator.showQueue()
        #expect(coordinator.backToTest())
        #expect(coordinator.isEditingFromReview)
        let testCase = try #require(coordinator.activeTestCase)
        let drafts = [testCase.id: TestCaseDraft(testCase: testCase, stepDrafts: [
            TestStepDraft(stepID: "second-1", outcome: .fail, notes: "Harness mounting requires correction.", confirmedAt: .now)
        ])]

        #expect(coordinator.advanceAfterSave(draftsByTestCaseID: drafts))
        #expect(coordinator.mode == .review)
        #expect(!coordinator.isEditingFromReview)
        #expect(coordinator.backToTest())
        #expect(coordinator.selectedTestCaseID == "first")
        #expect(coordinator.activeStepID == "first-2")
    }

    @Test("Starting an already complete stage opens review with the last result available to return")
    func completedStageStartsInReview() throws {
        let stage = focusStage()
        let coordinator = StageFocusCoordinator(stage: stage)
        let drafts = Dictionary(uniqueKeysWithValues: coordinator.orderedTestCases.map { testCase in
            (testCase.id, TestCaseDraft(testCase: testCase, stepDrafts: testCase.orderedSteps.map {
                TestStepDraft(stepID: $0.id, outcome: .pass, confirmedAt: .now)
            }))
        })

        #expect(coordinator.startNext(draftsByTestCaseID: drafts))
        #expect(coordinator.mode == .review)
        #expect(coordinator.backToTest())
        #expect(coordinator.selectedTestCaseID == "last")
        #expect(coordinator.activeStepID == "last-1")
    }

    @Test("A valid autosaved draft still requires explicit confirmation before advance or final review")
    func autosavedResultIsNotConfirmedResult() throws {
        let coordinator = StageFocusCoordinator(stage: focusStage())
        let firstCase = try #require(coordinator.orderedTestCases.first)
        let enteredDraft = TestStepDraft(stepID: "first-1", outcome: .pass, notes: "Judge's preserved draft note.")
        let drafts = [firstCase.id: TestCaseDraft(testCase: firstCase, stepDrafts: [enteredDraft])]

        #expect(coordinator.startNext(draftsByTestCaseID: drafts))
        #expect(coordinator.activeStepID == "first-1")
        #expect(!coordinator.advanceAfterSave(draftsByTestCaseID: drafts))
        let issues = coordinator.focusedValidationIssues(draftsByTestCaseID: drafts)
        let unconfirmed = try #require(issues.first { $0.issueID == "unconfirmedResult.first-1" })
        #expect(unconfirmed.message == "Confirm this result.")
        #expect(drafts[firstCase.id]?.stepDraft(stepID: "first-1")?.draft == enteredDraft)
    }

    @Test("Measurements without a range still require numeric input in the focused flow")
    func measurementWithoutRangeRequiresNumber() {
        let testCase = InspectionTestCase(id: "measurement", code: "MEASURE", title: "Measured value", steps: [
            InspectionTestStep(id: "measurement-step", code: "M-1", ruleReference: "T.1", title: "Measured value",
                               type: .measurement, content: "Record the measured value.", requiredOutcome: true, requiresEvidence: false)
        ])
        let stage = InspectionStage(id: "measure", title: "Measure", displayOrder: 1, sections: [
            InspectionSection(id: "measure.section", title: "Measure", displayOrder: 1, testCases: [testCase])
        ])
        let coordinator = StageFocusCoordinator(stage: stage)
        for input in ["", "invalid"] {
            let drafts = [testCase.id: TestCaseDraft(testCase: testCase, stepDrafts: [
                TestStepDraft(stepID: "measurement-step", outcome: .pass, measurementInput: input, confirmedAt: .now)
            ])]
            #expect(coordinator.startNext(draftsByTestCaseID: drafts))
            #expect(!coordinator.advanceAfterSave(draftsByTestCaseID: drafts))
            #expect(!coordinator.focusedValidationIssues(draftsByTestCaseID: drafts).isEmpty)
        }
        let validDrafts = [testCase.id: TestCaseDraft(testCase: testCase, stepDrafts: [
            TestStepDraft(stepID: "measurement-step", outcome: .pass, measurementInput: "12.5", confirmedAt: .now)
        ])]
        #expect(coordinator.advanceAfterSave(draftsByTestCaseID: validDrafts))
        #expect(coordinator.mode == .review)
        #expect(coordinator.focusedValidationIssues(draftsByTestCaseID: validDrafts).isEmpty)
    }

    @Test("A confirmed flagged result may advance but must be resolved and reconfirmed before final submission")
    func flagBlocksReviewSubmissionWithoutBlockingAdvance() throws {
        let testCase = try #require(focusStage().orderedSections.last?.orderedTestCases.last)
        let stage = InspectionStage(id: "flag", title: "Flagged result", displayOrder: 1, sections: [
            InspectionSection(id: "flag.section", title: "Flag", displayOrder: 1, testCases: [testCase])
        ])
        let coordinator = StageFocusCoordinator(stage: stage)
        var stepDraft = TestStepDraft(stepID: "last-1", outcome: .pass, confirmedAt: .now, flaggedForReview: true)
        var drafts = [testCase.id: TestCaseDraft(testCase: testCase, stepDrafts: [stepDraft])]
        #expect(coordinator.selectTestCase(id: testCase.id, draftsByTestCaseID: drafts))
        #expect(coordinator.advanceAfterSave(draftsByTestCaseID: drafts))
        #expect(coordinator.mode == .review)
        #expect(coordinator.focusedValidationIssues(draftsByTestCaseID: drafts).map(\.issueID) == ["flaggedIssue.last-1"])

        stepDraft.flaggedForReview = false
        stepDraft.confirmedAt = nil
        drafts[testCase.id]?.updateStepDraft(stepDraft)
        #expect(coordinator.focusedValidationIssues(draftsByTestCaseID: drafts).map(\.issueID) == ["unconfirmedResult.last-1"])
        stepDraft.confirmedAt = .now
        drafts[testCase.id]?.updateStepDraft(stepDraft)
        #expect(coordinator.focusedValidationIssues(draftsByTestCaseID: drafts).isEmpty)
    }

    @Test("Focused evidence requirement gates advance and review without changing deferred evidence validation")
    func focusedEvidenceGate() async throws {
        let stage = focusStage(requiresEvidence: true)
        let directory = URL.temporaryDirectory.appending(path: "StageFocusEvidenceTests-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: directory) }
        let evidenceStore = FocusedResultEvidenceStore(baseDirectory: directory)
        let coordinator = StageFocusCoordinator(stage: stage) {
            FocusedResultEvidenceStore.localAssetAvailable($0, baseDirectory: directory)
        }
        #expect(coordinator.selectTestCase(id: "last", draftsByTestCaseID: [:]))
        let testCase = try #require(coordinator.activeTestCase)
        var draft = TestCaseDraft(testCase: testCase, stepDrafts: [
            TestStepDraft(stepID: "last-1", outcome: .pass, confirmedAt: .now)
        ])
        #expect(InspectionTestCaseViewState(testCase: testCase, draft: draft).validationSummary.isPassing)
        #expect(!coordinator.advanceAfterSave(draftsByTestCaseID: [testCase.id: draft]))
        #expect(coordinator.focusedValidationIssues(draftsByTestCaseID: [testCase.id: draft])
            .contains { $0.issueID == "missingRequiredEvidence.last-1" })

        draft.updateStepDraft(TestStepDraft(stepID: "last-1", outcome: .pass, evidenceAttachments: [
            EvidenceAttachmentMetadata(id: "track-photo", displayName: "Inspection photo", mediaType: .photo,
                                       source: .mockAttachment, createdAt: .now)
        ], confirmedAt: .now))
        #expect(!coordinator.advanceAfterSave(draftsByTestCaseID: [testCase.id: draft]))
        let imageData = try #require(Data(base64Encoded: "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+aBEkAAAAASUVORK5CYII="))
        let photo = try await evidenceStore.storePhoto(imageData)
        draft.updateStepDraft(TestStepDraft(stepID: "last-1", outcome: .pass, evidenceAttachments: [photo], confirmedAt: .now))
        #expect(coordinator.advanceAfterSave(draftsByTestCaseID: [testCase.id: draft]))
        #expect(coordinator.mode == .review)
    }

    @Test("Invalid navigation keeps the selection; an empty stage has no focus return point")
    func invalidAndEmptyNavigation() {
        let coordinator = StageFocusCoordinator(stage: focusStage())
        #expect(coordinator.startNext(draftsByTestCaseID: [:]))
        #expect(!coordinator.selectStep(id: "unknown"))
        #expect(!coordinator.selectTestCase(id: "unknown", draftsByTestCaseID: [:]))
        #expect(!coordinator.editResult(testCaseID: "first", stepID: "unknown"))
        #expect(coordinator.activeStepID == "first-1")

        let empty = StageFocusCoordinator(stage: InspectionStage(id: "empty", title: "Empty", displayOrder: 0))
        #expect(!empty.startNext(draftsByTestCaseID: [:]))
        empty.showReview()
        #expect(!empty.hasReviewReturnPoint)
        #expect(!empty.backToTest())
        #expect(empty.mode == .queue)
    }
}

private func focusStage(requiresEvidence: Bool = false) -> InspectionStage {
    func step(_ id: String, order: Int, evidence: Bool = false) -> InspectionTestStep {
        InspectionTestStep(id: id, code: id, displayOrder: order, ruleReference: "T.1", title: id,
                           type: .check, content: "Verify \(id).", requiredOutcome: true, requiresEvidence: evidence)
    }
    let first = InspectionTestCase(id: "first", code: "FIRST", displayOrder: 1, title: "First", steps: [
        step("first-2", order: 2), step("first-1", order: 1)
    ])
    let second = InspectionTestCase(id: "second", code: "SECOND", displayOrder: 2, title: "Second", steps: [step("second-1", order: 1)])
    let last = InspectionTestCase(id: "last", code: "LAST", displayOrder: 1, title: "Last", steps: [step("last-1", order: 1, evidence: requiresEvidence)])
    return InspectionStage(id: "focus", title: "Focus", displayOrder: 1, sections: [
        InspectionSection(id: "later", title: "Later", displayOrder: 2, testCases: [last]),
        InspectionSection(id: "earlier", title: "Earlier", displayOrder: 1, testCases: [second, first])
    ])
}
