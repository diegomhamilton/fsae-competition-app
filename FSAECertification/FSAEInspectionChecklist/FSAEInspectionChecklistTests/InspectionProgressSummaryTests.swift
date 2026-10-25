import Foundation
import Testing
@testable import FSAEInspectionChecklist

@MainActor
struct InspectionProgressSummaryTests {
    @Test("Seven completed EV steps contribute seven of 312 overall steps")
    func sevenEVSteps() async throws {
        let urls = OfficialInspectionResource.allCases.reduce(into: [OfficialInspectionResource: URL]()) { urls, resource in
            urls[resource] = Bundle.main.url(forResource: resource.fileName, withExtension: "json")
        }
        let stages = try await InspectionContentService(resourceURLs: urls).loadOfficialStages()
        let ev = try #require(stages.first { $0.id == "04_ev" })
        var remaining = 7
        var drafts: [String: TestCaseDraft] = [:]
        for testCase in ev.orderedSections.flatMap(\.orderedTestCases) where remaining > 0 {
            let selectedSteps = testCase.orderedSteps.prefix(remaining)
            drafts[testCase.id] = TestCaseDraft(
                testCase: testCase,
                stepDrafts: selectedSteps.map { TestStepDraft(stepID: $0.id, outcome: .pass) }
            )
            remaining -= selectedSteps.count
        }
        let states = stages.map { FullStageViewState(stage: $0, draftsByTestCaseID: $0.id == ev.id ? drafts : [:]) }
        let progress = InspectionProgressSummary(stages: states)
        let evState = try #require(states.first { $0.stageID == ev.id })
        let stageProgress = InspectionProgressSummary(stages: [evState])
        #expect(progress.completeStepCount == 7)
        #expect(progress.totalStepCount == 312)
        #expect(abs(progress.fraction - 7.0 / 312) < 0.000001)
        #expect(progress.percentageText == (7.0 / 312).formatted(.percent.precision(.fractionLength(0...1))))
        #expect(progress.countText == "7/312 complete")
        #expect(stageProgress.totalStepCount == 166)
        #expect(abs(stageProgress.fraction - 7.0 / 166) < 0.000001)
        #expect(stageProgress.percentageText == (7.0 / 166).formatted(.percent.precision(.fractionLength(0...1))))
    }

    @Test("Empty inspections have finite zero progress")
    func emptyProgress() {
        let progress = InspectionProgressSummary(stages: [])
        #expect(progress.fraction == 0)
        #expect(progress.percentageText == "0%")
        #expect(progress.countText == "0/0 complete")
    }

    @Test("Small nonzero progress remains visible, and completion displays 100 percent")
    func percentagePrecision() {
        #expect(InspectionProgressSummary(completeStepCount: 1, totalStepCount: 312).percentageText == (1.0 / 312).formatted(.percent.precision(.fractionLength(0...1))))
        #expect(InspectionProgressSummary(completeStepCount: 1, totalStepCount: 10000).percentageText == "<\(0.001.formatted(.percent.precision(.fractionLength(1))))")
        #expect(InspectionProgressSummary(completeStepCount: 312, totalStepCount: 312).percentageText == "100%")
    }
}
