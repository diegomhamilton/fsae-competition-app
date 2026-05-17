import Foundation
import SwiftData

// MARK: - Seed DTOs


struct StageDTO: Decodable {
    let code: String
    let title: String
    let displayOrder: Int
    let sections: [SectionDTO]
}

struct SectionDTO: Decodable {
    let title: String
    let displayOrder: Int
    let testCases: [TestCaseDTO]
}

struct TestCaseDTO: Decodable {
    let itemId: String
    let ruleRef: String?
    let title: String
    let displayOrder: Int
    let badges: [String]
    let steps: [StepDTO]
}

struct StepDTO: Decodable {
    let displayOrder: Int
    let type: TestStepType
    let content: String
}

final class InspectionContentLoader {
    private let bundle: Bundle

    init(bundle: Bundle = .main) {
        self.bundle = bundle
    }

    func loadStage(fileName: String) throws -> StageDTO {
        guard let url = bundle.url(forResource: fileName, withExtension: "json") else {
            throw CocoaError(.fileNoSuchFile)
        }

        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(StageDTO.self, from: data)
    }

    func loadStages(fileNames: [String]) throws -> [StageDTO] {
        try fileNames.map(loadStage)
    }
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
            let loader = InspectionContentLoader()
            do {
                let stage = try loader.loadStage(fileName: fileName)
                try insert(stage)
            } catch {
                print("⚠️ Seed file failed to load: \(fileName).json (\(error.localizedDescription))")
                continue
            }
        }

        try modelContext.save()
    }

    private func insert(_ seed: StageDTO) throws {
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
