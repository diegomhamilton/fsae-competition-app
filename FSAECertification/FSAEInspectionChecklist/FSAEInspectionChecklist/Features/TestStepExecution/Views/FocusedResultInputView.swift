import SwiftUI

struct FocusedResultInputView: View {
    @Environment(\.dynamicTypeSize) private var textSize
    let form: FocusedResultForm
    let testCaseID: String
    let focusedField: FocusState<FocusedResultField?>.Binding
    let addPhoto: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            if form.isEditingNotes {
                if !form.draft.outcome.satisfiesRequiredOutcome {
                    Label(FocusedResultStrings.notes, systemImage: "note.text").font(.title2.bold())
                        .padding(12).glassEffect(.regular, in: .capsule)
                } else {
                    Button {
                        form.setNotesEditing(false)
                        form.editResult(includingEvidence: false)
                        focusedField.wrappedValue = nil
                    } label: {
                        HStack {
                            Label(form.draft.outcome.displayName, systemImage: form.draft.outcome == .fail ? "xmark.circle.fill" : "checkmark.circle.fill")
                                .font(.title2.bold())
                            Spacer()
                            Image(systemName: "pencil").font(.title3)
                        }
                        .frame(maxWidth: .infinity, minHeight: 48)
                        .padding(12)
                    }
                    .inspectionButtonStyle(tint: form.draft.outcome.color)
                    .accessibilityIdentifier("execution.result.edit")
                }
            } else if form.step.requiredOutcome && !form.isEditingMeasurement {
                let layout = textSize.isAccessibilitySize
                    ? AnyLayout(VStackLayout(spacing: 16))
                    : AnyLayout(HStackLayout(spacing: 20))
                layout {
                    ForEach([InspectionOutcome.fail, .pass], id: \.self) { outcome in
                        Button {
                            form.selectOutcome(outcome)
                            if outcome == .fail { focusedField.wrappedValue = .notes }
                        } label: {
                            Label(outcome.displayName, systemImage: outcome == .fail ? "xmark" : "checkmark")
                                .font(.title2.bold())
                                .frame(maxWidth: .infinity, minHeight: 80)
                                .contentShape(.rect(cornerRadius: 24))
                        }
                        .inspectionButtonStyle(tint: outcome == .fail ? .fsaeRed : .fsaeGreen)
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
                    .inspectionButtonStyle().disabled(form.isImportingPhoto)
                    .accessibilityIdentifier(InspectionAccessibilityIdentifier.testCaseEvidenceAction(testCaseID: testCaseID, stepID: form.step.id).rawValue)
            }
        }
    }
}
