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
        static let createTeamTitle = "Add Team"
        static let createTeamDetail = "Create a local team entry before starting inspection."
        static let teamNamePlaceholder = "Team display name"
        static let carNumberPlaceholder = "Car number"
        static let createTeamAction = "Add Team"
        static let emptyCatalog = "No local teams yet."
        static let emptyCatalogDetail = "Add a team to start the local inspection workflow."
    }

    @ObservedObject var coordinator: SessionSelectionCoordinator
    let selectTeam: (Int) -> Void
    let createTeam: (String, String) async throws -> Bool
    @State private var newTeamName = ""
    @State private var newCarNumber = ""
    @State private var creationError: String?

    init(
        coordinator: SessionSelectionCoordinator,
        selectTeam: @escaping (Int) -> Void,
        createTeam: @escaping (String, String) async throws -> Bool = { _, _ in false }
    ) {
        self.coordinator = coordinator
        self.selectTeam = selectTeam
        self.createTeam = createTeam
    }

    var body: some View {
        ScreenShell(
            eyebrow: Strings.eyebrow,
            title: Strings.title,
            subtitle: Strings.subtitle
        ) {
            createTeamPanel

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

    private var createTeamPanel: some View {
        ContentPanel {
            Label(Strings.createTeamTitle, systemImage: "person.badge.plus")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.fsaeText)
            Text(Strings.createTeamDetail)
                .font(.footnote)
                .foregroundStyle(Color.fsaeSecondaryText)
            VStack(spacing: 10) {
                TextField(Strings.teamNamePlaceholder, text: $newTeamName)
                    .textInputAutocapitalization(.words)
                    .textFieldStyle(.roundedBorder)
                    .accessibilityIdentifier(InspectionAccessibilityIdentifier.sessionSelectorCreateTeamNameField.rawValue)
                TextField(Strings.carNumberPlaceholder, text: $newCarNumber)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)
                    .accessibilityIdentifier(InspectionAccessibilityIdentifier.sessionSelectorCreateTeamCarNumberField.rawValue)
                Button {
                    let displayName = String(newTeamName.trimmingCharacters(in: .whitespacesAndNewlines))
                    let carNumber = String(newCarNumber.trimmingCharacters(in: .whitespacesAndNewlines))
                    let createTeam = createTeam
                    Task {
                        do {
                            if try await createTeam(displayName, carNumber) {
                                await MainActor.run {
                                    newTeamName = ""
                                    newCarNumber = ""
                                    creationError = nil
                                }
                            }
                        } catch LocalTeamCatalogValidationError.missingDisplayName {
                            await MainActor.run {
                                creationError = Strings.teamNamePlaceholder
                            }
                        } catch LocalTeamCatalogValidationError.missingCarNumber {
                            await MainActor.run {
                                creationError = Strings.carNumberPlaceholder
                            }
                        } catch {
                            await MainActor.run {
                                creationError = "Unable to add team."
                            }
                        }
                    }
                } label: {
                    Label(Strings.createTeamAction, systemImage: "plus.circle.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(newTeamName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || newCarNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .accessibilityIdentifier(InspectionAccessibilityIdentifier.sessionSelectorCreateTeamAction.rawValue)
            }
            if let creationError {
                Text(creationError)
                    .font(.footnote)
                    .foregroundStyle(Color.fsaeRed)
            }
        }
        .accessibilityIdentifier(InspectionAccessibilityIdentifier.sessionSelectorCreateTeamForm.rawValue)
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
