//
//  ActiveTeamDashboardView.swift
//  FSAEInspectionChecklist
//

import SwiftUI

struct ActiveTeamDashboardView: View {
    fileprivate enum Strings {
        static let eyebrow = "Active Team"
        static let subtitle = "Review the locally stored session and stage progress."
        static let overallProgress = "Overall progress"
        static let openBlockers = "Open blockers"
        static let currentStage = "Current Stage"
        static let openStage = "Open Stage"
        static let completeSession = "Complete Session"
        static let completeSessionBlocked = "Resolve validation blockers before completing this session."
        static let debugMarkAllPassed = "Mark All Passed"
        static let debugMarkAllIncomplete = "Mark All Incomplete"
        static let stages = "Stages"
        static let complete = "Complete"
        static let noBlockers = "No blockers"
    }

    @ObservedObject var coordinator: InspectionExecutionCoordinator
    let openStage: (String) -> Void
    let completeSession: () -> Void
    let debugMarkAllPassed: () -> Void
    let debugMarkAllIncomplete: () -> Void

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
            title: "\(team.carNumber) \(team.school)",
            subtitle: Strings.subtitle
        ) {
            ContentPanel {
                HStack(alignment: .center, spacing: 12) {
                    Text("\(team.carNumber) \(team.school)")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(Color.fsaeText)
                }
            }

            HStack(spacing: 12) {
                MetricTile(value: "\(overallProgressPercent(stages: stages))%", label: Strings.overallProgress, systemImage: "chart.pie", color: .fsaeGreen)
                MetricTile(value: "\(stages.map(\.blockerCount).reduce(0, +))", label: Strings.openBlockers, systemImage: "exclamationmark.triangle", color: .fsaeAmber)
            }

            ContentPanel {
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(Strings.currentStage)
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
                    Label(Strings.openStage, systemImage: "arrow.right.circle.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .accessibilityIdentifier(
                    InspectionAccessibilityIdentifier.activeTeamDashboardOpenCurrentStageAction(
                        teamID: team.id,
                        stageID: selectedStageID ?? "none"
                    ).rawValue
                )
                Button {
                    completeSession()
                } label: {
                    Label(Strings.completeSession, systemImage: "checkmark.seal.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                .disabled(!coordinator.canCompleteSession)
                .accessibilityHint(coordinator.canCompleteSession ? "" : Strings.completeSessionBlocked)
                .accessibilityIdentifier(
                    InspectionAccessibilityIdentifier.activeTeamDashboardCompleteSessionAction(teamID: team.id).rawValue
                )
                #if DEBUG
                Text("Debug Actions")
                Button {
                    debugMarkAllPassed()
                } label: {
                    Label(Strings.debugMarkAllPassed, systemImage: "checkmark.circle")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                .accessibilityIdentifier(
                    InspectionAccessibilityIdentifier.activeTeamDashboardDebugMarkAllPassedAction(teamID: team.id).rawValue
                )
                Button {
                    debugMarkAllIncomplete()
                } label: {
                    Label(Strings.debugMarkAllIncomplete, systemImage: "xmark.circle")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                .accessibilityIdentifier(
                    InspectionAccessibilityIdentifier.activeTeamDashboardDebugMarkAllIncompleteAction(teamID: team.id).rawValue
                )
                #endif
            }

            VStack(alignment: .leading, spacing: 12) {
                Text(Strings.stages)
                    .font(.headline)
                    .foregroundStyle(Color.fsaeText)
                ForEach(stageRows) { stageRow in
                    Button {
                        openStage(stage.stageID)
                    } label: {
                        StageRow(
                            teamID: team.id,
                            state: stage,
                            isSelected: stage.stageID == selectedStageID
                        )
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier(
                        InspectionAccessibilityIdentifier.activeTeamDashboardStageRow(
                            teamID: team.id,
                            stageID: stage.stageID
                        ).rawValue
                    )
                }
            }

        }
        .navigationTitle("Team")
    }

    private func overallProgressPercent(stages: [FullStageViewState]) -> Int {
        guard !stages.isEmpty else {
            return 0
        }

        return Int(stages.map(\.progressFraction).reduce(0, +) / Double(stages.count) * 100)
    }
}

private struct StageRow: View {
    let teamID: Int
    let state: FullStageViewState
    let isSelected: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 5) {
                    Text(state.stageTitle)
                        .font(.headline)
                        .foregroundStyle(Color.fsaeText)
                    Text(state.stageSubtitle)
                        .font(.caption)
                        .foregroundStyle(Color.fsaeSecondaryText)
                }
                Spacer()
                StatusPill(
                    text: state.blockerText == ActiveTeamDashboardView.Strings.noBlockers ? ActiveTeamDashboardView.Strings.complete : state.blockerText,
                    color: state.blockerCount == 0 ? Color.fsaeGreen : Color.fsaeAmber
                )
                .accessibilityIdentifier(
                    InspectionAccessibilityIdentifier.activeTeamDashboardStageStatus(
                        teamID: teamID,
                        stageID: state.stageID
                    ).rawValue
                )
            }
            ProgressView(value: state.progressFraction)
                .tint(state.blockerCount == 0 ? Color.fsaeGreen : Color.fsaePrimary)
        }
        .padding(14)
        .background(Color.fsaeSurface, in: RoundedRectangle(cornerRadius: 8))
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(isSelected ? Color.fsaePrimary : Color.fsaeBorder, lineWidth: isSelected ? 2 : 1)
        }
    }
}
