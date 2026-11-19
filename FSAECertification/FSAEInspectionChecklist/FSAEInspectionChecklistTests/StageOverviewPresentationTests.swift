import Testing
@testable import FSAEInspectionChecklist

@MainActor
struct StageOverviewPresentationTests {
    @Test("Queue reentry reveals the active test without resetting other expansion choices")
    func queueRevealsSelection() {
        let state = StageOverviewPresentation(firstSectionID: "first")
        state.toggleSection("first")
        state.toggleSection("other")
        state.prepareQueue(testCaseID: "case-8", sectionID: "supplies")
        #expect(state.expandedSectionIDs == ["other", "supplies"])
        #expect(state.queueRevealID == "case-8")
        state.prepareQueue(testCaseID: nil, sectionID: nil)
        #expect(state.expandedSectionIDs == ["other", "supplies"])
    }

    @Test("Queue and review offsets stay independent and invalid offsets are rejected")
    func independentOffsets() {
        let state = StageOverviewPresentation(firstSectionID: nil)
        state.rememberQueueOffset(210)
        state.rememberReviewOffset(480)
        state.rememberReviewOffset(-20)
        state.rememberQueueOffset(.infinity)
        #expect(state.queueOffset == 210)
        #expect(state.reviewOffset == 480)
        let otherStage = StageOverviewPresentation(firstSectionID: nil)
        #expect(otherStage.reviewOffset == 0)
    }
}
