import Foundation
import Testing
@testable import FSAEInspectionChecklist

@MainActor
struct InspectionLocalizationTests {
    @Test("Portuguese checklist covers all six stages without changing official content or identity")
    func completePortugueseChecklist() async throws {
        let stages = try await InspectionContentService().loadOfficialStages()
        #expect(stages.map(\.category) == [.inspection, .inspection, .inspection, .inspection, .test, .test])
        #expect(stages.map { InspectionLocalization.text($0.displayTitle, language: .portuguese) } == [
            "Equipamentos", "Carenagem", "Chassi", "Sistema elétrico", "Saída do piloto", "Chuva",
        ])
        for stage in stages {
            expectTranslation(stage.title)
            expectTranslation(stage.displayTitle)
            if let category = stage.category { expectTranslation(category.title) }
            for section in stage.sections {
                expectTranslation(section.title)
                for testCase in section.testCases {
                    expectTranslation(testCase.title)
                    for step in testCase.steps {
                        expectTranslation(step.content)
                        let translated = InspectionLocalization.text(step.content, language: .portuguese)
                        // Numeric limits, references, polarity and units stay faithful to the bundled sheet.
                        #expect(numbers(in: translated) == numbers(in: step.content))
                        #expect(InspectionLocalization.text(step.content, language: .english) == step.content)
                    }
                }
            }
        }
    }

    @Test("Portuguese uses established inspection terms and keeps original acronyms")
    func inspectionTerminology() {
        #expect(InspectionLocalization.text("Egress Test", language: .portuguese) == "Teste de saída do piloto")
        #expect(InspectionLocalization.text("EV Inspection", language: .portuguese) == "Inspeção elétrica (EV)")
        #expect(InspectionLocalization.text("CAUTION: ENERGIZED", language: .portuguese) == "ATENÇÃO: SISTEMA ENERGIZADO")
        #expect(InspectionLocalization.text("IMD SHUTDOWN TEST", language: .portuguese) == "Teste de desligamento pelo IMD")
    }

    @Test("Unknown text and user-authored notes are preserved; English remains available")
    func fallbackAndLanguageSelection() {
        #expect(InspectionLocalization.text("Equipe 42 — nota original", language: .portuguese) == "Equipe 42 — nota original")
        #expect(InspectionLocalization.text("Pass", language: .english) == "Pass")
    }

    @Test("The installed bundle advertises both languages and always requests the iOS language setting")
    func nativeLanguageSetting() {
        #expect(Set(Bundle.main.localizations).isSuperset(of: ["en", "pt-BR"]))
        #expect(Bundle.main.object(forInfoDictionaryKey: "UIPrefersShowingLanguageSettings") as? Bool == true)
    }

    #if DEBUG
    @Test("The fifth equipment item in the simulator uses the real glove instructions in both languages")
    func gloveInstructionsMatchOfficialContent() async throws {
        let stages = try await InspectionContentService(resources: [.garage]).loadOfficialStages()
        let officialGloves = try #require(stages.first?.orderedSections.flatMap(\.orderedTestCases).first { $0.id == "G5" })
        let previewGloves = try #require(InspectionSnapshotFixtures.stage(for: .gloves)
            .orderedSections.flatMap(\.orderedTestCases).first { $0.displayOrder == 5 })
        let instruction = try #require(previewGloves.orderedSteps.first?.content)

        #expect(previewGloves.title == officialGloves.title)
        #expect(previewGloves.ruleReferences == officialGloves.ruleReferences)
        #expect(instruction == officialGloves.orderedSteps.first?.content)
        #expect(InspectionLocalization.text(instruction, language: .portuguese).contains("Palmas de couro"))
        #expect(InspectionLocalization.text(instruction, language: .english).contains("Leather palms"))
    }
    #endif

    private func expectTranslation(_ source: String, sourceLocation: SourceLocation = #_sourceLocation) {
        #expect(InspectionLocalization.text(source, language: .portuguese) != source, "Missing Portuguese: \(source)", sourceLocation: sourceLocation)
    }

    private func numbers(in value: String) -> [String] {
        value.matches(of: /[0-9]+(?:[.,][0-9]+)*/).map { String($0.output) }.sorted()
    }
}
