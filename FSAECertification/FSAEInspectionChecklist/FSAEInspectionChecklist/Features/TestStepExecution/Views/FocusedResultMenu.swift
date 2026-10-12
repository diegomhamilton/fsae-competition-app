import SwiftUI

struct FocusedResultMenu: View {
    let form: FocusedResultForm
    let addNotes: () -> Void
    let addPhoto: () -> Void
    let flagIssue: () -> Void
    let review: () -> Void
    @State private var showsActions: Bool

    init(
        form: FocusedResultForm,
        addNotes: @escaping () -> Void,
        addPhoto: @escaping () -> Void,
        flagIssue: @escaping () -> Void,
        review: @escaping () -> Void
    ) {
        self.form = form
        self.addNotes = addNotes
        self.addPhoto = addPhoto
        self.flagIssue = flagIssue
        self.review = review
        #if DEBUG
        _showsActions = State(initialValue: InspectionSnapshotScenario.current?.rawValue == "secondary-actions")
        #else
        _showsActions = State(initialValue: false)
        #endif
    }

    var body: some View {
        Button {
            showsActions = true
        } label: {
            Label(FocusedResultStrings.more, systemImage: "plus")
                .labelStyle(.iconOnly)
                .font(.title2)
                .frame(minWidth: 56, minHeight: 56)
                .background(Color.fsaePrimary.opacity(0.12), in: .circle)
        }
        .foregroundStyle(form.isConfirming || form.didConfirm || form.isImportingPhoto ? Color.fsaeSecondaryText : Color.fsaePrimary)
        .disabled(form.isImportingPhoto)
        .accessibilityIdentifier("execution.secondary-actions")
        .confirmationDialog(FocusedResultStrings.more, isPresented: $showsActions, titleVisibility: .visible) {
            Button(FocusedResultStrings.addNotes, systemImage: "note.text", action: addNotes)
            Button(FocusedResultStrings.addPhoto, systemImage: "camera", action: addPhoto)
            Button(InspectionOutcome.notApplicable.displayName) { form.selectOutcome(.notApplicable) }
            Button(FocusedResultStrings.rerun, systemImage: "arrow.counterclockwise") { form.rerun() }
            if form.draft.flaggedForReview == true {
                Button(FocusedResultStrings.resolveFlag, systemImage: "flag.slash") { form.resolveFlag() }
            } else {
                Button(FocusedResultStrings.flag, systemImage: "flag", action: flagIssue)
            }
            Button(FocusedResultStrings.review, systemImage: "checklist", action: review)
        }
    }
}
