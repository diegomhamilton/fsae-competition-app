//
//  SessionSelectorView.swift
//  FSAEInspectionChecklist
//

import SwiftUI

struct SessionSelectorView: View {
    fileprivate enum Strings {
        static let eyebrow = "Session Selection"
        static let title = "Select Team"
        static let subtitle = "Start or resume a locally stored inspection session for the current event."
        static let resumeAvailable = "Resume available"
        static let blocked = "Blocked"
        static let localDrafts = "Local drafts are saved by team and session."
        static let localDraftsDetail = "Choose a team to restore its latest stage, blockers, notes, measurements, and evidence metadata without mixing inspection work between teams."
    }

    @ObservedObject var coordinator: SessionSelectionCoordinator
    let selectTeam: (Int) -> Void

    var body: some View {
        ScreenShell(
            eyebrow: Strings.eyebrow,
            title: Strings.title,
            subtitle: Strings.subtitle
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
                                    .accessibilityIdentifier(
                                        InspectionAccessibilityIdentifier.sessionSelectorTeamStatus(teamID: team.id).rawValue
                                    )
                                sessionAffordance(for: team)
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
                    .accessibilityIdentifier(
                        InspectionAccessibilityIdentifier.sessionSelectorTeamRow(teamID: team.id).rawValue
                    )
                }
            }

            ContentPanel {
                Label(Strings.localDrafts, systemImage: "externaldrive.badge.checkmark")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.fsaeText)
                Text(Strings.localDraftsDetail)
                    .font(.footnote)
                    .foregroundStyle(Color.fsaeSecondaryText)
            }
        }
        .navigationTitle("Sessions")
    }

    @ViewBuilder
    private func sessionAffordance(for team: InspectionTeam) -> some View {
        switch team.status {
        case .ready:
            EmptyView()
        case .resumed:
            Label(Strings.resumeAvailable, systemImage: "arrow.clockwise")
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.fsaeBlue)
                .accessibilityIdentifier(
                    InspectionAccessibilityIdentifier.sessionSelectorTeamResumeIndicator(teamID: team.id).rawValue
                )
        case .blocked:
            Label(Strings.blocked, systemImage: "exclamationmark.triangle.fill")
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.fsaeAmber)
                .accessibilityIdentifier(
                    InspectionAccessibilityIdentifier.sessionSelectorTeamBlockedIndicator(teamID: team.id).rawValue
                )
        }
    }
}
