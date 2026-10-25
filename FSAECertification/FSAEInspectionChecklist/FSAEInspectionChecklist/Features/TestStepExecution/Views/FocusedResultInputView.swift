import SwiftUI

struct FocusedResultInputView: View {
    let form: FocusedResultForm
    let testCaseID: String
    let focusedField: FocusState<FocusedResultField?>.Binding
    let addPhoto: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            if form.isEditingNotes {
                if !form.draft.outcome.satisfiesRequiredOutcome {
                    Label(FocusedResultStrings.notes, systemImage: "note.text").font(.title2.bold())
                } else {
                Button {
                    form.setNotesEditing(false)
                    form.editResult(includingEvidence: false)
                    focusedField.wrappedValue = nil
                } label: {
                    Label(form.draft.outcome.displayName, systemImage: form.draft.outcome == .fail ? "xmark.circle.fill" : "checkmark.circle.fill")
                        .font(.title2.bold()).foregroundStyle(form.draft.outcome.color)
                }
                .frame(minHeight: 48)
                }
            } else if form.step.requiredOutcome && !form.isEditingMeasurement {
                HStack(spacing: 12) {
                    ForEach([InspectionOutcome.pass, .fail], id: \.self) { outcome in
                        Button {
                            form.selectOutcome(outcome)
                            if outcome == .fail { focusedField.wrappedValue = .notes }
                        } label: {
                            VStack(spacing: 8) {
                                Image(systemName: form.draft.outcome == outcome ? "checkmark.circle.fill" : "circle")
                                Text(outcome.displayName)
                            }
                            .font(.title2.bold()).frame(maxWidth: .infinity, minHeight: 132)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(outcome == .fail ? Color.fsaeRed : Color.fsaePrimary)
                        .accessibilityIdentifier(InspectionAccessibilityIdentifier.testStepOutcome(stepID: form.step.id, outcome: outcome).rawValue)
                        .accessibilityValue(form.draft.outcome == outcome ? FocusedResultStrings.selected : "")
                    }
                }
            }
            if form.step.type == .measurement && !form.isEditingNotes {
                FocusedMeasurementInput(form: form, focusedField: focusedField)
            }
            if form.step.requiresEvidence && form.draft.evidenceAttachments.isEmpty {
                Button(FocusedResultStrings.addPhoto, systemImage: "camera", action: addPhoto)
                    .font(.title2.bold()).frame(maxWidth: .infinity, minHeight: 100)
                    .buttonStyle(.bordered).disabled(form.isImportingPhoto)
                    .accessibilityIdentifier(InspectionAccessibilityIdentifier.testCaseEvidenceAction(testCaseID: testCaseID, stepID: form.step.id).rawValue)
            }
        }
    }
}
