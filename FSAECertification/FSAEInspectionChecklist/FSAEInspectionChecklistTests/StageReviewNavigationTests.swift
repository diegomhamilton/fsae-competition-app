import Testing
@testable import FSAEInspectionChecklist

@MainActor
struct StageReviewNavigationTests {
    @Test("Review opened from the stage pushes one destination and native Back returns to the stage")
    func reviewFromStage() throws {
        let coordinator = coordinator()
        coordinator.showReview()
        let review = try #require(coordinator.route(after: nil))
        #expect(review.mode == .review)
        #expect(coordinator.route(after: review) == nil)
        coordinator.popNavigation(after: nil)
        #expect(coordinator.mode == .queue)
    }

    @Test("Review from a test is pushed above that test and native Back restores its selection")
    func reviewFromTest() throws {
        let coordinator = coordinator()
        #expect(coordinator.selectTestCase(id: "first", draftsByTestCaseID: [:]))
        let test = try #require(coordinator.route(after: nil))
        coordinator.showReview()
        let review = try #require(coordinator.route(after: test))
        #expect(review.mode == .review)
        coordinator.popNavigation(after: test)
        #expect(coordinator.mode == .focus)
        #expect(coordinator.selectedTestCaseID == "first")
        #expect(coordinator.route(after: test) == nil)
        coordinator.popNavigation(after: nil)
        #expect(coordinator.mode == .queue)
    }

    @Test("Native Back from a review correction returns to review, then to the original test")
    func backFromCorrection() throws {
        let coordinator = coordinator()
        #expect(coordinator.selectTestCase(id: "first", draftsByTestCaseID: [:]))
        let test = try #require(coordinator.route(after: nil))
        coordinator.showReview()
        let review = try #require(coordinator.route(after: test))
        #expect(coordinator.editResult(testCaseID: "second", stepID: "second-step"))
        #expect(coordinator.route(after: review)?.mode == .focus)
        coordinator.popNavigation(after: review)
        #expect(coordinator.mode == .review)
        #expect(!coordinator.isEditingFromReview)
        coordinator.popNavigation(after: test)
        #expect(coordinator.mode == .focus)
        #expect(coordinator.selectedTestCaseID == "first")
        #expect(coordinator.activeStepID == "first-step")
    }

    @Test("Repeated review and a completed correction reuse the existing review destination")
    func correctionReturnsToExistingReview() throws {
        let coordinator = coordinator()
        coordinator.showReview()
        let review = try #require(coordinator.route(after: nil))
        coordinator.showReview()
        #expect(coordinator.route(after: nil)?.id == review.id)
        #expect(coordinator.editResult(testCaseID: "second", stepID: "second-step"))
        coordinator.returnToReview()
        #expect(coordinator.mode == .review)
        #expect(coordinator.route(after: nil)?.id == review.id)
        #expect(coordinator.route(after: review) == nil)
        coordinator.popNavigation(after: nil)
        #expect(coordinator.mode == .queue)
    }

    private func coordinator() -> StageFocusCoordinator {
        let testCases = ["first", "second"].map { id in
            InspectionTestCase(id: id, code: id, title: id, steps: [
                InspectionTestStep(id: "\(id)-step", code: id, ruleReference: "T.1", title: id,
                                   type: .check, content: id, requiredOutcome: true, requiresEvidence: false)
            ])
        }
        let stage = InspectionStage(id: "stage", title: "Stage", displayOrder: 1, sections: [
            InspectionSection(id: "section", title: "Section", displayOrder: 1, testCases: testCases)
        ])
        return StageFocusCoordinator(stage: stage)
    }
}
