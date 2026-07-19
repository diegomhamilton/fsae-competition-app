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
                MetricTile(value: "\(overallProgressPercent(stages: stages))%", label: "Overall progress", systemImage: "chart.pie", color: .fsaeGreen)
                MetricTile(value: "\(stages.map(\.blockerCount).reduce(0, +))", label: "Open blockers", systemImage: "exclamationmark.triangle", color: .fsaeAmber)
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
                        openStage(stage.stageID)
                    } label: {
                        StageRow(
                            state: stage,
                            isSelected: stage.stageID == selectedStageID
                        )
                    }
                    .buttonStyle(.plain)
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
                    text: state.blockerText == "No blockers" ? "Complete" : state.blockerText,
                    color: state.blockerCount == 0 ? Color.fsaeGreen : Color.fsaeAmber
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
