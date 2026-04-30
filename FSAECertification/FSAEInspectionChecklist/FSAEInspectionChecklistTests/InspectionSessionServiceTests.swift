import Testing
import SwiftData
import Foundation
@testable import FSAEInspectionChecklist

// MARK: - createSession

@Suite("InspectionSessionService — createSession")
struct InspectionSessionServiceTests {

    @Test("createSession stores the provided teamName, vehicleNumber, and eventYear")
    func createSession_storesProvidedFields() throws {
        // Arrange
        let container = try makeContainer()
        let context = ModelContext(container)
        let service = InspectionSessionService(modelContext: context)

        // Act
        let session = try service.createSession(teamName: "Velocity", vehicleNumber: "42", eventYear: 2025)

        // Assert
        #expect(session.teamName == "Velocity")
        #expect(session.vehicleNumber == "42")
        #expect(session.eventYear == 2025)
    }

    @Test("createSession sets createdAt to approximately Date()")
    func createSession_setsCreatedAtToNow() throws {
        // Arrange
        let container = try makeContainer()
        let context = ModelContext(container)
        let service = InspectionSessionService(modelContext: context)
        let before = Date()

        // Act
        let session = try service.createSession(teamName: "Team", vehicleNumber: "1", eventYear: 2025)

        // Assert
        let after = Date()
        #expect(session.createdAt >= before)
        #expect(session.createdAt <= after)
    }

    @Test("createSession creates one TestCaseResult per seeded TestCase")
    func createSession_createsResultPerTestCase() throws {
        // Arrange
        let container = try makeContainer()
        let context = ModelContext(container)
        let template = insertTemplate(in: context, code: "t1", displayOrder: 1)
        let section = insertSection(in: context, template: template)
        insertTestCase(in: context, itemId: "TC1", displayOrder: 1, section: section, template: template)
        insertTestCase(in: context, itemId: "TC2", displayOrder: 2, section: section, template: template)
        insertTestCase(in: context, itemId: "TC3", displayOrder: 3, section: section, template: template)
        let service = InspectionSessionService(modelContext: context)

        // Act
        let session = try service.createSession(teamName: "Team", vehicleNumber: "1", eventYear: 2025)

        // Assert
        #expect(session.results.count == 3)
    }

    @Test("All created TestCaseResults have initial status .pending")
    func createSession_allResultsInitiallyPending() throws {
        // Arrange
        let container = try makeContainer()
        let context = ModelContext(container)
        let template = insertTemplate(in: context, displayOrder: 1)
        let section = insertSection(in: context, template: template)
        insertTestCase(in: context, itemId: "TC1", displayOrder: 1, section: section, template: template)
        insertTestCase(in: context, itemId: "TC2", displayOrder: 2, section: section, template: template)
        let service = InspectionSessionService(modelContext: context)

        // Act
        let session = try service.createSession(teamName: "Team", vehicleNumber: "1", eventYear: 2025)

        // Assert
        for result in session.results {
            #expect(result.status == .pending)
        }
    }

    @Test("Creating a second session does not delete the first")
    func createSession_secondSession_doesNotDeleteFirst() throws {
        // Arrange
        let container = try makeContainer()
        let context = ModelContext(container)
        let service = InspectionSessionService(modelContext: context)

        // Act
        try service.createSession(teamName: "Alpha", vehicleNumber: "1", eventYear: 2025)
        try service.createSession(teamName: "Beta", vehicleNumber: "2", eventYear: 2025)

        // Assert
        let sessions = try context.fetch(FetchDescriptor<InspectionSession>())
        #expect(sessions.count == 2)
    }
}

// MARK: - activeSession

extension InspectionSessionServiceTests {

    @Test("activeSession returns nil when no session exists")
    func activeSession_noSessions_returnsNil() throws {
        // Arrange
        let container = try makeContainer()
        let context = ModelContext(container)
        let service = InspectionSessionService(modelContext: context)

        // Act
        let result = try service.activeSession()

        // Assert
        #expect(result == nil)
    }

    @Test("activeSession returns the single session when one exists")
    func activeSession_oneSession_returnsThatSession() throws {
        // Arrange
        let container = try makeContainer()
        let context = ModelContext(container)
        let service = InspectionSessionService(modelContext: context)
        try service.createSession(teamName: "Only", vehicleNumber: "7", eventYear: 2025)

        // Act
        let result = try service.activeSession()

        // Assert
        let session = try #require(result)
        #expect(session.teamName == "Only")
    }

    @Test("activeSession returns the most recently created session when multiple exist")
    func activeSession_multipleSessions_returnsMostRecent() throws {
        // Arrange
        let container = try makeContainer()
        let context = ModelContext(container)
        let service = InspectionSessionService(modelContext: context)
        try service.createSession(teamName: "First", vehicleNumber: "1", eventYear: 2024)
        try service.createSession(teamName: "Second", vehicleNumber: "2", eventYear: 2025)

        // Act
        let result = try service.activeSession()

        // Assert
        let session = try #require(result)
        #expect(session.teamName == "Second")
    }
}

// MARK: - deleteSession

extension InspectionSessionServiceTests {

    @Test("deleteSession removes the session from the store")
    func deleteSession_removesSession() throws {
        // Arrange
        let container = try makeContainer()
        let context = ModelContext(container)
        let service = InspectionSessionService(modelContext: context)
        try service.createSession(teamName: "Temp", vehicleNumber: "9", eventYear: 2025)
        let session = try #require(try service.activeSession())

        // Act
        try service.deleteSession(session)

        // Assert
        #expect(try service.activeSession() == nil)
    }

    @Test("deleteSession cascade-deletes all associated TestCaseResults")
    func deleteSession_cascadeDeletesResults() throws {
        // Arrange
        let container = try makeContainer()
        let context = ModelContext(container)
        let template = insertTemplate(in: context, displayOrder: 1)
        let section = insertSection(in: context, template: template)
        let tc = insertTestCase(in: context, itemId: "TC1", displayOrder: 1, section: section, template: template)
        let service = InspectionSessionService(modelContext: context)
        let session = try service.createSession(teamName: "Team", vehicleNumber: "1", eventYear: 2025)
        _ = tc  // referenced to suppress warning

        // Act
        try service.deleteSession(session)

        // Assert
        let remainingResults = try context.fetch(FetchDescriptor<TestCaseResult>())
        #expect(remainingResults.isEmpty)
    }
}

// MARK: - templates

extension InspectionSessionServiceTests {

    @Test("templates() returns all seeded templates")
    func templates_returnsAllTemplates() throws {
        // Arrange
        let container = try makeContainer()
        let context = ModelContext(container)
        insertTemplate(in: context, code: "t1", displayOrder: 1)
        insertTemplate(in: context, code: "t2", displayOrder: 2)
        insertTemplate(in: context, code: "t3", displayOrder: 3)
        let service = InspectionSessionService(modelContext: context)

        // Act
        let templates = try service.templates()

        // Assert
        #expect(templates.count == 3)
    }

    @Test("templates() returns templates sorted ascending by displayOrder")
    func templates_sortedAscendingByDisplayOrder() throws {
        // Arrange
        let container = try makeContainer()
        let context = ModelContext(container)
        insertTemplate(in: context, code: "t3", displayOrder: 3)
        insertTemplate(in: context, code: "t1", displayOrder: 1)
        insertTemplate(in: context, code: "t2", displayOrder: 2)
        let service = InspectionSessionService(modelContext: context)

        // Act
        let templates = try service.templates()
        let orders = templates.map(\.displayOrder)

        // Assert
        #expect(orders == orders.sorted())
    }
}
