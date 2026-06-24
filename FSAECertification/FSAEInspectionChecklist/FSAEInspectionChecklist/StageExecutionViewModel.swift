import Foundation
import Observation

struct StageExecutionStepRowState: Identifiable, Equatable {
    let step: InspectionTestStep
    let result: StepResult
    let validationIssues: [ValidationIssue]

    var id: String {
        step.id
    }

    var measurementInput: String {
        result.measurementInput
    }

    var measurementValidationMessage: String? {
        validationIssues.first { issue in
            switch issue.code {
            case .missingMeasurement(stepID: _), .invalidMeasurement(stepID: _, error: _):
                true
            case .missingRequiredOutcome(stepID: _),
                    .missingInspectorNote(stepID: _),
                    .missingRequiredEvidence(stepID: _):
                false
            }
        }?.message
    }
}

@MainActor
@Observable
final class StageExecutionViewModel {
    let stage: InspectionStage
    private let steps: [InspectionTestStep]
    private let draftStore: InMemoryDraftStore
    private let validationService: ValidationService

    init(
        stage: InspectionStage,
        steps: [InspectionTestStep],
        draftStore: InMemoryDraftStore,
        validationService: ValidationService
    ) {
        self.stage = stage
        self.steps = steps
        self.draftStore = draftStore
        self.validationService = validationService
    }
    
    @MainActor
    convenience init(
        stage: InspectionStage,
        steps: [InspectionTestStep]
    ) {
        self.init(
            stage: stage,
            steps: steps,
            draftStore: InMemoryDraftStore(),
            validationService: ValidationService()
        )
    }
    
    @MainActor
    static func make(
        stage: InspectionStage,
        steps: [InspectionTestStep]
    ) -> StageExecutionViewModel {
        StageExecutionViewModel(
            stage: stage,
            steps: steps,
            draftStore: InMemoryDraftStore(),
            validationService: ValidationService()
        )
    }

    var rows: [StageExecutionStepRowState] {
        steps.map { step in
            let result = draftStore.result(stepID: step.id)
            return StageExecutionStepRowState(
                step: step,
                result: result,
                validationIssues: validationService.validateStep(step, result: result)
            )
        }
    }

    func row(stepID: String) -> StageExecutionStepRowState? {
        rows.first { $0.id == stepID }
    }

    func updateMeasurementInput(_ input: String, stepID: String) {
        guard let step = steps.first(where: { $0.id == stepID }), let range = step.measurementRange else {
            return
        }

        draftStore.update(stepID: stepID) { result in
            result.measurementInput = input
            result.measurementValue = try? MeasurementValue(rawValue: input, range: range)
        }
    }

    func draftResult(stepID: String) -> StepResult {
        draftStore.result(stepID: stepID)
    }
}
