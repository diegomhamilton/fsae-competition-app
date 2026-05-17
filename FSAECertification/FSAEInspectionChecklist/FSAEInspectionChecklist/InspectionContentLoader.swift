import Foundation

struct InspectionStageDTO: Codable, Equatable {
    let code: String
    let title: String
    let displayOrder: Int
    let sections: [InspectionSectionDTO]
}

struct InspectionSectionDTO: Codable, Equatable {
    let title: String
    let displayOrder: Int
    let testCases: [InspectionTestCaseDTO]
}

struct InspectionTestCaseDTO: Codable, Equatable {
    let itemId: String
    let ruleRef: String
    let title: String
    let displayOrder: Int
    let badges: [String]
    let steps: [InspectionStepDTO]
}

struct InspectionStepDTO: Codable, Equatable {
    let displayOrder: Int
    let type: InspectionStepTypeDTO
    let content: String
}

enum InspectionStepTypeDTO: String, Codable, Equatable {
    case action
    case check
    case context
    case measurement
    case precondition
}

struct InspectionContentLoader {
    enum LoadError: Error, Equatable, LocalizedError {
        case resourceDirectoryNotFound(String)
        case noStageFiles(URL)
        case fileReadFailed(String)
        case decodingFailed(String, String)

        var errorDescription: String? {
            switch self {
            case .resourceDirectoryNotFound(let directoryName):
                "Inspection content directory '\(directoryName)' was not found in the bundle."
            case .noStageFiles(let directoryURL):
                "No inspection stage JSON files were found in \(directoryURL.path)."
            case .fileReadFailed(let filename):
                "Unable to read inspection stage file '\(filename)'."
            case .decodingFailed(let filename, let reason):
                "Unable to decode inspection stage file '\(filename)': \(reason)"
            }
        }
    }

    private let stageDirectoryURL: URL

    init(stageDirectoryURL: URL) {
        self.stageDirectoryURL = stageDirectoryURL
    }

    init(bundle: Bundle = .main, resourceDirectoryName: String = "InspectionEvent") throws {
        guard let stageDirectoryURL = bundle.url(forResource: resourceDirectoryName, withExtension: nil) else {
            throw LoadError.resourceDirectoryNotFound(resourceDirectoryName)
        }

        self.stageDirectoryURL = stageDirectoryURL
    }

    func loadStageDTOs() throws -> [InspectionStageDTO] {
        let fileURLs = try stageFileURLs()
        let decoder = JSONDecoder()

        let stages = try fileURLs.map { fileURL in
            do {
                let data = try Data(contentsOf: fileURL)
                let stage = try decoder.decode(InspectionStageDTO.self, from: data)
                return stage.sortedByDisplayOrder()
            } catch let error as DecodingError {
                throw LoadError.decodingFailed(fileURL.lastPathComponent, error.deterministicDescription)
            } catch {
                throw LoadError.fileReadFailed(fileURL.lastPathComponent)
            }
        }

        return stages.sorted { lhs, rhs in
            if lhs.displayOrder == rhs.displayOrder {
                return lhs.code < rhs.code
            }

            return lhs.displayOrder < rhs.displayOrder
        }
    }

    private func stageFileURLs() throws -> [URL] {
        var isDirectory: ObjCBool = false
        guard FileManager.default.fileExists(atPath: stageDirectoryURL.path, isDirectory: &isDirectory),
              isDirectory.boolValue
        else {
            throw LoadError.noStageFiles(stageDirectoryURL)
        }

        let fileURLs = try FileManager.default.contentsOfDirectory(
            at: stageDirectoryURL,
            includingPropertiesForKeys: nil
        )
        .filter { $0.pathExtension.lowercased() == "json" }
        .sorted { $0.lastPathComponent < $1.lastPathComponent }

        guard !fileURLs.isEmpty else {
            throw LoadError.noStageFiles(stageDirectoryURL)
        }

        return fileURLs
    }
}

private extension InspectionStageDTO {
    func sortedByDisplayOrder() -> InspectionStageDTO {
        InspectionStageDTO(
            code: code,
            title: title,
            displayOrder: displayOrder,
            sections: sections
                .map { $0.sortedByDisplayOrder() }
                .sorted { $0.displayOrder < $1.displayOrder }
        )
    }
}

private extension InspectionSectionDTO {
    func sortedByDisplayOrder() -> InspectionSectionDTO {
        InspectionSectionDTO(
            title: title,
            displayOrder: displayOrder,
            testCases: testCases
                .map { $0.sortedByDisplayOrder() }
                .sorted { $0.displayOrder < $1.displayOrder }
        )
    }
}

private extension InspectionTestCaseDTO {
    func sortedByDisplayOrder() -> InspectionTestCaseDTO {
        InspectionTestCaseDTO(
            itemId: itemId,
            ruleRef: ruleRef,
            title: title,
            displayOrder: displayOrder,
            badges: badges,
            steps: steps.sorted { $0.displayOrder < $1.displayOrder }
        )
    }
}

private extension DecodingError {
    var deterministicDescription: String {
        switch self {
        case .dataCorrupted(let context):
            "dataCorrupted at \(context.codingPath.pathDescription): \(context.debugDescription)"
        case .keyNotFound(let key, let context):
            "keyNotFound '\(key.stringValue)' at \(context.codingPath.pathDescription): \(context.debugDescription)"
        case .typeMismatch(let type, let context):
            "typeMismatch '\(type)' at \(context.codingPath.pathDescription): \(context.debugDescription)"
        case .valueNotFound(let type, let context):
            "valueNotFound '\(type)' at \(context.codingPath.pathDescription): \(context.debugDescription)"
        @unknown default:
            "unknown decoding error"
        }
    }
}

private extension [CodingKey] {
    var pathDescription: String {
        guard !isEmpty else {
            return "<root>"
        }

        return map(\.stringValue).joined(separator: ".")
    }
}
