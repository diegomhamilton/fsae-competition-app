# Approach Prompt

Given this task and entities:

Task: `5.4 Implement InspectionValidationService rules for missing outcome, failed note requirement, invalid measurement, and missing evidence.`

Entities: `<paste entity summary>`

Propose a high-level implementation approach.

Include:

- Files or areas likely affected
- Test-first strategy using Swift Testing
- Existing patterns to follow in `InspectionTestStepModels.swift`, draft models, existing validation code, and current tests
- How missing required outcome is detected
- How failed outcome requiring non-whitespace notes is detected
- How invalid or missing measurement input is validated through `MeasurementValue`
- How missing required evidence metadata is detected
- How deterministic validation issue codes and messages will be shaped
- How validation issue/rule definitions receive `InspectionTestStep` and `StepResult`, then invoke a rule-local validation handler so `InspectionValidationService` can iterate rules instead of replicating per-issue helper logic
- How to preserve compatibility if `ValidationService` currently exists
- Swift 6 and Sendable considerations
- Accessibility and localization considerations for future UI summaries without adding UI work
- Manual validation path

Do not write code yet. Explain the solution shape and collaboration points.

Constraints:

- Branch: `codex/task-5.4-validation-service`
- Expected PR title: `TASK#5.4: Implement validation service`
- Do not implement real stage submission, recheck creation, persistence, or broad UI refactors.
- Do not structure the service as one copied helper function per issue type when the duplicated decision logic can live in the issue/rule's validation handler.
- Do not build automatically. The user owns build and validation unless they explicitly ask Codex to run it.
