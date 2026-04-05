import Foundation
import SwiftData

@Observable
final class InspectionStageViewModel {
    let template: InspectionTemplate
    let session: InspectionSession
    var errorMessage: String?

    private var resultService: TestCaseResultService?

    init(template: InspectionTemplate, session: InspectionSession) {
        self.template = template
        self.session = session
    }

    func configure(with resultService: TestCaseResultService) {
        self.resultService = resultService
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
}
