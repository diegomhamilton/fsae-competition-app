import Foundation
import SwiftData

@Observable
final class InspectionStageViewModel {
    let template: InspectionTemplate
    let session: InspectionSession
    var errorMessage: String?
    var activeTestCaseID: String?

    private var resultService: TestCaseResultService?

    init(template: InspectionTemplate, session: InspectionSession) {
        self.template = template
        self.session = session
    }

    func configure(with resultService: TestCaseResultService) {
        self.resultService = resultService
        if activeTestCaseID == nil {
            activeTestCaseID = firstPendingTestCase()?.itemId
        }
    }

    var sections: [InspectionSection] {
        template.sections.sorted { $0.displayOrder < $1.displayOrder }
    }

    func testCases(in section: InspectionSection) -> [TestCase] {
        section.testCases.sorted { $0.displayOrder < $1.displayOrder }
    }

    func result(for testCase: TestCase) -> TestCaseResult? {
        resultService?.result(for: testCase, in: session)
    }

    func progress() -> (completed: Int, total: Int) {
        resultService?.progress(for: template, in: session) ?? (0, 0)
    }

    func isActive(_ testCase: TestCase) -> Bool {
        activeTestCaseID == testCase.itemId
    }

    func activate(_ testCase: TestCase) {
        activeTestCaseID = testCase.itemId
    }

    func activeTestCase() -> TestCase? {
        allTestCasesOrdered().first { $0.itemId == activeTestCaseID }
    }

    /// Returns the next test case with a pending result after `current`, wrapping around.
    func nextPending(after current: TestCase) -> TestCase? {
        let all = allTestCasesOrdered()
        guard let idx = all.firstIndex(where: { $0.itemId == current.itemId }) else { return nil }
        let tail = Array(all[(idx + 1)...])
        let head = Array(all[..<idx])
        return (tail + head).first { isPending($0) }
    }

    func jumpToNextPendingFromActive() -> TestCase? {
        guard let active = activeTestCase() else { return firstPendingTestCase() }
        return nextPending(after: active)
    }

    private func firstPendingTestCase() -> TestCase? {
        allTestCasesOrdered().first { isPending($0) }
    }

    private func isPending(_ testCase: TestCase) -> Bool {
        let status = result(for: testCase)?.status
        return status == nil || status == .pending
    }

    private func allTestCasesOrdered() -> [TestCase] {
        sections.flatMap { testCases(in: $0) }
    }
}
