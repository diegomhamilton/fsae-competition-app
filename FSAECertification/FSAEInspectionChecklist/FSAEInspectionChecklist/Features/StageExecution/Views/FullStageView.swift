import SwiftUI

struct FullStageView: View {
    private enum Strings {
        static let queue = "Test queue"
        static let details = "View details"
        static let back = "Back to test"
        static let review = "Review stage"
        static let done = "Done"
    }

    let team: InspectionTeam
    let stage: InspectionStage
    let draftsByTestCaseID: [String: TestCaseDraft]
    let saveStepDraft: @MainActor (TestStepDraft, String) async -> Bool
    let latestDrafts: @MainActor () -> [String: TestCaseDraft]
    let hasUnsavedDraft: Bool
    let hasFailedSave: @MainActor (String) -> Bool
    let retryFailedSaves: @MainActor () async -> Bool
    let submitStage: @MainActor () async -> Bool
    let hasSubmittedStage: Bool
    @State private var focus: StageFocusCoordinator
    @State private var showsQueue = false
    @State private var showsDetails = false
    @State private var showsTypeBadge = false
    @State private var isConfirmingResult = false
    @State private var isSubmittingStage = false

    init(
        team: InspectionTeam,
        stage: InspectionStage,
        draftsByTestCaseID: [String: TestCaseDraft] = [:],
        saveStepDraft: @escaping @MainActor (TestStepDraft, String) async -> Bool = { _, _ in false },
        latestDrafts: (@MainActor () -> [String: TestCaseDraft])? = nil,
        hasUnsavedDraft: Bool = false,
        hasFailedSave: @escaping @MainActor (String) -> Bool = { _ in false },
        retryFailedSaves: @escaping @MainActor () async -> Bool = { false },
        initialTestCaseID: String? = nil,
        initialStepID: String? = nil,
        initialReview: Bool = false,
        initialDetails: Bool = false,
        initialQueue: Bool = false,
        initialDebugBadge: Bool = false,
        hasSubmittedStage: Bool = false,
        submitStage: @escaping @MainActor () async -> Bool = { false }
    ) {
        let navigation = StageFocusCoordinator(stage: stage)
        if let initialTestCaseID {
            navigation.selectTestCase(id: initialTestCaseID, stepID: initialStepID, draftsByTestCaseID: draftsByTestCaseID)
        }
        if initialReview { navigation.showReview() }
        #if DEBUG
        if ProcessInfo.processInfo.arguments.contains("-inspection-review-position") {
            navigation.overview.rememberReviewOffset(340)
            navigation.overview.lastCorrectedCaseID = "case-3"
        }
        if ProcessInfo.processInfo.arguments.contains("-inspection-queue-position") {
            navigation.selectTestCase(id: "case-8", draftsByTestCaseID: draftsByTestCaseID)
            if let first = stage.orderedSections.first { navigation.overview.toggleSection(first.id) }
        }
        #endif
        _focus = State(initialValue: navigation)
        _showsDetails = State(initialValue: initialDetails)
        _showsQueue = State(initialValue: initialQueue)
        _showsTypeBadge = State(initialValue: initialDebugBadge)
        self.team = team
        self.stage = stage
        self.draftsByTestCaseID = draftsByTestCaseID
        self.saveStepDraft = saveStepDraft
        self.latestDrafts = latestDrafts ?? { draftsByTestCaseID }
        self.hasUnsavedDraft = hasUnsavedDraft
        self.hasFailedSave = hasFailedSave
        self.retryFailedSaves = retryFailedSaves
        self.submitStage = submitStage
        self.hasSubmittedStage = hasSubmittedStage
    }

    var body: some View {
        queueScreen()
        .navigationTitle(stage.title)
        .navigationBarTitleDisplayMode(.large)
        .navigationDestination(item: Binding(
            get: { focus.route(after: nil) },
            set: { if $0 == nil { focus.popNavigation(after: nil) } }
        )) { route in
            StageExecutionDestination(route: route, coordinator: focus) { destination in
                executionScreen(for: destination)
            }
        }
        .sheet(isPresented: $showsQueue) {
            NavigationStack {
                queueScreen { showsQueue = false }
                    .navigationTitle(Strings.queue)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button(Strings.done) { showsQueue = false }
                                .inspectionButtonStyle()
                                .accessibilityIdentifier("execution.queue.close")
                        }
                        .sharedBackgroundVisibility(.hidden)
                    }
            }
        }
        .sheet(isPresented: $showsDetails) {
            if let testCase = activeTestCaseState, let step = activeStepState {
                FocusedTestDetails(testCase: testCase, step: step, showsTypeBadge: $showsTypeBadge)
            }
        }
    }

    private func executionScreen(for route: StageExecutionRoute) -> some View {
        ExecutionAdvanceTransition(sequence: focus.advanceSequence) {
            switch route.mode {
            case .focus: focusedScreen
            case .queue: Color.clear
            case .review: reviewScreen
            }
        }
        .navigationTitle(route.mode == .review ? Strings.review : "")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(route.mode == .focus ? .hidden : .visible, for: .tabBar)
        #if DEBUG
        .task {
            guard route.mode == .review else { return }
            switch InspectionSnapshotScenario.current?.rawValue {
            case "review-return": focus.backToTest()
            case "review-correction": focus.editResult(testCaseID: "case-1", stepID: "step-1")
            case "resolve-flag": focus.editResult(testCaseID: "case-3", stepID: "step-3")
            default: break
            }
        }
        #endif
    }

    private var focusedScreen: some View {
        FocusedExecutionLayout {
            if let testCase = activeTestCaseState {
                FocusExecutionContext(title: testCase.title, vehicle: team,
                    position: testPosition, total: focus.orderedTestCases.count)
            }
        } content: {
            if focus.mode == .focus, let testCase = activeTestCaseState, let step = activeStepState {
                if testCase.steps.count > 1 {
                    Menu {
                        ForEach(testCase.steps) { item in
                            Button(item.step.title) { focus.selectStep(id: item.id) }
                        }
                    } label: {
                        Text("Step \((testCase.steps.firstIndex { $0.id == step.id } ?? 0) + 1) of \(testCase.steps.count)")
                    }
                    .frame(minHeight: 48)
                    .accessibilityIdentifier("execution.step-selector")
                    .disabled(isConfirmingResult)
                }
                FocusedTestDescription(state: step, showsTypeBadge: showsTypeBadge)
            }
        } result: {
            if focus.mode == .focus, let testCase = activeTestCaseState, let step = activeStepState {
                FocusedResultView(
                    state: step, testCaseID: testCase.id, stageID: stage.id,
                    initialSaveFailure: hasFailedSave(testCase.id),
                    isReviewCorrection: focus.isEditingFromReview,
                    saveDraft: { await saveStepDraft($0, testCase.id) },
                    onConfirmedNext: {
                        // A delayed confirmation must not move a newly selected test.
                        guard focus.mode == .focus, focus.selectedTestCaseID == testCase.id,
                              focus.activeStepID == step.id else { return }
                        focus.advanceAfterSave(draftsByTestCaseID: latestDrafts())
                    },
                    onReview: {
                        guard focus.mode == .focus, focus.selectedTestCaseID == testCase.id,
                              focus.activeStepID == step.id else { return }
                        focus.showReview()
                    },
                    onConfirmationActivityChanged: { isConfirmingResult = $0 }
                )
                .id("\(testCase.id).\(step.id)")
            }

        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(Strings.details, systemImage: "info.circle") {
                    showsDetails = true
                }
                .labelStyle(.iconOnly)
                .inspectionButtonStyle()
                .accessibilityIdentifier("execution.details.open")
                .disabled(isConfirmingResult)
            }
            .sharedBackgroundVisibility(.hidden)
        }
    }

    private func queueScreen(close: @escaping () -> Void = {}) -> some View {
        StageQueueView(
            team: team, stage: stage, draftsByTestCaseID: draftsByTestCaseID,
            focusedIssues: focus.focusedValidationIssues(draftsByTestCaseID: draftsByTestCaseID),
            hasUnsavedDraft: hasUnsavedDraft,
            presentation: focus.overview,
            selectedTestCaseID: focus.selectedTestCaseID,
            startNext: { focus.continueInspection(draftsByTestCaseID: latestDrafts()); close() },
            review: { focus.showReview(); close() },
            selectTestCase: { id in
                focus.selectTestCase(id: id, draftsByTestCaseID: latestDrafts())
                close()
            }
        )
        .safeAreaInset(edge: .bottom) { recoveryNotice }
    }

    private var recoveryNotice: some View {
        DraftSaveRecoveryView(
            hasFailedSave: focus.orderedTestCases.contains { hasFailedSave($0.id) },
            retry: retryFailedSaves
        )
    }

    private var reviewScreen: some View {
        let issues = focus.focusedValidationIssues(draftsByTestCaseID: draftsByTestCaseID)
        let results = focus.orderedTestCases.map {
            draftsByTestCaseID[$0.id] ?? TestCaseDraft(testCase: $0)
        }
        return StageReviewView(
            team: team, stage: stage, draftsByTestCaseID: draftsByTestCaseID,
            focusedIssues: issues,
            presentation: focus.overview,
            editResult: { caseID, stepID in focus.editResult(testCaseID: caseID, stepID: stepID) }
        )
        .disabled(isSubmittingStage)
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 0) {
                recoveryNotice
                StageSubmissionAction(
                    canSubmit: !results.isEmpty && issues.isEmpty && !hasUnsavedDraft,
                    hasSubmitted: hasSubmittedStage,
                    results: results,
                    submit: submitStage,
                    onActivityChanged: { isSubmittingStage = $0 }
                )
            }
        }
    }

    private var activeTestCaseState: InspectionTestCaseViewState? {
        guard let testCase = focus.activeTestCase else { return nil }
        return InspectionTestCaseViewState(testCase: testCase,
            draft: draftsByTestCaseID[testCase.id] ?? TestCaseDraft(testCase: testCase))
    }

    private var activeStepState: InspectionTestCaseStepViewState? {
        activeTestCaseState?.steps.first { $0.id == focus.activeStepID }
    }

    private var testPosition: Int {
        (focus.orderedTestCases.firstIndex { $0.id == focus.selectedTestCaseID } ?? 0) + 1
    }
}
