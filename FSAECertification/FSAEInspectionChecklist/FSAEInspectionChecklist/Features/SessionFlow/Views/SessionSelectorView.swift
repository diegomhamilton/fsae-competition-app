//
//  SessionSelectorView.swift
//  FSAEInspectionChecklist
//

import SwiftUI

struct SessionSelectorView: View {
    fileprivate enum Strings {
        static let title = "Active Inspections"
        static let subtitle =
            "Select Team to start or resume a locally stored inspection session for the current event."
        static let createTeamTitle = "Add Team"
        static let emptyCatalog = "No local teams yet."
        static let emptyCatalogDetail = "Add a team to start the local inspection workflow."
    }

    @State private var showsAddTeam = false
    @ObservedObject var coordinator: SessionSelectionCoordinator
    let selectTeam: (Int) -> Void
    let createTeam: (LocalTeamCatalogEntry) -> Void

    init(
        coordinator: SessionSelectionCoordinator,
        selectTeam: @escaping (Int) -> Void,
        createTeam: @escaping (LocalTeamCatalogEntry) -> Void = { _ in }
    ) {
        self.coordinator = coordinator
        self.selectTeam = selectTeam
        self.createTeam = createTeam
    }

    var body: some View {
        ScreenShell(
            title: Strings.title,
            subtitle: Strings.subtitle
        ) {
            if coordinator.teams.isEmpty {
                ContentPanel {
                    Label(Strings.emptyCatalog, systemImage: "person.crop.circle.badge.plus")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.fsaeText)
                    Text(Strings.emptyCatalogDetail)
                        .font(.footnote)
                        .foregroundStyle(Color.fsaeSecondaryText)
                }
            }

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
                                Text(team.lastSaved)
                                    .font(.caption2)
                                    .foregroundStyle(Color.fsaeSecondaryText)
                            }
                            Spacer()
                            StatusPill(text: team.status.rawValue, color: team.status.color)
                                .accessibilityIdentifier(
                                    InspectionAccessibilityIdentifier.sessionSelectorTeamStatus(teamID: team.id)
                                        .rawValue
                                )
                        }
                        .padding(16)
                        .background(Color.fsaeSurface, in: RoundedRectangle(cornerRadius: 8))
                        .overlay {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(
                                    coordinator.selectedTeamID == team.id ? Color.fsaePrimary : Color.fsaeBorder,
                                    lineWidth: coordinator.selectedTeamID == team.id ? 2 : 1)
                        }
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier(
                        InspectionAccessibilityIdentifier.sessionSelectorTeamRow(teamID: team.id).rawValue
                    )
                }
            }

        }
        .navigationTitle(Strings.title)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(Strings.createTeamTitle, systemImage: "plus") {
                    showsAddTeam = true
                }
                .accessibilityIdentifier("session-selector.add-team")
            }
        }
        .sheet(isPresented: $showsAddTeam) {
            CreateTeamSheet(createTeam: createTeam)
        }
    }

}
