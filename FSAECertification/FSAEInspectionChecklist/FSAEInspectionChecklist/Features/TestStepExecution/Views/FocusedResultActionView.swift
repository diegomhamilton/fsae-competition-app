import SwiftUI

struct FocusedResultActionView: View {
    let form: FocusedResultForm
    let confirm: () -> Void
    var title = FocusedResultStrings.saveNext

    var body: some View {
        if form.didConfirm {
            Label(FocusedResultStrings.confirmed, systemImage: "checkmark.circle.fill")
                .font(.headline)
                .foregroundStyle(Color.fsaeGreen)
                .frame(maxWidth: .infinity, minHeight: 80)
                .accessibilityIdentifier("execution.result-confirmation")
        } else if form.isConfirming {
            ProgressView(FocusedResultStrings.saving)
                .frame(maxWidth: .infinity, minHeight: 80)
                .accessibilityIdentifier("execution.result-saving")
        } else {
            Button(action: confirm) {
                Label(title, systemImage: "arrow.right")
                    .font(.title3.bold())
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, minHeight: 80)
            }
                .inspectionButtonStyle()
                .tint(Color.fsaePrimary)
                .accessibilityIdentifier("execution.save-next")
        }
    }
}
