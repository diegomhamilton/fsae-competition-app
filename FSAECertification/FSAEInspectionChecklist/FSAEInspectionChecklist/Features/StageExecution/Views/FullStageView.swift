//
//  FullStageView.swift
//  FSAEInspectionChecklist
//

import SwiftUI

struct FullStageView: View {
    fileprivate enum Strings {
        static let eyebrow = "Stage"
        static let queue = "Test queue"
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
    let openStepDetail: (InspectionTestStep) -> Void
    let updateStepDraft: (TestStepDraft, String) -> Void
    let hasUnsavedDraft: Bool
    let submitStage: () -> Void
    let openBlockingRoute: (FullStageBlockingRoute) -> Void
    @State private var expandedSectionIDs: Set<String> = []
    @State private var selectedTestCaseID: String?
    @State private var isReviewing = false
    @State private var showsQueue = false
    @State private var confirmation: String?
    @State private var stepScrollPosition = ScrollPosition()
    @State private var activeStepID: String?
    @FocusState private var focusedNoteStepID: String?

    init(
        team: InspectionTeam,
        stage: InspectionStage,
        draftsByTestCaseID: [String: TestCaseDraft] = [:],
        openStepDetail: @escaping (InspectionTestStep) -> Void = { _ in },
        updateStepDraft: @escaping (TestStepDraft, String) -> Void = { _, _ in },
        hasUnsavedDraft: Bool = false,
        submitStage: @escaping () -> Void = {},
        openBlockingRoute: @escaping (FullStageBlockingRoute) -> Void = { _ in }
    ) {
        self.team = team
        self.stage = stage
        self.draftsByTestCaseID = draftsByTestCaseID
        self.openStepDetail = openStepDetail
        self.updateStepDraft = updateStepDraft
        self.hasUnsavedDraft = hasUnsavedDraft
        self.submitStage = submitStage
        self.openBlockingRoute = openBlockingRoute
    }

    var body: some View {
        let state = FullStageViewState(
            stage: stage,
            team: team,
            draftsByTestCaseID: draftsByTestCaseID
        )

        ScreenShell(
            title: state.teamName,
            subtitle: subtitle
        ) {
            if let activeTestCaseViewState, !isReviewing {
                ContentPanel {
                    Text(activeTestCaseViewState.title).font(.headline)
                    Text("\(team.carNumber) · \(team.school) · \(testPosition) of \(state.testCaseCount)")
                        .font(.subheadline).foregroundStyle(Color.fsaeSecondaryText)
                    HStack {
                        Button(Strings.queue, systemImage: "list.bullet") { showsQueue = true }
                        Spacer()
                        Label(hasUnsavedDraft ? Strings.saving : Strings.saved,
                              systemImage: hasUnsavedDraft ? "clock" : "checkmark.circle")
                            .font(.caption)
                            .accessibilityIdentifier("execution.save-status")
                    }
                    if let confirmation {
                        Text(confirmation).font(.caption).foregroundStyle(Color.fsaeGreen)
                    }
                }
                TestCaseStepCarousel(
                    stageID: stage.id,
                    testCaseID: activeTestCaseViewState.id,
                    steps: activeTestCaseViewState.steps,
                    focusedNoteStepID: $focusedNoteStepID,
                    scrollPosition: $stepScrollPosition,
                    activeStepID: $activeStepID,
                    openStepDetail: openStepDetail,
                    updateStepDraft: { updateStepDraft($0, activeTestCaseViewState.id) },
                    advanceFromStep: { _ in },
                    scrollToStep: scrollToStep
                )
                Button {
                    advanceExecution(from: activeTestCaseViewState)
                } label: {
                    Label(Strings.next, systemImage: "arrow.right")
                        .frame(maxWidth: .infinity, minHeight: 48)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .frame(maxWidth: .infinity)
                .disabled(!activeTestCaseViewState.canAdvance(from: activeStepID, hasUnsavedDraft: hasUnsavedDraft))
                .accessibilityIdentifier("execution.save-next")
                Button(Strings.review) { isReviewing = true }
            } else {
                FullStageSummaryPanel(viewState: state)
                Text(isReviewing ? Strings.review : Strings.queue).font(.headline)
                if !isReviewing, let nextTest = orderedTestCases.first(where: {
                    !InspectionTestCaseViewState(testCase: $0, draft: draftsByTestCaseID[$0.id] ?? TestCaseDraft(testCase: $0)).validationSummary.isPassing
                }) ?? orderedTestCases.first {
                    Button(Strings.startNext, systemImage: "play.fill") { selectTestCase(nextTest.id) }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        .accessibilityIdentifier("execution.start-next")
                }
                VStack(alignment: .leading, spacing: 18) {
                    ForEach(state.sections) { section in
                        FullStageSectionBlock(
                            stageID: state.stageID,
                            section: section,
                            isExpanded: expandedSectionIDs.contains(section.id),
                            toggleExpanded: {
                                if expandedSectionIDs.contains(section.id) {
                                    expandedSectionIDs.remove(section.id)
                                } else {
                                    expandedSectionIDs.insert(section.id)
                                }
                            }
                        ) { testCase in
                            selectTestCase(testCase.id)
                        }
                    }
                }

                if isReviewing {
                    FullStageValidationPanel(viewState: state, openBlockingRoute: openBlockingRoute)
                    Button {
                        submitStage()
                    } label: {
                        Label(Strings.submit, systemImage: "paperplane.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .disabled(!state.canSubmit || hasUnsavedDraft)
                    .accessibilityLabel(state.canSubmit ? Strings.submitReady : Strings.submitBlocked)
                    .accessibilityIdentifier(
                        state.canSubmit
                        ? InspectionAccessibilityIdentifier.testCaseStageSubmitAction(stageID: state.stageID).rawValue
                        : InspectionAccessibilityIdentifier.testCaseStageBlockedSubmitAction(stageID: state.stageID).rawValue
                    )
                } else {
                    Button(Strings.review) { isReviewing = true }
                }
            }
        }
        .onChange(of: isReviewing) { _, reviewing in
            if reviewing {
                expandedSectionIDs = Set(state.sections.map(\.id))
            }
        }
        .sheet(isPresented: $showsQueue) {
            NavigationStack {
                StageChecklistView(team: team, stage: stage, draftsByTestCaseID: draftsByTestCaseID) { testCase in
                    selectTestCase(testCase.id)
                    showsQueue = false
                }
                .toolbar {
                    Button(Strings.done) { showsQueue = false }
                }
            }
        }
        .task(id: confirmation) {
            guard confirmation != nil else { return }
            try? await Task.sleep(for: .seconds(2))
            confirmation = nil
        }
        .navigationTitle(stage.title)
    }

    private var orderedTestCases: [InspectionTestCase] {
        stage.orderedSections.flatMap(\.orderedTestCases)
    }

    private var testPosition: Int {
        (orderedTestCases.firstIndex { $0.id == selectedTestCaseID } ?? 0) + 1
    }

    private func selectTestCase(_ id: String) {
        selectedTestCaseID = id
        isReviewing = false
        activeStepID = orderedTestCases.first { $0.id == id }?.orderedSteps.first?.id
        stepScrollPosition = ScrollPosition()
        focusedNoteStepID = nil
    }

    private func advanceExecution(from testCase: InspectionTestCaseViewState) {
        let index = testCase.steps.firstIndex { $0.id == activeStepID } ?? 0
        if testCase.steps.indices.contains(index + 1) {
            scrollToStep(testCase.steps[index + 1].id)
        } else if testCase.validationSummary.isPassing {
            let nextIndex = testPosition
            if orderedTestCases.indices.contains(nextIndex) {
                selectTestCase(orderedTestCases[nextIndex].id)
            } else {
                isReviewing = true
            }
        }
        confirmation = Strings.confirmation
    }

    private var subtitle: String {
        "\(stage.subtitle.isEmpty ? Strings.localDraftFallback : stage.subtitle)"
    }

    private var activeTestCaseViewState: InspectionTestCaseViewState? {
        guard let selectedTestCaseID,
              let testCase = stage.orderedSections
                .flatMap(\.orderedTestCases)
                .first(where: { $0.id == selectedTestCaseID }) else {
            return nil
        }

        return InspectionTestCaseViewState(
            testCase: testCase,
            draft: draftsByTestCaseID[testCase.id] ?? TestCaseDraft(testCase: testCase)
        )
    }

    private func advanceToNextStep(after stepID: String, steps: [InspectionTestCaseStepViewState]) {
        guard let currentIndex = steps.firstIndex(where: { $0.id == stepID }) else { return }
        let nextIndex = steps.index(after: currentIndex)
        guard steps.indices.contains(nextIndex) else { return }
        scrollToStep(steps[nextIndex].id)
    }

    private func scrollToStep(_ stepID: String) {
        focusedNoteStepID = nil
        activeStepID = stepID
        withAnimation(.snappy) {
            stepScrollPosition.scrollTo(id: stepID)
        }
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
