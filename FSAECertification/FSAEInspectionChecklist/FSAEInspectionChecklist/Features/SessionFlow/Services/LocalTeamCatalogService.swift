//
//  LocalTeamCatalogService.swift
//  FSAEInspectionChecklist
//

import Foundation

nonisolated struct LocalTeamCatalogService {
    private let rootDirectory: URL
    private let fileManager: FileManager
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init(
        rootDirectory: URL? = nil,
        fileManager: FileManager = .default
    ) {
        self.rootDirectory = rootDirectory ?? Self.defaultRootDirectory(fileManager: fileManager)
        self.fileManager = fileManager
        encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        decoder = JSONDecoder()
    }

    func loadTeams(eventID: String) throws -> [InspectionEventTeamRecord] {
        let fileURL = catalogURL(eventID: eventID)
        guard fileManager.fileExists(atPath: fileURL.path) else {
            return []
        }

        let data = try Data(contentsOf: fileURL)
        return try decoder.decode([InspectionEventTeamRecord].self, from: data)
    }

    func saveTeams(
        _ teams: [InspectionEventTeamRecord],
        eventID: String
    ) throws {
        let eventDirectory = catalogDirectory(eventID: eventID)
        try fileManager.createDirectory(at: eventDirectory, withIntermediateDirectories: true)
        let data = try encoder.encode(teams.sortedForCatalog())
        try data.write(to: catalogURL(eventID: eventID), options: .atomic)
    }

    private func catalogDirectory(eventID: String) -> URL {
        rootDirectory
            .appendingPathComponent("events", isDirectory: true)
            .appendingPathComponent(Self.safePathComponent(eventID), isDirectory: true)
            .appendingPathComponent("teams", isDirectory: true)
    }

    private func catalogURL(eventID: String) -> URL {
        catalogDirectory(eventID: eventID)
            .appendingPathComponent("catalog.json")
    }

    private static func defaultRootDirectory(fileManager: FileManager) -> URL {
        let supportDirectory = fileManager.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first ?? fileManager.temporaryDirectory

        return supportDirectory.appendingPathComponent(
            "FSAEInspectionChecklist",
            isDirectory: true
        )
    }

    private static func safePathComponent(_ value: String) -> String {
        value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "/", with: "-")
            .replacingOccurrences(of: ":", with: "-")
    }
}

private extension Array where Element == InspectionEventTeamRecord {
    func sortedForCatalog() -> [InspectionEventTeamRecord] {
        sorted { lhs, rhs in
            if lhs.carNumber == rhs.carNumber {
                lhs.displayName < rhs.displayName
            } else {
                lhs.carNumber < rhs.carNumber
            }
        }
    }
}
