import Foundation
import Testing
@testable import FSAEInspectionChecklist

@MainActor
struct FocusedResultFormTests {
    @Test("Unanswered results start neutral; failure requires a reason")
    func incompleteResultIsNeutral() async {
        let form = FocusedResultForm(state: state(), autosaveDelay: .seconds(60)) { _ in true }
        #expect(!form.attemptedCompletion)
        #expect(!form.isReady)
        form.selectOutcome(.fail)
        #expect(form.showsNotes)
        #expect(!form.isReady)
        form.updateNotes("Restraint is damaged")
        #expect(!form.isReady)
        form.finishInput()
        #expect(form.isReady)
        #expect(await form.confirm())
    }

    @Test("Measurement entry stays editable until Done, including comma decimal input")
    func measurementNeedsDone() async {
        let form = FocusedResultForm(state: state(type: .measurement), autosaveDelay: .seconds(60)) { _ in true }
        form.selectOutcome(.pass)
        form.updateMeasurement("4,25")
        #expect(form.draft.measurementInput == "4.25")
        #expect(form.draft.measurementValue?.value == Decimal(string: "4.25"))
        #expect(!form.isReady)
        form.finishInput()
        #expect(form.isReady)
        form.editResult()
        #expect(!form.isReady)
        form.selectOutcome(.fail)
        form.updateNotes("Over the criterion")
        form.finishInput()
        #expect(form.isReady)
        await form.flush()
    }

    @Test("A required photo needs a persisted image, rather than mock metadata")
    func photoRequiresPersistedImage() async {
        let mock = EvidenceAttachmentMetadata(id: "mock", displayName: "Mock", mediaType: .photo, source: .mockAttachment, createdAt: Date())
        let form = FocusedResultForm(state: state(requiresEvidence: true, attachments: [mock]), autosaveDelay: .seconds(60), evidenceAvailable: { $0.localRelativePath != nil }) { _ in true }
        form.selectOutcome(.pass)
        #expect(!form.isReady)
        #expect(form.validationIssues.contains { $0.code == .missingRequiredEvidence })
        form.beginPhotoImport()
        form.finishPhotoImport(EvidenceAttachmentMetadata(
            id: "photo", displayName: "Photo", mediaType: .photo, source: .photoLibrary,
            createdAt: Date(), localRelativePath: "Evidence/photo.png"
        ))
        #expect(form.isReady)
        await form.flush()
    }

    @Test("A failed write retains input, exposes retry, and prevents advance")
    func failureCanRetry() async {
        let probe = ResultRetryProbe()
        let form = FocusedResultForm(state: state(), autosaveDelay: .seconds(60)) { draft in
            probe.writes.append(draft)
            return probe.shouldSucceed
        }
        form.selectOutcome(.pass)
        #expect(!(await form.confirm()))
        #expect(form.saveFailed)
        #expect(!form.didConfirm)
        #expect(form.draft.outcome == .pass)
        #expect(form.draft.confirmedAt == nil)
        probe.shouldSucceed = true
        #expect(await form.confirm())
        #expect(!form.saveFailed)
        #expect(form.didConfirm)
        #expect(form.draft.confirmedAt != nil)
        #expect(probe.writes.count == 2)
    }

    @Test("A reopened failed draft exposes its error and retries without losing restored fields")
    func restoredSaveFailureCanRetry() async {
        let timestamp = Date(timeIntervalSince1970: 100)
        var writes: [TestStepDraft] = []
        let form = FocusedResultForm(
            state: state(outcome: .pass, notes: "Retained judge note", confirmedAt: timestamp),
            initialSaveFailure: true,
            autosaveDelay: .seconds(60)
        ) { draft in
            writes.append(draft)
            return true
        }
        #expect(form.saveFailed)
        #expect(form.hasUnsavedChanges)
        #expect(form.draft.notes == "Retained judge note")
        #expect(form.draft.confirmedAt == timestamp)
        #expect(await form.flush())
        #expect(!form.saveFailed)
        #expect(!form.hasUnsavedChanges)
        #expect(writes.count == 1)
        #expect(writes.first?.outcome == .pass)
        #expect(writes.first?.notes == "Retained judge note")
        #expect(writes.first?.confirmedAt == timestamp)
    }

    @Test("A photo-only result can be edited without adding artificial pass/fail requirements")
    func photoOnlyResultCanEdit() async {
        let photo = EvidenceAttachmentMetadata(
            id: "photo", displayName: "Photo", mediaType: .photo, source: .photoLibrary,
            createdAt: Date(), localRelativePath: "Evidence/photo.png"
        )
        let form = FocusedResultForm(state: state(requiredOutcome: false, requiresEvidence: true, attachments: [photo]), autosaveDelay: .seconds(60), evidenceAvailable: { $0.localRelativePath != nil }) { _ in true }
        #expect(form.isReady)
        form.editResult()
        #expect(!form.isReady)
        #expect(form.isEditingEvidence)
        form.finishInput()
        #expect(form.isReady)
        #expect(await form.confirm())
    }

    @Test("Flags survive draft saving and confirmation; resolving retains the result and notes")
    func reviewFlagIsDurableAndResolvable() async {
        var writes: [TestStepDraft] = []
        let form = FocusedResultForm(state: state(), autosaveDelay: .seconds(60)) { draft in
            writes.append(draft)
            return true
        }
        form.updateNotes("Attachment requires senior judge review")
        form.flagIssue()
        form.finishInput()
        #expect(form.draft.flaggedForReview == true)
        #expect(await form.flush())
        #expect(writes.last?.flaggedForReview == true)
        #expect(await form.confirm())
        #expect(writes.last?.flaggedForReview == true)
        #expect(form.draft.confirmedAt != nil)
        form.resolveFlag()
        #expect(form.draft.flaggedForReview == false)
        #expect(form.draft.outcome == .fail)
        #expect(form.draft.notes == "Attachment requires senior judge review")
        #expect(form.draft.confirmedAt == nil)
        #expect(await form.confirm())
        #expect(writes.last?.flaggedForReview == false)
        #expect(writes.last?.outcome == .fail)
    }

    @Test("Restored photo metadata with missing image bytes cannot satisfy evidence")
    func missingPhotoBytesBlockConfirmation() async {
        let photo = EvidenceAttachmentMetadata(
            id: "missing", displayName: "Missing photo", mediaType: .photo, source: .photoLibrary,
            createdAt: Date(), localRelativePath: "Evidence/missing-\(UUID().uuidString).png"
        )
        let form = FocusedResultForm(state: state(requiredOutcome: false, requiresEvidence: true, attachments: [photo])) { _ in true }
        #expect(!form.isReady)
        #expect(!(await form.confirm()))
    }

    @Test("Autosave remains a draft; explicit confirmation records a timestamp and edits invalidate it")
    func autosaveIsDistinctFromConfirmation() async {
        var writes: [TestStepDraft] = []
        let form = FocusedResultForm(state: state(), autosaveDelay: .seconds(60)) { draft in
            writes.append(draft)
            return true
        }
        form.selectOutcome(.pass)
        #expect(await form.flush())
        #expect(writes.last?.confirmedAt == nil)
        #expect(form.draft.confirmedAt == nil)
        #expect(await form.confirm())
        #expect(writes.last?.confirmedAt != nil)
        #expect(form.draft.confirmedAt != nil)
        form.updateNotes("New observation")
        #expect(form.draft.confirmedAt == nil)
        #expect(await form.flush())
        #expect(writes.last?.confirmedAt == nil)
    }

    @Test("Editing during an in-flight confirmation invalidates the candidate timestamp")
    func lateEditCancelsConfirmation() async {
        let recorder = SuspendedResultWriter()
        let form = FocusedResultForm(state: state(), autosaveDelay: .seconds(60)) { draft in await recorder.write(draft) }
        form.selectOutcome(.pass)
        let confirmation = Task { await form.confirm() }
        await recorder.waitForFirstWrite()
        form.updateNotes("Later observation")
        recorder.finishFirstWrite()
        #expect(!(await confirmation.value))
        #expect(!form.didConfirm)
        #expect(form.draft.confirmedAt == nil)
        #expect(recorder.writes.last?.notes == "Later observation")
        #expect(recorder.writes.last?.confirmedAt == nil)
    }

    @Test("Measurement steps without range metadata still require a numeric input")
    func unboundedMeasurementNeedsValue() async {
        let form = FocusedResultForm(state: state(type: .measurement, requiredOutcome: false, hasMeasurementRange: false), autosaveDelay: .seconds(60)) { _ in true }
        form.finishInput()
        #expect(!form.isReady)
        form.updateMeasurement("invalid")
        form.finishInput()
        #expect(!form.isReady)
        form.updateMeasurement("12.5")
        form.finishInput()
        #expect(form.isReady)
        await form.flush()
    }

    @Test("A slow save cannot overwrite rapid later edits")
    func serialWritesRetainLatestKeystrokes() async {
        let recorder = SuspendedResultWriter()
        let form = FocusedResultForm(state: state(), autosaveDelay: .seconds(60)) { draft in
            await recorder.write(draft)
        }
        form.updateNotes("First edit")
        let flushing = Task { await form.flush() }
        await recorder.waitForFirstWrite()
        form.updateNotes("Latest edit")
        form.selectOutcome(.pass)
        recorder.finishFirstWrite()
        #expect(await flushing.value)
        #expect(recorder.writes.map(\.notes) == ["First edit", "Latest edit"])
        #expect(recorder.writes.last?.outcome == .pass)
        #expect(!form.hasUnsavedChanges)
    }

    @Test("Confirmation waits for acknowledged persistence and rejects duplicate taps")
    func confirmationWaitsForSave() async {
        let recorder = SuspendedResultWriter()
        let form = FocusedResultForm(state: state(), autosaveDelay: .seconds(60)) { draft in await recorder.write(draft) }
        form.selectOutcome(.pass)
        let confirmation = Task { await form.confirm() }
        await recorder.waitForFirstWrite()
        #expect(form.isConfirming)
        #expect(!form.didConfirm)
        #expect(!(await form.confirm()))
        recorder.finishFirstWrite()
        #expect(await confirmation.value)
        #expect(form.didConfirm)
    }

    private func state(
        type: InspectionTestStepType = .check,
        requiredOutcome: Bool = true,
        requiresEvidence: Bool = false,
        hasMeasurementRange: Bool = true,
        attachments: [EvidenceAttachmentMetadata] = [],
        outcome: InspectionOutcome = .pending,
        notes: String = "",
        confirmedAt: Date? = nil
    ) -> InspectionTestCaseStepViewState {
        let range = MeasurementRange(unit: .seconds, minimum: 0, maximum: 5, maximumFractionDigits: 2)
        return InspectionTestCaseStepViewState(
            displayOrder: 1,
            step: InspectionTestStep(
                id: "focus-step", code: "FOCUS", ruleReference: "IN.1", title: "Focused test",
                type: type, content: "Judge criterion", requiredOutcome: requiredOutcome,
                requiresEvidence: requiresEvidence, measurementRange: type == .measurement && hasMeasurementRange ? range : nil
            ),
            inheritedSafetyBadges: [], outcome: outcome, notes: notes, measurementInput: "", evidenceAttachments: attachments, confirmedAt: confirmedAt
        )
    }
}

@MainActor
private final class SuspendedResultWriter {
    private(set) var writes: [TestStepDraft] = []
    private var firstWrite: CheckedContinuation<Bool, Never>?
    private var started: CheckedContinuation<Void, Never>?

    func write(_ draft: TestStepDraft) async -> Bool {
        writes.append(draft)
        if writes.count > 1 { return true }
        return await withCheckedContinuation { continuation in
            firstWrite = continuation
            started?.resume()
            started = nil
        }
    }

    func waitForFirstWrite() async {
        if firstWrite != nil { return }
        await withCheckedContinuation { started = $0 }
    }

    func finishFirstWrite() {
        firstWrite?.resume(returning: true)
        firstWrite = nil
    }
}

@MainActor
private final class ResultRetryProbe {
    var shouldSucceed = false
    var writes: [TestStepDraft] = []
}
