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
    @State private var coordinator: StageSubmissionCoordinator
    #if DEBUG
    @State private var preparedSnapshot = false
    #endif

    init(
        canSubmit: Bool,
        hasSubmitted: Bool,
        results: [TestCaseDraft],
        submit: @escaping @MainActor () async -> Bool,
        onActivityChanged: @escaping (Bool) -> Void,
        coordinator: StageSubmissionCoordinator? = nil
    ) {
        self.canSubmit = canSubmit
        self.hasSubmitted = hasSubmitted
        self.results = results
        self.submit = submit
        self.onActivityChanged = onActivityChanged
        _coordinator = State(initialValue: coordinator ?? StageSubmissionCoordinator())
    }

    var body: some View {
        VStack(alignment: .leading) {
            if coordinator.failed {
                Text(Strings.failed).foregroundStyle(Color.fsaeRed)
                    .accessibilityIdentifier("execution.review.submit-failure")
            }
            if hasSubmitted || coordinator.succeeded {
                Label(Strings.submitted, systemImage: "checkmark.circle.fill")
                    .foregroundStyle(Color.fsaeGreen).font(.headline)
                    .frame(maxWidth: .infinity, minHeight: 56)
                    .accessibilityIdentifier("execution.review.submitted")
            } else if coordinator.isSubmitting {
                ProgressView(Strings.submitting).frame(maxWidth: .infinity, minHeight: 56)
            } else {
                Button { performSubmission() } label: {
                    Label(Strings.submit, systemImage: "paperplane.fill")
                        .frame(maxWidth: .infinity, minHeight: 48)
                }
                .inspectionButtonStyle().tint(Color.fsaePrimary)
                .controlSize(.large).disabled(!canSubmit)
                .accessibilityIdentifier("execution.review.submit")
            }
        }
        .padding().background(Color.fsaeSurface)
        .onChange(of: results) { _, _ in
            coordinator.resultsChanged()
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
        Task {
            await coordinator.perform(canSubmit: canSubmit, hasSubmitted: hasSubmitted,
                                      submit: submit, onActivityChanged: onActivityChanged)
        }
    }
}
