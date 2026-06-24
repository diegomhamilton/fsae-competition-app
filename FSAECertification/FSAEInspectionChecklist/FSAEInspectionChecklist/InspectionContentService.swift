import Foundation

enum OfficialInspectionResource: String, CaseIterable, Hashable, Sendable {
    case garage
    case body
    case chassis
    case ev
    case egress
    case rain

    var fileName: String {
        switch self {
        case .garage: "01_garage_inspection"
        case .body: "02_body_inspection"
        case .chassis: "03_chassis_inspection"
        case .ev: "04_ev_inspection"
        case .egress: "05_egress_test"
        case .rain: "06_rain_test"
        }
    }
}

enum InspectionContentLoadingError: Error, Equatable, Sendable {
    case missingResource(String)
    case malformedJSON(resourceName: String, details: String)
    case missingRequiredField(resourceName: String, field: String)
    case unsupportedStepType(resourceName: String, value: String)
}

struct InspectionContentService: @unchecked Sendable {
    private let bundle: Bundle
    private let resourceDirectory: String
    private let resources: [OfficialInspectionResource]
    private let resourceURLs: [OfficialInspectionResource: URL]?

    init(
        bundle: Bundle = .main,
        resourceDirectory: String = "InspectionEvent",
        resources: [OfficialInspectionResource] = OfficialInspectionResource.allCases
    ) {
        self.bundle = bundle
        self.resourceDirectory = resourceDirectory
        self.resources = resources
        resourceURLs = nil
    }

    init(resourceURLs: [OfficialInspectionResource: URL]) {
        bundle = .main
        resourceDirectory = "InspectionEvent"
        resources = OfficialInspectionResource.allCases
        self.resourceURLs = resourceURLs
    }

    func loadOfficialStages() async throws -> [InspectionStage] {
        var loadedStages: [InspectionStage] = []

        for resource in resources {
            let data = try data(for: resource)
            let stage = try decodeStage(data, resourceName: resource.fileName)
            loadedStages.append(stage)
        }

        return loadedStages.sorted { lhs, rhs in
            if lhs.displayOrder == rhs.displayOrder {
                lhs.title < rhs.title
            } else {
                lhs.displayOrder < rhs.displayOrder
            }
        }
    }

    func decodeStage(_ data: Data, resourceName: String) throws -> InspectionStage {
        do {
            return try JSONDecoder().decode(InspectionStage.self, from: data)
        } catch {
            throw mapDecodingError(error, resourceName: resourceName)
        }
    }

    private func data(for resource: OfficialInspectionResource) throws -> Data {
        let url: URL?
        if let resourceURLs {
            url = resourceURLs[resource]
        } else {
            url = bundle.url(
                forResource: resource.fileName,
                withExtension: "json",
            )
        }

        guard let url else {
            throw InspectionContentLoadingError.missingResource(resource.fileName)
        }

        guard FileManager.default.fileExists(atPath: url.path) else {
            throw InspectionContentLoadingError.missingResource(resource.fileName)
        }

        do {
            return try Data(contentsOf: url)
        } catch {
            throw InspectionContentLoadingError.malformedJSON(
                resourceName: resource.fileName,
                details: error.localizedDescription
            )
        }
    }

    private func mapDecodingError(
        _ error: Error,
        resourceName: String
    ) -> InspectionContentLoadingError {
        guard let decodingError = error as? DecodingError else {
            return .malformedJSON(resourceName: resourceName, details: error.localizedDescription)
        }

        switch decodingError {
        case .keyNotFound(let key, _):
            return .missingRequiredField(resourceName: resourceName, field: key.stringValue)
        case .dataCorrupted(let context):
            if let value = context.unsupportedStepTypeValue {
                return .unsupportedStepType(resourceName: resourceName, value: value)
            }
            return .malformedJSON(resourceName: resourceName, details: context.debugDescription)
        case .typeMismatch(_, let context), .valueNotFound(_, let context):
            return .malformedJSON(resourceName: resourceName, details: context.debugDescription)
        @unknown default:
            return .malformedJSON(resourceName: resourceName, details: "\(decodingError)")
        }
    }
}

private extension String {
    var deletingJSONExtension: String {
        guard hasSuffix(".json") else {
            return self
        }

        return String(dropLast(5))
    }
}

private extension DecodingError.Context {
    var unsupportedStepTypeValue: String? {
        let prefix = "Unsupported inspection step type: "
        guard debugDescription.hasPrefix(prefix) else {
            return nil
        }

        return String(debugDescription.dropFirst(prefix.count))
    }
}
