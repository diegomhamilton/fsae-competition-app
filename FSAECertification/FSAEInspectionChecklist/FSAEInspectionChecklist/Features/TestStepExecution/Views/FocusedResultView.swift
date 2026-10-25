import PhotosUI
import QuickLook
import SwiftUI

/// One place to enter, amend, persist, and confirm the active step's result.
/// Requirements come from the step schema rather than a fixed visual state enum.
struct FocusedResultView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let state: InspectionTestCaseStepViewState
    let testCaseID: String
    let stageID: String
    let onConfirmedNext: () -> Void
    let onReview: () -> Void
    let isReviewCorrection: Bool
    let onConfirmationActivityChanged: (Bool) -> Void
    @Namespace private var editTransition
    @State private var form: FocusedResultForm
    @State private var showsPhotoPicker = false
    @State private var showsPhotoSources = false
    @State private var showsCamera = false
    @State private var pendingPhotoSource: FocusedPhotoSourcePicker.Source?
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
            HStack {
                Spacer()
                FocusedResultMenu(
                    form: form,
                    addNotes: {
                        form.beginNotes()
                        focusedField = .notes
                    },
                    addPhoto: { form.preparePhotoReplacement(nil); showsPhotoSources = true },
                    flagIssue: {
                        form.flagIssue()
                        focusedField = .notes
                    },
                    review: returnToReview
                )
            }
            VStack(alignment: .leading) {
                if form.isReady || form.isConfirming || form.didConfirm {
                    FocusedResultSummaryView(
                        form: form,
                        testCaseID: testCaseID,
                        editTransition: editTransition,
                        edit: {
                            form.editResult(includingEvidence: false)
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
                    HStack {
                        Spacer()
                        if form.isEditingOutcome || form.isEditingMeasurement {
                            Label(FocusedResultStrings.editMode, systemImage: "pencil")
                                .font(.headline)
                                .foregroundStyle(Color.fsaePrimary)
                                .padding(.horizontal, 16).frame(minHeight: 48)
                                .glassEffect(.regular, in: .capsule)
                                .matchedGeometryEffect(id: "result-edit", in: editTransition)
                                .accessibilityIdentifier("execution.result.edit-mode")
                        }
                    }
                    FocusedResultInputView(
                        form: form,
                        testCaseID: testCaseID,
                        focusedField: $focusedField,
                        addPhoto: { form.preparePhotoReplacement(nil); showsPhotoSources = true }
                    )
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            FocusedNotesEditor(form: form, testCaseID: testCaseID, focusedField: $focusedField)
            ForEach(form.draft.evidenceAttachments.filter { $0.localRelativePath != nil }) { attachment in
                FocusedEvidenceTile(attachment: attachment, view: {
                    Task {
                        previewPhotoURL = try? await FocusedResultEvidenceStore.shared.fileURL(for: attachment)
                        previewPhotoURLs = previewPhotoURL.map { [$0] } ?? []
                    }
                }, retake: {
                    form.preparePhotoReplacement(attachment.id)
                    showsPhotoSources = true
                })
            }
            if form.isImportingPhoto {
                ProgressView(FocusedResultStrings.photoLoading)
            }
            if form.photoFailed {
                Label(FocusedResultStrings.photoFailed, systemImage: "exclamationmark.triangle")
                    .modifier(FocusedResultMessageSurface())
            }
            if form.saveFailed {
                VStack(alignment: .leading, spacing: 12) {
                    Label(FocusedResultStrings.saveFailed, systemImage: "exclamationmark.triangle")
                        .accessibilityIdentifier("execution.save-failure")
                    Button(FocusedResultStrings.retry, systemImage: "arrow.clockwise") {
                        Task { await form.flush() }
                    }
                    .frame(minHeight: 44)
                    .accessibilityIdentifier("execution.save-retry")
                }
                .modifier(FocusedResultMessageSurface())
            }
            if form.attemptedCompletion && !form.validationIssues.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(form.validationIssues) { issue in
                        Label(issue.code == .missingRequiredEvidence ? FocusedResultStrings.requiredEvidence : issue.localizedMessage,
                              systemImage: "exclamationmark.circle")
                            .accessibilityIdentifier("execution.validation.\(issue.id)")
                    }
                }
                .modifier(FocusedResultMessageSurface())
            }
            if isReviewCorrection {
                Button(FocusedResultStrings.returnToReview, systemImage: "arrow.uturn.backward", action: returnToReview)
                    .frame(minHeight: 48)
                    .disabled(form.isImportingPhoto)
                    .accessibilityIdentifier("execution.review.return")
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.horizontal, 4)
        .padding(.vertical, 12)

        .animation(reduceMotion ? nil : .smooth(duration: 0.22), value: form.isReady)
        .animation(reduceMotion ? nil : .smooth(duration: 0.22), value: form.isEditingNotes)
        .controlSize(.large)
        .disabled(form.isConfirming || form.didConfirm)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("execution.result-component")
        .sheet(isPresented: $showsPhotoSources, onDismiss: openRequestedPhotoSource) {
            FocusedPhotoSourcePicker { source in
                pendingPhotoSource = source
                showsPhotoSources = false
            }
            .presentationDetents([.medium])
        }
        .fullScreenCover(isPresented: $showsCamera) {
            FocusedCameraCapture(
                captured: { data in
                    showsCamera = false
                    importCapturedPhoto(data)
                },
                cancelled: { showsCamera = false }
            )
            .ignoresSafeArea()
        }
        .onChange(of: form.isImportingPhoto) { _, importing in
            onConfirmationActivityChanged(importing)
        }
        .photosPicker(isPresented: $showsPhotoPicker, selection: $selectedPhoto, matching: .images)
        .quickLookPreview($previewPhotoURL, in: previewPhotoURLs)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button(FocusedResultStrings.done) {
                    focusedField = nil
                    form.finishInput()
                }
                .accessibilityIdentifier("execution.result.done")
            }
        }
        .onChange(of: focusedField) { previous, newValue in
            form.setNotesEditing(newValue == .notes)
            if previous != nil && newValue == nil { form.finishInput() }
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
            case "photo-sources":
                showsPhotoSources = true
            case "optional-notes":
                form.beginNotes()
                focusedField = .notes
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
            if ProcessInfo.processInfo.arguments.contains("-inspection-invalid-measurement") {
                form.selectOutcome(.pass)
                form.updateMeasurement("6.25")
            }
        }
        #endif
    }

    private func openRequestedPhotoSource() {
        guard let source = pendingPhotoSource else { return }
        pendingPhotoSource = nil
        switch source {
        case .camera: showsCamera = true
        case .library: showsPhotoPicker = true
        }
    }

    private func importCapturedPhoto(_ data: Data?) {
        guard !form.isImportingPhoto else { return }
        form.beginPhotoImport()
        Task {
            guard let data else { form.finishPhotoImport(nil); return }
            do {
                let attachment = try await FocusedResultEvidenceStore.shared.storePhoto(data, source: .camera)
                form.finishPhotoImport(attachment)
            } catch { form.finishPhotoImport(nil) }
        }
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

/// Floating status copy needs an opaque reading surface, just like the notes editor.
private struct FocusedResultMessageSurface: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.callout)
            .foregroundStyle(Color.fsaeRed)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(Color.fsaeSurface, in: .rect(cornerRadius: 20))
            .overlay { RoundedRectangle(cornerRadius: 20).stroke(Color.fsaeRed.opacity(0.25), lineWidth: 1) }
    }
}
