import SwiftUI
import Testing
@testable import FSAEInspectionChecklist

@MainActor
struct StageSubmissionActionTests {
    @Test("US-002: blocked or previously submitted stages never invoke submission", arguments: [false, true])
    func blockedSubmission(hasSubmitted: Bool) async {
        let coordinator = StageSubmissionCoordinator()
        var calls = 0
        var activity: [Bool] = []
        await coordinator.perform(canSubmit: false, hasSubmitted: hasSubmitted, submit: {
            calls += 1; return true
        }, onActivityChanged: { activity.append($0) })
        await coordinator.perform(canSubmit: true, hasSubmitted: true, submit: {
            calls += 1; return true
        }, onActivityChanged: { activity.append($0) })
        #expect(calls == 0)
        #expect(activity.isEmpty)
        #expect(!coordinator.isSubmitting)
        #expect(!coordinator.succeeded)
        #expect(!coordinator.failed)
    }

    @Test("US-002: submitting spans the real operation and duplicate taps cannot submit twice")
    func pendingAndDuplicateSubmission() async {
        let coordinator = StageSubmissionCoordinator()
        let probe = SubmissionActionProbe()
        var activity: [Bool] = []
        let first = Task {
            await coordinator.perform(canSubmit: true, hasSubmitted: false, submit: probe.submit,
                                      onActivityChanged: { activity.append($0) })
        }
        await probe.waitUntilStarted()
        #expect(coordinator.isSubmitting)
        #expect(!coordinator.succeeded)
        #expect(!coordinator.failed)
        #expect(activity == [true])
        await coordinator.perform(canSubmit: true, hasSubmitted: false, submit: probe.submit,
                                  onActivityChanged: { activity.append($0) })
        #expect(probe.calls == 1)
        probe.finish(succeeded: true)
        await first.value
        #expect(!coordinator.isSubmitting)
        #expect(coordinator.succeeded)
        #expect(!coordinator.failed)
        #expect(activity == [true, false])
        await coordinator.perform(canSubmit: true, hasSubmitted: false, submit: probe.submit,
                                  onActivityChanged: { activity.append($0) })
        #expect(probe.calls == 1)
        #expect(activity == [true, false])
    }

    @Test("US-002: failed submission exposes retry and successful retry clears the failure")
    func failureThenRetry() async {
        let coordinator = StageSubmissionCoordinator()
        let probe = SubmissionActionProbe()
        var activity: [Bool] = []
        await coordinator.perform(canSubmit: true, hasSubmitted: false, submit: { false },
                                  onActivityChanged: { activity.append($0) })
        #expect(coordinator.failed)
        #expect(!coordinator.succeeded)
        #expect(!coordinator.isSubmitting)
        let retry = Task {
            await coordinator.perform(canSubmit: true, hasSubmitted: false, submit: probe.submit,
                                      onActivityChanged: { activity.append($0) })
        }
        await probe.waitUntilStarted()
        #expect(coordinator.isSubmitting)
        #expect(!coordinator.failed)
        probe.finish(succeeded: true)
        await retry.value
        #expect(coordinator.succeeded)
        #expect(!coordinator.failed)
        #expect(activity == [true, false, true, false])
    }

    @Test("US-002: changed results clear stale success or failure and allow a fresh attempt", arguments: [false, true])
    func resultsInvalidatePreviousAttempt(succeeded: Bool) async {
        let coordinator = StageSubmissionCoordinator()
        var calls = 0
        await coordinator.perform(canSubmit: true, hasSubmitted: false, submit: {
            calls += 1; return succeeded
        }, onActivityChanged: { _ in })
        #expect(coordinator.succeeded == succeeded)
        #expect(coordinator.failed == !succeeded)
        coordinator.resultsChanged()
        #expect(!coordinator.succeeded)
        #expect(!coordinator.failed)
        await coordinator.perform(canSubmit: true, hasSubmitted: false, submit: {
            calls += 1; return true
        }, onActivityChanged: { _ in })
        #expect(calls == 2)
        #expect(coordinator.succeeded)
    }

    #if canImport(UIKit)
    @Test("The action renders ready, blocked, submitted, failed and in-flight states")
    func rendersSubmissionStates() async throws {
        let coordinator = StageSubmissionCoordinator()
        try render(coordinator, canSubmit: true)
        try render(coordinator, canSubmit: false)
        try render(coordinator, hasSubmitted: true)
        await coordinator.perform(canSubmit: true, hasSubmitted: false, submit: { false }, onActivityChanged: { _ in })
        try render(coordinator)
        let probe = SubmissionActionProbe()
        let pending = Task {
            await coordinator.perform(canSubmit: true, hasSubmitted: false, submit: probe.submit,
                                      onActivityChanged: { _ in })
        }
        await probe.waitUntilStarted()
        // Always release the suspended operation even if rendering records a failure.
        defer { probe.finish(succeeded: true) }
        try render(coordinator)
        probe.finish(succeeded: true)
        await pending.value
        try render(coordinator)
    }

    private func render(_ coordinator: StageSubmissionCoordinator, canSubmit: Bool = true,
                        hasSubmitted: Bool = false) throws {
        let view = StageSubmissionAction(canSubmit: canSubmit, hasSubmitted: hasSubmitted, results: [],
            submit: { true }, onActivityChanged: { _ in }, coordinator: coordinator)
            .frame(width: 390)
        let image = try #require(ImageRenderer(content: view).uiImage)
        #expect(image.size.width == 390)
        #expect(image.size.height > 0)
    }
    #endif
}

@MainActor
private final class SubmissionActionProbe {
    private(set) var calls = 0
    private var completion: CheckedContinuation<Bool, Never>?
    private var started: CheckedContinuation<Void, Never>?

    func submit() async -> Bool {
        calls += 1
        return await withCheckedContinuation { continuation in
            completion = continuation
            started?.resume()
            started = nil
        }
    }

    func waitUntilStarted() async {
        if completion != nil { return }
        await withCheckedContinuation { started = $0 }
    }

    func finish(succeeded: Bool) {
        completion?.resume(returning: succeeded)
        completion = nil
    }
}
