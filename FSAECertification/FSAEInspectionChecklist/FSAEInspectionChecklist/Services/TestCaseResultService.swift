import Foundation
import SwiftData

final class TestCaseResultService {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func result(for testCase: TestCase, in session: InspectionSession) -> TestCaseResult? {
        session.results.first { $0.testCase?.itemId == testCase.itemId }
    }

    func setStatus(_ status: TestCaseStatus, for result: TestCaseResult) throws {
        result.status = status
        result.updatedAt = Date()
        try modelContext.save()
    }

    func setNotes(_ notes: String, for result: TestCaseResult) throws {
        result.inspectorNotes = notes.isEmpty ? nil : notes
        result.updatedAt = Date()
        try modelContext.save()
    }

    func progress(for template: InspectionTemplate, in session: InspectionSession) -> (completed: Int, total: Int) {
        let templateItemIds = Set(template.testCases.map(\.itemId))
        let relevant = session.results.filter { result in
            guard let id = result.testCase?.itemId else { return false }
            return templateItemIds.contains(id)
        }
        let completed = relevant.filter { $0.status != .pending }.count
        return (completed, relevant.count)
    }
}
