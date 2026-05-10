import SwiftUI

struct ActiveTeamDashboardView: View {
    let team: InspectionTeam
    let stages: [InspectionStage]
    @Binding var selectedStage: InspectionStage
    @Binding var selectedScreen: ProposedScreen
    @Binding var showingSwitchConfirmation: Bool

    var body: some View {
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
                        showingSwitchConfirmation = true
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
                MetricTile(value: "\(Int(stages.map(\.progress).reduce(0, +) / Double(stages.count) * 100))%", label: "Overall progress", systemImage: "chart.pie", color: .fsaeGreen)
                MetricTile(value: "\(stages.map(\.requiredOpenItems).reduce(0, +))", label: "Open blockers", systemImage: "exclamationmark.triangle", color: .fsaeAmber)
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
                    selectedScreen = .stageChecklist
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
                ForEach(stages) { stage in
                    Button {
                        selectedStage = stage
                        selectedScreen = .stageChecklist
                    } label: {
                        StageRow(stage: stage, isSelected: stage == selectedStage)
                    }
                    .buttonStyle(.plain)
                }
            }

        }
        .navigationTitle("Team")
    }
}

private struct StageRow: View {
    let stage: InspectionStage
    let isSelected: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 5) {
                    Text(stage.title)
                        .font(.headline)
                        .foregroundStyle(Color.fsaeText)
                    Text(stage.subtitle)
                        .font(.caption)
                        .foregroundStyle(Color.fsaeSecondaryText)
                }
                Spacer()
                StatusPill(text: stage.requiredOpenItems == 0 ? "Complete" : "\(stage.requiredOpenItems) blocker", color: stage.requiredOpenItems == 0 ? Color.fsaeGreen : Color.fsaeAmber)
            }
            ProgressView(value: stage.progress)
                .tint(stage.requiredOpenItems == 0 ? Color.fsaeGreen : Color.fsaePrimary)
        }
        .padding(14)
        .background(Color.fsaeSurface, in: RoundedRectangle(cornerRadius: 8))
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(isSelected ? Color.fsaePrimary : Color.fsaeBorder, lineWidth: isSelected ? 2 : 1)
        }
    }
}
