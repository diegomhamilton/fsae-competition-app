import Foundation
import SwiftData

final class InspectionSessionService {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func activeSession() throws -> InspectionSession? {
        let descriptor = FetchDescriptor<InspectionSession>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        return try modelContext.fetch(descriptor).first
    }

    @discardableResult
    func createSession(teamName: String, vehicleNumber: String, eventYear: Int) throws -> InspectionSession {
        let session = InspectionSession(
            teamName: teamName,
            vehicleNumber: vehicleNumber,
            eventYear: eventYear
        )
        modelContext.insert(session)

        // Create a pending result for every seeded TestCase
        let testCases = try modelContext.fetch(FetchDescriptor<TestCase>())
        for testCase in testCases {
            let result = TestCaseResult(testCase: testCase, session: session)
            session.results.append(result)
            modelContext.insert(result)
        }

        try modelContext.save()
        return session
    }

    func deleteSession(_ session: InspectionSession) throws {
        modelContext.delete(session)
        try modelContext.save()
    }

    func templates() throws -> [InspectionTemplate] {
        let descriptor = FetchDescriptor<InspectionTemplate>(
            sortBy: [SortDescriptor(\.displayOrder)]
        )
        return try modelContext.fetch(descriptor)
    }
}
