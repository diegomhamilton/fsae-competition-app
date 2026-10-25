import SwiftUI

struct FocusedNotesEditor: View {
    let form: FocusedResultForm
    let testCaseID: String
    let focusedField: FocusState<FocusedResultField?>.Binding
    var body: some View {
        if form.isEditingNotes {
            VStack(alignment: .leading, spacing: 12) {
                if form.draft.outcome == .fail {
                    Text(FocusedResultStrings.requiredNotes).font(.title3.bold())
                }
                TextField(FocusedResultStrings.writeNote,
                    text: Binding(get: { form.draft.notes }, set: form.updateNotes), axis: .vertical)
                    .font(.title2).lineLimit(3...6)
                    .focused(focusedField, equals: .notes)
                    .accessibilityIdentifier(InspectionAccessibilityIdentifier.testCaseNotesField(testCaseID: testCaseID, stepID: form.step.id).rawValue)

            }
            .padding(16).background(Color.fsaeSurface, in: .rect(cornerRadius: 20))
                .overlay { RoundedRectangle(cornerRadius: 20).stroke(Color.fsaeBorder, lineWidth: 1) }
                .shadow(color: .black.opacity(0.06), radius: 8, y: 2)
        } else if !form.draft.notes.isEmpty {
            Button {
                form.beginNotes()
                focusedField.wrappedValue = .notes
            } label: {
                VStack(alignment: .leading, spacing: 8) {
                    Label(FocusedResultStrings.notes, systemImage: "note.text").font(.headline)
                    Text(form.draft.notes).font(.title3).lineLimit(3)
                }
                .frame(maxWidth: .infinity, minHeight: 64, alignment: .leading).padding(16)
                .background(Color.fsaeSurface, in: .rect(cornerRadius: 20))
                .overlay { RoundedRectangle(cornerRadius: 20).stroke(Color.fsaeBorder, lineWidth: 1) }
                .shadow(color: .black.opacity(0.06), radius: 8, y: 2)
            }
            .buttonStyle(.plain).foregroundStyle(Color.fsaeText)
            .accessibilityIdentifier("execution.notes.preview")
        }
    }
}
