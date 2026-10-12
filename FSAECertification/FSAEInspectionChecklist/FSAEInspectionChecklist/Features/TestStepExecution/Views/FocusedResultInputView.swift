import SwiftUI

struct FocusedResultInputView: View {
    let form: FocusedResultForm
    let testCaseID: String
    let focusedField: FocusState<FocusedResultField?>.Binding
    let addPhoto: () -> Void

    var body: some View {
        VStack(alignment: .leading) {
            if form.step.requiredOutcome {
                HStack {
                    ForEach([InspectionOutcome.pass, .fail], id: \.self) { outcome in
                        Button {
                            form.selectOutcome(outcome)
                            if outcome == .fail { focusedField.wrappedValue = .notes }
                        } label: {
                            Label(outcome.displayName, systemImage: form.draft.outcome == outcome ? "checkmark.circle.fill" : "circle")
                                .frame(maxWidth: .infinity, minHeight: 48)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(outcome == .fail ? Color.fsaeRed : Color.fsaePrimary)
                        .accessibilityIdentifier(InspectionAccessibilityIdentifier.testStepOutcome(stepID: form.step.id, outcome: outcome).rawValue)
                        .accessibilityValue(form.draft.outcome == outcome ? FocusedResultStrings.selected : "")
                    }
                }
            }

            if form.step.type == .measurement {
                HStack {
                    TextField(
                        FocusedResultStrings.measurement,
                        text: Binding(get: { form.draft.measurementInput }, set: form.updateMeasurement)
                    )
                    .font(.title2)
                    .textFieldStyle(.roundedBorder)
                    .measurementKeyboard()
                    .focused(focusedField, equals: .measurement)
                    .accessibilityIdentifier(InspectionAccessibilityIdentifier.measurementField(stepID: form.step.id).rawValue)
                    Text(form.step.measurementRange?.unit.symbol ?? "")
                        .font(.title3)
                }
            }

            if form.showsNotes {
                TextField(
                    form.draft.outcome == .fail ? FocusedResultStrings.requiredNotes : FocusedResultStrings.notes,
                    text: Binding(get: { form.draft.notes }, set: form.updateNotes),
                    axis: .vertical
                )
                .lineLimit(2...5)
                .textFieldStyle(.roundedBorder)
                .focused(focusedField, equals: .notes)
                .accessibilityIdentifier(InspectionAccessibilityIdentifier.testCaseNotesField(testCaseID: testCaseID, stepID: form.step.id).rawValue)
            }

            if form.step.requiresEvidence {
                Button(FocusedResultStrings.addPhoto, systemImage: "camera") { addPhoto() }
                    .disabled(form.isImportingPhoto)
                    .buttonStyle(.bordered)
                    .frame(minHeight: 48)
                    .accessibilityIdentifier(InspectionAccessibilityIdentifier.testCaseEvidenceAction(testCaseID: testCaseID, stepID: form.step.id).rawValue)
            }

            ForEach(form.draft.evidenceAttachments) { attachment in
                Label(attachment.displayName, systemImage: "photo")
                    .font(.callout)
                    .contextMenu {
                        Button(FocusedResultStrings.removePhoto, systemImage: "trash", role: .destructive) {
                            form.removeAttachment(attachment.id)
                        }
                    }
            }

            if form.isEditingMeasurement || form.isEditingNotes || form.isEditingEvidence {
                Button {
                    focusedField.wrappedValue = nil
                    form.finishInput()
                } label: {
                    Label(FocusedResultStrings.done, systemImage: "checkmark")
                        .frame(maxWidth: .infinity, minHeight: 48)
                }
                .buttonStyle(.bordered)
                .accessibilityIdentifier("execution.result.done")
            }
        }
    }
}
