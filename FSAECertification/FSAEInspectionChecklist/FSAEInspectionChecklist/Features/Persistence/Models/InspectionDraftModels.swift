//
//  InspectionDraftModels.swift
//  FSAEInspectionChecklist
//

import Foundation

nonisolated struct StepResult: Equatable, Sendable {
    var outcome: InspectionOutcome
    var notes: String
    var measurementInput: String
    var measurementValue: MeasurementValue?
    var evidenceAttachments: [EvidenceAttachmentMetadata]

    var evidenceAttachmentCount: Int {
        evidenceAttachments.count
    }

    init(
        outcome: InspectionOutcome = .pending,
        notes: String = "",
        measurementInput: String = "",
        measurementValue: MeasurementValue? = nil,
        evidenceAttachments: [EvidenceAttachmentMetadata] = []
    ) {
        self.outcome = outcome
        self.notes = notes
        self.measurementInput = measurementInput
        self.measurementValue = measurementValue
        self.evidenceAttachments = evidenceAttachments
    }
}

@MainActor
final class InMemoryDraftStore {
    private var resultsByStepID: [String: StepResult] = [:]

    func result(stepID: String) -> StepResult {
        resultsByStepID[stepID] ?? StepResult()
    }

    func update(stepID: String, mutation: (inout StepResult) -> Void) {
        var result = result(stepID: stepID)
        mutation(&result)
        resultsByStepID[stepID] = result
    }

    func reset() {
        resultsByStepID = [:]
    }
}
