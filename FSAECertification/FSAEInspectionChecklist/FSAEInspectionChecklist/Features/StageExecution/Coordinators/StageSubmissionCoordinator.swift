import Observation

/// Owns the submission control's transient state; the execution coordinator owns persistence.
@MainActor @Observable
final class StageSubmissionCoordinator {
    private(set) var isSubmitting = false
    private(set) var succeeded = false
    private(set) var failed = false

    func resultsChanged() {
        succeeded = false
        failed = false
    }

    func perform(
        canSubmit: Bool,
        hasSubmitted: Bool,
        submit: @MainActor () async -> Bool,
        onActivityChanged: @MainActor (Bool) -> Void
    ) async {
        guard canSubmit, !isSubmitting, !hasSubmitted, !succeeded else { return }
        isSubmitting = true
        failed = false
        onActivityChanged(true)
        succeeded = await submit()
        failed = !succeeded
        isSubmitting = false
        onActivityChanged(false)
    }
}
