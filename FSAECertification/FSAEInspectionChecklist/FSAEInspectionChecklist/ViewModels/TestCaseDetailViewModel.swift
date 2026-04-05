import Foundation
import SwiftData

@Observable
final class TestCaseDetailViewModel {
    let testCase: TestCase
    let session: InspectionSession
    var errorMessage: String?

    private var resultService: TestCaseResultService?

    init(testCase: TestCase, session: InspectionSession) {
        self.testCase = testCase
        self.session = session
    }

    func configure(with resultService: TestCaseResultService) {
        self.resultService = resultService
    }

    var result: TestCaseResult? {
        resultService?.result(for: testCase, in: session)
    }

    var sortedSteps: [TestStep] {
        testCase.steps.sorted { $0.displayOrder < $1.displayOrder }
    }

    func setStatus(_ status: TestCaseStatus) {
        guard let result else { return }
        do {
            try resultService?.setStatus(status, for: result)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func setNotes(_ notes: String) {
        guard let result else { return }
        do {
            try resultService?.setNotes(notes, for: result)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
