//
//  SubmissionSnapshotService.swift
//  FSAEInspectionChecklist
//

import Foundation

nonisolated struct SubmissionSnapshotResult: Sendable {
    let snapshot: SubmittedStageSnapshotFile
    let stageSnapshotURL: URL
    let testCaseSnapshotURLs: [URL]
}

nonisolated enum SubmissionSnapshotError: Error, Equatable, Sendable {
    case emptyStageSubmission
    case duplicateTestCaseID(String)
    case missingSubmittedTestCaseSnapshot(String)
    case missingSubmittedStageSnapshot(String)
    case submissionAlreadyExists(String)
}

actor SubmissionSnapshotService {
    private let persistence: TestCaseJSONPersistenceService

    init(persistence: TestCaseJSONPersistenceService = TestCaseJSONPersistenceService()) {
        self.persistence = persistence
    }

    func createStageSnapshot(
        context: InspectionPersistenceContext,
        submissionID: String,
        drafts: [TestCaseDraft],
        submittedAt: Date = Date(),
        recheckReferencesByTestCaseID: [String: [String]] = [:],
        recheckReferences: [String] = []
    ) async throws -> SubmissionSnapshotResult {
        try await validateNewSubmission(
            context: context,
            submissionID: submissionID,
            drafts: drafts
        )

        var testCaseSnapshotURLs: [URL] = []
        var testCaseSnapshots: [SubmittedTestCaseSnapshotFile] = []

        for draft in drafts {
            let references = recheckReferencesByTestCaseID[draft.id] ?? []
            let fileURL = try await persistence.saveSubmittedTestCaseSnapshot(
                draft,
                context: context,
                submissionID: submissionID,
                submittedAt: submittedAt,
                recheckReferences: references
            )
            let snapshot = try await persistence.loadSubmittedTestCaseSnapshot(
                context: context,
                submissionID: submissionID,
                testCaseID: draft.id
            )
            guard let snapshot else {
                throw SubmissionSnapshotError.missingSubmittedTestCaseSnapshot(draft.id)
            }

            testCaseSnapshotURLs.append(fileURL)
            testCaseSnapshots.append(snapshot)
        }

        let stageRecheckReferences = recheckReferences.isEmpty
            ? uniqueRecheckReferences(from: testCaseSnapshots)
            : recheckReferences
        let stageSnapshotURL = try await persistence.saveSubmittedStageSnapshot(
            submissionID: submissionID,
            context: context,
            submittedAt: submittedAt,
            testCases: testCaseSnapshots,
            validationSummary: testCaseSnapshots.flatMap(\.validationSummary),
            recheckReferences: stageRecheckReferences
        )
        let stageSnapshot = try await persistence.loadSubmittedStageSnapshot(
            context: context,
            submissionID: submissionID
        )
        guard let stageSnapshot else {
            throw SubmissionSnapshotError.missingSubmittedStageSnapshot(submissionID)
        }

        return SubmissionSnapshotResult(
            snapshot: stageSnapshot,
            stageSnapshotURL: stageSnapshotURL,
            testCaseSnapshotURLs: testCaseSnapshotURLs
        )
    }

    private func validateNewSubmission(
        context: InspectionPersistenceContext,
        submissionID: String,
        drafts: [TestCaseDraft]
    ) async throws {
        guard !drafts.isEmpty else {
            throw SubmissionSnapshotError.emptyStageSubmission
        }

        var seenTestCaseIDs: Set<String> = []
        for draft in drafts where !seenTestCaseIDs.insert(draft.id).inserted {
            throw SubmissionSnapshotError.duplicateTestCaseID(draft.id)
        }

        if await persistence.submissionExists(context: context, submissionID: submissionID) {
            throw SubmissionSnapshotError.submissionAlreadyExists(submissionID)
        }
    }

    private func uniqueRecheckReferences(
        from snapshots: [SubmittedTestCaseSnapshotFile]
    ) -> [String] {
        var seenReferences: Set<String> = []
        return snapshots
            .flatMap(\.recheckReferences)
            .filter { seenReferences.insert($0).inserted }
    }
}
