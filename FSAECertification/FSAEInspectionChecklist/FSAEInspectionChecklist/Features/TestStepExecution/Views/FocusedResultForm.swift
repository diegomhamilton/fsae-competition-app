import Foundation
import Observation

/// Owns judge input until it is durably saved. Parent projections never overwrite
/// newer local keystrokes while an earlier draft is being written.
@Observable
@MainActor
final class FocusedResultForm {
    let step: InspectionTestStep
    private(set) var draft: TestStepDraft
    private(set) var attemptedCompletion = false
    private(set) var isConfirming = false
    private(set) var didConfirm = false
    private(set) var saveFailed = false
    private(set) var photoFailed = false
    private(set) var isImportingPhoto = false
    private(set) var isEditingMeasurement = false
    private(set) var isEditingNotes = false
    private(set) var isEditingOutcome = false
    private(set) var isEditingEvidence = false
    var showsOptionalNotes = false

    @ObservationIgnored private let saveDraft: @MainActor (TestStepDraft) async -> Bool
    @ObservationIgnored private let autosaveDelay: Duration
    @ObservationIgnored private let evidenceAvailable: @MainActor (EvidenceAttachmentMetadata) -> Bool
    @ObservationIgnored private var revision = 0
    @ObservationIgnored private var savedRevision = 0
    @ObservationIgnored private var debounceTask: Task<Void, Never>?
    @ObservationIgnored private var writerTask: Task<Bool, Never>?
    @ObservationIgnored private var writerID: UUID?
    @ObservationIgnored private var confirmationTimestamp: Date?

    init(
        state: InspectionTestCaseStepViewState,
        initialSaveFailure: Bool = false,
        autosaveDelay: Duration = .milliseconds(300),
        evidenceAvailable: @escaping @MainActor (EvidenceAttachmentMetadata) -> Bool = { FocusedResultEvidenceStore.localAssetAvailable($0) },
        saveDraft: @escaping @MainActor (TestStepDraft) async -> Bool
    ) {
        step = state.step
        draft = TestStepDraft(
            stepID: state.id,
            outcome: state.outcome,
            notes: state.notes,
            measurementInput: state.measurementInput,
            measurementValue: state.step.measurementInput(from: state.measurementInput).measurementValue,
            evidenceAttachments: state.evidenceAttachments,
            confirmedAt: state.confirmedAt,
            flaggedForReview: state.flaggedForReview
        )
        self.autosaveDelay = autosaveDelay
        self.saveDraft = saveDraft
        self.evidenceAvailable = evidenceAvailable
        saveFailed = initialSaveFailure
        revision = initialSaveFailure ? 1 : 0
        isEditingMeasurement = state.step.type == .measurement && state.measurementInput.isEmpty
        isEditingNotes = state.outcome == .fail && state.notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var validationIssues: [InspectionTestCaseValidationIssue] {
        var issues = InspectionTestCaseStepViewState(
            displayOrder: step.displayOrder,
            step: step,
            inheritedSafetyBadges: [],
            outcome: draft.outcome,
            notes: draft.notes,
            measurementInput: draft.measurementInput,
            evidenceAttachments: draft.evidenceAttachments
        ).validationIssues
        if step.type == .measurement && step.measurementRange == nil {
            let input = draft.measurementInput.trimmingCharacters(in: .whitespacesAndNewlines)
            if input.isEmpty {
                issues.append(InspectionTestCaseValidationIssue(stepID: step.id, stepTitle: step.title, code: .missingMeasurement))
            } else if Decimal(string: input, locale: Locale(identifier: "en_US_POSIX")) == nil {
                issues.append(InspectionTestCaseValidationIssue(stepID: step.id, stepTitle: step.title, code: .invalidMeasurement))
            }
        }
        if step.requiresEvidence && !draft.evidenceAttachments.contains(where: evidenceAvailable) {
            issues.append(InspectionTestCaseValidationIssue(stepID: step.id, stepTitle: step.title, code: .missingRequiredEvidence))
        }
        return issues
    }

    var isReady: Bool {
        validationIssues.isEmpty && !isEditingMeasurement && !isEditingNotes && !isEditingOutcome && !isEditingEvidence && !isImportingPhoto
    }

    var showsNotes: Bool {
        draft.outcome == .fail || showsOptionalNotes || !draft.notes.isEmpty
    }

    var hasUnsavedChanges: Bool { revision > savedRevision }

    func selectOutcome(_ outcome: InspectionOutcome) {
        draft.outcome = outcome
        isEditingOutcome = false
        if outcome == .fail && draft.notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            isEditingNotes = true
        } else if outcome != .fail {
            isEditingNotes = false
        }
        changed()
    }

    func updateNotes(_ notes: String) {
        draft.notes = notes
        changed()
    }

    func updateMeasurement(_ input: String) {
        let normalized = input.replacing(",", with: ".")
        let parsed = step.measurementInput(from: normalized)
        draft.measurementInput = normalized
        draft.measurementValue = parsed.measurementValue
        isEditingMeasurement = true
        changed()
    }

    func editResult() {
        isEditingOutcome = step.requiredOutcome
        if step.type == .measurement { isEditingMeasurement = true }
        if step.requiresEvidence { isEditingEvidence = true }
        if !step.requiredOutcome && step.type != .measurement && !step.requiresEvidence { beginNotes() }
        attemptedCompletion = false
    }

    func beginNotes() {
        showsOptionalNotes = true
        isEditingNotes = true
    }

    func setNotesEditing(_ editing: Bool) { isEditingNotes = editing }

    func finishInput() {
        attemptedCompletion = true
        isEditingMeasurement = false
        isEditingNotes = false
        isEditingOutcome = false
        isEditingEvidence = false
    }

    func rerun() {
        draft.outcome = .pending
        draft.measurementInput = ""
        draft.measurementValue = nil
        attemptedCompletion = false
        isEditingMeasurement = step.type == .measurement
        isEditingNotes = false
        isEditingEvidence = false
        isEditingOutcome = false
        didConfirm = false
        changed()
    }

    func flagIssue() {
        draft.flaggedForReview = true
        selectOutcome(.fail)
        beginNotes()
    }

    func resolveFlag() {
        draft.flaggedForReview = false
        changed()
    }

    func beginPhotoImport() {
        isImportingPhoto = true
        photoFailed = false
    }

    func finishPhotoImport(_ attachment: EvidenceAttachmentMetadata?) {
        isImportingPhoto = false
        guard let attachment else {
            photoFailed = true
            return
        }
        draft.evidenceAttachments.append(attachment)
        isEditingEvidence = false
        changed()
    }

    func removeAttachment(_ id: String) {
        draft.evidenceAttachments.removeAll { $0.id == id }
        changed()
    }

    /// Serial writes are important: a slow older save must not finish after, and
    /// overwrite, a later edit. Every worker catches up to the newest revision.
    @discardableResult
    func flush() async -> Bool {
        debounceTask?.cancel()
        debounceTask = nil
        while hasUnsavedChanges {
            let task: Task<Bool, Never>
            let id: UUID
            if let currentTask = writerTask, let currentID = writerID {
                task = currentTask
                id = currentID
            } else {
                id = UUID()
                task = Task { await writePendingRevisions() }
                writerID = id
                writerTask = task
            }
            let succeeded = await task.value
            if writerID == id {
                writerTask = nil
                writerID = nil
            }
            if !succeeded { return false }
        }
        return !saveFailed
    }

    /// Confirmation always performs a save, even when a draft was restored or
    /// already autosaved. It never advances on an unacknowledged write.
    func confirm() async -> Bool {
        guard !isConfirming else { return false }
        attemptedCompletion = true
        guard isReady else { return false }
        isConfirming = true
        didConfirm = false
        draft.confirmedAt = nil
        confirmationTimestamp = Date()
        revision += 1
        let succeeded = await flush()
        isConfirming = false
        confirmationTimestamp = nil
        didConfirm = succeeded && draft.confirmedAt != nil
        return didConfirm
    }

    private func changed() {
        revision += 1
        draft.confirmedAt = nil
        confirmationTimestamp = nil
        didConfirm = false
        debounceTask?.cancel()
        debounceTask = Task {
            do { try await Task.sleep(for: autosaveDelay) }
            catch { return }
            // Detach the delay task before flushing, so flush does not cancel
            // the active writer through the debounce task's cancellation.
            debounceTask = nil
            await flush()
        }
    }

    private func writePendingRevisions() async -> Bool {
        while hasUnsavedChanges {
            let writingRevision = revision
            var writingDraft = draft
            if let confirmationTimestamp { writingDraft.confirmedAt = confirmationTimestamp }
            guard await saveDraft(writingDraft) else {
                saveFailed = true
                return false
            }
            if writingRevision == revision { draft.confirmedAt = writingDraft.confirmedAt }
            savedRevision = writingRevision
            saveFailed = false
        }
        debounceTask?.cancel()
        debounceTask = nil
        return true
    }
}
