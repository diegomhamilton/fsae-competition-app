import SwiftUI

struct StageSubmissionAction: View {
    private enum Strings {
        static let submit = "Submit stage"
        static let submitting = "Submitting stage..."
        static let submitted = "Stage submitted"
        static let failed = "Stage could not be submitted. Your results are kept; try again."
    }
    let canSubmit: Bool
    let hasSubmitted: Bool
    let results: [TestCaseDraft]
    let submit: @MainActor () async -> Bool
    let onActivityChanged: (Bool) -> Void
    @State private var isSubmitting = false
    @State private var succeeded = false
    @State private var failed = false
    #if DEBUG
    @State private var preparedSnapshot = false
    #endif

    var body: some View {
        VStack(alignment: .leading) {
            if failed {
                Text(Strings.failed).foregroundStyle(Color.fsaeRed)
                    .accessibilityIdentifier("execution.review.submit-failure")
            }
            if hasSubmitted || succeeded {
                Label(Strings.submitted, systemImage: "checkmark.circle.fill")
                    .foregroundStyle(Color.fsaeGreen).font(.headline)
                    .frame(maxWidth: .infinity, minHeight: 56)
                    .accessibilityIdentifier("execution.review.submitted")
            } else if isSubmitting {
                ProgressView(Strings.submitting).frame(maxWidth: .infinity, minHeight: 56)
            } else {
                Button { performSubmission() } label: {
                    Label(Strings.submit, systemImage: "paperplane.fill")
                        .frame(maxWidth: .infinity, minHeight: 48)
                }
                .buttonStyle(.borderedProminent).tint(Color.fsaePrimary)
                .controlSize(.large).disabled(!canSubmit)
                .accessibilityIdentifier("execution.review.submit")
            }
        }
        .padding().background(Color.fsaeSurface)
        .onChange(of: results) { _, _ in
            succeeded = false
            failed = false
        }
        #if DEBUG
        .task {
            guard !preparedSnapshot else { return }
            preparedSnapshot = true
            if ["review-submitted", "submission-failure"].contains(InspectionSnapshotScenario.current?.rawValue ?? "") {
                performSubmission()
            }
        }
        #endif
    }

    private func performSubmission() {
        guard canSubmit, !isSubmitting, !hasSubmitted, !succeeded else { return }
        isSubmitting = true
        failed = false
        onActivityChanged(true)
        Task {
            succeeded = await submit()
            failed = !succeeded
            isSubmitting = false
            onActivityChanged(false)
        }
    }
}
