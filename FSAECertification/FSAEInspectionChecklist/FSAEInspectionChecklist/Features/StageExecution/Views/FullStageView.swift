import SwiftUI

struct FullStageView: View {
    fileprivate enum Strings {
        static let eyebrow = "Stage"
        static let queue = "Test queue"
        static let details = "View details"
        static let back = "Back to test"
        static let review = "Review results"
        static let next = "Save & next test"
        static let saved = "Saved on this device"
        static let saving = "Changes not yet saved"
        static let confirmation = "Result recorded"
        static let done = "Done"
        static let startNext = "Start next test"
        static let failed = "Failed outcome"
        static let sectionTitle = "Sections"
        static let progress = "Stage progress"
        static let validation = "Validation blockers"
        static let blockerCount = "blockers"
        static let expandBlockersHint = "Tap to show or hide validation blockers."
        static let submitReady = "Ready to submit"
        static let submitBlocked = "Submission blocked"
        static let submit = "Submit Stage"
        static let noBlockers = "No blockers found for this stage."
        static let openTestCase = "Open Test Case"
        static let complete = "Complete"
        static let blocked = "Blocked"
        static let noBlockersShort = "No blockers"
        static let testCase = "test case"
        static let testCases = "test cases"
        static let expandSectionHint = "Tap to expand or collapse this section."
        static let localDraftFallback = "Review ordered test cases and validation from local draft state."

        enum Accessibility {
            static let summary = "Stage summary"
            static let validationSummary = "Stage validation summary"
            static let submit = "Submit stage"
            static let blockedSubmit = "Submission blocked"
            static let energizedBadge = "Caution, energized dynamic test step"
        }
    }


    let team: InspectionTeam
    let stage: InspectionStage
    let draftsByTestCaseID: [String: TestCaseDraft]
    let saveStepDraft: @MainActor (TestStepDraft, String) async -> Bool
    let latestDrafts: @MainActor () -> [String: TestCaseDraft]
    let hasUnsavedDraft: Bool
    let hasFailedSave: @MainActor (String) -> Bool
    let retryFailedSaves: @MainActor () async -> Bool
    let submitStage: () -> Void
    @State private var focus: StageFocusCoordinator
    @State private var expandedSectionIDs: Set<String> = []
    @State private var showsQueue = false
    @State private var showsDetails = false
    @State private var showsTypeBadge = false
    @State private var isConfirmingResult = false

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
        submitStage: @escaping () -> Void = {}
    ) {
        let navigation = StageFocusCoordinator(stage: stage)
        if let initialTestCaseID {
            navigation.selectTestCase(id: initialTestCaseID, stepID: initialStepID, draftsByTestCaseID: draftsByTestCaseID)
        }
        if initialReview { navigation.showReview() }
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
    }

    var body: some View {
        Group {
            switch focus.mode {
            case .focus: focusedScreen
            case .queue: queueScreen()
            case .review: legacyReviewScreen
            }
        }
        .sheet(isPresented: $showsQueue) {
            NavigationStack {
                queueScreen(isDrawer: true) { showsQueue = false }
                    .navigationTitle(Strings.queue)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button(Strings.done) { showsQueue = false }
                                .accessibilityIdentifier("execution.queue.close")
                        }
                    }
            }
        }
        .sheet(isPresented: $showsDetails) {
            if let testCase = activeTestCaseState, let step = activeStepState {
                FocusedTestDetails(testCase: testCase, step: step, showsTypeBadge: $showsTypeBadge)
            }
        }
        .toolbar {
            if focus.mode == .focus {
                ToolbarItem(placement: .topBarLeading) {
                    Button { showsQueue = true } label: { Text(Strings.queue) }
                        .accessibilityIdentifier("execution.queue")
                        .disabled(isConfirmingResult)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showsDetails = true } label: { Text(Strings.details) }
                        .accessibilityIdentifier("execution.details.open")
                        .disabled(isConfirmingResult)
                }
            } else if focus.mode == .review, focus.hasReviewReturnPoint {
                ToolbarItem(placement: .topBarLeading) {
                    Button(Strings.back) { focus.backToTest() }
                        .accessibilityIdentifier("execution.review.back-to-test")
                }
            }
        }
        .navigationTitle(focus.mode == .focus ? "" : stage.title)
        .navigationBarTitleDisplayMode(focus.mode == .focus ? .inline : .large)
        .toolbar(focus.mode == .focus ? .hidden : .visible, for: .tabBar)
    }

    private var focusedScreen: some View {
        ScreenShell(title: stage.title, subtitle: "") {
            if focus.mode == .focus, let testCase = activeTestCaseState, let step = activeStepState {
                FocusExecutionContext(title: testCase.title, vehicle: team,
                    position: testPosition, total: focus.orderedTestCases.count)
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
    }

    private func queueScreen(isDrawer: Bool = false, close: @escaping () -> Void = {}) -> some View {
        StageQueueView(
            team: team, stage: stage, draftsByTestCaseID: draftsByTestCaseID,
            focusedIssues: focus.focusedValidationIssues(draftsByTestCaseID: draftsByTestCaseID),
            hasActiveSelection: !isDrawer && focus.hasActiveSelection,
            hasUnsavedDraft: hasUnsavedDraft,
            startNext: { focus.startNext(draftsByTestCaseID: latestDrafts()); close() },
            continueTest: { focus.backToTest(); close() },
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

    private var legacyReviewScreen: some View {
        let state = FullStageViewState(stage: stage, team: team, draftsByTestCaseID: draftsByTestCaseID)
        return ScreenShell(title: stage.title, subtitle: "") {
            FullStageSummaryPanel(viewState: state)
            Text(Strings.review).font(.headline)
            ForEach(state.sections) { section in
                FullStageSectionBlock(stageID: stage.id, section: section, isExpanded: true,
                    toggleExpanded: {}, openTestCase: { item in
                        if let stepID = item.orderedSteps.first?.id {
                            focus.editResult(testCaseID: item.id, stepID: stepID)
                        }
                    })
            }
            FullStageValidationPanel(viewState: state) { route in
                focus.editResult(testCaseID: route.testCaseID, stepID: route.stepID)
            }
            Button(Strings.submit, action: submitStage)
                .buttonStyle(.borderedProminent).controlSize(.large)
                .disabled(!focus.focusedValidationIssues(draftsByTestCaseID: draftsByTestCaseID).isEmpty || hasUnsavedDraft)
            recoveryNotice
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

private struct FullStageSummaryPanel: View {
    let viewState: FullStageViewState

    var body: some View {
        ContentPanel {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(viewState.teamName)
                        .font(.headline)
                        .foregroundStyle(Color.fsaeText)
                        .accessibilityIdentifier(
                            InspectionAccessibilityIdentifier.testCaseStageSummary(stageID: viewState.stageID).rawValue
                        )
                    Text("\(viewState.testCaseCount) test cases · \(viewState.blockerText)")
                        .font(.subheadline)
                        .foregroundStyle(Color.fsaeSecondaryText)
                }
                Spacer()
                StatusPill(
                    text: viewState.canSubmit ? FullStageView.Strings.submitReady : FullStageView.Strings.submitBlocked,
                    color: viewState.canSubmit ? .fsaeGreen : .fsaeAmber
                )
            }

            ProgressView(value: viewState.progressFraction)
                .tint(viewState.canSubmit ? Color.fsaeGreen : Color.fsaePrimary)
                .accessibilityLabel(FullStageView.Strings.progress)
                .accessibilityValue(viewState.progressText)
                .accessibilityIdentifier(
                    InspectionAccessibilityIdentifier.testCaseStageSummary(stageID: viewState.stageID).rawValue
                )

            HStack {
                Label(viewState.progressText, systemImage: "checkmark.circle")
                    .font(.caption)
                    .foregroundStyle(Color.fsaeSecondaryText)
                Spacer()
                Label(viewState.blockerText, systemImage: viewState.canSubmit ? "checkmark.seal" : "exclamationmark.triangle")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(viewState.canSubmit ? Color.fsaeGreen : Color.fsaeAmber)
            }
        }
    }
}

private struct FullStageSectionBlock: View {
    let stageID: String
    let section: FullStageSectionViewState
    let isExpanded: Bool
    let toggleExpanded: () -> Void
    let openTestCase: (InspectionTestCase) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Button(action: toggleExpanded) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(section.title)
                            .font(.headline)
                            .foregroundStyle(Color.fsaeText)
                        if !section.subtitle.isEmpty {
                            Text(section.subtitle)
                                .font(.subheadline)
                                .foregroundStyle(Color.fsaeSecondaryText)
                                .multilineTextAlignment(.leading)
                        }
                    }
                    Spacer()
                    HStack(spacing: 8) {
                        Text(testCaseCountLabel)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color.fsaeSecondaryText)
                        Image(systemName: "chevron.right")
                            .foregroundStyle(Color.fsaeSecondaryText)
                            .rotationEffect(.degrees(isExpanded ? 90 : 0))
                            .animation(.snappy(duration: 0.28), value: isExpanded)
                    }
                }
            }
            .buttonStyle(.plain)
            .accessibilityLabel("\(section.title)\(section.subtitle.isEmpty ? "" : ", \(section.subtitle)"), \(testCaseCountLabel)")
            .accessibilityHint(FullStageView.Strings.expandSectionHint)
            .accessibilityValue(isExpanded ? "Expanded" : "Collapsed")
            .accessibilityIdentifier(
                    InspectionAccessibilityIdentifier.testCaseStageSection(stageID: section.stageID, sectionID: section.id).rawValue
                )

            if isExpanded {
                VStack(spacing: 12) {
                    ForEach(section.testCases) { testCase in
                        Button {
                            openTestCase(testCase.testCase)
                        } label: {
                            FullStageTestCaseRow(stageID: stageID, testCase: testCase)
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier(
                            InspectionAccessibilityIdentifier.testCaseStageRow(stageID: stageID, testCaseID: testCase.id).rawValue
                        )
                    }
                }
            }
        }
    }

    private var testCaseCountLabel: String {
        let label = section.testCases.count == 1
            ? FullStageView.Strings.testCase
            : FullStageView.Strings.testCases
        return "\(section.testCases.count) \(label)"
    }
}

private struct FullStageTestCaseRow: View {
    let stageID: String
    let testCase: FullStageTestCaseViewState

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    ViewThatFits(in: .horizontal) {
                        HStack(spacing: 6) {
                            metadataLabels
                        }
                        VStack(alignment: .leading, spacing: 6) {
                            metadataLabels
                        }
                    }

                    Text(testCase.title)
                        .font(.headline)
                        .foregroundStyle(Color.fsaeText)
                        .multilineTextAlignment(.leading)

                    if let firstRule = testCase.ruleReferences.first {
                        Text(firstRule)
                            .font(.caption)
                            .foregroundStyle(Color.fsaeSecondaryText)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right.circle")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(Color.fsaePrimary)
                    .accessibilityLabel(FullStageView.Strings.openTestCase)
            }

            HStack {
                Label(testCase.progressSummary.completeStepCount.description + "/" + testCase.progressSummary.totalStepCount.description, systemImage: "checkmark.circle")
                    .font(.caption)
                    .foregroundStyle(Color.fsaeSecondaryText)
                Spacer()
                Label(testCase.validationSummary.isPassing ? FullStageView.Strings.noBlockersShort : "\(testCase.validationSummary.blockerCount) blockers", systemImage: testCase.validationSummary.isPassing ? "checkmark.seal" : "exclamationmark.triangle")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(testCase.validationSummary.isPassing ? Color.fsaeGreen : Color.fsaeAmber)
            }
        }
        .padding(14)
        .background(Color.fsaeSurface, in: RoundedRectangle(cornerRadius: 8))
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(testCase.validationSummary.isPassing ? Color.fsaeBorder : Color.fsaeAmber.opacity(0.55))
        }
    }

    private var metadataLabels: some View {
        Group {
            if testCase.state.steps.contains(where: { $0.outcome == .fail }) {
                StatusPill(text: FullStageView.Strings.failed, color: .fsaeRed)
            }
            Text(testCase.code)
                .font(.caption.weight(.bold))
                .foregroundStyle(Color.fsaeSecondaryText)
            StatusPill(text: testCase.validationSummary.isPassing ? FullStageView.Strings.complete : FullStageView.Strings.blocked, color: testCase.validationSummary.isPassing ? .fsaeGreen : .fsaeAmber)
                .accessibilityLabel(testCase.validationSummary.isPassing ? FullStageView.Strings.complete : FullStageView.Strings.blocked)
                .accessibilityIdentifier(
                    InspectionAccessibilityIdentifier.testCaseStageStatus(stageID: stageID, testCaseID: testCase.id).rawValue
                )
        }
    }
}

private struct FullStageValidationPanel: View {
    let viewState: FullStageViewState
    let openBlockingRoute: (FullStageBlockingRoute) -> Void
    @State private var isExpanded = false

    var body: some View {
        ContentPanel {
            Button {
                withAnimation(.snappy(duration: 0.28)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack(alignment: .firstTextBaseline) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(FullStageView.Strings.validation)
                            .font(.headline)
                            .foregroundStyle(Color.fsaeText)
                        Text(blockerCountLabel)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(viewState.canSubmit ? Color.fsaeGreen : Color.fsaeRed)
                    }
                    Spacer()
                    HStack(spacing: 8) {
                        StatusPill(
                            text: viewState.canSubmit ? FullStageView.Strings.submitReady : FullStageView.Strings.submitBlocked,
                            color: viewState.canSubmit ? .fsaeGreen : .fsaeRed
                        )
                        Image(systemName: "chevron.right")
                            .foregroundStyle(Color.fsaeSecondaryText)
                            .rotationEffect(.degrees(isExpanded ? 90 : 0))
                            .animation(.snappy(duration: 0.28), value: isExpanded)
                    }
                }
            }
            .buttonStyle(.plain)
            .accessibilityLabel(FullStageView.Strings.validation)
            .accessibilityHint(FullStageView.Strings.expandBlockersHint)
            .accessibilityValue(isExpanded ? "Expanded, \(blockerCountLabel)" : "Collapsed, \(blockerCountLabel)")
            .accessibilityIdentifier(
                InspectionAccessibilityIdentifier.testCaseStageValidationSummary(stageID: viewState.stageID).rawValue
            )

            if viewState.validationSummary.issues.isEmpty {
                Text(FullStageView.Strings.noBlockers)
                    .font(.footnote)
                    .foregroundStyle(Color.fsaeSecondaryText)
            } else if isExpanded {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(viewState.validationSummary.issues) { issue in
                        Button {
                            openBlockingRoute(
                                FullStageBlockingRoute(
                                    stageID: issue.stageID,
                                    testCaseID: issue.testCaseID,
                                    stepID: issue.stepID,
                                    issueID: issue.issueID
                                )
                            )
                        } label: {
                            Label {
                                Text("\(issue.testCaseCode) · \(issue.stepTitle): \(issue.message)")
                            } icon: {
                                Image(systemName: "exclamationmark.triangle.fill")
                            }
                        }
                        .buttonStyle(.plain)
                        .font(.footnote)
                        .foregroundStyle(Color.fsaeRed)
                        .accessibilityIdentifier(
                            InspectionAccessibilityIdentifier.testCaseStageValidationSummary(stageID: issue.stageID).rawValue
                        )
                    }
                }
            }
        }
    }

    private var blockerCountLabel: String {
        let count = viewState.validationSummary.blockerCount
        return "\(count) \(FullStageView.Strings.blockerCount)"
    }
}
