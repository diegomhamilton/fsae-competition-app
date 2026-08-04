//
//  LocalSessionCatalogService.swift
//  FSAEInspectionChecklist
//

import Foundation

nonisolated struct LocalSessionCatalogService {
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
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
    }

    func loadSessions(
        eventID: String,
        teamID: String
    ) throws -> [InspectionSessionRecord] {
        let fileURL = catalogURL(eventID: eventID, teamID: teamID)
        guard fileManager.fileExists(atPath: fileURL.path) else {
            return []
        }

        let data = try Data(contentsOf: fileURL)
        return try decoder.decode([InspectionSessionRecord].self, from: data)
    }

    func saveSessions(
        _ sessions: [InspectionSessionRecord],
        eventID: String,
        teamID: String
    ) throws {
        let directory = catalogDirectory(eventID: eventID, teamID: teamID)
        try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        let data = try encoder.encode(sessions.sortedForSessionCatalog())
        try data.write(to: catalogURL(eventID: eventID, teamID: teamID), options: .atomic)
    }

    private func catalogDirectory(
        eventID: String,
        teamID: String
    ) -> URL {
        rootDirectory
            .appendingPathComponent("events", isDirectory: true)
            .appendingPathComponent(Self.safePathComponent(eventID), isDirectory: true)
            .appendingPathComponent("teams", isDirectory: true)
            .appendingPathComponent(Self.safePathComponent(teamID), isDirectory: true)
            .appendingPathComponent("sessions", isDirectory: true)
    }

    private func catalogURL(
        eventID: String,
        teamID: String
    ) -> URL {
        catalogDirectory(eventID: eventID, teamID: teamID)
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

private extension Array where Element == InspectionSessionRecord {
    func sortedForSessionCatalog() -> [InspectionSessionRecord] {
        sorted { lhs, rhs in
            if lhs.startedAt == rhs.startedAt {
                lhs.id < rhs.id
            } else {
                lhs.startedAt > rhs.startedAt
            }
        }
    }
}
