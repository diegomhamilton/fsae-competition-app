import SwiftUI

struct SessionSelectorView: View {
    @ObservedObject var coordinator: SessionSelectionCoordinator
    let selectTeam: (Int) -> Void

    var body: some View {
        ScreenShell(
            eyebrow: "SC-001 Session Selector",
            title: "Select Team",
            subtitle: "Judge-facing roster with clear resume status and current inspection position."
        ) {
            VStack(spacing: 12) {
                ForEach(coordinator.teams) { team in
                    Button {
                        selectTeam(team.id)
                    } label: {
                        HStack(spacing: 14) {
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Text(team.carNumber)
                                        .font(.title3.weight(.bold))
                                        .foregroundStyle(Color.fsaeText)
                                    Text(team.school)
                                        .font(.headline)
                                        .foregroundStyle(Color.fsaeText)
                                }
                                Text(team.currentStage)
                                    .font(.subheadline)
                                    .foregroundStyle(Color.fsaeSecondaryText)
                            }
                            Spacer()
                            VStack(alignment: .trailing, spacing: 8) {
                                StatusPill(text: team.status.rawValue, color: team.status.color)
                                Text(team.lastSaved)
                                    .font(.caption)
                                    .foregroundStyle(Color.fsaeSecondaryText)
                            }
                        }
                        .padding(16)
                        .background(Color.fsaeSurface, in: RoundedRectangle(cornerRadius: 8))
                        .overlay {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(coordinator.selectedTeamID == team.id ? Color.fsaePrimary : Color.fsaeBorder, lineWidth: coordinator.selectedTeamID == team.id ? 2 : 1)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }

            ContentPanel {
                Label("Resumable sessions stay visible as first-class rows.", systemImage: "arrow.clockwise")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.fsaeText)
                Text("This overview intentionally collapses loading, empty, and error states into the roster concept so the app structure stays easy to evaluate before state handling is designed.")
                    .font(.footnote)
                    .foregroundStyle(Color.fsaeSecondaryText)
            }
        }
        .navigationTitle("Sessions")
    }
}
