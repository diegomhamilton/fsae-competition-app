import Testing
import SwiftData
import Foundation
@testable import FSAEInspectionChecklist

// MARK: - Versioning

@Suite("InspectionSeedService — Versioning", .serialized)
struct InspectionSeedServiceTests {

    @Test("seedIfNeeded on fresh store inserts templates")
    func seedIfNeeded_freshStore_insertsTemplates() throws {
        // Arrange
        let container = try makeContainer()
        let context = ModelContext(container)
        resetSeedVersion()
        let service = InspectionSeedService(modelContext: context)

        // Act
        try service.seedIfNeeded()

        // Assert
        let templates = try context.fetch(FetchDescriptor<InspectionTemplate>())
        #expect(templates.count > 0)
    }

    @Test("seedIfNeeded on already-seeded store does not insert duplicates")
    func seedIfNeeded_alreadySeeded_noDuplicates() throws {
        // Arrange
        let container = try makeContainer()
        let context = ModelContext(container)
        resetSeedVersion()
        let service = InspectionSeedService(modelContext: context)
        try service.seedIfNeeded()
        let countAfterFirstSeed = try context.fetch(FetchDescriptor<InspectionTemplate>()).count

        // Act
        try service.seedIfNeeded()

        // Assert
        let countAfterSecondSeed = try context.fetch(FetchDescriptor<InspectionTemplate>()).count
        #expect(countAfterSecondSeed == countAfterFirstSeed)
    }

    @Test("After successful seed, UserDefaults seed version key equals 1")
    func seedIfNeeded_setsUserDefaultsSeedVersion() throws {
        // Arrange
        let container = try makeContainer()
        let context = ModelContext(container)
        resetSeedVersion()
        let service = InspectionSeedService(modelContext: context)

        // Act
        try service.seedIfNeeded()

        // Assert
        #expect(UserDefaults.standard.integer(forKey: seedVersionKey) == 1)
    }
}

// MARK: - Template structure

extension InspectionSeedServiceTests {

    @Test("Exactly 6 templates are seeded")
    func seedIfNeeded_seeds6Templates() throws {
        // Arrange
        let (_, context) = try makeSeededContext()

        // Act
        let templates = try context.fetch(FetchDescriptor<InspectionTemplate>())

        // Assert
        #expect(templates.count == 6)
    }

    @Test("Templates are seeded with the correct codes")
    func seedIfNeeded_correctTemplateCodes() throws {
        // Arrange
        let expectedCodes: Set<String> = ["01_garage", "02_body", "03_chassis", "04_ev", "05_egress", "06_rain"]
        let (_, context) = try makeSeededContext()

        // Act
        let templates = try context.fetch(FetchDescriptor<InspectionTemplate>())
        let codes = Set(templates.map(\.code))

        // Assert
        #expect(codes == expectedCodes)
    }

    @Test("Templates are ordered by displayOrder 1–6 with no gaps")
    func seedIfNeeded_templatesOrderedOneToSix() throws {
        // Arrange
        let (_, context) = try makeSeededContext()

        // Act
        let descriptor = FetchDescriptor<InspectionTemplate>(sortBy: [SortDescriptor(\.displayOrder)])
        let templates = try context.fetch(descriptor)
        let orders = templates.map(\.displayOrder)

        // Assert
        #expect(orders == [1, 2, 3, 4, 5, 6])
    }

    @Test("Every template contains at least one InspectionSection")
    func seedIfNeeded_everyTemplateHasSection() throws {
        // Arrange
        let (_, context) = try makeSeededContext()

        // Act
        let templates = try context.fetch(FetchDescriptor<InspectionTemplate>())

        // Assert
        for template in templates {
            #expect(template.sections.count >= 1, "Template '\(template.code)' has no sections")
        }
    }

    @Test("Every section contains at least one TestCase")
    func seedIfNeeded_everySectionHasTestCase() throws {
        // Arrange
        let (_, context) = try makeSeededContext()

        // Act
        let sections = try context.fetch(FetchDescriptor<InspectionSection>())

        // Assert
        for section in sections {
            #expect(section.testCases.count >= 1, "Section '\(section.title)' has no test cases")
        }
    }
}

// MARK: - TestCase content

extension InspectionSeedServiceTests {

    @Test("EV template contains exactly 120 test cases")
    func seedIfNeeded_evTemplate_has120TestCases() throws {
        // Arrange
        let (_, context) = try makeSeededContext()
        let descriptor = FetchDescriptor<InspectionTemplate>(
            predicate: #Predicate { $0.code == "04_ev" }
        )

        // Act
        let evTemplate = try #require(try context.fetch(descriptor).first)

        // Assert
        #expect(evTemplate.testCases.count == 120)
    }

    @Test("Each test case has a non-empty itemId and title")
    func seedIfNeeded_allTestCasesHaveItemIdAndTitle() throws {
        // Arrange
        let (_, context) = try makeSeededContext()

        // Act
        let testCases = try context.fetch(FetchDescriptor<TestCase>())

        // Assert
        for tc in testCases {
            #expect(!tc.itemId.isEmpty, "TestCase has empty itemId")
            #expect(!tc.title.isEmpty, "TestCase '\(tc.itemId)' has empty title")
        }
    }

    @Test("Every test case has at least one TestStep")
    func seedIfNeeded_everyTestCaseHasStep() throws {
        // Arrange
        let (_, context) = try makeSeededContext()

        // Act
        let testCases = try context.fetch(FetchDescriptor<TestCase>())

        // Assert
        for tc in testCases {
            #expect(tc.steps.count >= 1, "TestCase '\(tc.itemId)' has no steps")
        }
    }

    @Test("Test cases EV101–EV120 carry the CAUTION: ENERGIZED badge")
    func seedIfNeeded_ev101to120_haveEnergizedBadge() throws {
        // Arrange
        let (_, context) = try makeSeededContext()
        let energizedBadge = "CAUTION: ENERGIZED"
        let expectedIds = Set((101...120).map { "EV\($0)" })

        // Act
        let testCases = try context.fetch(FetchDescriptor<TestCase>())
        let ev101to120 = testCases.filter { expectedIds.contains($0.itemId) }

        // Assert
        #expect(ev101to120.count == 20)
        for tc in ev101to120 {
            #expect(tc.badges.contains(energizedBadge), "\(tc.itemId) missing CAUTION: ENERGIZED badge")
        }
    }

    @Test("Test cases EV48–EV56 carry the CAUTION: ENERGIZED badge")
    func seedIfNeeded_ev48to56_haveEnergizedBadge() throws {
        // Arrange
        let (_, context) = try makeSeededContext()
        let energizedBadge = "CAUTION: ENERGIZED"
        let expectedIds = Set((48...56).map { "EV\($0)" })

        // Act
        let testCases = try context.fetch(FetchDescriptor<TestCase>())
        let ev48to56 = testCases.filter { expectedIds.contains($0.itemId) }

        // Assert
        #expect(ev48to56.count == 9)
        for tc in ev48to56 {
            #expect(tc.badges.contains(energizedBadge), "\(tc.itemId) missing CAUTION: ENERGIZED badge")
        }
    }

    @Test("Other EV test cases do not carry the CAUTION: ENERGIZED badge")
    func seedIfNeeded_otherEvTestCases_noEnergizedBadge() throws {
        // Arrange
        let (_, context) = try makeSeededContext()
        let energizedBadge = "CAUTION: ENERGIZED"
        let energizedIds = Set((101...120).map { "EV\($0)" } + (48...56).map { "EV\($0)" })

        // Act
        let descriptor = FetchDescriptor<InspectionTemplate>(
            predicate: #Predicate { $0.code == "04_ev" }
        )
        let evTemplate = try #require(try context.fetch(descriptor).first)
        let otherCases = evTemplate.testCases.filter { !energizedIds.contains($0.itemId) }

        // Assert
        for tc in otherCases {
            #expect(!tc.badges.contains(energizedBadge), "\(tc.itemId) unexpectedly has CAUTION: ENERGIZED badge")
        }
    }

    @Test("Multi-step EV101 produces at least one .instruction step")
    func seedIfNeeded_ev101_hasInstructionStep() throws {
        // Arrange
        let (_, context) = try makeSeededContext()
        let predicate = #Predicate<TestCase> { $0.itemId == "EV101" }

        // Act
        let ev101 = try #require(try context.fetch(FetchDescriptor<TestCase>(predicate: predicate)).first)

        // Assert
        let hasInstruction = ev101.steps.contains { $0.type == .instruction }
        #expect(hasInstruction)
    }
}

// MARK: - TestStep types

extension InspectionSeedServiceTests {

    @Test("Egress test case contains at least one .precondition step")
    func seedIfNeeded_egressTest_hasPreconditionStep() throws {
        // Arrange
        let (_, context) = try makeSeededContext()
        let predicate = #Predicate<TestCase> { $0.itemId == "EgressTest" }

        // Act
        let egressCase = try #require(try context.fetch(FetchDescriptor<TestCase>(predicate: predicate)).first)

        // Assert
        #expect(egressCase.steps.contains { $0.type == .precondition })
    }

    @Test("Egress test case contains at least one .note step")
    func seedIfNeeded_egressTest_hasNoteStep() throws {
        // Arrange
        let (_, context) = try makeSeededContext()
        let predicate = #Predicate<TestCase> { $0.itemId == "EgressTest" }

        // Act
        let egressCase = try #require(try context.fetch(FetchDescriptor<TestCase>(predicate: predicate)).first)

        // Assert
        #expect(egressCase.steps.contains { $0.type == .note })
    }

    @Test("Egress test case contains at least one .instruction step")
    func seedIfNeeded_egressTest_hasInstructionStep() throws {
        // Arrange
        let (_, context) = try makeSeededContext()
        let predicate = #Predicate<TestCase> { $0.itemId == "EgressTest" }

        // Act
        let egressCase = try #require(try context.fetch(FetchDescriptor<TestCase>(predicate: predicate)).first)

        // Assert
        #expect(egressCase.steps.contains { $0.type == .instruction })
    }

    @Test("Rain test case contains at least one .precondition step")
    func seedIfNeeded_rainTest_hasPreconditionStep() throws {
        // Arrange
        let (_, context) = try makeSeededContext()
        let predicate = #Predicate<TestCase> { $0.itemId == "RainTest" }

        // Act
        let rainCase = try #require(try context.fetch(FetchDescriptor<TestCase>(predicate: predicate)).first)

        // Assert
        #expect(rainCase.steps.contains { $0.type == .precondition })
    }

    @Test("EV1 produces exactly one step of type .requirement")
    func seedIfNeeded_ev1_hasSingleRequirementStep() throws {
        // Arrange
        let (_, context) = try makeSeededContext()
        let predicate = #Predicate<TestCase> { $0.itemId == "EV1" }

        // Act
        let ev1 = try #require(try context.fetch(FetchDescriptor<TestCase>(predicate: predicate)).first)

        // Assert
        #expect(ev1.steps.count == 1)
        #expect(ev1.steps.first?.type == .requirement)
    }

    @Test("Steps within a test case have unique sequential displayOrder starting at 1")
    func seedIfNeeded_steps_haveUniqueSequentialOrder() throws {
        // Arrange
        let (_, context) = try makeSeededContext()

        // Act
        let testCases = try context.fetch(FetchDescriptor<TestCase>())

        // Assert
        for tc in testCases {
            let orders = tc.steps.map(\.displayOrder).sorted()
            let expected = Array(1...orders.count)
            #expect(orders == expected, "\(tc.itemId) steps have non-sequential displayOrder: \(orders)")
        }
    }
}
