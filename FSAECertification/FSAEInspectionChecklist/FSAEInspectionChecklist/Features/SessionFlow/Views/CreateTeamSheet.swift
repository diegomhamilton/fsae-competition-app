import SwiftUI

struct CreateTeamSheet: View {
    private enum Strings {
        static let createTeamTitle = "Add Team"
        static let teamNamePlaceholder = "Team display name"
        static let carNumberPlaceholder = "Car number"
        static let createTeamAction = "Add Team"
        static let duplicateFieldsError = "Enter a distinct car number."
        static let cancel = "Cancel"
    }

    let createTeam: (LocalTeamCatalogEntry) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var displayName = ""
    @State private var carNumber = ""
    @State private var creationError: String?

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField(Strings.teamNamePlaceholder, text: $displayName)
                        .textInputAutocapitalization(.words)
                        .accessibilityIdentifier(
                            InspectionAccessibilityIdentifier.sessionSelectorCreateTeamNameField.rawValue)
                    TextField(Strings.carNumberPlaceholder, text: $carNumber)
                        .keyboardType(.numberPad)
                        .accessibilityIdentifier(
                            InspectionAccessibilityIdentifier.sessionSelectorCreateTeamCarNumberField.rawValue)
                    Button {
                        submit()
                    } label: {
                        Label(Strings.createTeamAction, systemImage: "plus.circle.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(submissionEntry == nil)
                    .accessibilityIdentifier(
                        InspectionAccessibilityIdentifier.sessionSelectorCreateTeamAction.rawValue)
                }
                if let creationError {
                    Text(creationError)
                        .font(.footnote)
                        .foregroundStyle(Color.fsaeRed)
                }
            }
            .navigationTitle(Strings.createTeamTitle)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(Strings.cancel) { dismiss() }
                        .accessibilityIdentifier("session-selector.add-team.cancel")
                }
            }
            .accessibilityIdentifier(
                InspectionAccessibilityIdentifier.sessionSelectorCreateTeamForm.rawValue)
        }
    }

    private var submissionEntry: LocalTeamCatalogEntry? {
        let entry = LocalTeamCatalogEntry(
            displayName: String(displayName.trimmingCharacters(in: .whitespacesAndNewlines)),
            carNumber: String(carNumber.trimmingCharacters(in: .whitespacesAndNewlines))
        )

        guard !entry.displayName.isEmpty,
            !entry.carNumber.isEmpty,
            entry.displayName.caseInsensitiveCompare(entry.carNumber) != .orderedSame
        else {
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
        dismiss()
    }
}
