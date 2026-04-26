import Foundation
import SwiftData
@testable import FSAEInspectionChecklist

// MARK: - Container

func makeContainer() throws -> ModelContainer {
    let schema = Schema([
        InspectionTemplate.self,
        InspectionSection.self,
        TestCase.self,
        TestStep.self,
        InspectionSession.self,
        TestCaseResult.self
    ])
    return try ModelContainer(for: schema, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
}

// MARK: - Seed helpers

let seedVersionKey = "inspection_seed_version"

func resetSeedVersion() {
    UserDefaults.standard.removeObject(forKey: seedVersionKey)
}

func makeSeededContext() throws -> (container: ModelContainer, context: ModelContext) {
    let container = try makeContainer()
    let context = ModelContext(container)
    resetSeedVersion()
    let service = InspectionSeedService(modelContext: context)
    try service.seedIfNeeded()
    return (container, context)
}

// MARK: - Model builders

@discardableResult
func insertTemplate(
    in context: ModelContext,
    code: String = "test",
    title: String = "Test",
    displayOrder: Int = 1
) -> InspectionTemplate {
    let template = InspectionTemplate(code: code, title: title, displayOrder: displayOrder)
    context.insert(template)
    return template
}

@discardableResult
func insertSection(
    in context: ModelContext,
    title: String = "Section",
    displayOrder: Int = 1,
    template: InspectionTemplate
) -> InspectionSection {
    let section = InspectionSection(title: title, displayOrder: displayOrder)
    section.template = template
    template.sections.append(section)
    context.insert(section)
    return section
}

@discardableResult
func insertTestCase(
    in context: ModelContext,
    itemId: String,
    title: String = "Test Case",
    displayOrder: Int = 1,
    badges: [String] = [],
    section: InspectionSection,
    template: InspectionTemplate
) -> TestCase {
    let tc = TestCase(itemId: itemId, title: title, displayOrder: displayOrder, badges: badges)
    tc.section = section
    tc.template = template
    section.testCases.append(tc)
    template.testCases.append(tc)
    context.insert(tc)
    return tc
}

@discardableResult
func insertStep(
    in context: ModelContext,
    displayOrder: Int,
    type: TestStepType,
    content: String = "content",
    testCase: TestCase
) -> TestStep {
    let step = TestStep(displayOrder: displayOrder, type: type, content: content)
    step.testCase = testCase
    testCase.steps.append(step)
    context.insert(step)
    return step
}

func insertSession(
    in context: ModelContext,
    teamName: String = "Team A",
    vehicleNumber: String = "1",
    eventYear: Int = 2025,
    for testCases: [TestCase] = []
) -> InspectionSession {
    let session = InspectionSession(teamName: teamName, vehicleNumber: vehicleNumber, eventYear: eventYear)
    context.insert(session)
    for tc in testCases {
        let result = TestCaseResult(testCase: tc, session: session)
        session.results.append(result)
        context.insert(result)
    }
    return session
}
