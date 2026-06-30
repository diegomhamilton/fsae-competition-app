//
//  MockInspectionTestStepFixtureLoader.swift
//  FSAEInspectionChecklist
//

import Foundation

enum MockInspectionTestStepFixtureLoader {
    enum FixtureError: Error, Equatable {
        case missingResource(String)
    }

    static func loadStep(named name: String, bundle: Bundle = .main) async throws -> InspectionTestStep {
        guard let url = bundle.url(
            forResource: name,
            withExtension: "json",
            subdirectory: "MockInspectionTestSteps"
        ) else {
            throw FixtureError.missingResource(name)
        }

        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(InspectionTestStep.self, from: data)
    }

    static func loadRepresentativeSteps(bundle: Bundle = .main) async throws -> [InspectionTestStep] {
        var steps: [InspectionTestStep] = []
        for name in representativeFixtureNames {
            try await steps.append(loadStep(named: name, bundle: bundle))
        }
        return steps
    }

    static let representativeFixtureNames = [
        "check_step",
        "measurement_step",
        "evidence_required_step",
        "energized_step",
        "passing_step",
        "failing_step",
        "pending_step",
        "edge_case_step"
    ]
}
