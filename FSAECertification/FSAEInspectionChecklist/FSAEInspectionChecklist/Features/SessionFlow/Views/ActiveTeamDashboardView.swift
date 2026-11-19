//
//  ActiveTeamDashboardView.swift
//  FSAEInspectionChecklist
//

import SwiftUI

struct ActiveTeamDashboardView: View {
    #if DEBUG
    @AppStorage(InternalSettingsView.showDebugActionsKey) private var showDebugActions = false
    #endif
    fileprivate enum Strings {
        static var eyebrow: String { "Active Team".inspectionLocalized }
        static var overallProgress: String { "Overall progress".inspectionLocalized }
        static var openBlockers: String { "Open blockers".inspectionLocalized }
        static var currentStage: String { "Current Stage".inspectionLocalized }
        static var openStage: String { "Open Stage".inspectionLocalized }
        static var completeSession: String { "Complete Session".inspectionLocalized }
        static var completeSessionBlocked: String { "Resolve validation blockers before completing this session.".inspectionLocalized }
        static var debugActions: String { "Debug Actions".inspectionLocalized }
        static var debugMarkAllPassed: String { "Mark All Passed".inspectionLocalized }
        static var debugMarkAllIncomplete: String { "Mark All Incomplete".inspectionLocalized }
        static var stages: String { "Stages".inspectionLocalized }
        static var complete: String { "Complete".inspectionLocalized }
        static var noBlockers: String { "No blockers".inspectionLocalized }
    }

    @ObservedObject var coordinator: InspectionExecutionCoordinator
    let openStage: (String) -> Void
    let completeSession: () -> Void
    let debugMarkAllPassed: () -> Void
    let debugMarkAllIncomplete: () -> Void

    var body: some View {
        let team = coordinator.activeTeam
        let stages = coordinator.stages
        let progress = InspectionProgressSummary(stages: stages)
        let selectedStageID = coordinator.activeStage?.id

        ScreenShell(
            title: "\(team.carNumber) \(team.school)"
        ) {

            HStack(spacing: 12) {
                MetricTile(value: progress.percentageText, label: "\(Strings.overallProgress) · \(progress.countText)", systemImage: "chart.pie", color: .fsaeGreen)
                MetricTile(value: "\(stages.map(\.blockerCount).reduce(0, +))", label: Strings.openBlockers, systemImage: "exclamationmark.triangle", color: .fsaeAmber)
            }

            ContentPanel {
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(Strings.currentStage)
                            .font(.caption.weight(.bold))
                            .foregroundStyle(Color.fsaeSecondaryText)
                        Text(team.currentStage.inspectionLocalized)
                            .font(.title3.weight(.bold))
                            .foregroundStyle(Color.fsaeText)
                    }
                    Spacer()
                    StatusPill(text: team.lastSaved.inspectionLocalized, color: .fsaeBlue)
                }
                Button {
                    if let stageID = selectedStageID {
                        openStage(stageID)
                    }
                } label: {
                    Label(Strings.openStage, systemImage: "arrow.right.circle.fill")
                        .frame(maxWidth: .infinity)
                }
                .inspectionButtonStyle()
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
                .inspectionButtonStyle()
                .controlSize(.large)
                .disabled(!coordinator.canCompleteSession)
                .accessibilityHint(coordinator.canCompleteSession ? "" : Strings.completeSessionBlocked)
                .accessibilityIdentifier(
                    InspectionAccessibilityIdentifier.activeTeamDashboardCompleteSessionAction(teamID: team.id).rawValue
                )
                #if DEBUG
                if showDebugActions {
                    Text(Strings.debugActions)
                    Button {
                        debugMarkAllPassed()
                    } label: {
                        Label(Strings.debugMarkAllPassed, systemImage: "checkmark.circle")
                            .frame(maxWidth: .infinity)
                    }
                    .inspectionButtonStyle()
                    .accessibilityIdentifier(
                        InspectionAccessibilityIdentifier.activeTeamDashboardDebugMarkAllPassedAction(teamID: team.id).rawValue
                    )
                    Button {
                        debugMarkAllIncomplete()
                    } label: {
                        Label(Strings.debugMarkAllIncomplete, systemImage: "xmark.circle")
                            .frame(maxWidth: .infinity)
                    }
                    .inspectionButtonStyle()
                    .accessibilityIdentifier(
                        InspectionAccessibilityIdentifier.activeTeamDashboardDebugMarkAllIncompleteAction(teamID: team.id).rawValue
                    )
                }
                #endif
            }

            VStack(alignment: .leading, spacing: 12) {
                Text(Strings.stages)
                    .font(.headline)
                    .foregroundStyle(Color.fsaeText)
                ForEach(stages) { stage in
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
        .navigationTitle("\(team.carNumber) \(team.school)")
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
                    Text(state.stageTitle.inspectionLocalized)
                        .font(.headline)
                        .foregroundStyle(Color.fsaeText)
                    Text(state.stageSubtitle.inspectionLocalized)
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
            Text("\(state.progressText) · \(InspectionProgressSummary(completeStepCount: state.completeStepCount, totalStepCount: state.stepCount).percentageText)")
                .font(.caption)
                .foregroundStyle(Color.fsaeSecondaryText)
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
