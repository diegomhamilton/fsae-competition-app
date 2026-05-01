import Foundation
import SwiftData
import Testing
@testable import FSAEInspectionChecklist

struct FSAEInspectionChecklistTests {

    // MARK: - Shared helpers

    private func makeContainer() throws -> ModelContainer {
        let schema = Schema([
            InspectionTemplate.self,
            InspectionSection.self,
            TestCase.self,
            TestStep.self,
            InspectionSession.self,
            TestCaseResult.self
        ])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        return try ModelContainer(for: schema, configurations: [configuration])
    }

    @discardableResult
    private func makeTemplate(
        in context: ModelContext,
        code: String = "01_template",
        order: Int = 1,
        sectionOrders: [Int] = [1],
        testCasesPerSection: Int = 2
    ) -> InspectionTemplate {
        let template = InspectionTemplate(code: code, title: "Template \(code)", displayOrder: order)
        context.insert(template)

        for sectionOrder in sectionOrders {
            let section = InspectionSection(title: "Section \(sectionOrder)", displayOrder: sectionOrder)
            section.template = template
            template.sections.append(section)
            context.insert(section)

            for itemIndex in 1...testCasesPerSection {
                let testCase = TestCase(
                    itemId: "\(code)-S\(sectionOrder)-I\(itemIndex)",
                    title: "Item \(itemIndex)",
                    displayOrder: itemIndex
                )
                testCase.section = section
                testCase.template = template
                section.testCases.append(testCase)
                template.testCases.append(testCase)
                context.insert(testCase)
            }
        }

        return template
    }

    // MARK: - InspectionSessionService

    @Test func createSession_persistsProvidedFieldsAndPendingResults() throws {
        let container = try makeContainer()
        let context = ModelContext(container)
        let template = makeTemplate(in: context, code: "01", order: 1, sectionOrders: [1, 2], testCasesPerSection: 3)
        #expect(template.testCases.count == 6)

        let service = InspectionSessionService(modelContext: context)
        let session = try service.createSession(teamName: "Alpha", vehicleNumber: "42", eventYear: 2026)

        #expect(session.teamName == "Alpha")
        #expect(session.vehicleNumber == "42")
        #expect(session.eventYear == 2026)
        #expect(abs(session.createdAt.timeIntervalSinceNow) < 2)
        #expect(session.results.count == 6)
        #expect(session.results.allSatisfy { $0.status == .pending })
    }

    @Test func activeSession_returnsNilThenLatestSession() throws {
        let container = try makeContainer()
        let context = ModelContext(container)
        makeTemplate(in: context)

        let service = InspectionSessionService(modelContext: context)
        #expect(try service.activeSession() == nil)

        let first = try service.createSession(teamName: "A", vehicleNumber: "1", eventYear: 2025)
        usleep(5_000)
        let second = try service.createSession(teamName: "B", vehicleNumber: "2", eventYear: 2026)

        #expect(try service.activeSession()?.persistentModelID == second.persistentModelID)
        let sessions = try context.fetch(FetchDescriptor<InspectionSession>())
        #expect(sessions.count == 2)
        #expect(sessions.contains(where: { $0.persistentModelID == first.persistentModelID }))
    }

    @Test func deleteSession_removesSessionAndAssociatedResults() throws {
        let container = try makeContainer()
        let context = ModelContext(container)
        makeTemplate(in: context, testCasesPerSection: 4)

        let service = InspectionSessionService(modelContext: context)
        let session = try service.createSession(teamName: "Team", vehicleNumber: "9", eventYear: 2026)
        #expect(session.results.count == 4)

        try service.deleteSession(session)

        #expect(try service.activeSession() == nil)
        let remainingResults = try context.fetch(FetchDescriptor<TestCaseResult>())
        #expect(remainingResults.isEmpty)
    }

    @Test func templates_returnsAllSortedByDisplayOrder() throws {
        let container = try makeContainer()
        let context = ModelContext(container)

        _ = makeTemplate(in: context, code: "02", order: 2)
        _ = makeTemplate(in: context, code: "01", order: 1)
        _ = makeTemplate(in: context, code: "03", order: 3)

        let service = InspectionSessionService(modelContext: context)
        let templates = try service.templates()

        #expect(templates.count == 3)
        #expect(templates.map(\.displayOrder) == [1, 2, 3])
        #expect(templates.map(\.code) == ["01", "02", "03"])
    }

    // MARK: - TestCaseResultService

    @Test func resultFor_returnsExpectedMatchOrNil() throws {
        let container = try makeContainer()
        let context = ModelContext(container)

        let template = makeTemplate(in: context, code: "R", testCasesPerSection: 2)
        let testCase1 = try #require(template.testCases.first)
        let testCase2 = try #require(template.testCases.last)

        let sessionService = InspectionSessionService(modelContext: context)
        let session = try sessionService.createSession(teamName: "Team", vehicleNumber: "7", eventYear: 2026)

        let resultService = TestCaseResultService(modelContext: context)

        #expect(resultService.result(for: testCase1, in: session) != nil)

        let missingCase = TestCase(itemId: "missing", title: "Missing", displayOrder: 999)
        #expect(resultService.result(for: missingCase, in: session) == nil)

        let secondSession = try sessionService.createSession(teamName: "Team2", vehicleNumber: "8", eventYear: 2026)
        let secondResult = resultService.result(for: testCase2, in: secondSession)
        #expect(secondResult != nil)
    }

    @Test func setStatusAndNotes_updateFieldsAndTimestamp() throws {
        let container = try makeContainer()
        let context = ModelContext(container)
        let template = makeTemplate(in: context)
        let session = try InspectionSessionService(modelContext: context)
            .createSession(teamName: "Team", vehicleNumber: "1", eventYear: 2026)
        let resultService = TestCaseResultService(modelContext: context)

        let testCase = try #require(template.testCases.first)
        let result = try #require(resultService.result(for: testCase, in: session))

        let firstUpdatedAt = result.updatedAt
        usleep(5_000)
        try resultService.setStatus(.pass, for: result)
        #expect(result.status == .pass)
        #expect(result.updatedAt > firstUpdatedAt)

        let secondUpdatedAt = result.updatedAt
        usleep(5_000)
        try resultService.setStatus(.notApplicable, for: result)
        #expect(result.status == .notApplicable)
        #expect(result.updatedAt > secondUpdatedAt)

        try resultService.setNotes("inspected", for: result)
        #expect(result.inspectorNotes == "inspected")

        try resultService.setNotes("", for: result)
        #expect(result.inspectorNotes == nil)
    }

    @Test func progress_countsOnlyTemplateResultsAndTreatsNonPendingAsCompleted() throws {
        let container = try makeContainer()
        let context = ModelContext(container)

        let templateA = makeTemplate(in: context, code: "A", order: 1, testCasesPerSection: 3)
        let templateB = makeTemplate(in: context, code: "B", order: 2, testCasesPerSection: 2)

        let session = try InspectionSessionService(modelContext: context)
            .createSession(teamName: "Team", vehicleNumber: "1", eventYear: 2026)
        let resultService = TestCaseResultService(modelContext: context)

        #expect(resultService.progress(for: templateA, in: session) == (0, 3))

        for testCase in templateA.testCases.prefix(2) {
            let result = try #require(resultService.result(for: testCase, in: session))
            try resultService.setStatus(.fail, for: result)
        }
        let naResult = try #require(resultService.result(for: templateA.testCases[2], in: session))
        try resultService.setStatus(.notApplicable, for: naResult)

        let bResult = try #require(resultService.result(for: templateB.testCases[0], in: session))
        try resultService.setStatus(.pass, for: bResult)

        #expect(resultService.progress(for: templateA, in: session) == (3, 3))
        #expect(resultService.progress(for: templateB, in: session) == (1, 2))

        let emptyTemplate = InspectionTemplate(code: "EMPTY", title: "Empty", displayOrder: 99)
        context.insert(emptyTemplate)
        #expect(resultService.progress(for: emptyTemplate, in: session) == (0, 0))
    }

    // MARK: - ViewModels

    @Test func activeSessionViewModel_createSession_successAndFailurePaths() throws {
        let container = try makeContainer()
        let context = ModelContext(container)
        let template = makeTemplate(in: context)
        let sessionService = InspectionSessionService(modelContext: context)
        let resultService = TestCaseResultService(modelContext: context)

        let viewModel = ActiveSessionViewModel()
        viewModel.configure(with: sessionService, resultService: resultService)
        viewModel.createSession(teamName: "Team", vehicleNumber: "10", eventYear: 2026)

        #expect(viewModel.errorMessage == nil)

        let session = try #require(try sessionService.activeSession())
        let progress = viewModel.progress(for: template, in: session)
        #expect(progress == (0, template.testCases.count))
    }

    @Test func inspectionStageViewModel_sectionsAndTestCases_areSortedAndScoped() throws {
        let container = try makeContainer()
        let context = ModelContext(container)

        let template = InspectionTemplate(code: "S", title: "Stage", displayOrder: 1)
        context.insert(template)

        let section2 = InspectionSection(title: "S2", displayOrder: 2)
        let section1 = InspectionSection(title: "S1", displayOrder: 1)
        section1.template = template
        section2.template = template
        template.sections = [section2, section1]
        context.insert(section1)
        context.insert(section2)

        let tc2 = TestCase(itemId: "TC2", title: "Two", displayOrder: 2)
        let tc1 = TestCase(itemId: "TC1", title: "One", displayOrder: 1)
        [tc1, tc2].forEach {
            $0.section = section1
            $0.template = template
            context.insert($0)
        }
        section1.testCases = [tc2, tc1]
        template.testCases = [tc2, tc1]

        let sessionService = InspectionSessionService(modelContext: context)
        let session = try sessionService.createSession(teamName: "Team", vehicleNumber: "11", eventYear: 2026)
        let resultService = TestCaseResultService(modelContext: context)

        let viewModel = InspectionStageViewModel(template: template, session: session)
        viewModel.configure(with: resultService)

        #expect(viewModel.sections.map(\.displayOrder) == [1, 2])
        #expect(viewModel.testCases(in: section1).map(\.itemId) == ["TC1", "TC2"])
        #expect(viewModel.testCases(in: section2).isEmpty)

        let first = try #require(viewModel.testCases(in: section1).first)
        viewModel.activate(first)
        #expect(viewModel.activeTestCase()?.itemId == "TC1")

        let firstResult = try #require(resultService.result(for: first, in: session))
        try resultService.setStatus(.pass, for: firstResult)

        #expect(viewModel.jumpToNextPendingFromActive()?.itemId == "TC2")
    }

    @Test func testCaseDetailViewModel_sortedStepsAndMutations_workAsExpected() throws {
        let container = try makeContainer()
        let context = ModelContext(container)

        let template = makeTemplate(in: context, code: "D", testCasesPerSection: 1)
        let testCase = try #require(template.testCases.first)
        let step2 = TestStep(displayOrder: 2, type: .instruction, content: "Second")
        let step1 = TestStep(displayOrder: 1, type: .requirement, content: "First")
        step1.testCase = testCase
        step2.testCase = testCase
        context.insert(step1)
        context.insert(step2)
        testCase.steps = [step2, step1]

        let session = try InspectionSessionService(modelContext: context)
            .createSession(teamName: "Team", vehicleNumber: "12", eventYear: 2026)
        let resultService = TestCaseResultService(modelContext: context)

        let viewModel = TestCaseDetailViewModel(testCase: testCase, session: session)
        viewModel.configure(with: resultService)

        #expect(viewModel.sortedSteps.map(\.displayOrder) == [1, 2])
        #expect(viewModel.result != nil)

        viewModel.setStatus(.pass)
        #expect(viewModel.result?.status == .pass)
        viewModel.setNotes("checked")
        #expect(viewModel.result?.inspectorNotes == "checked")
        #expect(viewModel.errorMessage == nil)
    }
}
