import Foundation
import Testing
@testable import FSAEInspectionChecklist

@Suite("Inspection content loading")
struct InspectionContentLoaderTests {
    @Test("loads bundled stage DTOs in display order")
    func loadsBundledStageDTOsInDisplayOrder() throws {
        // Arrange
        let loader = try InspectionContentLoader(bundle: appBundle)

        // Act
        let stages = try loader.loadStageDTOs()

        // Assert
        #expect(stages.map(\.displayOrder) == [1, 2, 3, 4, 5, 6])
        #expect(stages.map(\.title) == [
            "Garage Inspection",
            "Body Inspection",
            "Chassis Inspection",
            "EV Inspection",
            "Egress Test",
            "Rain Test"
        ])
    }

    @Test("decodes representative garage stage shape")
    func decodesRepresentativeGarageStageShape() throws {
        // Arrange
        let loader = try InspectionContentLoader(bundle: appBundle)

        // Act
        let garageStage = try #require(try loader.loadStageDTOs().first { $0.code == "01_garage" })
        let driverEquipment = try #require(garageStage.sections.first)
        let wetTires = try #require(driverEquipment.testCases.first { $0.itemId == "G8" })

        // Assert
        #expect(garageStage.title == "Garage Inspection")
        #expect(garageStage.displayOrder == 1)
        #expect(garageStage.sections.count == 1)
        #expect(driverEquipment.title == "Driver Equipment")
        #expect(driverEquipment.testCases.count == 9)
        #expect(driverEquipment.testCases.map(\.itemId) == [
            "G1", "G2", "G3", "G4", "G5", "G6", "G7", "G8", "G9"
        ])
        #expect(wetTires.steps.count == 1)
        #expect(wetTires.steps.first?.type == .measurement)
    }

    @Test("sorts nested content by display order")
    func sortsNestedContentByDisplayOrder() throws {
        // Arrange
        let directoryURL = try makeTemporaryStageDirectory(
            stageJSON: """
            {
              "code": "ordering",
              "title": "Ordering",
              "displayOrder": 1,
              "sections": [
                {
                  "title": "Second Section",
                  "displayOrder": 2,
                  "testCases": [
                    {
                      "itemId": "B",
                      "ruleRef": "R2",
                      "title": "Second Case",
                      "displayOrder": 2,
                      "badges": [],
                      "steps": [
                        { "displayOrder": 2, "type": "check", "content": "Second step" },
                        { "displayOrder": 1, "type": "check", "content": "First step" }
                      ]
                    },
                    {
                      "itemId": "A",
                      "ruleRef": "R1",
                      "title": "First Case",
                      "displayOrder": 1,
                      "badges": [],
                      "steps": [
                        { "displayOrder": 1, "type": "context", "content": "Only step" }
                      ]
                    }
                  ]
                },
                {
                  "title": "First Section",
                  "displayOrder": 1,
                  "testCases": []
                }
              ]
            }
            """
        )
        defer {
            try? FileManager.default.removeItem(at: directoryURL)
        }
        let loader = InspectionContentLoader(stageDirectoryURL: directoryURL)

        // Act
        let stage = try #require(try loader.loadStageDTOs().first)

        // Assert
        #expect(stage.sections.map(\.title) == ["First Section", "Second Section"])
        #expect(stage.sections[1].testCases.map(\.itemId) == ["A", "B"])
        #expect(stage.sections[1].testCases[1].steps.map(\.content) == ["First step", "Second step"])
    }

    @Test("missing stage directory produces deterministic error")
    func missingStageDirectoryProducesDeterministicError() throws {
        // Arrange
        let missingDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        let loader = InspectionContentLoader(stageDirectoryURL: missingDirectoryURL)

        // Act
        let loadResult = Result {
            try loader.loadStageDTOs()
        }

        // Assert
        guard case .failure(let error) = loadResult,
              case InspectionContentLoader.LoadError.noStageFiles(missingDirectoryURL) = error
        else {
            Issue.record("Expected noStageFiles for \(missingDirectoryURL.path), got \(loadResult)")
            return
        }
    }

    @Test("malformed stage data produces deterministic decoding error")
    func malformedStageDataProducesDeterministicDecodingError() throws {
        // Arrange
        let directoryURL = try makeTemporaryStageDirectory(
            stageJSON: """
            {
              "code": "malformed",
              "title": "Malformed",
              "displayOrder": 1,
              "sections": [
                {
                  "title": "Missing order",
                  "testCases": []
                }
              ]
            }
            """
        )
        defer {
            try? FileManager.default.removeItem(at: directoryURL)
        }
        let loader = InspectionContentLoader(stageDirectoryURL: directoryURL)

        // Act
        let loadResult = Result {
            try loader.loadStageDTOs()
        }

        // Assert
        guard case .failure(let error) = loadResult,
              case InspectionContentLoader.LoadError.decodingFailed("stage.json", let reason) = error
        else {
            Issue.record("Expected decodingFailed for malformed stage JSON, got \(loadResult)")
            return
        }

        #expect(reason.contains("keyNotFound 'displayOrder'"))
    }

    private var appBundle: Bundle {
        get throws {
            try #require(Bundle(identifier: "com.Maia.FSAEInspectionChecklist"))
        }
    }

    private func makeTemporaryStageDirectory(stageJSON: String) throws -> URL {
        let directoryURL = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)

        let fileURL = directoryURL.appendingPathComponent("stage.json")
        try stageJSON.data(using: .utf8)?.write(to: fileURL)

        return directoryURL
    }
}
