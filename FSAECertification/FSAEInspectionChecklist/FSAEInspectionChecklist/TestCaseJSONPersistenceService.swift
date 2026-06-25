import Foundation

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

    init(issue: ValidationIssue) {
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
    }

    func loadDraft(
        context: InspectionPersistenceContext,
        testCaseID: String
    ) throws -> TestCaseDraft? {
        let fileURL = draftFileURL(context: context, testCaseID: testCaseID)
        guard fileManager.fileExists(atPath: fileURL.path) else {
            return nil
        }

        let data = try Data(contentsOf: fileURL)
        return try decoder.decode(TestCaseDraftFile.self, from: data).draft
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

    func deleteDraft(
        context: InspectionPersistenceContext,
        testCaseID: String
    ) throws {
        let fileURL = draftFileURL(context: context, testCaseID: testCaseID)
        guard fileManager.fileExists(atPath: fileURL.path) else {
            return
        }

        try fileManager.removeItem(at: fileURL)
    }

    func submissionsDirectoryURL(context: InspectionPersistenceContext) -> URL {
        sessionDirectoryURL(context: context)
            .appendingPathComponent("submissions")
    }

    private func draftDirectoryURL(context: InspectionPersistenceContext) -> URL {
        sessionDirectoryURL(context: context)
            .appendingPathComponent("drafts")
            .appendingPathComponent(Self.pathComponent(for: context.stageID))
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
