//
//  TeamSwitchConfirmationView.swift
//  FSAEInspectionChecklist
//

import SwiftUI

struct TeamSwitchConfirmationView: View {
    fileprivate enum Strings {
        static var eyebrow: String { "Team Switch".inspectionLocalized }
        static var title: String { "Save Draft Before Switching?".inspectionLocalized }
        static var subtitle: String { "The current session has local inspection work that should be saved before loading another team.".inspectionLocalized }
        static var currentTeam: String { "Current team".inspectionLocalized }
        static var targetTeam: String { "Target team".inspectionLocalized }
        static var savedDraft: String { "Draft will be saved with the current stage pointer.".inspectionLocalized }
        static var cancel: String { "Cancel".inspectionLocalized }
        static var saveAndSwitch: String { "Save & Switch".inspectionLocalized }
    }

    @ObservedObject var coordinator: InspectionExecutionCoordinator
    let cancelSwitch: () -> Void
    let confirmSwitch: () -> Void

    var body: some View {
        let currentTeam = coordinator.activeTeam
        let targetTeam = coordinator.pendingSwitchTarget ?? coordinator.activeTeam

        VStack(alignment: .leading, spacing: 20) {
            Capsule()
                .fill(Color.black.opacity(0.18))
                .frame(width: 42, height: 5)
                .frame(maxWidth: .infinity)

            VStack(alignment: .leading, spacing: 8) {
                Text(Strings.eyebrow.uppercased())
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color.fsaePrimary)
                Text(Strings.title)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(Color.fsaeText)
                Text(Strings.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(Color.fsaeSecondaryText)
            }

            ContentPanel {
                Label("\(Strings.currentTeam): \(currentTeam.carNumber) \(currentTeam.school)", systemImage: "person.crop.circle.badge.checkmark")
                Label("\(Strings.targetTeam): \(targetTeam.carNumber) \(targetTeam.school)", systemImage: "arrow.right.circle")
                Label(Strings.savedDraft, systemImage: "externaldrive.badge.checkmark")
            }

            HStack {
                Button(Strings.cancel) {
                    cancelSwitch()
                }
                .inspectionButtonStyle()
                .controlSize(.large)
                .accessibilityIdentifier(
                    InspectionAccessibilityIdentifier.teamSwitchCancelAction(
                        currentTeamID: currentTeam.id,
                        targetTeamID: targetTeam.id
                    ).rawValue
                )

                Button {
                    confirmSwitch()
                } label: {
                    Label(Strings.saveAndSwitch, systemImage: "checkmark.circle.fill")
                }
                .inspectionButtonStyle()
                .controlSize(.large)
                .accessibilityIdentifier(
                    InspectionAccessibilityIdentifier.teamSwitchConfirmAction(
                        currentTeamID: currentTeam.id,
                        targetTeamID: targetTeam.id
                    ).rawValue
                )
            }
        }
        .padding(20)
        .background(Color.fsaeBackground)
    }
}
