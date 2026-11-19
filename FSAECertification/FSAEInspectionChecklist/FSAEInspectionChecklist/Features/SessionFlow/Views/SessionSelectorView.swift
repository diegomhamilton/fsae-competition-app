//
//  SessionSelectorView.swift
//  FSAEInspectionChecklist
//

import SwiftUI
#if os(iOS)
import UIKit
#endif

struct SessionSelectorView: View {
    fileprivate enum Strings {
        static var title: String { "Active Inspections".inspectionLocalized }
        static var createTeamTitle: String { "Add Team".inspectionLocalized }
        static var emptyCatalog: String { "No local teams yet.".inspectionLocalized }
        static var emptyCatalogDetail: String { "Add a team to start the local inspection workflow.".inspectionLocalized }
        static var language: String { "Language".inspectionLocalized }
    }

    @State private var showsAddTeam = false
    @Environment(\.openURL) private var openURL
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
            title: Strings.title
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
                                Text(team.currentStage.inspectionLocalized)
                                    .font(.subheadline)
                                    .foregroundStyle(Color.fsaeSecondaryText)
                                Text(team.lastSaved.inspectionLocalized)
                                    .font(.caption2)
                                    .foregroundStyle(Color.fsaeSecondaryText)
                            }
                            Spacer()
                            StatusPill(text: team.status.rawValue.inspectionLocalized, color: team.status.color)
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
            #if os(iOS)
            ToolbarItem(placement: .topBarLeading) {
                Button(Strings.language, systemImage: "globe") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        openURL(url)
                    }
                }
                .labelStyle(.iconOnly)
                .inspectionButtonStyle()
                .accessibilityIdentifier("session-selector.language")
            }
            .sharedBackgroundVisibility(.hidden)
            #endif
            ToolbarItem(placement: .primaryAction) {
                Button(Strings.createTeamTitle, systemImage: "plus") {
                    showsAddTeam = true
                }
                .labelStyle(.iconOnly)
                .inspectionButtonStyle()
                .accessibilityIdentifier("session-selector.add-team")
            }
            .sharedBackgroundVisibility(.hidden)
        }
        .sheet(isPresented: $showsAddTeam) {
            CreateTeamSheet(createTeam: createTeam)
        }
    }

}
