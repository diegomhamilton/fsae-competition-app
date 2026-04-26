import Foundation
import SwiftData

// MARK: - Seed DTOs

private struct SeedTemplate: Decodable {
    let code: String
    let title: String
    let displayOrder: Int
    let sections: [SeedSection]
}

private struct SeedSection: Decodable {
    let title: String
    let displayOrder: Int
    let testCases: [SeedTestCase]
}

private struct SeedTestCase: Decodable {
    let itemId: String
    let ruleRef: String?
    let title: String
    let displayOrder: Int
    let badges: [String]
    let steps: [SeedTestStep]
}

private struct SeedTestStep: Decodable {
    let displayOrder: Int
    let type: TestStepType
    let content: String
}

// MARK: - Service

final class InspectionSeedService {
    private let modelContext: ModelContext
    private let seedVersion = 2

    private var currentSeedVersion: Int {
        get { UserDefaults.standard.integer(forKey: "inspection_seed_version") }
        set { UserDefaults.standard.set(newValue, forKey: "inspection_seed_version") }
    }

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func seedIfNeeded() throws {
        guard currentSeedVersion < seedVersion else { return }
        try seed()
        currentSeedVersion = seedVersion
    }

    private func seed() throws {
        let fileNames = [
            "01_garage_inspection",
            "02_body_inspection",
            "03_chassis_inspection",
            "04_ev_inspection",
            "05_egress_test",
            "06_rain_test"
        ]

        for fileName in fileNames {
            guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
                print("⚠️ Seed file not found: \(fileName).json")
                continue
            }
            let data = try Data(contentsOf: url)
            let seedTemplate = try JSONDecoder().decode(SeedTemplate.self, from: data)
            try insert(seedTemplate)
        }

        try modelContext.save()
    }

    private func insert(_ seed: SeedTemplate) throws {
        let template = InspectionTemplate(
            code: seed.code,
            title: seed.title,
            displayOrder: seed.displayOrder
        )
        modelContext.insert(template)

        for seedSection in seed.sections {
            let section = InspectionSection(title: seedSection.title, displayOrder: seedSection.displayOrder)
            section.template = template
            modelContext.insert(section)
            template.sections.append(section)

            for seedCase in seedSection.testCases {
                let testCase = TestCase(
                    itemId: seedCase.itemId,
                    ruleRef: seedCase.ruleRef,
                    title: seedCase.title,
                    displayOrder: seedCase.displayOrder,
                    badges: seedCase.badges
                )
                testCase.section = section
                testCase.template = template
                modelContext.insert(testCase)
                section.testCases.append(testCase)
                template.testCases.append(testCase)

                for seedStep in seedCase.steps {
                    let step = TestStep(
                        displayOrder: seedStep.displayOrder,
                        type: seedStep.type,
                        content: seedStep.content
                    )
                    step.testCase = testCase
                    modelContext.insert(step)
                    testCase.steps.append(step)
                }
            }
        }
    }
}
