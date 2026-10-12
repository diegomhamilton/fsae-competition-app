import PhotosUI
import QuickLook
import SwiftUI

/// One place to enter, amend, persist, and confirm the active step's result.
/// Requirements come from the step schema rather than a fixed visual state enum.
struct FocusedResultView: View {
    let state: InspectionTestCaseStepViewState
    let testCaseID: String
    let stageID: String
    let onConfirmedNext: () -> Void
    let onReview: () -> Void
    let isReviewCorrection: Bool
    let onConfirmationActivityChanged: (Bool) -> Void
    @State private var form: FocusedResultForm
    @State private var showsPhotoPicker = false
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var previewPhotoURL: URL?
    @State private var previewPhotoURLs: [URL] = []
    @State private var confirmationTask: Task<Void, Never>?
    #if DEBUG
    @State private var preparedSnapshot = false
    #endif
    @FocusState private var focusedField: FocusedResultField?

    init(
        state: InspectionTestCaseStepViewState,
        testCaseID: String,
        stageID: String,
        initialSaveFailure: Bool = false,
        isReviewCorrection: Bool = false,
        saveDraft: @escaping @MainActor (TestStepDraft) async -> Bool,
        onConfirmedNext: @escaping () -> Void,
        onReview: @escaping () -> Void,
        onConfirmationActivityChanged: @escaping (Bool) -> Void = { _ in }
    ) {
        self.state = state
        self.testCaseID = testCaseID
        self.stageID = stageID
        self.onConfirmedNext = onConfirmedNext
        self.onReview = onReview
        self.isReviewCorrection = isReviewCorrection
        self.onConfirmationActivityChanged = onConfirmationActivityChanged
        #if DEBUG
        let snapshotScenario = InspectionSnapshotScenario.current?.rawValue
        _form = State(initialValue: FocusedResultForm(state: state, initialSaveFailure: initialSaveFailure, saveDraft: { draft in
            if snapshotScenario == "save-failure" { return false }
            if snapshotScenario == "saving" {
                do { try await Task.sleep(for: .seconds(90)) }
                catch { return false }
            }
            return await saveDraft(draft)
        }))
        #else
        _form = State(initialValue: FocusedResultForm(state: state, initialSaveFailure: initialSaveFailure, saveDraft: saveDraft))
        #endif
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .bottom) {
                VStack(alignment: .leading) {
                    if form.isReady || form.isConfirming || form.didConfirm {
                        FocusedResultSummaryView(
                            form: form,
                            testCaseID: testCaseID,
                            edit: {
                                form.editResult()
                                if state.step.type == .measurement { focusedField = .measurement }
                            },
                            viewEvidence: {
                                Task {
                                    var urls: [URL] = []
                                    for attachment in form.draft.evidenceAttachments where attachment.localRelativePath != nil {
                                        if let url = try? await FocusedResultEvidenceStore.shared.fileURL(for: attachment) { urls.append(url) }
                                    }
                                    previewPhotoURLs = urls
                                    previewPhotoURL = urls.first
                                }
                            }
                        )
                        FocusedResultActionView(form: form, confirm: confirm, title: isReviewCorrection ? FocusedResultStrings.saveReview : FocusedResultStrings.saveNext)
                    } else {
                        FocusedResultInputView(
                            form: form,
                            testCaseID: testCaseID,
                            focusedField: $focusedField,
                            addPhoto: { showsPhotoPicker = true }
                        )
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                FocusedResultMenu(
                    form: form,
                    addNotes: {
                        form.beginNotes()
                        focusedField = .notes
                    },
                    addPhoto: { showsPhotoPicker = true },
                    flagIssue: {
                        form.flagIssue()
                        focusedField = .notes
                    },
                    review: returnToReview
                )
            }
            if form.isImportingPhoto {
                ProgressView(FocusedResultStrings.photoLoading)
            }
            if form.photoFailed {
                Text(FocusedResultStrings.photoFailed)
                    .font(.callout)
                    .foregroundStyle(Color.fsaeRed)
            }
            if form.saveFailed {
                Label(FocusedResultStrings.saveFailed, systemImage: "exclamationmark.triangle")
                    .font(.callout)
                    .foregroundStyle(Color.fsaeRed)
                    .accessibilityIdentifier("execution.save-failure")
                Button(FocusedResultStrings.retry, systemImage: "arrow.clockwise") {
                    Task { await form.flush() }
                }
                .accessibilityIdentifier("execution.save-retry")
            }
            if form.attemptedCompletion {
                ForEach(form.validationIssues) { issue in
                    Text(issue.code == .missingRequiredEvidence ? FocusedResultStrings.requiredEvidence : issue.localizedMessage)
                        .font(.callout)
                        .foregroundStyle(Color.fsaeRed)
                        .accessibilityIdentifier("execution.validation.\(issue.id)")
                }
            }
            if isReviewCorrection {
                Button(FocusedResultStrings.returnToReview, systemImage: "arrow.uturn.backward", action: returnToReview)
                    .frame(minHeight: 48)
                    .disabled(form.isImportingPhoto)
                    .accessibilityIdentifier("execution.review.return")
            }
        }
        .controlSize(.large)
        .disabled(form.isConfirming || form.didConfirm)
        .accessibilityIdentifier("execution.result-component")
        .photosPicker(isPresented: $showsPhotoPicker, selection: $selectedPhoto, matching: .images)
        .quickLookPreview($previewPhotoURL, in: previewPhotoURLs)
        .onChange(of: focusedField) { _, newValue in
            form.setNotesEditing(newValue == .notes)
        }
        .onChange(of: selectedPhoto) { _, newValue in
            guard let newValue, !form.isImportingPhoto else { return }
            form.beginPhotoImport()
            Task {
                defer { selectedPhoto = nil }
                do {
                    guard let data = try await newValue.loadTransferable(type: Data.self) else {
                        form.finishPhotoImport(nil)
                        return
                    }
                    let attachment = try await FocusedResultEvidenceStore.shared.storePhoto(data)
                    form.finishPhotoImport(attachment)
                } catch {
                    form.finishPhotoImport(nil)
                }
            }
        }
        .onDisappear {
            confirmationTask?.cancel()
            confirmationTask = nil
            onConfirmationActivityChanged(false)
            Task { await form.flush() }
        }
        #if DEBUG
        .task {
            guard !preparedSnapshot else { return }
            preparedSnapshot = true
            switch InspectionSnapshotScenario.current?.rawValue {
            case "save-failure":
                onConfirmationActivityChanged(true)
                _ = await form.confirm()
                onConfirmationActivityChanged(false)
            case "saving", "confirmed":
                form.selectOutcome(.pass)
                onConfirmationActivityChanged(true)
                _ = await form.confirm()
                if !form.didConfirm { onConfirmationActivityChanged(false) }
            case "optional-notes":
                form.beginNotes()
            case "auto-advance":
                if state.id == "step-3" {
                    form.selectOutcome(.pass)
                    confirm()
                }
            case "measurement":
                focusedField = .measurement
            case "measurement-ready":
                form.selectOutcome(.pass)
                form.updateMeasurement("4.25")
                form.finishInput()
                await form.flush()
            case "fail-input":
                form.selectOutcome(.fail)
                form.updateNotes("")
                form.setNotesEditing(true)
            default:
                break
            }
        }
        #endif
    }

    private func confirm() {
        guard confirmationTask == nil else { return }
        focusedField = nil
        onConfirmationActivityChanged(true)
        confirmationTask = Task {
            guard await form.confirm() else {
                confirmationTask = nil
                onConfirmationActivityChanged(false)
                return
            }
            do { try await Task.sleep(for: .milliseconds(550)) }
            catch {
                confirmationTask = nil
                onConfirmationActivityChanged(false)
                return
            }
            guard !Task.isCancelled else {
                confirmationTask = nil
                onConfirmationActivityChanged(false)
                return
            }
            onConfirmedNext()
            confirmationTask = nil
            onConfirmationActivityChanged(false)
        }
    }

    private func returnToReview() {
        focusedField = nil
        Task {
            if await form.flush() { onReview() }
        }
    }
}
