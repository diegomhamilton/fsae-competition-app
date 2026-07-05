//
//  ActiveTeamDashboardView.swift
//  FSAEInspectionChecklist
//

import SwiftUI

struct ActiveTeamDashboardView: View {
    @ObservedObject var coordinator: InspectionExecutionCoordinator
    let openStage: (String) -> Void
    let requestTeamSwitch: () -> Void

    var body: some View {
        let team = coordinator.activeTeam
        let stageRows = coordinator.stages.map { stage in
            ActiveTeamStageRowState(
                stage: stage,
                draftsByTestCaseID: coordinator.draftsByTestCaseID
            )
        }
        let selectedStageID = coordinator.activeStage?.id

        ScreenShell(
            eyebrow: "SC-002 Active Team Dashboard",
            title: "\(team.carNumber) \(team.school)",
            subtitle: "Active team context, current stage, inspection progress, and the switch-team action."
        ) {
            ContentPanel {
                HStack(alignment: .top, spacing: 12) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("\(team.carNumber) \(team.school)")
                            .font(.title3.weight(.bold))
                            .foregroundStyle(Color.fsaeText)
                        HStack {
                            StatusPill(text: team.lastSaved, color: Color.fsaeBlue)
                            StatusPill(text: team.currentStage, color: Color.fsaeGray)
                        }
                    }
                    Spacer()
                    Button {
                        requestTeamSwitch()
                    } label: {
                        Label("Switch", systemImage: "person.2.badge.gearshape")
                            .labelStyle(.iconOnly)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                    .accessibilityLabel("Switch Team")
                }
            }

            HStack(spacing: 12) {
                MetricTile(value: "\(overallProgressPercent(stageRows: stageRows))%", label: "Overall progress", systemImage: "chart.pie", color: .fsaeGreen)
                MetricTile(value: "\(stageRows.map(\.blockerCount).reduce(0, +))", label: "Open blockers", systemImage: "exclamationmark.triangle", color: .fsaeAmber)
            }

            ContentPanel {
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Current Stage")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(Color.fsaeSecondaryText)
                        Text(team.currentStage)
                            .font(.title3.weight(.bold))
                            .foregroundStyle(Color.fsaeText)
                    }
                    Spacer()
                    StatusPill(text: team.lastSaved, color: .fsaeBlue)
                }
                Button {
                    if let stageID = selectedStageID {
                        openStage(stageID)
                    }
                } label: {
                    Label("Open Stage", systemImage: "arrow.right.circle.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }

            VStack(alignment: .leading, spacing: 12) {
                Text("Stages")
                    .font(.headline)
                    .foregroundStyle(Color.fsaeText)
                ForEach(stageRows) { stageRow in
                    Button {
                        openStage(stageRow.id)
                    } label: {
                        StageRow(stageRow: stageRow, isSelected: stageRow.id == selectedStageID)
                    }
                    .buttonStyle(.plain)
                }
            }

        }
        .navigationTitle("Team")
    }

    private func overallProgressPercent(stageRows: [ActiveTeamStageRowState]) -> Int {
        guard !stageRows.isEmpty else {
            return 0
        }

        return Int(stageRows.map(\.progressFraction).reduce(0, +) / Double(stageRows.count) * 100)
    }
}

struct ActiveTeamStageRowState: Identifiable, Equatable, Sendable {
    let stage: InspectionStage
    let completedStepCount: Int
    let totalStepCount: Int
    let blockerCount: Int

    var id: String {
        stage.id
    }

    var progressFraction: Double {
        guard totalStepCount > 0 else {
            return 0
        }

        return Double(completedStepCount) / Double(totalStepCount)
    }

    var status: ActiveTeamStageStatus {
        if totalStepCount == 0 {
            return .notStarted
        }

        if blockerCount > 0 {
            return .blocked
        }

        return completedStepCount == totalStepCount ? .complete : .inProgress
    }

    var statusText: String {
        switch status {
        case .notStarted, .inProgress, .complete:
            status.displayName
        case .blocked:
            switch blockerCount {
            case 1: "1 blocker"
            default: "\(blockerCount) blockers"
            }
        }
    }

    init(
        stage: InspectionStage,
        draftsByTestCaseID: [String: TestCaseDraft] = [:]
    ) {
        self.stage = stage

        let testCases = stage.orderedSections.flatMap(\.orderedTestCases)
        let summaries = testCases.map { testCase in
            InspectionTestCaseViewState(
                testCase: testCase,
                draft: draftsByTestCaseID[testCase.id] ?? TestCaseDraft(testCase: testCase)
            )
        }

        completedStepCount = summaries.map(\.progressSummary.completeStepCount).reduce(0, +)
        totalStepCount = summaries.map(\.progressSummary.totalStepCount).reduce(0, +)
        blockerCount = summaries.map(\.validationSummary.blockerCount).reduce(0, +)
    }
}

enum ActiveTeamStageStatus: Equatable, Sendable {
    case notStarted
    case inProgress
    case blocked
    case complete

    var displayName: String {
        switch self {
        case .notStarted: "Not Started"
        case .inProgress: "In Progress"
        case .blocked: "Blocked"
        case .complete: "Complete"
        }
    }

    var color: Color {
        switch self {
        case .notStarted: .fsaeGray
        case .inProgress: .fsaeBlue
        case .blocked: .fsaeAmber
        case .complete: .fsaeGreen
        }
    }
}

private struct StageRow: View {
    let stageRow: ActiveTeamStageRowState
    let isSelected: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 5) {
                    Text(stageRow.stage.title)
                        .font(.headline)
                        .foregroundStyle(Color.fsaeText)
                    Text(stageRow.stage.subtitle)
                        .font(.caption)
                        .foregroundStyle(Color.fsaeSecondaryText)
                }
                Spacer()
                StatusPill(text: stageRow.statusText, color: stageRow.status.color)
            }
            ProgressView(value: stageRow.progressFraction)
                .tint(stageRow.status == .complete ? Color.fsaeGreen : Color.fsaePrimary)
        }
        .padding(14)
        .background(Color.fsaeSurface, in: RoundedRectangle(cornerRadius: 8))
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(isSelected ? Color.fsaePrimary : Color.fsaeBorder, lineWidth: isSelected ? 2 : 1)
        }
    }
}
