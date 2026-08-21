//
//  TestCaseJSONPersistenceService.swift
//  FSAEInspectionChecklist
//

import Foundation
import os

nonisolated private let persistenceSubsystem: String = Bundle(for: TestCaseJSONPersistenceService.self).bundleIdentifier ?? "Persistence"
nonisolated private let persistenceSignposter = OSSignposter(subsystem: persistenceSubsystem, category: "TestCasePersistence")

nonisolated struct InspectionPersistenceContext: Codable, Hashable, Sendable {
    let eventID: String
    let teamID: String
    let sessionID: String
    let stageID: String
}

nonisolated struct PersistedValidationIssue: Codable, Hashable, Sendable {
    let id: String
    let stepID: String
    let code: String
    let localizationKey: String
    let localizationArguments: [String: String]
    let message: String

    @MainActor init(issue: ValidationIssue) {
        id = issue.id
        stepID = issue.code.stepID
        code = issue.code.storageCode
        localizationKey = issue.localizationKey.rawValue
        localizationArguments = issue.localizationArguments
        message = issue.message
    }
}

nonisolated struct TestCaseDraftFile: Codable, Hashable, Sendable {
    static let currentSchemaVersion = 1

    let schemaVersion: Int
    let eventID: String
    let teamID: String
    let sessionID: String
    let stageID: String
    let testCaseID: String
    let updatedAt: Date
    let testCase: InspectionTestCase
    let stepDrafts: [TestStepDraft]
    let validationSummary: [PersistedValidationIssue]
    let recheckReferences: [String]

    init(
        context: InspectionPersistenceContext,
        draft: TestCaseDraft,
        updatedAt: Date,
        validationSummary: [PersistedValidationIssue],
        recheckReferences: [String] = []
    ) {
        schemaVersion = Self.currentSchemaVersion
        eventID = context.eventID
        teamID = context.teamID
        sessionID = context.sessionID
        stageID = context.stageID
        testCaseID = draft.id
        self.updatedAt = updatedAt
        testCase = draft.testCase
        stepDrafts = draft.stepDrafts
        self.validationSummary = validationSummary
        self.recheckReferences = recheckReferences
    }

    var context: InspectionPersistenceContext {
        InspectionPersistenceContext(
            eventID: eventID,
            teamID: teamID,
            sessionID: sessionID,
            stageID: stageID
        )
    }

    var draft: TestCaseDraft {
        TestCaseDraft(testCase: testCase, stepDrafts: stepDrafts)
    }
}

nonisolated struct SubmittedTestCaseSnapshotFile: Codable, Hashable, Sendable {
    static let currentSchemaVersion = 1

    let schemaVersion: Int
    let submissionID: String
    let eventID: String
    let teamID: String
    let sessionID: String
    let stageID: String
    let testCaseID: String
    let submittedAt: Date
    let testCase: InspectionTestCase
    let stepDrafts: [TestStepDraft]
    let validationSummary: [PersistedValidationIssue]
    let recheckReferences: [String]

    init(
        submissionID: String,
        context: InspectionPersistenceContext,
        draft: TestCaseDraft,
        submittedAt: Date,
        validationSummary: [PersistedValidationIssue],
        recheckReferences: [String] = []
    ) {
        schemaVersion = Self.currentSchemaVersion
        self.submissionID = submissionID
        eventID = context.eventID
        teamID = context.teamID
        sessionID = context.sessionID
        stageID = context.stageID
        testCaseID = draft.id
        self.submittedAt = submittedAt
        testCase = draft.testCase
        stepDrafts = draft.stepDrafts
        self.validationSummary = validationSummary
        self.recheckReferences = recheckReferences
    }
}

nonisolated struct SubmittedStageSnapshotFile: Codable, Hashable, Sendable {
    static let currentSchemaVersion = 1

    let schemaVersion: Int
    let submissionID: String
    let eventID: String
    let teamID: String
    let sessionID: String
    let stageID: String
    let submittedAt: Date
    let testCases: [SubmittedTestCaseSnapshotFile]
    let validationSummary: [PersistedValidationIssue]
    let recheckReferences: [String]

    init(
        submissionID: String,
        context: InspectionPersistenceContext,
        submittedAt: Date,
        testCases: [SubmittedTestCaseSnapshotFile],
        validationSummary: [PersistedValidationIssue],
        recheckReferences: [String] = []
    ) {
        schemaVersion = Self.currentSchemaVersion
        self.submissionID = submissionID
        eventID = context.eventID
        teamID = context.teamID
        sessionID = context.sessionID
        stageID = context.stageID
        self.submittedAt = submittedAt
        self.testCases = testCases
        self.validationSummary = validationSummary
        self.recheckReferences = recheckReferences
    }
}

actor TestCaseJSONPersistenceService {
    private let rootDirectory: URL
    private let fileManager: FileManager
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init(
        rootDirectory: URL? = nil,
        fileManager: FileManager = .default,
        encoder: JSONEncoder = .inspectionPersistenceEncoder,
        decoder: JSONDecoder = .inspectionPersistenceDecoder
    ) {
        self.rootDirectory = rootDirectory ?? Self.defaultRootDirectory(fileManager: fileManager)
        self.fileManager = fileManager
        self.encoder = encoder
        self.decoder = decoder
    }

    func draftFileURL(
        context: InspectionPersistenceContext,
        testCaseID: String
    ) -> URL {
        draftDirectoryURL(context: context)
            .appendingPathComponent(Self.pathComponent(for: testCaseID))
            .appendingPathExtension("json")
    }

    func saveDraft(
        _ draft: TestCaseDraft,
        context: InspectionPersistenceContext,
        updatedAt: Date = Date(),
        recheckReferences: [String] = []
    ) throws -> URL {
        try persistenceSignposter.withIntervalSignpost(
            "Save Draft",
            "testCaseID=\(draft.id, privacy: .public) eventID=\(context.eventID, privacy: .public)"
        ) {
            do {
                let file = TestCaseDraftFile(
                    context: context,
                    draft: draft,
                    updatedAt: updatedAt,
                    validationSummary: draft.validationSummary(for: draft.testCase).issues.map(PersistedValidationIssue.init),
                    recheckReferences: recheckReferences
                )
                let directoryURL = draftDirectoryURL(context: context)
                try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)

                let fileURL = draftFileURL(context: context, testCaseID: draft.id)
                let data = try encoder.encode(file)
                try data.write(to: fileURL, options: .atomic)
                return fileURL
            } catch {
                persistenceSignposter.emitEvent(
                    "Save Draft Error",
                    "testCaseID=\(draft.id, privacy: .public) eventID=\(context.eventID, privacy: .public) error=\(String(describing: error), privacy: .public)"
                )
                throw error
            }
        }
    }

    func loadDraft(
        context: InspectionPersistenceContext,
        testCaseID: String
    ) throws -> TestCaseDraft? {
        try persistenceSignposter.withIntervalSignpost(
            "Load Draft",
            "testCaseID=\(testCaseID, privacy: .public) eventID=\(context.eventID, privacy: .public)"
        ) {
            do {
                let fileURL = draftFileURL(context: context, testCaseID: testCaseID)
                guard fileManager.fileExists(atPath: fileURL.path) else {
                    return nil
                }

                let data = try Data(contentsOf: fileURL)
                return try decoder.decode(TestCaseDraftFile.self, from: data).draft
            } catch {
                persistenceSignposter.emitEvent(
                    "Load Draft Error",
                    "testCaseID=\(testCaseID, privacy: .public) eventID=\(context.eventID, privacy: .public) error=\(String(describing: error), privacy: .public)"
                )
                throw error
            }
        }
    }

    func loadDraftFile(
        context: InspectionPersistenceContext,
        testCaseID: String
    ) throws -> TestCaseDraftFile? {
        let fileURL = draftFileURL(context: context, testCaseID: testCaseID)
        guard fileManager.fileExists(atPath: fileURL.path) else {
            return nil
        }

        let data = try Data(contentsOf: fileURL)
        return try decoder.decode(TestCaseDraftFile.self, from: data)
    }

    func loadDraftFiles(context: InspectionPersistenceContext) throws -> [TestCaseDraftFile] {
        let directoryURL = draftDirectoryURL(context: context)
        guard fileManager.fileExists(atPath: directoryURL.path) else {
            return []
        }

        let fileURLs = try fileManager.contentsOfDirectory(
            at: directoryURL,
            includingPropertiesForKeys: nil
        )

        return try fileURLs
            .filter { $0.pathExtension == "json" }
            .sorted { $0.lastPathComponent < $1.lastPathComponent }
            .map { fileURL in
                let data = try Data(contentsOf: fileURL)
                return try decoder.decode(TestCaseDraftFile.self, from: data)
            }
    }

    func deleteDraft(
        context: InspectionPersistenceContext,
        testCaseID: String
    ) throws {
        try persistenceSignposter.withIntervalSignpost(
            "Delete Draft",
            "testCaseID=\(testCaseID, privacy: .public) eventID=\(context.eventID, privacy: .public)"
        ) {
            do {
                let fileURL = draftFileURL(context: context, testCaseID: testCaseID)
                guard fileManager.fileExists(atPath: fileURL.path) else {
                    return
                }

                try fileManager.removeItem(at: fileURL)
            } catch {
                persistenceSignposter.emitEvent(
                    "Delete Draft Error",
                    "testCaseID=\(testCaseID, privacy: .public) eventID=\(context.eventID, privacy: .public) error=\(String(describing: error), privacy: .public)"
                )
                throw error
            }
        }
    }

    func clearDraftsForSession(context: InspectionPersistenceContext) throws {
        let draftsDirectory = sessionDirectoryURL(context: context)
            .appendingPathComponent("drafts")
        guard fileManager.fileExists(atPath: draftsDirectory.path) else {
            return
        }

        try fileManager.removeItem(at: draftsDirectory)
    }

    func saveSubmittedTestCaseSnapshot(
        _ draft: TestCaseDraft,
        context: InspectionPersistenceContext,
        submissionID: String,
        submittedAt: Date = Date(),
        recheckReferences: [String] = [],
        removeDraft: Bool = true
    ) throws -> URL {
        try persistenceSignposter.withIntervalSignpost(
            "Save Submitted TestCase Snapshot",
            "testCaseID=\(draft.id, privacy: .public) submissionID=\(submissionID, privacy: .public) eventID=\(context.eventID, privacy: .public)"
        ) {
            do {
                let file = SubmittedTestCaseSnapshotFile(
                    submissionID: submissionID,
                    context: context,
                    draft: draft,
                    submittedAt: submittedAt,
                    validationSummary: draft.validationSummary(for: draft.testCase).issues.map(PersistedValidationIssue.init),
                    recheckReferences: recheckReferences
                )
                let directoryURL = submittedTestCasesDirectoryURL(context: context, submissionID: submissionID)
                try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)

                let fileURL = submittedTestCaseFileURL(
                    context: context,
                    submissionID: submissionID,
                    testCaseID: draft.id
                )
                let data = try encoder.encode(file)
                try data.write(to: fileURL, options: .atomic)

                if removeDraft {
                    try deleteDraft(context: context, testCaseID: draft.id)
                }

                return fileURL
            } catch {
                persistenceSignposter.emitEvent(
                    "Save Submitted TestCase Snapshot Error",
                    "testCaseID=\(draft.id, privacy: .public) submissionID=\(submissionID, privacy: .public) eventID=\(context.eventID, privacy: .public) error=\(String(describing: error), privacy: .public)"
                )
                throw error
            }
        }
    }

    func saveSubmittedStageSnapshot(
        submissionID: String,
        context: InspectionPersistenceContext,
        submittedAt: Date = Date(),
        testCases: [SubmittedTestCaseSnapshotFile],
        validationSummary: [PersistedValidationIssue],
        recheckReferences: [String] = []
    ) throws -> URL {
        try persistenceSignposter.withIntervalSignpost(
            "Save Submitted Stage Snapshot",
            "submissionID=\(submissionID, privacy: .public) eventID=\(context.eventID, privacy: .public)"
        ) {
            do {
                let file = SubmittedStageSnapshotFile(
                    submissionID: submissionID,
                    context: context,
                    submittedAt: submittedAt,
                    testCases: testCases,
                    validationSummary: validationSummary,
                    recheckReferences: recheckReferences
                )
                let directoryURL = submissionDirectoryURL(context: context, submissionID: submissionID)
                try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)

                let fileURL = submittedStageSnapshotFileURL(context: context, submissionID: submissionID)
                let data = try encoder.encode(file)
                try data.write(to: fileURL, options: .atomic)
                return fileURL
            } catch {
                persistenceSignposter.emitEvent(
                    "Save Submitted Stage Snapshot Error",
                    "submissionID=\(submissionID, privacy: .public) eventID=\(context.eventID, privacy: .public) error=\(String(describing: error), privacy: .public)"
                )
                throw error
            }
        }
    }

    func loadSubmittedTestCaseSnapshot(
        context: InspectionPersistenceContext,
        submissionID: String,
        testCaseID: String
    ) throws -> SubmittedTestCaseSnapshotFile? {
        try persistenceSignposter.withIntervalSignpost(
            "Load Submitted TestCase Snapshot",
            "testCaseID=\(testCaseID, privacy: .public) submissionID=\(submissionID, privacy: .public) eventID=\(context.eventID, privacy: .public)"
        ) {
            do {
                let fileURL = submittedTestCaseFileURL(
                    context: context,
                    submissionID: submissionID,
                    testCaseID: testCaseID
                )
                guard fileManager.fileExists(atPath: fileURL.path) else {
                    return nil
                }

                let data = try Data(contentsOf: fileURL)
                return try decoder.decode(SubmittedTestCaseSnapshotFile.self, from: data)
            } catch {
                persistenceSignposter.emitEvent(
                    "Load Submitted TestCase Snapshot Error",
                    "testCaseID=\(testCaseID, privacy: .public) submissionID=\(submissionID, privacy: .public) eventID=\(context.eventID, privacy: .public) error=\(String(describing: error), privacy: .public)"
                )
                throw error
            }
        }
    }

    func loadSubmittedStageSnapshot(
        context: InspectionPersistenceContext,
        submissionID: String
    ) throws -> SubmittedStageSnapshotFile? {
        try persistenceSignposter.withIntervalSignpost(
            "Load Submitted Stage Snapshot",
            "submissionID=\(submissionID, privacy: .public) eventID=\(context.eventID, privacy: .public)"
        ) {
            do {
                let fileURL = submittedStageSnapshotFileURL(context: context, submissionID: submissionID)
                guard fileManager.fileExists(atPath: fileURL.path) else {
                    return nil
                }

                let data = try Data(contentsOf: fileURL)
                return try decoder.decode(SubmittedStageSnapshotFile.self, from: data)
            } catch {
                persistenceSignposter.emitEvent(
                    "Load Submitted Stage Snapshot Error",
                    "submissionID=\(submissionID, privacy: .public) eventID=\(context.eventID, privacy: .public) error=\(String(describing: error), privacy: .public)"
                )
                throw error
            }
        }
    }

    func submissionExists(
        context: InspectionPersistenceContext,
        submissionID: String
    ) -> Bool {
        fileManager.fileExists(
            atPath: submissionDirectoryURL(context: context, submissionID: submissionID).path
        )
    }

    func submissionsDirectoryURL(context: InspectionPersistenceContext) -> URL {
        sessionDirectoryURL(context: context)
            .appendingPathComponent("submissions")
    }

    func submissionDirectoryURL(
        context: InspectionPersistenceContext,
        submissionID: String
    ) -> URL {
        submissionsDirectoryURL(context: context)
            .appendingPathComponent(Self.pathComponent(for: submissionID))
    }

    func submittedStageSnapshotFileURL(
        context: InspectionPersistenceContext,
        submissionID: String
    ) -> URL {
        submissionDirectoryURL(context: context, submissionID: submissionID)
            .appendingPathComponent("stage-snapshot")
            .appendingPathExtension("json")
    }

    func submittedTestCaseFileURL(
        context: InspectionPersistenceContext,
        submissionID: String,
        testCaseID: String
    ) -> URL {
        submittedTestCasesDirectoryURL(context: context, submissionID: submissionID)
            .appendingPathComponent(Self.pathComponent(for: testCaseID))
            .appendingPathExtension("json")
    }

    func rechecksDirectoryURL(context: InspectionPersistenceContext) -> URL {
        sessionDirectoryURL(context: context)
            .appendingPathComponent("rechecks")
    }

    private func draftDirectoryURL(context: InspectionPersistenceContext) -> URL {
        sessionDirectoryURL(context: context)
            .appendingPathComponent("drafts")
            .appendingPathComponent(Self.pathComponent(for: context.stageID))
    }

    private func submittedTestCasesDirectoryURL(
        context: InspectionPersistenceContext,
        submissionID: String
    ) -> URL {
        submissionDirectoryURL(context: context, submissionID: submissionID)
            .appendingPathComponent("test-cases")
    }

    private func sessionDirectoryURL(context: InspectionPersistenceContext) -> URL {
        rootDirectory
            .appendingPathComponent("events")
            .appendingPathComponent(Self.pathComponent(for: context.eventID))
            .appendingPathComponent("teams")
            .appendingPathComponent(Self.pathComponent(for: context.teamID))
            .appendingPathComponent("sessions")
            .appendingPathComponent(Self.pathComponent(for: context.sessionID))
    }

    private static func defaultRootDirectory(fileManager: FileManager) -> URL {
        let applicationSupportDirectory = fileManager.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        )[0]
        return applicationSupportDirectory.appendingPathComponent("FSAEInspectionChecklist")
    }

    private static func pathComponent(for rawValue: String) -> String {
        rawValue
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: ":", with: "_")
    }
}

private extension JSONEncoder {
    nonisolated static var inspectionPersistenceEncoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return encoder
    }
}

private extension JSONDecoder {
    nonisolated static var inspectionPersistenceDecoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
}

private extension ValidationIssue.Code {
    var stepID: String {
        switch self {
        case .missingRequiredOutcome(let stepID),
                .missingInspectorNote(let stepID),
                .missingMeasurement(let stepID),
                .invalidMeasurement(let stepID, _),
                .missingRequiredEvidence(let stepID):
            stepID
        }
    }

    var storageCode: String {
        switch self {
        case .missingRequiredOutcome:
            "missingRequiredOutcome"
        case .missingInspectorNote:
            "missingInspectorNote"
        case .missingMeasurement:
            "missingMeasurement"
        case .invalidMeasurement(_, let error):
            "invalidMeasurement.\(error)"
        case .missingRequiredEvidence:
            "missingRequiredEvidence"
        }
    }
}
