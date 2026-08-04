//
//  FullStageView.swift
//  FSAEInspectionChecklist
//

import SwiftUI

struct FullStageView: View {
    fileprivate enum Strings {
        static let eyebrow = "Stage"
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
    let submitStage: () -> Void
    let openBlockingRoute: (FullStageBlockingRoute) -> Void
    @State private var expandedSectionIDs: Set<String> = []
    @State private var selectedTestCaseID: String?
    @State private var stepScrollPosition = ScrollPosition()
    @State private var activeStepID: String?
    @FocusState private var focusedNoteStepID: String?

    init(
        team: InspectionTeam,
        stage: InspectionStage,
        draftsByTestCaseID: [String: TestCaseDraft] = [:],
        openStepDetail: @escaping (InspectionTestStep) -> Void = { _ in },
        updateStepDraft: @escaping (TestStepDraft, String) -> Void = { _, _ in },
        submitStage: @escaping () -> Void = {},
        openBlockingRoute: @escaping (FullStageBlockingRoute) -> Void = { _ in }
    ) {
        self.team = team
        self.stage = stage
        self.draftsByTestCaseID = draftsByTestCaseID
        self.openStepDetail = openStepDetail
        self.updateStepDraft = updateStepDraft
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
            FullStageSummaryPanel(viewState: state)

            if let activeTestCaseViewState {
                ContentPanel {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(activeTestCaseViewState.code)
                                .font(.caption.weight(.bold))
                                .foregroundStyle(Color.fsaeSecondaryText)
                            Text(activeTestCaseViewState.title)
                                .font(.headline)
                                .foregroundStyle(Color.fsaeText)
                        }
                        Spacer()
                        Text(activeTestCaseViewState.progressSummary.fractionComplete, format: .percent)
                            .font(.caption.weight(.bold))
                            .foregroundStyle(Color.fsaeSecondaryText)
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
                    updateStepDraft: { stepDraft in
                        updateStepDraft(stepDraft, activeTestCaseViewState.id)
                    },
                    advanceFromStep: { stepID in
                        advanceToNextStep(after: stepID, steps: activeTestCaseViewState.steps)
                    },
                    scrollToStep: scrollToStep
                )
            }

            VStack(alignment: .leading, spacing: 18) {
                ForEach(state.sections) { section in
                    FullStageSectionBlock(
                        stageID: state.stageID,
                        section: section,
                        isExpanded: expandedSectionIDs.contains(section.id),
                        toggleExpanded: {
                            withAnimation(.snappy(duration: 0.28)) {
                                if expandedSectionIDs.contains(section.id) {
                                    expandedSectionIDs.remove(section.id)
                                } else {
                                    expandedSectionIDs.insert(section.id)
                                }
                            }
                        }
                    ) { testCase in
                        selectedTestCaseID = testCase.id
                    }
                }
            }

            FullStageValidationPanel(
                viewState: state,
                openBlockingRoute: openBlockingRoute
            )

            Button {
                submitStage()
            } label: {
                Label(Strings.submit, systemImage: "paperplane.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(!state.canSubmit)
            .opacity(state.canSubmit ? 1 : 0.7)
            .accessibilityLabel(state.canSubmit ? Strings.submitReady : Strings.submitBlocked)
            .accessibilityIdentifier(
                state.canSubmit
                ? InspectionAccessibilityIdentifier.testCaseStageSubmitAction(stageID: state.stageID).rawValue
                : InspectionAccessibilityIdentifier.testCaseStageBlockedSubmitAction(stageID: state.stageID).rawValue
            )
        }
        .navigationTitle(stage.title)
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
