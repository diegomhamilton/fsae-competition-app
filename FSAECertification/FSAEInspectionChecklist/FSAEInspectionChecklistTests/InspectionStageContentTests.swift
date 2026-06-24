import Foundation
import Testing
@testable import FSAEInspectionChecklist

@MainActor
struct InspectionStageContentTests {
    @Test("inspection-data stages expose stable identity, title, display order, and ordered sections")
    func inspectionDataStageExposesStableIdentityTitleDisplayOrderAndOrderedSections() {
        let stage = InspectionStage(
            id: "04_ev",
            code: "04_ev",
            title: "EV Inspection",
            displayOrder: 4,
            sections: [
                inspectionSection(id: "04_ev.internal", title: "Accumulator Internal Checks", displayOrder: 2),
                inspectionSection(id: "04_ev.external", title: "External Checks", displayOrder: 1)
            ]
        )

        #expect(stage.id == "04_ev")
        #expect(stage.title == "EV Inspection")
        #expect(stage.displayOrder == 4)
        #expect(stage.orderedSections.map(\.id) == ["04_ev.external", "04_ev.internal"])
        #expect(stage.sectionIDs == ["04_ev.external", "04_ev.internal"])
    }

    @Test("inspection-data sections expose stable identity, title, display order, and ordered test cases")
    func inspectionDataSectionExposesStableIdentityTitleDisplayOrderAndOrderedTestCases() {
        let section = InspectionSection(
            id: "04_ev.external",
            title: "External Checks",
            displayOrder: 1,
            testCases: [
                inspectionTestCase(id: "EV2", displayOrder: 2, title: "SECOND CHECK"),
                inspectionTestCase(id: "EV1", displayOrder: 1, title: "FIRST CHECK")
            ]
        )

        #expect(section.id == "04_ev.external")
        #expect(section.title == "External Checks")
        #expect(section.displayOrder == 1)
        #expect(section.orderedTestCases.map(\.id) == ["EV1", "EV2"])
        #expect(section.testCaseIDs == ["EV1", "EV2"])
    }

    @Test("inspection-data bundled JSON decodes six official stages in display order")
    func inspectionDataBundledJSONDecodesSixOfficialStagesInDisplayOrder() async throws {
        let service = InspectionContentService(resourceURLs: officialInspectionResourceURLs())

        let stages = try await service.loadOfficialStages()

        #expect(stages.map(\.id) == ["01_garage", "02_body", "03_chassis", "04_ev", "05_egress", "06_rain"])
        #expect(stages.map(\.title) == [
            "Garage Inspection",
            "Body Inspection",
            "Chassis Inspection",
            "EV Inspection",
            "Egress Test",
            "Rain Test"
        ])
        #expect(stages.map(\.displayOrder) == [1, 2, 3, 4, 5, 6])
    }

    @Test("inspection-data decoded stages preserve ordered cases, ordered steps, rules, badges, and content")
    func inspectionDataDecodedStagesPreserveOrderedCasesOrderedStepsRulesBadgesAndContent() async throws {
        let service = InspectionContentService(resourceURLs: officialInspectionResourceURLs())

        let stages = try await service.loadOfficialStages()
        let garage = try #require(stages.first { $0.id == "01_garage" })
        let garageSection = try #require(garage.orderedSections.first)
        let firstGarageCase = try #require(garageSection.orderedTestCases.first)
        let ev = try #require(stages.first { $0.id == "04_ev" })
        let energizedCase = try #require(ev.orderedSections.flatMap(\.orderedTestCases).first { $0.id == "EV101" })

        #expect(garageSection.title == "Driver Equipment")
        #expect(Array(garageSection.orderedTestCases.map(\.id).prefix(3)) == ["G1", "G2", "G3"])
        #expect(firstGarageCase.code == "G1")
        #expect(firstGarageCase.ruleReferences == ["VE.3.2"])
        #expect(firstGarageCase.orderedSteps.map(\.type) == [.check])
        #expect(firstGarageCase.orderedSteps.first?.content.contains("Closed-face with integral chin guard") == true)
        #expect(energizedCase.safetyBadges == [.energized])
        #expect(energizedCase.orderedSteps.map(\.displayOrder) == [1, 2, 3, 4, 5])
        #expect(energizedCase.orderedSteps.map(\.type) == [.measurement, .action, .action, .action, .action])
    }

    @Test("inspection-data unsupported step types fail with a typed content error")
    func inspectionDataUnsupportedStepTypesFailWithTypedContentError() throws {
        let service = InspectionContentService(resourceURLs: officialInspectionResourceURLs())

        #expect(throws: InspectionContentLoadingError.self) {
            _ = try service.decodeStage(
                Data(stageJSON(stepType: "unsupported").utf8),
                resourceName: "bad_step_type.json"
            )
        }
    }

    @Test("inspection-data malformed JSON and missing required fields fail with typed content errors")
    func inspectionDataMalformedJSONAndMissingRequiredFieldsFailWithTypedContentErrors() throws {
        let service = InspectionContentService(resourceURLs: officialInspectionResourceURLs())

        #expect(throws: InspectionContentLoadingError.self) {
            _ = try service.decodeStage(Data("{".utf8), resourceName: "malformed.json")
        }

        #expect(throws: InspectionContentLoadingError.self) {
            _ = try service.decodeStage(
                Data(stageJSON(omittingStageTitle: true).utf8),
                resourceName: "missing_title.json"
            )
        }
    }

    @Test("inspection-data missing bundled resources fail before returning partial official content")
    func inspectionDataMissingBundledResourcesFailBeforeReturningPartialOfficialContent() async {
        let service = InspectionContentService(resourceURLs: [
            .garage: URL(fileURLWithPath: "/tmp/missing-garage-inspection.json")
        ])

        var capturedError: InspectionContentLoadingError?
        do {
            _ = try await service.loadOfficialStages()
        } catch let error as InspectionContentLoadingError {
            capturedError = error
        } catch {
            capturedError = nil
        }

        #expect(capturedError == .missingResource("01_garage_inspection.json"))
    }
}

private func inspectionSection(
    id: String,
    title: String,
    displayOrder: Int
) -> InspectionSection {
    InspectionSection(
        id: id,
        title: title,
        displayOrder: displayOrder,
        testCases: [
            inspectionTestCase(id: "\(id).case", displayOrder: 1, title: "\(title) case")
        ]
    )
}

private func inspectionTestCase(
    id: String,
    displayOrder: Int,
    title: String
) -> InspectionTestCase {
    InspectionTestCase(
        id: id,
        code: id,
        displayOrder: displayOrder,
        title: title,
        ruleReferences: ["EV.6.1"],
        steps: [
            InspectionTestStep(
                id: "\(id).step.1",
                code: "\(id)-1",
                displayOrder: 1,
                ruleReference: "EV.6.1",
                title: title,
                type: .check,
                content: "Verify \(title).",
                requiredOutcome: true,
                requiresEvidence: false
            )
        ]
    )
}

private func officialInspectionResourceURLs() -> [OfficialInspectionResource: URL] {
    let testFile = URL(fileURLWithPath: #filePath)
    let repoRoot = testFile
        .deletingLastPathComponent()
        .deletingLastPathComponent()
        .deletingLastPathComponent()
        .deletingLastPathComponent()
    let resourceRoot = repoRoot.appendingPathComponent("Design/Resources/InspectionEvent")

    return OfficialInspectionResource.allCases.reduce(into: [:]) { urls, resource in
        urls[resource] = resourceRoot.appendingPathComponent(resource.fileName)
    }
}

private func stageJSON(
    stepType: String = "check",
    omittingStageTitle: Bool = false
) -> String {
    let titleLine = omittingStageTitle ? "" : #""title": "Bad Stage","#

    return """
    {
      "code": "bad_stage",
      \(titleLine)
      "displayOrder": 1,
      "sections": [
        {
          "title": "Bad Section",
          "displayOrder": 1,
          "testCases": [
            {
              "itemId": "BAD1",
              "ruleRef": "EV.6.1",
              "title": "Bad Case",
              "displayOrder": 1,
              "badges": [],
              "steps": [
                {
                  "displayOrder": 1,
                  "type": "\(stepType)",
                  "content": "Bad content."
                }
              ]
            }
          ]
        }
      ]
    }
    """
}
