import Foundation
import SwiftData

enum TestCaseStatus: String, Codable {
    case pending
    case pass
    case fail
    case notApplicable
}

@Model
final class TestCaseResult {
    var testCase: TestCase?
    var session: InspectionSession?
    var status: TestCaseStatus
    var inspectorNotes: String?
    var updatedAt: Date

    init(testCase: TestCase, session: InspectionSession) {
        self.testCase = testCase
        self.session = session
        self.status = .pending
        self.updatedAt = Date()
    }
}
