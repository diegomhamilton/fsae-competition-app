import SwiftUI

struct FocusedResultActionView: View {
    let form: FocusedResultForm
    let confirm: () -> Void

    var body: some View {
        if form.didConfirm {
            Label(FocusedResultStrings.confirmed, systemImage: "checkmark.circle.fill")
                .font(.headline)
                .foregroundStyle(Color.fsaeGreen)
                .frame(maxWidth: .infinity, minHeight: 56)
                .accessibilityIdentifier("execution.result-confirmation")
        } else if form.isConfirming {
            ProgressView(FocusedResultStrings.saving)
                .frame(maxWidth: .infinity, minHeight: 56)
                .accessibilityIdentifier("execution.result-saving")
        } else {
            Button(action: confirm) {
                Label(FocusedResultStrings.saveNext, systemImage: "arrow.right")
                    .frame(maxWidth: .infinity, minHeight: 48)
            }
                .buttonStyle(.borderedProminent)
                .tint(Color.fsaePrimary)
                .accessibilityIdentifier("execution.save-next")
        }
    }
}
