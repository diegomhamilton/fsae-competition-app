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
        static let duplicateFieldsError = "Enter a distinct car number."
        static let genericCreationError = "Unable to add team."
    }

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
        CreateTeamForm(createTeam: createTeam)
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

private struct CreateTeamForm: View {
    fileprivate enum Strings {
        static let createTeamTitle = SessionSelectorView.Strings.createTeamTitle
        static let createTeamDetail = SessionSelectorView.Strings.createTeamDetail
        static let teamNamePlaceholder = SessionSelectorView.Strings.teamNamePlaceholder
        static let carNumberPlaceholder = SessionSelectorView.Strings.carNumberPlaceholder
        static let createTeamAction = SessionSelectorView.Strings.createTeamAction
        static let duplicateFieldsError = SessionSelectorView.Strings.duplicateFieldsError
        static let genericCreationError = SessionSelectorView.Strings.genericCreationError
    }

    let createTeam: (LocalTeamCatalogEntry) -> Void
    @State private var displayName = ""
    @State private var carNumber = ""
    @State private var creationError: String?

    var body: some View {
        ContentPanel {
            Label(Strings.createTeamTitle, systemImage: "person.badge.plus")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.fsaeText)
            Text(Strings.createTeamDetail)
                .font(.footnote)
                .foregroundStyle(Color.fsaeSecondaryText)
            VStack(spacing: 10) {
                TextField(Strings.teamNamePlaceholder, text: $displayName)
                    .textInputAutocapitalization(.words)
                    .textFieldStyle(.roundedBorder)
                    .accessibilityIdentifier(InspectionAccessibilityIdentifier.sessionSelectorCreateTeamNameField.rawValue)
                TextField(Strings.carNumberPlaceholder, text: $carNumber)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)
                    .accessibilityIdentifier(InspectionAccessibilityIdentifier.sessionSelectorCreateTeamCarNumberField.rawValue)
                Button {
                    submit()
                } label: {
                    Label(Strings.createTeamAction, systemImage: "plus.circle.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(submissionEntry == nil)
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

    private var submissionEntry: LocalTeamCatalogEntry? {
        let entry = LocalTeamCatalogEntry(
            displayName: String(displayName.trimmingCharacters(in: .whitespacesAndNewlines)),
            carNumber: String(carNumber.trimmingCharacters(in: .whitespacesAndNewlines))
        )

        guard !entry.displayName.isEmpty,
              !entry.carNumber.isEmpty,
              entry.displayName.caseInsensitiveCompare(entry.carNumber) != .orderedSame else {
            return nil
        }

        return entry
    }

    private func submit() {
        guard let entry = submissionEntry else {
            creationError = Strings.duplicateFieldsError
            return
        }

        let createTeam = createTeam
        createTeam(entry)
        displayName = ""
        carNumber = ""
        creationError = nil
    }
}
