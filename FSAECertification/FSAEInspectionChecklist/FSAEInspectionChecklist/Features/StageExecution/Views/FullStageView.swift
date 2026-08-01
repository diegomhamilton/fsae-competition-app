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
        static let submitReady = "Ready to submit"
        static let submitBlocked = "Submission blocked"
        static let submit = "Submit Stage"
        static let noBlockers = "No blockers found for this stage."
        static let openTestCase = "Open Test Case"
        static let complete = "Complete"
        static let blocked = "Blocked"
        static let noBlockersShort = "No blockers"
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
    let openTestCase: (InspectionTestCase) -> Void
    let submitStage: () -> Void
    let openBlockingRoute: (FullStageBlockingRoute) -> Void

    init(
        team: InspectionTeam,
        stage: InspectionStage,
        draftsByTestCaseID: [String: TestCaseDraft] = [:],
        openTestCase: @escaping (InspectionTestCase) -> Void = { _ in },
        submitStage: @escaping () -> Void = {},
        openBlockingRoute: @escaping (FullStageBlockingRoute) -> Void = { _ in }
    ) {
        self.team = team
        self.stage = stage
        self.draftsByTestCaseID = draftsByTestCaseID
        self.openTestCase = openTestCase
        self.submitStage = submitStage
        self.openBlockingRoute = openBlockingRoute
    }

    var body: some View {
        let state = FullStageViewState(stage: stage, draftsByTestCaseID: draftsByTestCaseID)

        ScreenShell(
            title: state.stageTitle,
            subtitle: subtitle
        ) {
            FullStageSummaryPanel(viewState: state)

            VStack(alignment: .leading, spacing: 18) {
                ForEach(state.sections) { section in
                    FullStageSectionBlock(
                        stageID: state.stageID,
                        section: section,
                        openTestCase: openTestCase
                    )
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
        .navigationTitle("Stage")
    }

    private var subtitle: String {
        "\(team.carNumber) \(team.school) · \(stage.subtitle.isEmpty ? Strings.localDraftFallback : stage.subtitle)"
    }
}

private struct FullStageSummaryPanel: View {
    let viewState: FullStageViewState

    var body: some View {
        ContentPanel {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(viewState.stageTitle)
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
    let openTestCase: (InspectionTestCase) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(section.title)
                .font(.headline)
                .foregroundStyle(Color.fsaeText)
                .accessibilityIdentifier(
                    InspectionAccessibilityIdentifier.testCaseStageSection(stageID: section.stageID, sectionID: section.id).rawValue
                )

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

    var body: some View {
        ContentPanel {
            HStack(alignment: .firstTextBaseline) {
                Text(FullStageView.Strings.validation)
                    .font(.headline)
                    .foregroundStyle(Color.fsaeText)
                    .accessibilityIdentifier(
                        InspectionAccessibilityIdentifier.testCaseStageValidationSummary(stageID: viewState.stageID).rawValue
                    )
                Spacer()
                StatusPill(
                    text: viewState.canSubmit ? FullStageView.Strings.submitReady : FullStageView.Strings.submitBlocked,
                    color: viewState.canSubmit ? .fsaeGreen : .fsaeRed
                )
            }

            if viewState.validationSummary.issues.isEmpty {
                Text(FullStageView.Strings.noBlockers)
                    .font(.footnote)
                    .foregroundStyle(Color.fsaeSecondaryText)
            } else {
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
                                Text("\(issue.stepTitle): \(issue.message)")
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
}
