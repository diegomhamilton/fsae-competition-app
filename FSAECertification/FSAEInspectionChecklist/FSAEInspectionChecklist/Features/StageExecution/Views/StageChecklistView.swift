//
//  StageChecklistView.swift
//  FSAEInspectionChecklist
//

import SwiftUI

struct StageChecklistView: View {
    fileprivate enum Strings {
        static let eyebrow = "SC-003 Stage Checklist"
        static let sections = "Sections"
        static let testCases = "Test Cases"
        static let blockers = "Blockers"
        static let rules = "Rules"
        static let testCase = "test case"
        static let testCasePlural = "test cases"
        static let expandSectionHint = "Tap to expand or collapse this section."
        static let openTestCase = "Open Test Case"
        static let noRuleReferences = "No rule reference"
    }

    let team: InspectionTeam
    let stage: InspectionStage
    let draftsByTestCaseID: [String: TestCaseDraft]
    let selectTestCase: (InspectionTestCase) -> Void
    @State private var expandedSectionIDs: Set<String> = []

    init(
        team: InspectionTeam,
        stage: InspectionStage,
        draftsByTestCaseID: [String: TestCaseDraft] = [:],
        selectTestCase: @escaping (InspectionTestCase) -> Void
    ) {
        self.team = team
        self.stage = stage
        self.draftsByTestCaseID = draftsByTestCaseID
        self.selectTestCase = selectTestCase
    }

    var body: some View {
        let viewState = InspectionStageListViewState(
            stage: stage,
            draftsByTestCaseID: draftsByTestCaseID
        )

        ScreenShell(
            title: stage.title,
            subtitle: "\(team.carNumber) \(team.school) · ordered test cases grouped by inspection section."
        ) {
            StageMetrics(viewState: viewState)

            VStack(alignment: .leading, spacing: 18) {
                ForEach(viewState.sections) { section in
                    StageSectionBlock(
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
                        selectTestCase(testCase)
                    }
                }
            }
        }
        .accessibilityIdentifier(InspectionAccessibilityIdentifier.testCaseStageSummary(stageID: stage.id).rawValue)
        .navigationTitle(stage.title)
    }
}

private struct StageMetrics: View {
    let viewState: InspectionStageListViewState

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 12) {
                metricTiles
            }
            VStack(spacing: 12) {
                metricTiles
            }
        }
    }

    private var metricTiles: some View {
        Group {
            MetricTile(
                value: "\(viewState.sections.count)",
                label: StageChecklistView.Strings.sections,
                systemImage: "square.stack.3d.up",
                color: .fsaeBlue
            )
            MetricTile(
                value: "\(viewState.testCaseCount)",
                label: StageChecklistView.Strings.testCases,
                systemImage: "list.bullet.rectangle",
                color: .fsaeGreen
            )
            MetricTile(
                value: "\(viewState.blockerCount)",
                label: StageChecklistView.Strings.blockers,
                systemImage: "exclamationmark.triangle",
                color: viewState.blockerCount == 0 ? .fsaeGreen : .fsaeAmber
            )
        }
    }
}

private struct StageSectionBlock: View {
    let section: InspectionStageListSectionViewState
    let isExpanded: Bool
    let toggleExpanded: () -> Void
    let selectTestCase: (InspectionTestCase) -> Void

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
            .accessibilityHint(StageChecklistView.Strings.expandSectionHint)
            .accessibilityValue(isExpanded ? "Expanded" : "Collapsed")
            .accessibilityIdentifier(
                    InspectionAccessibilityIdentifier.testCaseStageSection(
                        stageID: section.rows.first?.stageID ?? "",
                        sectionID: section.id
                    ).rawValue
                )

            if isExpanded {
                VStack(spacing: 12) {
                    ForEach(section.rows) { row in
                        Button {
                            selectTestCase(row.testCase)
                        } label: {
                            StageTestCaseRow(row: row)
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier(
                            InspectionAccessibilityIdentifier.testCaseStageRow(
                                stageID: row.stageID,
                                testCaseID: row.id
                            ).rawValue
                        )
                    }
                }
            }
        }
    }

    private var testCaseCountLabel: String {
        let label = section.rows.count == 1
            ? StageChecklistView.Strings.testCase
            : StageChecklistView.Strings.testCasePlural
        return "\(section.rows.count) \(label)"
    }
}

private struct StageTestCaseRow: View {
    let row: InspectionStageTestCaseRowState

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

                    Text(row.title)
                        .font(.headline)
                        .foregroundStyle(Color.fsaeText)
                        .multilineTextAlignment(.leading)

                    ruleReferenceLine
                }

                Spacer()

                Image(systemName: "chevron.right.circle")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(Color.fsaePrimary)
                    .accessibilityLabel(StageChecklistView.Strings.openTestCase)
            }

            HStack {
                Label(row.progressText, systemImage: "checkmark.circle")
                    .font(.caption)
                    .foregroundStyle(Color.fsaeSecondaryText)
                Spacer()
                Label(row.blockerSummary, systemImage: row.blockerCount == 0 ? "checkmark.seal" : "exclamationmark.triangle")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(row.blockerCount == 0 ? Color.fsaeGreen : Color.fsaeAmber)
            }
        }
        .padding(14)
        .background(Color.fsaeSurface, in: RoundedRectangle(cornerRadius: 8))
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(row.blockerCount == 0 ? Color.fsaeBorder : Color.fsaeAmber.opacity(0.55))
        }
    }

    @ViewBuilder
    private var ruleReferenceLine: some View {
        if row.ruleReferences.isEmpty {
            Text(StageChecklistView.Strings.noRuleReferences)
                .font(.caption)
                .foregroundStyle(Color.fsaeSecondaryText)
        } else {
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text(StageChecklistView.Strings.rules)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color.fsaeSecondaryText)
                Text(row.ruleReferences.joined(separator: " • "))
                    .font(.caption)
                    .foregroundStyle(Color.fsaeSecondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var metadataLabels: some View {
        Group {
            Text(row.code)
                .font(.caption.weight(.bold))
                .foregroundStyle(Color.fsaeSecondaryText)
            StatusPill(text: row.status.displayName, color: row.status.color)
            ForEach(row.safetyBadges, id: \.self) { badge in
                StatusPill(text: badge.displayName, color: .fsaeRed)
                    .accessibilityLabel(badge.accessibilityLabel)
                    .accessibilityValue(badge.accessibilityLabel)
            }
        }
    }
}
